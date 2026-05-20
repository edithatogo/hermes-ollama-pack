#!/bin/bash
# Merge MLX LoRA adapter with base model, convert to GGUF, push to Ollama.
# Usage: scripts/export_ollama.sh [adapter_dir] [model_name] [base_model]

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
HUB_DIR="$(cd "$REPO_DIR/.." && pwd)"
ADAPTER="${1:-$REPO_DIR/experiments/gemma4-e4b/lora_adapter}"
MODEL_NAME="${2:-gemma4-hermes}"
BASE_MODEL="${3:-}"
if [ -z "$BASE_MODEL" ] && [ -f "$ADAPTER/adapter_config.json" ]; then
    BASE_MODEL="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1])).get("model", ""))' "$ADAPTER/adapter_config.json")"
fi

if [ -z "$BASE_MODEL" ]; then
    echo "Base model is required when adapter_config.json does not contain a model field." >&2
    exit 1
fi

if [ -f "$HUB_DIR/scripts/env.sh" ]; then
    # Keep Hugging Face, temporary, and export caches on the external SSD.
    # shellcheck disable=SC1091
    source "$HUB_DIR/scripts/env.sh"
fi

PYTHON_BIN="${PYTHON_BIN:-python3}"
WORK_ROOT="${HERMES_EXPORT_ROOT:-${HERMES_STORAGE_ROOT:-$REPO_DIR}/hermes-exports}"
WORK_DIR="$WORK_ROOT/ollama/$MODEL_NAME"
MERGE_DIR="$WORK_DIR/merged"
OLLAMA_DIR="$WORK_DIR/ollama-pkg"

echo "=== Exporting to Ollama ==="
echo "Adapter:   $ADAPTER"
echo "Base:      $BASE_MODEL"
echo "Model:     $MODEL_NAME"
echo "Work dir:  $WORK_DIR"
echo ""

mkdir -p "$MERGE_DIR" "$OLLAMA_DIR"

# Step 1: Merge LoRA adapter and export GGUF using mlx_lm.fuse when available
echo "Step 1: Merging LoRA adapter..."
GGUF_FILE="$WORK_DIR/$MODEL_NAME-f16.gguf"
if command -v mlx_lm.fuse >/dev/null 2>&1; then
    if ! mlx_lm.fuse \
        --model "$BASE_MODEL" \
        --adapter-path "$ADAPTER" \
        --save-path "$MERGE_DIR" \
        --export-gguf \
        --gguf-path "$GGUF_FILE"; then
        echo "  GGUF export failed; retrying fused safetensors export only."
        mlx_lm.fuse \
            --model "$BASE_MODEL" \
            --adapter-path "$ADAPTER" \
            --save-path "$MERGE_DIR"
    fi
elif "$PYTHON_BIN" -c "import mlx_lm.fuse" 2>/dev/null; then
    if ! "$PYTHON_BIN" -m mlx_lm.fuse \
        --model "$BASE_MODEL" \
        --adapter-path "$ADAPTER" \
        --save-path "$MERGE_DIR" \
        --export-gguf \
        --gguf-path "$GGUF_FILE"; then
        echo "  GGUF export failed; retrying fused safetensors export only."
        "$PYTHON_BIN" -m mlx_lm.fuse \
            --model "$BASE_MODEL" \
            --adapter-path "$ADAPTER" \
            --save-path "$MERGE_DIR"
    fi
else
    echo "  mlx_lm.fuse not found. Attempting Python import..."
    "$PYTHON_BIN" -c "
import sys, json
from pathlib import Path
adapter = Path('$ADAPTER')
merge_dir = Path('$MERGE_DIR')
# Load adapter config to find base model
cfg_path = adapter / 'adapter_config.json'
if cfg_path.exists():
    cfg = json.loads(cfg_path.read_text())
    print(f'  Base model from config: {cfg.get(\"model\", \"unknown\")}')
if not list(merge_dir.glob('*')):
    print('  No merge tool available — adapter weights preserved separately.')
    print(f'  Manual merge command: mlx_lm.fuse --adapter-path {adapter} --save-path {merge_dir}')
    merge_dir.mkdir(parents=True, exist_ok=True)
    (merge_dir / 'USE_ADAPTER').write_text(str(adapter))
"
fi

# Step 2: Install llama.cpp if needed for conversion or quantization
LLAMA_CPP="${HERMES_LLAMA_CPP:-${HERMES_STORAGE_ROOT:-$REPO_DIR}/hermes-tools/llama.cpp}"
if [ ! -f "$LLAMA_CPP/convert_hf_to_gguf.py" ]; then
    echo "Step 2: Cloning llama.cpp..."
    git clone --depth 1 https://github.com/ggerganov/llama.cpp.git "$LLAMA_CPP"
fi

# Step 3: Convert merged model to GGUF
echo "Step 3: Converting to GGUF..."
if [ -f "$GGUF_FILE" ]; then
    echo "  GGUF already exported by mlx_lm.fuse: $GGUF_FILE"
elif [ -f "$MERGE_DIR/config.json" ]; then
    if ! "$PYTHON_BIN" "$LLAMA_CPP/convert_hf_to_gguf.py" "$MERGE_DIR" \
        --outfile "$GGUF_FILE" \
        --outtype f16; then
        echo "  GGUF conversion failed; keeping fused safetensors package."
    fi
else
    echo "  No merged model found at $MERGE_DIR. Creating placeholder model info."
    cat > "$OLLAMA_DIR/Modelfile" << MODFILE
# $MODEL_NAME — Hermes-style fine-tune
# Base model: google/gemma-4-E4B-it
FROM google/gemma-4-E4B-it

SYSTEM """You are Hermes, an AI assistant fine-tuned from Gemma 4 E4B.
You are helpful, harmless, and honest. You provide clear, accurate answers.
When using tools, follow the exact function schema provided."""

TEMPLATE """{{ if .System }}<|start_header_id|>system<|end_header_id|>

{{ .System }}<|eot_id|>{{ end }}{{ range .Messages }}{{ if eq .Role "user" }}<|start_header_id|>user<|end_header_id|>

{{ .Content }}<|eot_id|><|start_header_id|>assistant<|end_header_id|>

{{ else if eq .Role "assistant" }}{{ .Content }}<|eot_id|>{{ end }}{{ end }}"""

PARAMETER temperature 0.7
PARAMETER top_p 0.9
PARAMETER stop "<|eot_id|>"
PARAMETER stop "<|start_header_id|>"
PARAMETER num_ctx 8192
MODFILE
    echo "  Modelfile created. Build with: ollama create $MODEL_NAME -f $OLLAMA_DIR/Modelfile"
    exit 0
fi

# Step 4: Quantize
echo "Step 4: Quantizing..."
Q4_FILE="$WORK_DIR/$MODEL_NAME-q4_k_m.gguf"
QUANTIZE_BIN=""
for candidate in "$LLAMA_CPP/quantize" "$LLAMA_CPP/build/bin/llama-quantize" "$LLAMA_CPP/build/bin/quantize"; do
    if [ -x "$candidate" ]; then
        QUANTIZE_BIN="$candidate"
        break
    fi
done

if [ ! -f "$GGUF_FILE" ]; then
    echo "  No GGUF file to quantize."
    if [ -f "$MERGE_DIR/config.json" ]; then
        mkdir -p "$OLLAMA_DIR"
        cat > "$OLLAMA_DIR/Modelfile" << MODFILE
FROM $MERGE_DIR

PARAMETER temperature 0.7
PARAMETER top_p 0.9
PARAMETER num_ctx 8192
MODFILE
        echo "  Fused safetensors package created at $MERGE_DIR."
        echo "  Experimental Ollama create command:"
        echo "    ollama create $MODEL_NAME --experimental -f $OLLAMA_DIR/Modelfile"
    fi
    exit 0
elif [ -n "$QUANTIZE_BIN" ]; then
    "$QUANTIZE_BIN" "$GGUF_FILE" "$Q4_FILE" q4_k_m
    MODEL_FILE="$Q4_FILE"
else
    echo "  quantize binary not found, building llama.cpp..."
    cd "$LLAMA_CPP"
    make -j4 quantize 2>/dev/null || make -j4 2>/dev/null || true
    cd "$REPO_DIR"
    QUANTIZE_BIN=""
    for candidate in "$LLAMA_CPP/quantize" "$LLAMA_CPP/build/bin/llama-quantize" "$LLAMA_CPP/build/bin/quantize"; do
        if [ -x "$candidate" ]; then
            QUANTIZE_BIN="$candidate"
            break
        fi
    done
    if [ -n "$QUANTIZE_BIN" ]; then
        "$QUANTIZE_BIN" "$GGUF_FILE" "$Q4_FILE" q4_k_m
        MODEL_FILE="$Q4_FILE"
    else
        echo "  Using f16 (no quantization available)"
        MODEL_FILE="$GGUF_FILE"
    fi
fi

# Step 5: Package for Ollama
echo "Step 5: Creating Ollama package..."
cp "$MODEL_FILE" "$OLLAMA_DIR/model.gguf"
cp "$REPO_DIR/modelfiles/Gemma4-Hermes.Modelfile" "$OLLAMA_DIR/Modelfile"

if [ "${HERMES_SKIP_OLLAMA_CREATE:-0}" = "1" ]; then
    echo "Skipping 'ollama create' because HERMES_SKIP_OLLAMA_CREATE=1."
    echo "Package dir: $OLLAMA_DIR"
    echo "Create later with: ollama create $MODEL_NAME -f $OLLAMA_DIR/Modelfile"
    exit 0
fi

# Step 6: Create Ollama model
echo "Step 6: Creating Ollama model..."
cd "$OLLAMA_DIR"
ollama create "$MODEL_NAME" -f Modelfile
cd "$REPO_DIR"

echo ""
echo "=== Complete ==="
echo "Ollama model: $MODEL_NAME"
ollama list | grep "$MODEL_NAME"
echo ""
echo "Run: ollama run $MODEL_NAME"
echo "Or in Hermes: switch to model $MODEL_NAME"

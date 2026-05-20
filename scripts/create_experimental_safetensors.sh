#!/bin/bash
# Create an Ollama model from a local HF safetensors model directory.
# Usage: scripts/create_experimental_safetensors.sh <model_dir> <model_name> [modelfile]

set -euo pipefail

MODEL_DIR="${1:?model_dir is required}"
MODEL_NAME="${2:?model_name is required}"
MODEFILE_TEMPLATE="${3:-}"

if [ ! -d "$MODEL_DIR" ]; then
    echo "Model directory not found: $MODEL_DIR" >&2
    exit 1
fi

TMP_DIR="$(mktemp -d)"
MODEFILE="$TMP_DIR/Modelfile"

if [ -n "$MODEFILE_TEMPLATE" ]; then
    cp "$MODEFILE_TEMPLATE" "$MODEFILE"
    # Allow template files to use a placeholder instead of hardcoding paths.
    sed -i.bak "s|__MODEL_DIR__|$MODEL_DIR|g" "$MODEFILE"
else
    cat > "$MODEFILE" <<MODFILE
FROM $MODEL_DIR

PARAMETER temperature 0.7
PARAMETER top_p 0.9
PARAMETER num_ctx 8192
MODFILE
fi

ollama create "$MODEL_NAME" --experimental -f "$MODEFILE"
rm -rf "$TMP_DIR"

echo "Created $MODEL_NAME"
ollama show "$MODEL_NAME" >/dev/null

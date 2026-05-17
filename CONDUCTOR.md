# Ollama Pack — Conductor Setup

This repo is Track 3 of the Hermes Training Hub.

## Hub References

| Document | Location |
|----------|----------|
| Hub conductor | `/Users/doughnut/GitHub/hermes-training/CONDUCTOR.md` |
| MoSCoW requirements | `/Users/doughnut/GitHub/hermes-training/REQUIREMENTS.md` |
| Architecture design | `/Users/doughnut/GitHub/hermes-training/DESIGN.md` |
| Interface contracts | `/Users/doughnut/GitHub/hermes-training/CONTRACTS.md` |

## Track Status

| Requirement | Status |
|-------------|--------|
| M5 Export to Ollama | ✅ scripts/export_ollama.sh written |
| M8 llama.cpp ready | ✅ Built at `/Users/doughnut/GitHub/llama.cpp` |
| S7 GGUF conversion | ✅ llama-quantize compiled with Metal |

## Available Modelfiles

| Modelfile | Target Model | Status |
|-----------|-------------|--------|
| `modelfiles/Gemma4-Hermes.Modelfile` | Gemma 4 E4B-it Hermes | Ready (awaiting adapter) |
| `modelfiles/LFM2-Hermes.Modelfile` | LFM2-8B-A1B Hermes | Ready (awaiting adapter) |

## Contracts in Effect

- CONTRACT-006: `modelfiles/*.Modelfile` (Ollama Modelfile format)
- CONTRACT-010: `scripts/export_ollama.sh` (exit codes)

## Dependencies

This track is BLOCKED on Track 1 (gemma4) and Track 2 (lfm2) producing trained adapters.
Once an adapter exists at `experiments/*/lora_adapter/`, run:

```bash
bash scripts/export_ollama.sh /path/to/adapter model-name
```

## Context Preservation Notes

- No training happens in this repo. It only contains packaging/deployment scripts.
- llama.cpp is built at `/Users/doughnut/GitHub/llama.cpp/`
  - `convert_hf_to_gguf.py` for HF → GGUF conversion
  - `build/bin/llama-quantize` for Q4_K_M quantization
- Ollama runs as a service and is available at `http://127.0.0.1:11434`
- The export script handles: merge → convert → quantize → ollama create

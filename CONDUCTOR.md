# Ollama Pack — Conductor Context

This repo is the runtime packaging and Hermes integration track for the Hermes Training Hub.

## Hub References

| Document | Location |
|---|---|
| Hub conductor | `/Volumes/PortableSSD/GitHub/hermes-training/CONDUCTOR.md` |
| Runtime targets | `/Volumes/PortableSSD/GitHub/hermes-training/RUNTIME_TARGETS.md` |
| Benchmark plan | `/Volumes/PortableSSD/GitHub/hermes-training/BENCHMARKING_PLAN.md` |
| Documentation plan | `/Volumes/PortableSSD/GitHub/hermes-training/DOCUMENTATION_PLAN.md` |
| Applications | `/Volumes/PortableSSD/GitHub/hermes-training/APPLICATIONS.md` |

## Track Status

| Requirement | Status |
|---|---|
| Ollama Modelfiles | Present for Gemma, LFM, Qwen |
| Runtime smoke script | Present; validates parseable JSON from `/v1/models` and `/v1/chat/completions` |
| Experimental safetensors path | Present |
| GGUF path | Documented; validate per model/license |
| Hermes launch target | Ollama OpenAI-compatible endpoint |
| SSD artifact policy | Keep GGUFs, merged models, and exports off Git |
| Specialist runtime lane | Documented in runtime targets; needs a lane-specific launcher and run card before promotion |

## Available Modelfiles

| Modelfile | Target Model | Status |
|---|---|---|
| `modelfiles/Gemma4-Hermes.Modelfile` | Gemma-family Hermes runtime | Ready for runtime proof |
| `modelfiles/LFM-Hermes.Modelfile` | LFM/LFM2.5 runtime | Ready for runtime proof |
| `modelfiles/Qwen3-Hermes.Modelfile` | Qwen3 runtime | Ready for runtime proof |

## Next Actions

1. Validate the LFM2.5 smoke adapter through MLX generation first.
2. Package only benchmark-promoted adapters for Ollama or LM Studio.
3. Keep model artifacts in SSD-backed export paths, not Git.
4. Run `scripts/runtime_smoke.sh` before marking a runtime path usable by Hermes.
5. Document the exact runtime endpoint and command in the model/run card.
6. For specialist runtimes, capture the launcher, endpoint, and lane explicitly instead of assuming Ollama defaults.

## Contracts in Effect

- `modelfiles/*.Modelfile`: Ollama model definitions.
- `scripts/export_ollama.sh`: merge/convert/package flow.
- `scripts/create_experimental_safetensors.sh`: experimental path where supported.
- `scripts/runtime_smoke.sh`: runtime validation.

## Application Notes

This track enables:

- `ollama launch hermes` with local adapters/models
- LM Studio fallback for GGUF-compatible releases
- MLX server fallback for Apple Silicon-native serving
- local OpenAI-compatible endpoints for coding agents and desktop assistants
- side-by-side runtime benchmarks across Ollama, LM Studio, and MLX

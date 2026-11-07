# Local model and coding-agent runtime qualification — 8 November 2026

**Status: planned; no newly validated runtime/model combination.** Extends, does not replace, [existing runtime packaging](../runtime-packaging_20260520/). Canonical model discovery and result schema: [models_lang](https://github.com/edithatogo/models_lang/blob/main/conductor/tracks/local-model-qualification_20261108/index.md) (link targets main after upstream merge). Keep current Ollama, LM Studio, GGUF, experimental safetensors and MLX paths working.

## Implementation work for coding agent

1. Inventory real hosts/accelerators: Windows x64 and ARM64; Linux x64 and ARM64; macOS ARM64; NVIDIA exact GPU/VRAM, CUDA driver/toolkit; Apple Metal and MLX; CPU and Intel OpenVINO if available. Distinguish RTX 4060 8 GB from 4060 Ti 16 GB; do not assume an NVIDIA '4600' SKU. Never describe MLX as hardware.
2. Add versioned, opt-in benchmark profiles for `Qwen/Qwen3.5-4B`, `XiaomiMiMo/MiMo-V2.6-Distill-Qwen-9B`, `Qwen/Qwen3.8-27B`, `Qwen/Qwen3-Coder-Next`, `LiquidAI/LFM3-1.7B`, `LiquidAI/LFM2.5-8B-A1B` and `LiquidAI/LFM2.5-24B-A2B`. Probe whether each exact checkpoint is actually supported by each installed runtime and quantisation; unsupported is a valid result. Never auto-download models or assume Q4 fits at full context.
3. Execute a fixed Hermes tool-call suite: strict JSON/schema validity, refusal and no-op behaviour, permission prompts, rollback, file edits, tests, shell/tool injection and multi-step recovery. Include existing `edithatogo/qwen3-4b-hermes-lora` MLX and PEFT/GGUF comparative baselines.
4. Measure weights + KV cache + peak memory, prefill and output tokens/sec, time to first token, tool-call accuracy, end-to-end coding outcomes, cold start, errors, quantisation regression and stability. Record source revision, prompt template and engine exact version. Use maintained upstream llama.cpp/Ollama/MLX/vLLM support, not bespoke kernels.
5. Emit `models_lang` qualification result schema records, with redacted or synthetic prompts and a manifest of permitted licences. Include per-platform scripts with explicit skip reasons, replay commands and rollback. Do not route confidential work to cloud endpoints. Separate local-only mode from opt-in external controls.

## Acceptance

- At least one actually executed and repeatable scenario on available hardware for each *claimed* supported runtime; otherwise report `unverified`.
- Tests fail closed for unexpected remote endpoint, unsupported architecture, unexpected network egress, missing quantisation metadata or unpinned model identity.
- Baseline Hermes launcher remains compatible; existing packaging is not regressed.
- Ranking is Pareto-based per device/task, not a global 'best model'. No promotion of fine-tuning without comparative holdout gain.

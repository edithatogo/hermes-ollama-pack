# Runtime Card: Qwen3 4B MLX Smoke

## Identity

- Run name: `qwen3-4b-mlx-smoke`
- Date: 2026-05-21
- Operator: Codex
- Platform lane: Mac/MLX local Hermes agent lane
- Runtime: MLX server; GGUF validated through llama.cpp; Ollama import remains blocked
- Model name: `Qwen/Qwen3-4B-MLX-4bit`
- Endpoint model ID: `Qwen/Qwen3-4B-MLX-4bit`
- Model revision: HF `main` as cached in `/Volumes/PortableSSD/huggingface/hub`
- Artifact location: `gemma4/experiments/qwen3-4b-smoke/lora_adapter`

## Command

- Start command: `python -m mlx_lm.server --model Qwen/Qwen3-4B-MLX-4bit --adapter-path gemma4/experiments/qwen3-4b-smoke/lora_adapter --host 127.0.0.1 --port 8088`
- Environment: `source scripts/env.sh`; SSD-backed `HF_HOME`, `HF_HUB_CACHE`, and `TMPDIR`
- Base endpoint: `http://127.0.0.1:8088/v1`
- Hermes endpoint: OpenAI-compatible `/v1/models` and `/v1/chat/completions`

## Endpoint Smoke Matrix

| Runtime | Start Command | Base Endpoint | Smoke Prompt | Expected Result | Result |
|---|---|---|---|---|---|
| MLX server | `python -m mlx_lm.server --model Qwen/Qwen3-4B-MLX-4bit --adapter-path gemma4/experiments/qwen3-4b-smoke/lora_adapter --host 127.0.0.1 --port 8088` | `http://127.0.0.1:8088/v1` | `/no_think Return exactly this JSON object and nothing else: {"ok": true}` | `/v1/models` and `/v1/chat/completions` respond and the JSON reply is parseable. | Passed |
| Ollama experimental safetensors | `OLLAMA_MODELS=/Volumes/PortableSSD/ollama-models ollama create qwen3-4b-hermes-smoke --experimental -f /Volumes/PortableSSD/hermes-exports/ollama/qwen3-4b-hermes-smoke/ollama-pkg/Modelfile` | `http://127.0.0.1:11434/v1` | `/no_think Return exactly this JSON object and nothing else: {"ok": true}` | Hermes sees the model and endpoint responds. | Failed: model imported, but `/v1/chat/completions` returned HTTP 500 from the Ollama MLX runner |
| llama.cpp GGUF | `/opt/homebrew/bin/llama-completion -m /Volumes/PortableSSD/hermes-exports/ollama/qwen3-4b-hermes-smoke/qwen3-4b-hermes-smoke-q4_K_M.gguf -p '/no_think Return exactly this JSON object and nothing else: {"ok": true}' -n 32 --temp 0 --ctx-size 4096` | local CLI | `/no_think Return exactly this JSON object and nothing else: {"ok": true}` | GGUF loads and returns parseable JSON. | Passed |
| Ollama GGUF | `OLLAMA_MODELS=/Volumes/PortableSSD/ollama-models ollama create qwen3-4b-hermes-smoke-gguf -f /Volumes/PortableSSD/hermes-exports/ollama/qwen3-4b-hermes-smoke/ollama-gguf-pkg/Modelfile` | `http://127.0.0.1:11434/v1` | `/no_think Return exactly this JSON object and nothing else: {"ok": true}` | Ollama imports model and OpenAI-compatible chat endpoint responds. | Failed: daemon died during or immediately after blob upload with broken-pipe/connection loss |
| LM Studio | `lms load /Volumes/PortableSSD/hermes-exports/ollama/qwen3-4b-hermes-smoke/qwen3-4b-hermes-smoke-q4_K_M.gguf --identifier qwen3-4b-hermes-smoke-q4_K_M && lms server start --port 1234` | `http://localhost:1234/v1` | `/no_think Return exactly this JSON object and nothing else: {"ok": true}` | OpenAI-compatible chat completions respond from the LM Studio server. | Ready to validate with the SSD-backed GGUF artifact |
| Specialist runtime | pending lane-specific launcher | pending | Return JSON with key `ok` set to true. | Runtime exposes parseable `/v1/models` and chat completion. | Not run |

## Result

- Status: passed for MLX OpenAI-compatible endpoint
- Smoke command: `BASE_URL=http://127.0.0.1:8088/v1 SMOKE_PROMPT='/no_think Return exactly this JSON object and nothing else: {"ok": true}' ollama-pack/scripts/runtime_smoke.sh Qwen/Qwen3-4B-MLX-4bit`
- Latency: endpoint smoke completed successfully; detailed latency is not yet captured by `runtime_smoke.sh`
- Peak memory: Qwen3 smoke training peaked at 3.944 GB; runtime peak was not separately sampled
- GGUF artifacts:
  - F16: `/Volumes/PortableSSD/hermes-exports/ollama/qwen3-4b-hermes-smoke/qwen3-4b-hermes-smoke-f16.gguf` (`7.5G`)
  - Q4_K_M: `/Volumes/PortableSSD/hermes-exports/ollama/qwen3-4b-hermes-smoke/qwen3-4b-hermes-smoke-q4_K_M.gguf` (`2.3G`)
- GGUF conversion notes: MLX direct `--export-gguf` does not support `qwen3`; llama.cpp conversion required a dequantized fused export at `/Volumes/PortableSSD/hermes-exports/ollama/qwen3-4b-hermes-smoke/merged-dequantized`.
- llama.cpp result: Q4_K_M GGUF loaded and returned `{"ok": true}`; prompt throughput was about `332 tok/s`, generation throughput about `69 tok/s`.
- Limitation(s): Qwen3 thinking mode can return reasoning without `content` unless prompted with `/no_think`. Ollama experimental safetensors import succeeded, but chat completion failed with an MLX runner panic. Ollama GGUF import also failed because the daemon dropped during model creation. Ollama is therefore not a validated Qwen3 runtime for this package yet.
- Notes: The MLX server warns it is not recommended for production. Use it as a local Hermes-compatible development endpoint, not a hardened serving layer. The Qwen3 GGUF is valid for llama.cpp/LM Studio-style testing, but Ollama remains blocked by import/runtime instability on this machine. Validate LM Studio with `bash scripts/runtime_smoke_lmstudio.sh /Volumes/PortableSSD/hermes-exports/ollama/qwen3-4b-hermes-smoke/qwen3-4b-hermes-smoke-q4_K_M.gguf http://localhost:1234/v1 qwen3-4b-hermes-smoke-q4_K_M`.
- Specialist runtime notes: KTransformers/other specialist lanes remain separate because this proof uses an MLX adapter.

## SSD Artifact Policy

- Model cache is under `/Volumes/PortableSSD/huggingface`.
- Adapter artifact is under ignored `gemma4/experiments/`.
- No generated weights or runtime binaries should be committed.

## Follow-Up

- [x] Record the exact model ID and revision
- [x] Record the command and endpoint actually used
- [x] Record the smoke prompt and response shape
- [x] Record runtime limitations or compatibility notes
- [x] Record the platform lane and specialist-runtime distinction
- [ ] Add timing capture to `runtime_smoke.sh`
- [x] Attempt Ollama experimental safetensors import
- [x] Export GGUF from dequantized fused model
- [x] Validate GGUF with llama.cpp
- [ ] Validate GGUF in LM Studio OpenAI-compatible server
- [ ] Re-test Ollama after the Qwen3 GGUF import crash is resolved upstream or with a newer Ollama build

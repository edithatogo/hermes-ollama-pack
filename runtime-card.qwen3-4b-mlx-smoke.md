# Runtime Card: Qwen3 4B MLX Smoke

## Identity

- Run name: `qwen3-4b-mlx-smoke`
- Date: 2026-05-21
- Operator: Codex
- Platform lane: Mac/MLX local Hermes agent lane
- Runtime: MLX server
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
| Ollama | pending GGUF export | `http://127.0.0.1:11434/v1` | Return JSON with key `ok` set to true. | Hermes sees the model and endpoint responds. | Not run: MLX adapter is not a GGUF artifact |
| LM Studio | pending GGUF export | `http://localhost:1234/v1` | Return JSON with key `ok` set to true. | OpenAI-compatible chat completions respond. | Not run: MLX adapter is not a GGUF artifact |
| Specialist runtime | pending lane-specific launcher | pending | Return JSON with key `ok` set to true. | Runtime exposes parseable `/v1/models` and chat completion. | Not run |

## Result

- Status: passed for MLX OpenAI-compatible endpoint
- Smoke command: `BASE_URL=http://127.0.0.1:8088/v1 SMOKE_PROMPT='/no_think Return exactly this JSON object and nothing else: {"ok": true}' ollama-pack/scripts/runtime_smoke.sh Qwen/Qwen3-4B-MLX-4bit`
- Latency: endpoint smoke completed successfully; detailed latency is not yet captured by `runtime_smoke.sh`
- Peak memory: Qwen3 smoke training peaked at 3.944 GB; runtime peak was not separately sampled
- Limitation(s): Qwen3 thinking mode can return reasoning without `content` unless prompted with `/no_think`
- Notes: The MLX server warns it is not recommended for production. Use it as a local Hermes-compatible development endpoint, not a hardened serving layer.
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
- [ ] Export/promote GGUF only after a publishable adapter exists

# Hermes Ollama Pack

Packaging and runtime validation for Hermes-ready local models.

This track supports multiple runtime paths:

- **Ollama launcher:** `ollama launch hermes`
- **Ollama GGUF:** stable cross-tool path for Ollama and LM Studio.
- **Ollama experimental safetensors:** uses newer local Ollama builds that can create models from HF-style safetensors directories with `ollama create --experimental`.
- **MLX server:** fallback for MLX-native checkpoints/adapters.
- **LM Studio fallback:** GGUF desktop runtime for local OpenAI-compatible serving.

## Preferred Hermes Path

```bash
ollama launch hermes
```

The local Ollama repo has a Hermes launcher that configures Hermes against `http://127.0.0.1:11434/v1` and sets the selected Ollama model as the default.

## MLX Server Path

Use MLX when the adapter or checkpoint is MLX-compatible and you want the Mac-first fallback:

```bash
mlx_lm.server --model <path_to_model_or_hf_repo>
```

The default server binds on `http://127.0.0.1:8080/v1`.

## GGUF Path

```bash
bash scripts/export_ollama.sh ../gemma4/experiments/gemma4-e4b/lora_adapter gemma4-hermes
ollama launch hermes
```

Use GGUF when:

- LM Studio compatibility is required.
- The model architecture has stable llama.cpp/Ollama conversion.
- You want a portable artifact.

The packaging command builds the Ollama artifact; `ollama launch hermes` is the validation target for Hermes itself.

Hermes can be pointed at either Ollama's OpenAI-compatible endpoint or LM Studio's local server when the GGUF is the active runtime.

## Experimental Safetensors Path

For local Ollama builds with experimental safetensors/MLX support:

```bash
bash scripts/create_experimental_safetensors.sh /path/to/hf-model-dir qwen3-hermes modelfiles/Qwen3-Hermes.Modelfile
```

Use this when:

- The model is already in HF safetensors format.
- The local Ollama build supports the architecture.
- Avoiding a GGUF conversion is useful.

## LM Studio Fallback

When GGUF is the practical desktop fallback, start the LM Studio server with the SSD-backed artifact and use its OpenAI-compatible endpoint:

```bash
lms server start --port 1234
```

For the Qwen3 smoke artifact recorded in this track, use:

```bash
GGUF_PATH=/Volumes/PortableSSD/hermes-exports/ollama/qwen3-4b-hermes-smoke/qwen3-4b-hermes-smoke-q4_K_M.gguf
lms load "$GGUF_PATH" --identifier qwen3-4b-hermes-smoke-q4_K_M
lms server start --port 1234
```

Hermes can target `http://localhost:1234/v1` when LM Studio is the active runtime, and `scripts/runtime_smoke_lmstudio.sh` can validate the endpoint against the same SSD-backed GGUF file.

## Runtime Smoke Test

```bash
bash scripts/runtime_smoke.sh gemma4-hermes
```

The test checks `/v1/models` and `/v1/chat/completions` with JSON parsing, which is the surface Hermes needs.
Override `BASE_URL` for MLX (`http://127.0.0.1:8080/v1`) or LM Studio (`http://localhost:1234/v1`) when the runtime is not Ollama.

For LM Studio smoke validation with the Qwen3 GGUF artifact:

```bash
bash scripts/runtime_smoke_lmstudio.sh \
  /Volumes/PortableSSD/hermes-exports/ollama/qwen3-4b-hermes-smoke/qwen3-4b-hermes-smoke-q4_K_M.gguf \
  http://localhost:1234/v1 \
  qwen3-4b-hermes-smoke-q4_K_M
```

## Endpoint Smoke Matrix

| Runtime | Start Command | Endpoint | Smoke Check |
|---|---|---|---|
| Ollama | `ollama launch hermes` | `http://127.0.0.1:11434/v1` | Hermes picker sees the model and `/v1/models` responds |
| MLX server | `mlx_lm.server --model <path_to_model_or_hf_repo>` | `http://127.0.0.1:8080/v1` | `/v1/models` and `/v1/chat/completions` respond |
| LM Studio | `lms load /Volumes/PortableSSD/hermes-exports/ollama/qwen3-4b-hermes-smoke/qwen3-4b-hermes-smoke-q4_K_M.gguf --identifier qwen3-4b-hermes-smoke-q4_K_M && lms server start --port 1234` | `http://localhost:1234/v1` | OpenAI-compatible chat completion responds against the SSD-backed GGUF artifact |
| Specialist runtime | `<runtime-specific launcher>` | `<OpenAI-compatible endpoint>` | Use the same JSON parsing checks, then record the launcher and lane in the run card |

## SSD Artifact Policy

- Keep merged models, GGUF exports, and packaged runtime artifacts on SSD-backed paths.
- Do not commit generated weights, exports, or cache directories to Git.
- If you need a local handoff path, stage it under `/Volumes/PortableSSD` and document the exact folder in the run card.

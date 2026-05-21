# Runtime Card: Local Ollama Installed Models Smoke

## Identity

- Run name: `ollama-installed-models-smoke`
- Date: 2026-05-22
- Operator: Codex
- Platform lane: Mac local Ollama runtime
- Runtime: Ollama `0.24.0`
- Base endpoint: `http://127.0.0.1:11434/v1`
- Report: `reports/runtime/ollama-installed-models-smoke/run-card.md`
- Scope: already-installed Ollama models only; no pulls

## Endpoint Smoke Matrix

| Runtime | Model | Base Endpoint | Smoke Prompt | Expected Result | Result |
|---|---|---|---|---|---|
| Ollama | `hermes3:8b` | `http://127.0.0.1:11434/v1` | `Return exactly this JSON object and nothing else: {"ok": true}` | `/v1/models` sees the model and `/v1/chat/completions` returns strict JSON with `ok=true`. | Passed, 33083 ms |
| Ollama | `sam860/LFM2:2.6b` | `http://127.0.0.1:11434/v1` | `Return exactly this JSON object and nothing else: {"ok": true}` | `/v1/models` sees the model and `/v1/chat/completions` returns strict JSON with `ok=true`. | Passed, 6008 ms |

## Commands

```bash
ollama list
curl -sS --max-time 3 http://127.0.0.1:11434/v1/models
SMOKE_PROMPT='Return exactly this JSON object and nothing else: {"ok": true}' ollama-pack/scripts/runtime_smoke.sh 'hermes3:8b' http://127.0.0.1:11434/v1
SMOKE_PROMPT='Return exactly this JSON object and nothing else: {"ok": true}' ollama-pack/scripts/runtime_smoke.sh 'sam860/LFM2:2.6b' http://127.0.0.1:11434/v1
```

## Result

- Status: passed for the two requested already-installed chat models.
- Installed target models: `hermes3:8b` and `sam860/LFM2:2.6b`.
- Ignored installed model: `nomic-embed-text:latest`, because it is an embedding model rather than a chat smoke target.
- No model pulls, creates, imports, conversions, or weight changes were performed.

## Limitations

- The timings are single smoke measurements, not throughput or quality benchmarks.
- The run validates the local Ollama OpenAI-compatible endpoint surface only.
- The smoke prompt exercises strict JSON compliance for a minimal response; it does not validate larger Hermes workflows.

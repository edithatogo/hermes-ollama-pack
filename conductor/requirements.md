# Requirements — Ollama Pack

## Must Have

| ID | Requirement | Verification |
|---|---|---|
| M1 | Runtime smoke script exists | `scripts/runtime_smoke.sh` |
| M2 | Modelfiles exist for active model families | `modelfiles/*.Modelfile` |
| M3 | Runtime artifacts stay off Git and on SSD | export paths documented |
| M4 | Hermes endpoint documented | runtime card includes endpoint |
| M5 | Health >= 9.5 before completion | health checkpoint in plan |

## Should Have

| ID | Requirement | Priority |
|---|---|---|
| S1 | MLX server runtime card | High |
| S2 | Ollama runtime card | High |
| S3 | LM Studio/GGUF fallback card | Medium |

## Won't Have

| ID | Requirement | Reason |
|---|---|
| W1 | Package unbenchmarked adapters as releases | benchmark gate required |

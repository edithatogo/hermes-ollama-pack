# Plan: Runtime Packaging and Hermes Validation

## Phase 1: MLX

- [x] Task: Validate MLX adapter generation.
- [x] Task: Document MLX server command and endpoint.

## Phase 2: Ollama/LM Studio

- [ ] Task: Validate Modelfile/runtime path.
- [x] Task: Document GGUF/LM Studio fallback.
- [x] Task: Document SSD artifact policy.

## Phase 3: Hermes

- [x] Task: Validate Hermes endpoint.
- [x] Task: Document runtime card template.
- [x] Task: Document endpoint smoke matrix.

## Health Check

- [x] Task: Estimate track health using hub `conductor/health-score.md`.
- [ ] Task: Close or document all gaps below health 9.5.
- [x] Task: Run hub readiness validation and attach result to the track notes.
- [ ] Task: Confirm health >= 9.5 before marking this track complete.

- Current readiness result: hub readiness validation passes in the shared repo venv; `mlx_lm` and `datasets` import successfully there.
- Current health estimate: 9.6 / 10.
- Evidence: Qwen3 4B MLX adapter loaded through `mlx_lm.server`; `/v1/models` and `/v1/chat/completions` passed through `scripts/runtime_smoke.sh`; runtime card recorded at `runtime-card.qwen3-4b-mlx-smoke.md`.
- Gaps: Ollama/LM Studio remain pending until a GGUF export exists; specialist runtimes remain lane-specific follow-up work.

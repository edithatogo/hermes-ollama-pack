# Plan: Runtime Packaging and Hermes Validation

## Phase 1: Runtime Scripts

- [x] Task: provide an Ollama/OpenAI-compatible runtime smoke script.
- [x] Task: provide an LM Studio GGUF runtime smoke script.
- [x] Task: validate the Qwen empty-thinking normalization helper with a
  self-test.

## Phase 2: Packaging Paths

- [x] Task: document the Ollama launcher path for Hermes.
- [x] Task: document MLX server as the Mac-first adapter runtime path.
- [x] Task: document GGUF and LM Studio fallback paths.
- [x] Task: provide experimental safetensors packaging for newer Ollama builds.
- [x] Task: keep generated runtime artifacts on `/Volumes/PortableSSD`.

## Phase 3: Runtime Cards

- [x] Task: record local installed-Ollama model smoke evidence.
- [x] Task: record Qwen3 MLX server, llama.cpp GGUF, Ollama, and LM Studio
  runtime status.
- [x] Task: record current blocked runtime surfaces as blocked rather than
  ready.

## Phase 4: Track Closure

- [x] Task: restore missing Conductor track spec and plan files.
- [x] Task: update hub references to the SSD-backed project path.
- [x] Task: run syntax, normalization, and hub readiness validation.

## Health Check

- Target: >= 9.5 / 10
- Current estimate: 9.7 / 10
- Evidence: runtime scripts exist and syntax-check; normalization self-test
  passes; modelfiles exist for Gemma, LFM, and Qwen; runtime cards record
  Ollama installed-model proof and Qwen3 MLX/GGUF/Ollama/LM Studio status;
  artifact policy keeps generated weights and exports on `/Volumes/PortableSSD`;
  hub `scripts/validate_readiness.py` passes.
- Gaps: LM Studio live smoke and Ollama Qwen3 retest remain blocked until the
  relevant endpoint or runtime upgrade is available. They are documented as
  runtime follow-ups, not blockers to the packaging track.
- Decision: complete the track as a packaging and runtime-validation lane, with
  blocked runtime surfaces explicitly recorded rather than promoted.

# Specification: Runtime Packaging and Hermes Validation

Package and validate local Hermes runtime paths without committing generated
weights or exports. The track covers Ollama, GGUF/LM Studio, MLX server, and
specialist-runtime handoff rules.

Acceptance criteria:

- Runtime smoke scripts validate OpenAI-compatible `/v1/models` and
  `/v1/chat/completions` surfaces.
- Qwen-style empty leading thinking wrappers are normalized only when empty,
  while non-empty reasoning and malformed JSON still fail strict parsing.
- Modelfiles exist for active Gemma, LFM, and Qwen model-family lanes.
- Runtime cards record commands, endpoints, model names, artifacts, outcomes,
  limitations, and SSD-backed artifact locations.
- Generated models, GGUF files, merged exports, and caches remain outside Git.
- The runtime track reaches health `>= 9.5 / 10`.

Out of scope:

- Publishing unbenchmarked adapters as runtime releases.
- Treating runtime-normalized output as a strict benchmark pass.
- Downloading large new model artifacts during track closure.

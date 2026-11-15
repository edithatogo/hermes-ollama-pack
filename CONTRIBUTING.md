# Contributing to hermes-ollama-pack

Contributions improve local-model packaging and Hermes runtime integration across the documented Ollama, MLX, GGUF, and LM Studio paths.

## Before you start

Read the [README](README.md) and [Conductor context](CONDUCTOR.md). Identify the runtime lane, model format, and endpoint affected by a change. Preserve the distinction between packaging an artifact and proving that a runtime can serve it.

Search existing issues and pull requests to avoid duplicating work. Describe substantial proposals before implementation, and use repository issue or pull request templates when available. Small corrections can go directly into a focused pull request.

For bug reports, include the affected version or commit, environment, minimal reproduction, expected and actual behavior, and sanitized diagnostics. For feature requests, explain the use case and intended outcome.

## Development and validation

The README provides an offline check for the JSON normalization helper:

```sh
python3 scripts/normalize_runtime_json.py --self-test
```

For an already configured local model, it also documents:

```sh
bash scripts/runtime_smoke.sh gemma4-hermes
```

The second command requires the matching model and runtime endpoint. Record actual model identity, artifact revision, runtime version, endpoint, command, and result; do not report it as passing when the runtime is unavailable. Preserve strict JSON parsing: only the documented empty leading thinking wrapper may be normalized.

Keep weights and generated packages out of Git. Package only adapters permitted by the existing benchmark and redistribution gates. Separate runtime-specific fixes from changes to model quality or promotion status.

Update affected documentation and examples alongside behavior changes. Add a focused regression case for a bug fix where executable tests are appropriate. Record checks that were not run and the reason.

## Submitting a pull request

Create a focused branch from the current `main` branch and open a pull request back to it. Keep unrelated formatting, refactoring, and dependency changes separate.

Include:

- The problem, proposed change, and resulting behavior.
- Related issues or existing track references.
- Exact validation commands or inspection steps, results, and limitations.
- Compatibility implications and any data or dependency provenance.

Inspect the complete diff before submission. Required automated checks must pass before merge. Follow the existing repository and account policies; this guide does not introduce a second-person approval requirement or relax existing checks.

## Security and sensitive information

Follow the [account security policy](https://github.com/edithatogo/.github/blob/main/SECURITY.md). Report vulnerabilities privately through GitHub's **Report a vulnerability** option if available. Otherwise request a private reporting contact without disclosing the vulnerability publicly. Keep credentials, personal data, and unredacted logs out of commits, issues, and examples.

## Licensing and conduct

Preserve existing attribution and applicable source or package terms. This guide does not grant a new license. Submit only material you are entitled to contribute, and document unclear permissions before adding third-party content. Follow the [account code of conduct](https://github.com/edithatogo/.github/blob/main/CODE_OF_CONDUCT.md). This guide adds no CLA, mandatory sign-off, or relicensing condition.

## Reference guidance

- [GitHub contributor guidelines](https://docs.github.com/en/communities/setting-up-your-project-for-healthy-contributions/setting-guidelines-for-repository-contributors)
- [OpenSSF Best Practices criteria](https://www.bestpractices.dev/en/criteria)

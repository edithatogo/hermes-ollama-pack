#!/usr/bin/env python3
"""Normalize runtime assistant content before strict JSON validation."""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any


EMPTY_LEADING_THINK_RE = re.compile(r"\A(\s*)<think>\s*</think>", re.IGNORECASE)


def normalize_assistant_content(content: str) -> str:
    """Remove only empty leading Qwen-style think wrappers.

    This deliberately does not extract JSON from arbitrary text. Non-empty
    reasoning wrappers remain in place and will fail the later strict JSON parse.
    """

    normalized = content
    while True:
        next_value = EMPTY_LEADING_THINK_RE.sub(r"\1", normalized, count=1)
        if next_value == normalized:
            return normalized
        normalized = next_value


def load_json_file(path: Path, label: str) -> Any:
    try:
        with path.open("r", encoding="utf-8") as fh:
            return json.load(fh)
    except json.JSONDecodeError as exc:
        raise ValueError(f"{label} was not valid JSON: {exc}") from exc


def assistant_content_from_chat_response(payload: Any) -> str:
    if not isinstance(payload, dict):
        raise ValueError("Chat completion response was not a JSON object.")

    choices = payload.get("choices")
    if not isinstance(choices, list) or not choices:
        raise ValueError("Chat completion did not include choices[].")

    first_choice = choices[0]
    if not isinstance(first_choice, dict):
        raise ValueError("Chat completion choices[0] was not an object.")

    message = first_choice.get("message", {})
    if not isinstance(message, dict):
        raise ValueError("Chat completion choices[0].message was not an object.")

    content = message.get("content")
    if not isinstance(content, str) or not content.strip():
        raise ValueError("Chat completion did not include assistant content.")

    return content


def parse_strict_json(content: str) -> Any:
    normalized = normalize_assistant_content(content)
    try:
        return json.loads(normalized)
    except json.JSONDecodeError as exc:
        raise ValueError(f"Assistant response was not valid JSON: {exc}") from exc


def validate_chat_response(path: Path) -> None:
    payload = load_json_file(path, "Chat completion response")
    content = assistant_content_from_chat_response(payload)
    parsed = parse_strict_json(content)

    if not isinstance(parsed, dict) or parsed.get("ok") is not True:
        raise ValueError("Assistant JSON did not include ok=true.")


def run_self_test() -> None:
    valid_cases = [
        ('{"ok": true}', {"ok": True}),
        ('<think></think>{"ok": true}', {"ok": True}),
        ('\n<think>\n\t</think>\n{"ok": true}', {"ok": True}),
        ('<think></think><think> </think>{"ok": true}', {"ok": True}),
    ]
    invalid_cases = [
        '<think>reasoning</think>{"ok": true}',
        'prefix {"ok": true}',
        '<think></think>prefix {"ok": true}',
    ]

    for raw, expected in valid_cases:
        parsed = parse_strict_json(raw)
        if parsed != expected:
            raise AssertionError(f"Unexpected parse result for {raw!r}: {parsed!r}")

    for raw in invalid_cases:
        try:
            parse_strict_json(raw)
        except ValueError:
            continue
        raise AssertionError(f"Expected strict parse failure for {raw!r}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Normalize empty leading <think></think> wrappers before strict JSON "
            "parsing. Without --chat-response, stdin is normalized and written to stdout."
        )
    )
    parser.add_argument(
        "--chat-response",
        type=Path,
        help="OpenAI-compatible chat completion response JSON file to validate.",
    )
    parser.add_argument(
        "--self-test",
        action="store_true",
        help="Run built-in normalization and strict-parse checks.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()

    try:
        if args.self_test:
            run_self_test()
            print("normalize_runtime_json self-test passed")
            return 0

        if args.chat_response is not None:
            validate_chat_response(args.chat_response)
            return 0

        sys.stdout.write(normalize_assistant_content(sys.stdin.read()))
        return 0
    except (AssertionError, ValueError) as exc:
        print(str(exc), file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())

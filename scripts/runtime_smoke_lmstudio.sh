#!/bin/bash
# Smoke test a GGUF model through an LM Studio OpenAI-compatible endpoint.
# Usage: scripts/runtime_smoke_lmstudio.sh <gguf_path> [base_url] [model_id] [smoke_prompt]

set -euo pipefail

GGUF_PATH="${1:?gguf_path is required}"
BASE_URL="${2:-${BASE_URL:-http://127.0.0.1:1234/v1}}"
MODEL_ID="${3:-${MODEL_ID:-}}"
SMOKE_PROMPT="${4:-${SMOKE_PROMPT:-/no_think Return exactly this JSON object and nothing else: {\"ok\": true}}}"

if [ ! -f "$GGUF_PATH" ]; then
    echo "GGUF file not found: $GGUF_PATH" >&2
    exit 1
fi

MODELS_RESPONSE="$(mktemp)"
CHAT_RESPONSE="$(mktemp)"
cleanup() {
    rm -f "$MODELS_RESPONSE" "$CHAT_RESPONSE"
}
trap cleanup EXIT

json_field_matches() {
    python3 - "$1" "$2" <<'PY'
import json
import sys

needle = sys.argv[1]
path = sys.argv[2]

with open(path, "r", encoding="utf-8") as fh:
    try:
        payload = json.load(fh)
    except json.JSONDecodeError as exc:
        print(f"/models response was not valid JSON: {exc}", file=sys.stderr)
        sys.exit(1)

if not needle:
    sys.exit(0)

matches = set()

def add_candidate(value):
    if isinstance(value, str) and value:
        matches.add(value)

if isinstance(payload, dict):
    for key in ("data", "models"):
        value = payload.get(key)
        if isinstance(value, list):
            for item in value:
                if isinstance(item, dict):
                    for field in ("id", "name", "model"):
                        add_candidate(item.get(field))
                else:
                    add_candidate(item)
    for field in ("id", "name", "model"):
        add_candidate(payload.get(field))

if needle not in matches and f"{needle}:latest" not in matches:
    print(f"Model {needle} was not visible in the /models response.", file=sys.stderr)
    sys.exit(1)
PY
}

build_chat_payload() {
    python3 - "$MODEL_ID" "$SMOKE_PROMPT" <<'PY'
import json
import sys

model = sys.argv[1]
prompt = sys.argv[2]

payload = {
    "messages": [{"role": "user", "content": prompt}],
    "temperature": 0,
}
if model:
    payload["model"] = model

print(json.dumps(payload))
PY
}

validate_chat_response() {
    python3 - "$CHAT_RESPONSE" <<'PY'
import json
import sys

path = sys.argv[1]

with open(path, "r", encoding="utf-8") as fh:
    try:
        payload = json.load(fh)
    except json.JSONDecodeError as exc:
        print(f"Chat completion response was not valid JSON: {exc}", file=sys.stderr)
        sys.exit(1)

choices = payload.get("choices")
if not isinstance(choices, list) or not choices:
    print("Chat completion did not include choices[].", file=sys.stderr)
    sys.exit(1)

message = choices[0].get("message", {})
content = message.get("content")
if not isinstance(content, str) or not content.strip():
    print("Chat completion did not include assistant content.", file=sys.stderr)
    sys.exit(1)

try:
    parsed = json.loads(content)
except json.JSONDecodeError as exc:
    print(f"Assistant response was not valid JSON: {exc}", file=sys.stderr)
    sys.exit(1)

if parsed.get("ok") is not True:
    print("Assistant JSON did not include ok=true.", file=sys.stderr)
    sys.exit(1)
PY
}

echo "Validating GGUF artifact on SSD..."
echo "  GGUF path: $GGUF_PATH"
echo "  Base URL: $BASE_URL"

echo "Checking models endpoint..."
curl -fsS "$BASE_URL/models" >"$MODELS_RESPONSE"
json_field_matches "$MODEL_ID" "$MODELS_RESPONSE"

echo "Checking chat completions endpoint..."
START_NS="$(date +%s%N)"
curl -fsS "$BASE_URL/chat/completions" \
    -H 'Content-Type: application/json' \
    -d "$(build_chat_payload)" \
    >"$CHAT_RESPONSE"
END_NS="$(date +%s%N)"
validate_chat_response
LATENCY_MS="$(( (END_NS - START_NS) / 1000000 ))"

echo "LM Studio smoke passed for $(basename "$GGUF_PATH")"
echo "Chat latency: ${LATENCY_MS}ms"

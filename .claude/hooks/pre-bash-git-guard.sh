#!/usr/bin/env bash
# Pre-Bash Git Guard — blocks git commit/push/tag unless --dry-run
# Enforces: "Never git commit or push without explicit user instruction"
# Exit code 2 = block, Exit code 0 = allow

set -euo pipefail

INPUT=$(cat)
# shellcheck source=lib/detect-python.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/detect-python.sh"
COMMAND=$(echo "$INPUT" | $PYTHON -c "
import sys, json
data = json.load(sys.stdin)
print(data.get('command', ''))
" 2>/dev/null || echo "")

if [ -z "$COMMAND" ]; then
  exit 0
fi

# Match git followed by commit, push, or tag (with optional flags in between)
if echo "$COMMAND" | grep -qiE "git\s+([a-z\.\-]+=\S+\s+)*(commit|push|tag)"; then
  # Allow if --dry-run is present
  if echo "$COMMAND" | grep -q "\-\-dry-run"; then
    exit 0
  fi
  echo "Git write blocked: commit, push, and tag operations require explicit permission." >&2
  echo "What to do: (1) Ask Claude to commit for you (it will request permission)" >&2
  echo "            (2) Run the git command yourself in a separate terminal" >&2
  exit 2
fi

exit 0

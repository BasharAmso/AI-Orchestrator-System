#!/usr/bin/env bash
# Pre-Bash Git Guard — blocks git commit/push/tag unless --dry-run
# Enforces: "Never git commit or push without explicit user instruction"
# Exit code 2 = block, Exit code 0 = allow

set -euo pipefail
echo "$(basename "${BASH_SOURCE[0]}")" >> /tmp/aos-hook-usage.log 2>/dev/null || true

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

# Block --no-verify flag (bypasses pre-commit/push hooks)
if echo "$COMMAND" | grep -qE "\-\-no-verify"; then
  echo "Git guard blocked: --no-verify bypasses safety hooks." >&2
  echo "Remove the flag or run the command yourself in a separate terminal." >&2
  exit 2
fi

# Match git followed by commit, push, or tag (with optional flags in between)
if echo "$COMMAND" | grep -qiE "git\s+([a-z\.\-]+=\S+\s+)*(commit|push|tag)"; then
  # Allow during overnight mode (set by /overnight command)
  if [ "${AOS_OVERNIGHT_MODE:-false}" = "true" ]; then
    # Still block force push even in overnight mode
    if echo "$COMMAND" | grep -qiE "push\s+(-f|--force)"; then
      echo "Git force push blocked even in overnight mode." >&2
      exit 2
    fi
    exit 0
  fi
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

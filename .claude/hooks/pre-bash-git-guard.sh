#!/usr/bin/env bash
# Pre-Bash Git Guard — blocks git commit/push/tag unless --dry-run
# Enforces: "Never git commit or push without explicit user instruction"
# Exit code 2 = block, Exit code 0 = allow

set -euo pipefail

INPUT=$(cat)
PYTHON=$(python3 -c "import sys" 2>/dev/null && echo python3 || echo python)
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
  echo "BLOCKED by pre-bash-git-guard: git write operation detected" >&2
  echo "Git commit/push/tag operations are blocked by safety policy." >&2
  echo "Options: (1) Run the command manually in your terminal" >&2
  echo "         (2) Add to permissions.allow in .claude/settings.json" >&2
  exit 2
fi

exit 0

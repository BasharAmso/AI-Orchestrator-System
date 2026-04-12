#!/usr/bin/env bash
# Pre-Bash Firewall — blocks dangerous commands before execution
# Called by settings.json PreToolUse hook for all Bash tool calls
# Exit code 2 = block the command and show error to Claude
# Exit code 0 = allow the command to proceed

set -euo pipefail
BASHI_TMP="${TMPDIR:-${TMP:-${TEMP:-/tmp}}}"
echo "$(basename "${BASH_SOURCE[0]}")" >> "$BASHI_TMP/bashi-hook-usage.log" 2>/dev/null || true

INPUT=$(cat)
# shellcheck source=lib/detect-python.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/detect-python.sh"
COMMAND=$(echo "$INPUT" | $PYTHON -c "
import sys, json
data = json.load(sys.stdin)
print(data.get('command', ''))
" 2>/dev/null || echo "")

BLOCKED_PATTERNS=(
  "rm -rf /[[:space:]]*$"
  "rm -rf \*"
  "git reset --hard"
  "git push --force"
  "git push -f"
  "DROP TABLE"
  "DROP DATABASE"
  "truncate "
  "chmod 777"
  "> /etc/"
  "sudo rm"
  "rm -rf \."
  "> /dev/sda"
  "mkfs"
  "dd if="
)

# Allowlist mode: only explicitly permitted command prefixes are allowed.
# Set FIREWALL_MODE=allowlist in settings.json env to enable.
FIREWALL_MODE="${FIREWALL_MODE:-blocklist}"

if [ "$FIREWALL_MODE" = "allowlist" ]; then
  ALLOWED_PREFIXES=(
    "git status" "git add" "git diff" "git log" "git commit" "git branch"
    "git checkout" "git stash" "git show" "git rev-parse" "git merge"
    "npm test" "npm run" "npm install" "npm ci" "npm ls"
    "npx " "node " "python " "python3 "
    "ls" "cat " "pwd" "echo " "head " "tail " "wc " "sort " "uniq "
    "find " "grep " "rg " "mkdir " "cp " "mv " "touch "
    "cd " "which " "command " "type " "env " "printenv"
    "bash .claude/"
  )

  ALLOWED=false
  for prefix in "${ALLOWED_PREFIXES[@]}"; do
    if [[ "$COMMAND" == "$prefix"* ]] || [[ "$COMMAND" == "$prefix" ]]; then
      ALLOWED=true
      break
    fi
  done

  if [ "$ALLOWED" = false ]; then
    echo "BLOCKED by pre-bash-firewall (allowlist mode): command not in allowed list" >&2
    echo "Command: $COMMAND" >&2
    echo "To allow, add the command prefix to the allowlist or switch to blocklist mode." >&2
    exit 2
  fi
fi

# Blocklist mode (default): block known dangerous patterns
for pattern in "${BLOCKED_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qiE "$pattern"; then
    echo "BLOCKED by pre-bash-firewall: '$pattern' detected in command" >&2
    echo "If this is intentional, ask the user to run the command manually." >&2
    exit 2
  fi
done

# Block pipe-to-shell patterns
if echo "$COMMAND" | grep -qE "\|\s*(ba)?sh"; then
  echo "BLOCKED by pre-bash-firewall: pipe-to-shell pattern detected" >&2
  exit 2
fi

exit 0

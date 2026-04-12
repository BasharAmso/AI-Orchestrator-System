#!/usr/bin/env bash
# Post-MCP Failure Advisor — detects MCP tool failures and suggests fixes
# Registered as PostToolUse for mcp__* tools
# Always exits 0 — advisory only, never blocks

set -uo pipefail
BASHI_TMP="${TMPDIR:-${TMP:-${TEMP:-/tmp}}}"
echo "$(basename "${BASH_SOURCE[0]}")" >> "$BASHI_TMP/bashi-hook-usage.log" 2>/dev/null || true

INPUT=$(cat)
# shellcheck source=lib/detect-python.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/detect-python.sh"

RESULT=$($PYTHON -c "
import sys, json
d = json.load(sys.stdin)
tool = d.get('tool_name', '')
error = str(d.get('error', ''))
result = str(d.get('tool_result', ''))
combined = error + result
keywords = ['ECONNREFUSED', 'timed out', 'server disconnected', 'not connected',
            'EPIPE', 'spawn', 'ENOENT', 'MCP error', 'server closed']
if any(k.lower() in combined.lower() for k in keywords):
    print(f'FAILED|{tool}|{(error or result)[:200]}')
else:
    print('OK')
" <<< "$INPUT" 2>/dev/null || echo "OK")

if [[ "$RESULT" == FAILED* ]]; then
  TOOL_NAME=$(echo "$RESULT" | cut -d'|' -f2)
  SERVER_NAME=$(echo "$TOOL_NAME" | sed 's/^mcp__\([^_]*\)__.*/\1/')
  echo "" >&2
  echo "MCP failure detected: $TOOL_NAME" >&2
  echo "Server '$SERVER_NAME' may need restart:" >&2
  echo "  1. Run: claude mcp restart $SERVER_NAME" >&2
  echo "  2. Or close and reopen VS Code" >&2
fi

exit 0

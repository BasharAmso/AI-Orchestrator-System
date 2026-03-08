#!/usr/bin/env bash
# Pre-Write Size Guard — blocks changes exceeding 500 lines
# Enforces orchestrator circuit breaker: ">500 line change in a single file"
# Exit code 2 = block, Exit code 0 = allow

set -euo pipefail

INPUT=$(cat)

PYTHON=$(python3 -c "import sys" 2>/dev/null && echo python3 || echo python)
RESULT=$(echo "$INPUT" | $PYTHON -c "
import sys, json

data = json.load(sys.stdin)

# Write tool: check 'content'
content = data.get('content', '')
if content:
    lines = content.count('\n') + (1 if content and not content.endswith('\n') else 0)
    path = data.get('file_path', data.get('path', 'unknown'))
    print(f'{lines}|{path}')
    sys.exit(0)

# Edit tool: check 'new_string'
new_string = data.get('new_string', '')
if new_string:
    lines = new_string.count('\n') + (1 if new_string and not new_string.endswith('\n') else 0)
    path = data.get('file_path', data.get('path', 'unknown'))
    print(f'{lines}|{path}')
    sys.exit(0)

# MultiEdit tool: check largest 'new_string' in edits array
edits = data.get('edits', [])
if edits:
    max_lines = 0
    for edit in edits:
        ns = edit.get('new_string', '')
        count = ns.count('\n') + (1 if ns and not ns.endswith('\n') else 0)
        if count > max_lines:
            max_lines = count
    path = data.get('file_path', data.get('path', 'unknown'))
    print(f'{max_lines}|{path}')
    sys.exit(0)

print('0|unknown')
" 2>/dev/null || echo "0|unknown")

LINE_COUNT="${RESULT%%|*}"
FILE_PATH="${RESULT#*|}"
LIMIT=500

if [ "$LINE_COUNT" -gt "$LIMIT" ] 2>/dev/null; then
  echo "BLOCKED by pre-write-size-guard: $LINE_COUNT lines exceeds $LIMIT-line limit for $FILE_PATH" >&2
  echo "Break the change into smaller pieces or ask the user to confirm this large write." >&2
  exit 2
fi

exit 0

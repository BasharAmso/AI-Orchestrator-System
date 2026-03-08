#!/usr/bin/env bash
# Post-Edit Quality Check — runs after any Write/Edit tool use
# Always exits 0 — this hook reports issues, it does not block

set -euo pipefail

INPUT=$(cat)
FILE=$(echo "$INPUT" | $(command -v python3 || command -v python) -c "
import sys, json
d = json.load(sys.stdin)
print(d.get('file_path', d.get('path', '')))
" 2>/dev/null || echo "")

if [ -z "$FILE" ] || [ ! -f "$FILE" ]; then
  exit 0
fi

EXT="${FILE##*.}"

case "$EXT" in
  json)
    if ! $(command -v python3 || command -v python) -m json.tool "$FILE" > /dev/null 2>&1; then
      echo "WARNING: $FILE may contain invalid JSON" >&2
    fi
    ;;
  sh)
    if command -v bash &>/dev/null; then
      if ! bash -n "$FILE" 2>/dev/null; then
        echo "WARNING: $FILE contains bash syntax errors" >&2
      fi
    fi
    ;;
  md)
    if grep -q "<<<<<<" "$FILE" 2>/dev/null; then
      echo "WARNING: $FILE contains unresolved merge conflicts" >&2
    fi
    ;;
esac

exit 0

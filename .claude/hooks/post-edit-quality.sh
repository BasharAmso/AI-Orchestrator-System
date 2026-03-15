#!/usr/bin/env bash
# Post-Edit Quality Check — runs after any Write/Edit tool use
# Always exits 0 — this hook reports issues, it does not block

set -euo pipefail

INPUT=$(cat)
PYTHON=$(python3 -c "import sys" 2>/dev/null && echo python3 || echo python)
FILE=$(echo "$INPUT" | $PYTHON -c "
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
    if ! $PYTHON -m json.tool "$FILE" > /dev/null 2>&1; then
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

# --- Auto-format if a project formatter is available ---
# Only runs if the project has a formatter configured; never imposes one
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "")
if [ -n "$PROJECT_ROOT" ]; then
  case "$EXT" in
    js|jsx|ts|tsx|css|scss|html)
      if [ -f "$PROJECT_ROOT/biome.json" ] || [ -f "$PROJECT_ROOT/biome.jsonc" ]; then
        npx biome format --write "$FILE" 2>/dev/null || true
      elif [ -f "$PROJECT_ROOT/.prettierrc" ] || [ -f "$PROJECT_ROOT/.prettierrc.json" ] || [ -f "$PROJECT_ROOT/prettier.config.js" ] || [ -f "$PROJECT_ROOT/prettier.config.mjs" ]; then
        npx prettier --write "$FILE" 2>/dev/null || true
      fi
      ;;
    py)
      if command -v black &>/dev/null; then
        black --quiet "$FILE" 2>/dev/null || true
      fi
      ;;
    go)
      if command -v gofmt &>/dev/null; then
        gofmt -w "$FILE" 2>/dev/null || true
      fi
      ;;
  esac
fi

exit 0

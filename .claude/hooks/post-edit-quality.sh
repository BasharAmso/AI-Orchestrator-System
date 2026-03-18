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

    # --- Framework convention validation for STATE.md ---
    if echo "$FILE" | grep -q "STATE\.md$" 2>/dev/null; then
      $PYTHON -c "
import sys

with open('$FILE', 'r', encoding='utf-8') as f:
    content = f.read()

warnings = []

# Check task table has 4 columns (Skill column)
if '| # | Task | Priority |' in content and '| # | Task | Priority | Skill |' not in content:
    warnings.append('Task queue missing Skill column. See TASK-FORMAT.md.')

# Check Current Phase is valid
valid_phases = ['Not Started', 'Planning', 'Building', 'Ready for Deploy', 'Deploying', 'Live']
import re
phase_match = re.search(r'## Current Phase\s+\x60([^\x60]+)\x60', content)
if phase_match:
    phase = phase_match.group(1).strip()
    if phase not in valid_phases:
        warnings.append(f'Invalid phase: \"{phase}\". Valid: {valid_phases}')

# Check Framework Mode is valid
mode_match = re.search(r'## Framework Mode\s+\x60([^\x60]+)\x60', content)
if mode_match:
    mode = mode_match.group(1).strip()
    if mode not in ['Full Planning', 'Quick Start']:
        warnings.append(f'Invalid framework mode: \"{mode}\". Use Full Planning or Quick Start.')

# Check for duplicate task numbers
task_nums = re.findall(r'^\|\s*(\d+)\s*\|', content, re.MULTILINE)
if len(task_nums) != len(set(task_nums)):
    warnings.append('Duplicate task numbers found in Next Task Queue.')

for w in warnings:
    print(f'CONVENTION: {w}', file=sys.stderr)
" 2>/dev/null || true
    fi

    # --- Framework convention validation for EVENTS.md ---
    if echo "$FILE" | grep -q "EVENTS\.md$" 2>/dev/null; then
      $PYTHON -c "
import sys, re

with open('$FILE', 'r', encoding='utf-8') as f:
    content = f.read()

warnings = []

# Check for duplicate event IDs
evt_ids = re.findall(r'(EVT-\d+)', content)
seen = set()
dupes = set()
for eid in evt_ids:
    if eid in seen:
        dupes.add(eid)
    seen.add(eid)
if dupes:
    warnings.append(f'Duplicate event IDs found: {sorted(dupes)}')

for w in warnings:
    print(f'CONVENTION: {w}', file=sys.stderr)
" 2>/dev/null || true
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

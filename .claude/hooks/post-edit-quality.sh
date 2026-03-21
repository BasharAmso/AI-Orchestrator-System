#!/usr/bin/env bash
# Post-Edit Quality Check — runs after any Write/Edit tool use
# Always exits 0 — this hook reports issues, it does not block

set -uo pipefail
echo "$(basename "${BASH_SOURCE[0]}")" >> /tmp/aos-hook-usage.log 2>/dev/null || true

INPUT=$(cat)
# shellcheck source=lib/detect-python.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/detect-python.sh"
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
      $PYTHON - "$FILE" <<'PYEOF' 2>/dev/null || true
import sys, re

with open(sys.argv[1], 'r', encoding='utf-8') as f:
    content = f.read()

warnings = []

# Check task table has 4 columns (Skill column)
if '| # | Task | Priority |' in content and '| # | Task | Priority | Skill |' not in content:
    warnings.append('Task queue missing Skill column. See TASK-FORMAT.md.')

# Check Current Phase is valid
valid_phases = ['Not Started', 'Planning', 'Building', 'Ready for Deploy', 'Deploying', 'Live']
phase_match = re.search(r'## Current Phase\s+\x60([^\x60]+)\x60', content)
if phase_match:
    phase = phase_match.group(1).strip()
    if phase not in valid_phases:
        warnings.append(f'Invalid phase: "{phase}". Valid: {valid_phases}')

# Check Framework Mode is valid
mode_match = re.search(r'## Framework Mode\s+\x60([^\x60]+)\x60', content)
if mode_match:
    mode = mode_match.group(1).strip()
    if mode not in ['Full Planning', 'Quick Start']:
        warnings.append(f'Invalid framework mode: "{mode}". Use Full Planning or Quick Start.')

# Check for duplicate task numbers
task_nums = re.findall(r'^\|\s*(\d+)\s*\|', content, re.MULTILINE)
if len(task_nums) != len(set(task_nums)):
    warnings.append('Duplicate task numbers found in Next Task Queue.')

for w in warnings:
    print(f'CONVENTION: {w}', file=sys.stderr)
PYEOF
    fi

    # --- Semantic validation for SKILL.md files ---
    if echo "$FILE" | grep -q "skills/.*SKILL\.md$" 2>/dev/null; then
      $PYTHON - "$FILE" <<'PYEOF' 2>/dev/null || true
import sys, re

with open(sys.argv[1], 'r', encoding='utf-8') as f:
    content = f.read()

warnings = []

# Check YAML frontmatter exists and has required fields
fm_match = re.match(r'^---\s*\n(.*?)\n---', content, re.DOTALL)
if not fm_match:
    warnings.append('SKILL.md missing YAML frontmatter (--- block at top)')
else:
    fm = fm_match.group(1)
    for field in ['id', 'name', 'owner', 'triggers']:
        if not re.search(rf'^{field}:', fm, re.MULTILINE):
            warnings.append(f'SKILL.md frontmatter missing required field: {field}')

    # Validate id format
    id_match = re.search(r'^id:\s*(SKL-\d+)', fm, re.MULTILINE)
    if not id_match:
        warnings.append('SKILL.md id should match format SKL-XXXX')

    # Validate owner is a known agent name
    owner_match = re.search(r'^owner:\s*(\S+)', fm, re.MULTILINE)
    if owner_match:
        known_agents = [
            'orchestrator', 'builder', 'reviewer', 'fixer', 'deployer',
            'designer', 'documenter', 'explorer', 'coach',
            'product-manager', 'project-manager', 'architecture-designer'
        ]
        if owner_match.group(1) not in known_agents:
            warnings.append(f'SKILL.md owner "{owner_match.group(1)}" is not a known agent')

# Check for Definition of Done section
if '## Definition of Done' not in content and '### Definition of Done' not in content:
    warnings.append('SKILL.md missing Definition of Done section')

for w in warnings:
    print(f'SEMANTIC: {w}', file=sys.stderr)
PYEOF
    fi

    # --- Semantic validation for REGISTRY.md ---
    if echo "$FILE" | grep -q "REGISTRY\.md$" 2>/dev/null; then
      HOOKS_DIR="$(dirname "${BASH_SOURCE[0]}")"
      FRAMEWORK_ROOT="$(cd "$HOOKS_DIR/../.." && pwd)"
      $PYTHON - "$FILE" "$FRAMEWORK_ROOT" <<'PYEOF' 2>/dev/null || true
import sys, re, os

with open(sys.argv[1], 'r', encoding='utf-8') as f:
    content = f.read()

framework_root = sys.argv[2]
warnings = []

# Extract skill folder paths from registry table
paths = re.findall(r'\.claude/skills/([^/`\s|]+)/?', content)
for folder in set(paths):
    skill_path = os.path.join(framework_root, '.claude', 'skills', folder, 'SKILL.md')
    if not os.path.isfile(skill_path):
        warnings.append(f'Registry references .claude/skills/{folder}/ but SKILL.md not found on disk')

# Check for duplicate SKL IDs
skl_ids = re.findall(r'(SKL-\d+)', content)
seen = set()
for sid in skl_ids:
    if sid in seen:
        warnings.append(f'Duplicate skill ID in registry: {sid}')
    seen.add(sid)

for w in warnings:
    print(f'SEMANTIC: {w}', file=sys.stderr)
PYEOF
    fi

    # --- Framework convention validation for EVENTS.md ---
    if echo "$FILE" | grep -q "EVENTS\.md$" 2>/dev/null; then
      $PYTHON - "$FILE" <<'PYEOF' 2>/dev/null || true
import sys, re

with open(sys.argv[1], 'r', encoding='utf-8') as f:
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
PYEOF
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
    rs)
      if command -v rustfmt &>/dev/null; then
        rustfmt "$FILE" 2>/dev/null || true
      fi
      ;;
    php)
      if [ -f "$PROJECT_ROOT/vendor/bin/pint" ]; then
        "$PROJECT_ROOT/vendor/bin/pint" "$FILE" 2>/dev/null || true
      elif [ -f "$PROJECT_ROOT/vendor/bin/php-cs-fixer" ]; then
        "$PROJECT_ROOT/vendor/bin/php-cs-fixer" fix "$FILE" --quiet 2>/dev/null || true
      fi
      ;;
    rb)
      if command -v rubocop &>/dev/null; then
        rubocop -a --fail-level error "$FILE" 2>/dev/null || true
      fi
      ;;
  esac
  # Universal fallback: trim trailing whitespace + ensure final newline
  if [ -f "$PROJECT_ROOT/.editorconfig" ]; then
    case "$EXT" in
      js|jsx|ts|tsx|css|scss|html|py|go|rs|php|rb) ;; # already formatted
      *)
        sed -i 's/[[:space:]]*$//' "$FILE" 2>/dev/null || true
        [ -s "$FILE" ] && [ "$(tail -c1 "$FILE" | wc -l)" -eq 0 ] && echo "" >> "$FILE" 2>/dev/null || true
        ;;
    esac
  fi
fi

# --- Strategic compact suggestion ---
EDIT_COUNTER="/tmp/aos-edit-count"
COUNT=0
[ -f "$EDIT_COUNTER" ] && COUNT=$(cat "$EDIT_COUNTER" 2>/dev/null || echo "0")
COUNT=$((COUNT + 1))
echo "$COUNT" > "$EDIT_COUNTER"

if [ $((COUNT % 30)) -eq 0 ]; then
  echo "" >&2
  echo "Context check: $COUNT edits this session. Consider /save then /compact to free context." >&2
fi

exit 0

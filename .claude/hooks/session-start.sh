#!/usr/bin/env bash
# Session Start - loads project context dashboard
# Exit code 0 - informational only

set -euo pipefail
BASHI_TMP="${TMPDIR:-${TMP:-${TEMP:-/tmp}}}"
: > "$BASHI_TMP/bashi-hook-usage.log" 2>/dev/null || true
echo "$(basename "${BASH_SOURCE[0]}")" >> "$BASHI_TMP/bashi-hook-usage.log" 2>/dev/null || true

FRAMEWORK_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CLAUDE_DIR="$FRAMEWORK_ROOT/.claude"
STATE_FILE="$CLAUDE_DIR/project/STATE.md"
EVENTS_FILE="$CLAUDE_DIR/project/EVENTS.md"
POLICY_FILE="$CLAUDE_DIR/project/RUN_POLICY.md"
PARSER="$CLAUDE_DIR/hooks/lib/parse_state.py"
# shellcheck source=lib/detect-python.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/detect-python.sh"

echo "--- bashi Session Context ---"
echo "Framework root: $FRAMEWORK_ROOT"
echo ""

if [ -f "$STATE_FILE" ]; then
  if [ -f "$PARSER" ]; then
    STATE_JSON=$($PYTHON "$PARSER" "$STATE_FILE" all 2>/dev/null || echo '{}')

    PHASE=$(echo "$STATE_JSON" | $PYTHON -c "import json,sys; d=json.loads(sys.stdin.read()); print(d.get('phase','Not Started'))" 2>/dev/null || echo "Not Started")
    MODE=$(echo "$STATE_JSON" | $PYTHON -c "import json,sys; d=json.loads(sys.stdin.read()); print(d.get('mode','Unknown'))" 2>/dev/null || echo "Unknown")
    ACTIVE_DESC=$(echo "$STATE_JSON" | $PYTHON -c "import json,sys; d=json.loads(sys.stdin.read()); print(d.get('active_desc','-'))" 2>/dev/null || echo "-")
    COMPLETED=$(echo "$STATE_JSON" | $PYTHON -c "import json,sys; d=json.loads(sys.stdin.read()); print(d.get('completed',0))" 2>/dev/null || echo "0")
    QUEUED=$(echo "$STATE_JSON" | $PYTHON -c "import json,sys; d=json.loads(sys.stdin.read()); print(d.get('queued',0))" 2>/dev/null || echo "0")
    CHECKPOINTED=$(echo "$STATE_JSON" | $PYTHON -c "import json,sys; d=json.loads(sys.stdin.read()); print(d.get('checkpointed',''))" 2>/dev/null || echo "")
    SESSION_STARTED=$(echo "$STATE_JSON" | $PYTHON -c "import json,sys; d=json.loads(sys.stdin.read()); print(d.get('session_started',''))" 2>/dev/null || echo "")
  else
    PHASE="Not Started"
    MODE="Unknown"
    ACTIVE_DESC="-"
    COMPLETED=0
    QUEUED=0
    CHECKPOINTED=""
    SESSION_STARTED=""
  fi

  TOTAL=$((COMPLETED + QUEUED))
  if [ "$TOTAL" -gt 0 ]; then
    PCT=$((COMPLETED * 100 / TOTAL))
    PROGRESS="$COMPLETED/$TOTAL tasks ($PCT%)"
  else
    PROGRESS="No tasks tracked yet"
  fi

  CYCLE_LIMIT="10"
  if [ -f "$POLICY_FILE" ]; then
    CL=$(grep -i 'autonomous' "$POLICY_FILE" 2>/dev/null | grep -oE '[0-9]+' | head -1 || echo "10")
    [ -n "$CL" ] && CYCLE_LIMIT="$CL"
  fi

  if [ "$CHECKPOINTED" = "No" ] && [ -n "$SESSION_STARTED" ] && [ "$SESSION_STARTED" != "-" ]; then
    echo ""
    echo "WARNING: Previous session (started $SESSION_STARTED) did not run /save."
    echo "Some progress may not be saved. Run /status to check."
    echo ""
  fi

  echo "Phase: ${PHASE:-Not Started} | Mode: ${MODE:-Unknown} | Cycle Limit: $CYCLE_LIMIT"
  echo "Progress: $PROGRESS"
  if [ "$ACTIVE_DESC" != "-" ] && [ -n "$ACTIVE_DESC" ]; then
    echo "Active: $ACTIVE_DESC"
  else
    echo "Active: None"
  fi
else
  echo "STATE.md not found - run /setup to initialize."
fi

if [ -f "$EVENTS_FILE" ]; then
  if [ -f "$PARSER" ]; then
    PENDING=$($PYTHON "$PARSER" "$EVENTS_FILE" events_pending 2>/dev/null || echo "0")
  else
    PENDING=$(awk '/^## Unprocessed Events/,/^---/' "$EVENTS_FILE" 2>/dev/null | grep -c '^EVT-' || echo "0")
  fi
  echo "Pending events: $PENDING"
else
  echo "EVENTS.md not found."
fi

REGISTRY_FILE="$CLAUDE_DIR/skills/REGISTRY.md"
SKILLS_DIR="$CLAUDE_DIR/skills"
if [ -f "$REGISTRY_FILE" ] && [ -d "$SKILLS_DIR" ]; then
  REGISTRY_CHECK=$($PYTHON -c "
import os, re
registry = open('$REGISTRY_FILE', encoding='utf-8').read()
skills_dir = '$SKILLS_DIR'
registered = {}
for m in re.finditer(r'\| (SKL-\d+) \|[^|]+\|[^|]+\|[^|]+\| \x60?\.claude/skills/([^/\x60]+)/?\x60? \|', registry):
    registered[m.group(2)] = m.group(1)
on_disk = set()
for entry in os.listdir(skills_dir):
    skill_path = os.path.join(skills_dir, entry, 'SKILL.md')
    if os.path.isfile(skill_path):
        on_disk.add(entry)
warnings = []
for folder, skl_id in registered.items():
    if folder not in on_disk:
        warnings.append(f'Stale registry entry: {skl_id} ({folder}/) - folder missing')
for folder in sorted(on_disk - set(registered.keys())):
    warnings.append(f'Unregistered skill: {folder}/ has SKILL.md but is not in REGISTRY.md')
if warnings:
    print('\\n'.join(warnings))
" 2>/dev/null || echo "")
  if [ -n "$REGISTRY_CHECK" ]; then
    echo "Registry warnings:"
    echo "$REGISTRY_CHECK"
    echo "Run /fix-registry to resolve."
  fi
fi

FAILED=$($PYTHON "$PARSER" "$STATE_FILE" failed_approaches 2>/dev/null || echo "0")
if [ "$FAILED" -gt 0 ]; then
  echo "Failed approaches: $FAILED - review STATE.md before retrying similar strategies"
fi

MEMORY_PATH="${AI_MEMORY_PATH:-$HOME/Projects/AI-Memory}"
MEMORY_PATH="${MEMORY_PATH/#\~/$HOME}"
if [ -d "$MEMORY_PATH" ]; then
  LESSON_COUNT=$(find "$MEMORY_PATH" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
  echo "AI-Memory: $LESSON_COUNT entries at $MEMORY_PATH"
else
  echo "AI-Memory: Not found at $MEMORY_PATH"
  echo "Run /setup in any project to create it, or set AI_MEMORY_PATH in your shell profile."
fi

date +%s > "$BASHI_TMP/aos-session-start-time"
echo "0" > "$BASHI_TMP/aos-edit-count"

PROJECT_NAME=$(basename "$FRAMEWORK_ROOT")
if command -v powershell.exe &>/dev/null; then
  powershell.exe -Command "
    Add-Type -AssemblyName System.Windows.Forms
    \$notify = New-Object System.Windows.Forms.NotifyIcon
    \$notify.Icon = [System.Drawing.SystemIcons]::Information
    \$notify.Visible = \$true
    \$notify.ShowBalloonTip(4000, '${PROJECT_NAME} - ready', 'Claude Code session started.', [System.Windows.Forms.ToolTipIcon]::Info)
    Start-Sleep -Milliseconds 5000
    \$notify.Dispose()
  " 2>/dev/null || true
elif command -v osascript &>/dev/null; then
  osascript -e "display notification \"Claude Code session started.\" with title \"${PROJECT_NAME} - ready\"" 2>/dev/null || true
fi

MCP_STATUS=$($PYTHON -c "
import json, os
paths = [
    os.path.join('$FRAMEWORK_ROOT', '.claude', 'settings.json'),
    os.path.expanduser('~/.claude/settings.json'),
    os.path.expanduser('~/.claude.json'),
]
for path in paths:
    try:
        with open(path, 'r', encoding='utf-8') as f:
            data = json.load(f)
    except FileNotFoundError:
        continue
    except Exception:
        continue
    if 'cortex' in data.get('mcpServers', {}):
        print(f'configured ({path})')
        break
else:
    print('not configured')
" 2>/dev/null || echo "unknown")
echo "Cortex MCP: ${MCP_STATUS}"
echo "--- End Session Context ---"
exit 0
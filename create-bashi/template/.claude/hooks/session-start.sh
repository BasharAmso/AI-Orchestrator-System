#!/usr/bin/env bash
# Session Start — loads project context dashboard
# Exit code 0 — informational only

set -euo pipefail
echo "$(basename "${BASH_SOURCE[0]}")" >> /tmp/bashi-hook-usage.log 2>/dev/null || true

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

# Extract phase, mode, and active task from STATE.md using shared parser
if [ -f "$STATE_FILE" ]; then
  if [ -f "$PARSER" ]; then
    STATE_JSON=$($PYTHON "$PARSER" "$STATE_FILE" all 2>/dev/null || echo '{}')

    PHASE=$(echo "$STATE_JSON" | $PYTHON -c "import json,sys; d=json.loads(sys.stdin.read()); print(d.get('phase','Not Started'))" 2>/dev/null || echo "Not Started")
    MODE=$(echo "$STATE_JSON" | $PYTHON -c "import json,sys; d=json.loads(sys.stdin.read()); print(d.get('mode','Unknown'))" 2>/dev/null || echo "Unknown")
    ACTIVE_DESC=$(echo "$STATE_JSON" | $PYTHON -c "import json,sys; d=json.loads(sys.stdin.read()); print(d.get('active_desc','—'))" 2>/dev/null || echo "—")
    COMPLETED=$(echo "$STATE_JSON" | $PYTHON -c "import json,sys; d=json.loads(sys.stdin.read()); print(d.get('completed',0))" 2>/dev/null || echo "0")
    QUEUED=$(echo "$STATE_JSON" | $PYTHON -c "import json,sys; d=json.loads(sys.stdin.read()); print(d.get('queued',0))" 2>/dev/null || echo "0")
    CHECKPOINTED=$(echo "$STATE_JSON" | $PYTHON -c "import json,sys; d=json.loads(sys.stdin.read()); print(d.get('checkpointed',''))" 2>/dev/null || echo "")
    SESSION_STARTED=$(echo "$STATE_JSON" | $PYTHON -c "import json,sys; d=json.loads(sys.stdin.read()); print(d.get('session_started',''))" 2>/dev/null || echo "")
  else
    # Fallback: basic extraction if parser not found (matches STATE.md table/backtick format)
    PHASE=$($PYTHON -c "
import re
with open('$STATE_FILE','r',encoding='utf-8') as f: c=f.read()
m=re.search(r'## Current Phase\s+\x60([^\x60]+)\x60',c)
print(m.group(1).strip() if m else 'Not Started')
" 2>/dev/null || echo "Not Started")
    MODE=$($PYTHON -c "
with open('$STATE_FILE','r',encoding='utf-8') as f:
    lines=f.readlines()
    headers=None
    mode_col=0
    for line in lines:
        if '|' in line and '**YES**' not in line and 'Mode' in line and 'Active' in line:
            cols=[c.strip() for c in line.split('|') if c.strip()]
            for i,c in enumerate(cols):
                if c.lower()=='mode': mode_col=i
            headers=True
            continue
        if headers and '**YES**' in line and '|' in line:
            parts=[p.strip() for p in line.split('|') if p.strip()]
            if len(parts)>mode_col: print(parts[mode_col]); break
    else: print('Unknown')
" 2>/dev/null || echo "Unknown")
    ACTIVE_DESC="—"
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

  # Get cycle limit from RUN_POLICY
  CYCLE_LIMIT="10"
  if [ -f "$POLICY_FILE" ]; then
    CL=$(grep -i 'autonomous' "$POLICY_FILE" 2>/dev/null | grep -oE '[0-9]+' | head -1 || echo "10")
    [ -n "$CL" ] && CYCLE_LIMIT="$CL"
  fi

  # Check for stale session lock
  if [ "$CHECKPOINTED" = "No" ] && [ -n "$SESSION_STARTED" ] && [ "$SESSION_STARTED" != "—" ]; then
    echo ""
    echo "WARNING: Previous session (started $SESSION_STARTED) did not run /save."
    echo "Some progress may not be saved. Run /status to check."
    echo ""
  fi

  echo "Phase: ${PHASE:-Not Started} | Mode: ${MODE:-Unknown} | Cycle Limit: $CYCLE_LIMIT"
  echo "Progress: $PROGRESS"
  if [ "$ACTIVE_DESC" != "—" ] && [ -n "$ACTIVE_DESC" ]; then
    echo "Active: $ACTIVE_DESC"
  else
    echo "Active: None"
  fi
else
  echo "STATE.md not found — run /setup to initialize."
fi

# Count pending events
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

# Registry validation: check for stale or missing skill entries
REGISTRY_FILE="$CLAUDE_DIR/skills/REGISTRY.md"
SKILLS_DIR="$CLAUDE_DIR/skills"
if [ -f "$REGISTRY_FILE" ] && [ -d "$SKILLS_DIR" ]; then
  REGISTRY_CHECK=$($PYTHON -c "
import os, re, sys

registry = open('$REGISTRY_FILE').read()
skills_dir = '$SKILLS_DIR'

# Extract folder paths from registry table rows
registered = {}
for m in re.finditer(r'\| (SKL-\d+) \|[^|]+\|[^|]+\|[^|]+\| \x60?\.claude/skills/([^/\x60]+)/?\x60? \|', registry):
    registered[m.group(2)] = m.group(1)

# Find actual skill folders on disk (contain SKILL.md)
on_disk = set()
for entry in os.listdir(skills_dir):
    skill_path = os.path.join(skills_dir, entry, 'SKILL.md')
    if os.path.isfile(skill_path):
        on_disk.add(entry)

warnings = []
# Stale: in registry but folder missing
for folder, skl_id in registered.items():
    if folder not in on_disk:
        warnings.append(f'Stale registry entry: {skl_id} ({folder}/) — folder missing')
# Unregistered: on disk but not in registry
for folder in sorted(on_disk - set(registered.keys())):
    warnings.append(f'Unregistered skill: {folder}/ has SKILL.md but is not in REGISTRY.md')

if warnings:
    print('\n'.join(warnings))
" 2>/dev/null || echo "")
  if [ -n "$REGISTRY_CHECK" ]; then
    echo "Registry warnings:"
    echo "$REGISTRY_CHECK"
    echo "Run /fix-registry to resolve."
  fi
fi

# Failed approaches check
FAILED=$($PYTHON "$PARSER" "$STATE_FILE" failed_approaches 2>/dev/null || echo "0")
if [ "$FAILED" -gt 0 ]; then
  echo "Failed approaches: $FAILED — review STATE.md before retrying similar strategies"
fi

# AI-Memory check
MEMORY_PATH="${AI_MEMORY_PATH:-$HOME/Projects/AI-Memory}"
MEMORY_PATH="${MEMORY_PATH/#\~/$HOME}"  # expand ~ if env var used tilde literal
if [ -d "$MEMORY_PATH" ]; then
  LESSON_COUNT=$(find "$MEMORY_PATH" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
  echo "AI-Memory: $LESSON_COUNT entries at $MEMORY_PATH"
else
  echo "AI-Memory: Not found at $MEMORY_PATH"
  echo "Run /setup in any project to create it, or set AI_MEMORY_PATH in your shell profile."
fi

# Write session start timestamp for cost tracker
date +%s > /tmp/aos-session-start-time
# Reset edit counter for strategic compact suggestions
echo "0" > /tmp/aos-edit-count
# Initialize hook usage log for this session
echo "" > /tmp/bashi-hook-usage.log

# Session start notification
PROJECT_NAME=$(basename "$FRAMEWORK_ROOT")
if command -v powershell.exe &>/dev/null; then
  powershell.exe -Command "
    Add-Type -AssemblyName System.Windows.Forms
    \$notify = New-Object System.Windows.Forms.NotifyIcon
    \$notify.Icon = [System.Drawing.SystemIcons]::Information
    \$notify.Visible = \$true
    \$notify.ShowBalloonTip(4000, '${PROJECT_NAME} — ready', 'Claude Code session started.', [System.Windows.Forms.ToolTipIcon]::Info)
    Start-Sleep -Milliseconds 5000
    \$notify.Dispose()
  " 2>/dev/null || true
elif command -v osascript &>/dev/null; then
  osascript -e "display notification \"Claude Code session started.\" with title \"${PROJECT_NAME} — ready\"" 2>/dev/null || true
fi

# --- Cortex MCP status ---
SETTINGS_FILE="${FRAMEWORK_ROOT}/.claude/settings.json"
if [ -f "$SETTINGS_FILE" ] && command -v python3 &>/dev/null; then
  MCP_STATUS=$(python3 -c "
import json, sys
try:
    with open('${SETTINGS_FILE}', 'r') as f:
        d = json.load(f)
    servers = d.get('mcpServers', {})
    if 'cortex' in servers:
        print('configured')
    else:
        print('not configured (optional)')
except:
    print('unknown')
" 2>/dev/null || echo "unknown")
elif [ -f "$SETTINGS_FILE" ] && command -v python &>/dev/null; then
  MCP_STATUS=$(python -c "
import json, sys
try:
    with open('${SETTINGS_FILE}', 'r') as f:
        d = json.load(f)
    servers = d.get('mcpServers', {})
    if 'cortex' in servers:
        print('configured')
    else:
        print('not configured (optional)')
except:
    print('unknown')
" 2>/dev/null || echo "unknown")
else
  MCP_STATUS="not checked"
fi
echo "Cortex MCP: ${MCP_STATUS}"
echo "--- End Session Context ---"
exit 0

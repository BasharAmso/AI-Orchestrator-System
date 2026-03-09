#!/usr/bin/env bash
# Session Start — loads project context dashboard
# Exit code 0 — informational only

set -euo pipefail

FRAMEWORK_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CLAUDE_DIR="$FRAMEWORK_ROOT/.claude"
STATE_FILE="$CLAUDE_DIR/project/STATE.md"
EVENTS_FILE="$CLAUDE_DIR/project/EVENTS.md"
POLICY_FILE="$CLAUDE_DIR/project/RUN_POLICY.md"

echo "=== AI-Builder-System Session Context ==="
echo "Framework root: $FRAMEWORK_ROOT"
echo ""

# Extract phase, mode, and active task from STATE.md
if [ -f "$STATE_FILE" ]; then
  PHASE=$(grep -A1 "^## Current Phase" "$STATE_FILE" 2>/dev/null | tail -1 | sed 's/^`//;s/`$//' | xargs)
  MODE=$(grep '^\*\*YES\*\*' "$STATE_FILE" 2>/dev/null | head -1 | sed 's/|//g;s/\*\*YES\*\*//;s/  */ /g' | awk '{print $1}' || echo "Unknown")
  # Fallback: try matching the row with **YES**
  if [ -z "$MODE" ] || [ "$MODE" = "Unknown" ]; then
    MODE=$(grep -B0 '\*\*YES\*\*' "$STATE_FILE" 2>/dev/null | head -1 | sed 's/|/\n/g' | head -2 | tail -1 | xargs || echo "Unknown")
  fi

  # Count completed and queued tasks
  COMPLETED=$(awk '/^## Completed Tasks Log/,/^---/' "$STATE_FILE" 2>/dev/null | grep -c '^|' | head -1 || echo "0")
  COMPLETED=$((COMPLETED > 2 ? COMPLETED - 2 : 0))  # subtract header rows
  QUEUED=$(awk '/^## Next Task Queue/,/^---/' "$STATE_FILE" 2>/dev/null | grep -c '^|' | head -1 || echo "0")
  QUEUED=$((QUEUED > 2 ? QUEUED - 2 : 0))  # subtract header rows

  # Check for placeholder-only entries
  if grep -q '(none yet)' "$STATE_FILE" 2>/dev/null && [ "$COMPLETED" -le 1 ]; then
    COMPLETED=0
  fi
  if grep -q '(none — will be seeded' "$STATE_FILE" 2>/dev/null && [ "$QUEUED" -le 1 ]; then
    QUEUED=0
  fi

  TOTAL=$((COMPLETED + QUEUED))
  if [ "$TOTAL" -gt 0 ]; then
    PCT=$((COMPLETED * 100 / TOTAL))
    PROGRESS="$COMPLETED/$TOTAL tasks ($PCT%)"
  else
    PROGRESS="No tasks tracked yet"
  fi

  # Active task description
  ACTIVE_DESC=$(awk '/^## Active Task/,/^###/' "$STATE_FILE" 2>/dev/null | grep '| Description |' | sed 's/.*| Description | *//;s/ *|.*//' || echo "—")

  # Get cycle limit from RUN_POLICY
  CYCLE_LIMIT="10"
  if [ -f "$POLICY_FILE" ]; then
    CL=$(grep -i 'autonomous' "$POLICY_FILE" 2>/dev/null | grep -oP '\d+' | head -1 || echo "10")
    [ -n "$CL" ] && CYCLE_LIMIT="$CL"
  fi

  # Check for stale session lock (previous session didn't checkpoint)
  CHECKPOINTED=$(awk '/^## Session Lock/,/^---/' "$STATE_FILE" 2>/dev/null | grep '| Checkpointed |' | sed 's/.*| Checkpointed | *//;s/ *|.*//' || echo "")
  SESSION_STARTED=$(awk '/^## Session Lock/,/^---/' "$STATE_FILE" 2>/dev/null | grep '| Session Started |' | sed 's/.*| Session Started | *//;s/ *|.*//' || echo "")
  if [ "$CHECKPOINTED" = "No" ] && [ -n "$SESSION_STARTED" ] && [ "$SESSION_STARTED" != "—" ]; then
    echo ""
    echo "WARNING: Previous session (started $SESSION_STARTED) did not run /checkpoint."
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
  PENDING=$(awk '/^## Unprocessed Events/,/^---/' "$EVENTS_FILE" 2>/dev/null | grep -c '^EVT-' || echo "0")
  echo "Pending events: $PENDING"
else
  echo "EVENTS.md not found."
fi

# AI-Memory check
MEMORY_PATH="${AI_MEMORY_PATH:-$HOME/Projects/AI-Memory}"
if [ -d "$MEMORY_PATH" ]; then
  LESSON_COUNT=$(find "$MEMORY_PATH" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
  echo "AI-Memory: $LESSON_COUNT entries at $MEMORY_PATH"
else
  echo "AI-Memory: Not found at $MEMORY_PATH"
  echo "Set AI_MEMORY_PATH in your shell profile to point to your local AI-Memory path."
fi

echo "========================================="
exit 0

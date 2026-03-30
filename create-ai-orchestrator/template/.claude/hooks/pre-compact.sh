#!/usr/bin/env bash
# PreCompact Hook — preserves critical state context before CC auto-compacts
# When Claude Code compacts context (~75% utilization), key state references
# can be lost. This hook outputs a state summary that survives compaction.
# Exit code 0 = always allow compaction to proceed

set -uo pipefail
echo "$(basename "${BASH_SOURCE[0]}")" >> /tmp/aos-hook-usage.log 2>/dev/null || true

FRAMEWORK_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CLAUDE_DIR="$FRAMEWORK_ROOT/.claude"
STATE_FILE="$CLAUDE_DIR/project/STATE.md"
EVENTS_FILE="$CLAUDE_DIR/project/EVENTS.md"
PARSER="$CLAUDE_DIR/hooks/lib/parse_state.py"
# shellcheck source=lib/detect-python.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/detect-python.sh"

echo "--- Pre-Compact State Snapshot ---"

if [ -f "$STATE_FILE" ]; then
  if [ -f "$PARSER" ]; then
    PHASE=$($PYTHON "$PARSER" "$STATE_FILE" phase 2>/dev/null || echo "Unknown")
    MODE=$($PYTHON "$PARSER" "$STATE_FILE" mode 2>/dev/null || echo "Unknown")
    ACTIVE_ID=$($PYTHON "$PARSER" "$STATE_FILE" active_id 2>/dev/null || echo "—")
    ACTIVE_DESC=$($PYTHON "$PARSER" "$STATE_FILE" active_desc 2>/dev/null || echo "—")
    QUEUED=$($PYTHON "$PARSER" "$STATE_FILE" queued 2>/dev/null || echo "0")

    echo "Phase: $PHASE | Mode: $MODE"

    # Check if active ID looks like a real task ID (starts with letter/digit, not em-dash or empty)
    if echo "$ACTIVE_ID" | grep -qE '^[A-Za-z0-9]'; then
      echo "Active Task: $ACTIVE_ID: $ACTIVE_DESC"
      echo "  WARNING: Task in progress — run /save FIRST to preserve work before compaction"
    else
      echo "Active Task: None"
    fi

    echo "Pending tasks: $QUEUED"

    FAILED=$($PYTHON "$PARSER" "$STATE_FILE" failed_approaches 2>/dev/null || echo "0")
    if [ "$FAILED" -gt 0 ]; then
      echo "Failed approaches: $FAILED (DO NOT retry these — see STATE.md)"
    fi

    # Format recent completed tasks — pipe to avoid shell quoting issues with task descriptions
    $PYTHON "$PARSER" "$STATE_FILE" completed_recent 2>/dev/null | $PYTHON -c "
import json, sys
try:
    items = json.loads(sys.stdin.read())
    if items:
        print('Last completed:')
        for row in items:
            vals = [v for v in row.values() if v]
            print('  - ' + ' | '.join(vals[:3]))
except Exception:
    pass
" 2>/dev/null

  else
    echo "Parser not found -- skipping state summary"
  fi
else
  echo "No STATE.md found"
fi

# Pending event count
if [ -f "$EVENTS_FILE" ]; then
  if [ -f "$PARSER" ]; then
    PENDING_EVENTS=$($PYTHON "$PARSER" "$EVENTS_FILE" events_pending 2>/dev/null || echo "0")
  else
    PENDING_EVENTS="0"
  fi
  echo "Pending events: $PENDING_EVENTS"
else
  echo "No EVENTS.md found"
fi

# Knowledge Source
if [ -f "$STATE_FILE" ]; then
  KS=$(grep "Knowledge Source" "$STATE_FILE" | head -1 | sed 's/.*| *\([^|]*\) *|.*/\1/' | xargs)
  [ -n "$KS" ] && echo "Knowledge Source: $KS" || echo "Knowledge Source: Files (default)"
fi
echo "--- End State Snapshot ---"

exit 0

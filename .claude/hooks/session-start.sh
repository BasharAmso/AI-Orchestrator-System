#!/usr/bin/env bash
# Session Start — loads project context summary
# Run manually via /load-context command (not wired to PreToolUse hooks)
# to avoid firing on every tool call
# Exit code 0 — informational only

set -euo pipefail

FRAMEWORK_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CLAUDE_DIR="$FRAMEWORK_ROOT/.claude"
STATE_FILE="$CLAUDE_DIR/project/STATE.md"
EVENTS_FILE="$CLAUDE_DIR/project/EVENTS.md"

echo "=== AI-Builder-System Session Context ==="
echo "Framework root: $FRAMEWORK_ROOT"
echo ""

if [ -f "$STATE_FILE" ]; then
  ACTIVE_TASK=$(grep -m1 "^## Active Task" "$STATE_FILE" 2>/dev/null || echo "")
  if [ -n "$ACTIVE_TASK" ]; then
    echo "Active task found in STATE.md — review before starting work."
  else
    echo "No active task in STATE.md"
  fi
fi

if [ -f "$EVENTS_FILE" ]; then
  PENDING=$(grep -c "^- \[ \]" "$EVENTS_FILE" 2>/dev/null || echo "0")
  if [ "$PENDING" -gt 0 ]; then
    echo "Pending events: $PENDING unprocessed items in EVENTS.md"
  else
    echo "No pending events."
  fi
fi

MEMORY_PATH="${AI_MEMORY_PATH:-$HOME/Projects/AI-Memory}"
if [ -d "$MEMORY_PATH" ]; then
  LESSON_COUNT=$(find "$MEMORY_PATH" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
  echo "AI-Memory: $LESSON_COUNT entries available at $MEMORY_PATH"
else
  echo "AI-Memory: Not found at $MEMORY_PATH"
  echo "Set AI_MEMORY_PATH in your shell profile to point to your local AI-Memory path."
fi

echo "========================================="
exit 0

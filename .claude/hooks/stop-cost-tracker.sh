#!/usr/bin/env bash
# Stop Cost Tracker — logs session duration and activity metrics
# Appends one line per session to .claude/project/session-log.csv
# Always exits 0 — reporting only, never blocks

set -euo pipefail

FRAMEWORK_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
LOG_FILE="$FRAMEWORK_ROOT/.claude/project/session-log.csv"

# Create log with header if it doesn't exist
if [ ! -f "$LOG_FILE" ]; then
  echo "date,session_start,session_end,duration_min" > "$LOG_FILE"
fi

# Session timing: read start time written by session-start hook
START_FILE="/tmp/aos-session-start-time"
NOW=$(date +%s)
NOW_FMT=$(date "+%Y-%m-%d %H:%M")
TODAY=$(date "+%Y-%m-%d")

if [ -f "$START_FILE" ]; then
  START_TIME=$(cat "$START_FILE" 2>/dev/null || echo "$NOW")
  START_FMT=$(date -d "@$START_TIME" "+%H:%M" 2>/dev/null || date -r "$START_TIME" "+%H:%M" 2>/dev/null || echo "??:??")
  ELAPSED=$(( (NOW - START_TIME) / 60 ))
else
  START_FMT="??:??"
  ELAPSED=0
fi

END_FMT=$(date "+%H:%M")

# Append session record
echo "$TODAY,$START_FMT,$END_FMT,$ELAPSED" >> "$LOG_FILE"

# Report to user
if [ "$ELAPSED" -gt 0 ]; then
  echo "Session: ${ELAPSED}min ($START_FMT - $END_FMT) | Logged to .claude/project/session-log.csv"
fi

exit 0

#!/usr/bin/env bash
# Stop Cost Tracker — logs session duration and activity metrics
# Updates one line per session in .claude/project/session-log.csv
# Always exits 0 — reporting only, never blocks

set -uo pipefail

FRAMEWORK_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
LOG_FILE="$FRAMEWORK_ROOT/.claude/project/session-log.csv"

# Create log with header if it doesn't exist
if [ ! -f "$LOG_FILE" ]; then
  echo "date,session_start,session_end,duration_min" > "$LOG_FILE"
fi

# Session timing: read start time written by session-start hook
START_FILE="/tmp/aos-session-start-time"
NOW=$(date +%s)
TODAY=$(date "+%Y-%m-%d")
END_FMT=$(date "+%H:%M")

if [ -f "$START_FILE" ]; then
  START_TIME=$(cat "$START_FILE" 2>/dev/null || echo "$NOW")
  START_FMT=$(date -d "@$START_TIME" "+%H:%M" 2>/dev/null || date -r "$START_TIME" "+%H:%M" 2>/dev/null || echo "??:??")
  ELAPSED=$(( (NOW - START_TIME) / 60 ))
else
  START_FMT="??:??"
  ELAPSED=0
fi

# Staleness guard: if elapsed > 8 hours, the start timestamp is stale
if [ "$ELAPSED" -gt 480 ]; then
  ELAPSED=0
  START_FMT="stale"
fi

# Deduplication: if the last row has the same date and start time, update it
# instead of appending a new row (Stop hook fires on every tool stop)
LAST_LINE=$(tail -1 "$LOG_FILE" 2>/dev/null || echo "")
LAST_DATE=$(echo "$LAST_LINE" | cut -d',' -f1)
LAST_START=$(echo "$LAST_LINE" | cut -d',' -f2)

if [ "$LAST_DATE" = "$TODAY" ] && [ "$LAST_START" = "$START_FMT" ]; then
  # Update the last line: remove it and append the updated version
  sed -i '$d' "$LOG_FILE" 2>/dev/null || true
fi

# Append session record
echo "$TODAY,$START_FMT,$END_FMT,$ELAPSED" >> "$LOG_FILE"

# Report to user (only on meaningful sessions)
if [ "$ELAPSED" -gt 0 ]; then
  echo "Session: ${ELAPSED}min ($START_FMT - $END_FMT) | Logged to .claude/project/session-log.csv"
  echo "Run /log-session to record quality metrics for this session."

  # System notification — lets you walk away while Claude works
  PROJECT_NAME=$(basename "$FRAMEWORK_ROOT")
  if command -v powershell.exe &>/dev/null; then
    # Windows: system tray balloon tooltip
    powershell.exe -Command "
      Add-Type -AssemblyName System.Windows.Forms
      \$notify = New-Object System.Windows.Forms.NotifyIcon
      \$notify.Icon = [System.Drawing.SystemIcons]::Information
      \$notify.Visible = \$true
      \$notify.ShowBalloonTip(6000, '${PROJECT_NAME} — done', 'Session ended (${ELAPSED}min). Run /log-session to capture metrics.', [System.Windows.Forms.ToolTipIcon]::Info)
      Start-Sleep -Milliseconds 7000
      \$notify.Dispose()
    " 2>/dev/null || true
  elif command -v osascript &>/dev/null; then
    # macOS: native notification
    osascript -e "display notification \"Session ended (${ELAPSED}min). Run /log-session.\" with title \"${PROJECT_NAME} — done\"" 2>/dev/null || true
  fi
fi

exit 0

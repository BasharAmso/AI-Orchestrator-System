#!/usr/bin/env bash
# PreCompact Hook — preserves critical state context before CC auto-compacts
# When Claude Code compacts context (~75% utilization), key state references
# can be lost. This hook outputs a state summary that survives compaction.
# Exit code 0 = always allow compaction to proceed

set -euo pipefail

STATE_FILE=".claude/project/STATE.md"
EVENTS_FILE=".claude/project/EVENTS.md"

echo "--- Pre-Compact State Snapshot ---"

# Current phase and mode
if [ -f "$STATE_FILE" ]; then
  PYTHON=$(python3 -c "import sys" 2>/dev/null && echo python3 || echo python)
  $PYTHON -c "
import re

with open('$STATE_FILE', 'r', encoding='utf-8') as f:
    content = f.read()

# Extract phase — STATE.md uses: ## Current Phase followed by backtick-wrapped value
phase_match = re.search(r'## Current Phase\s+\x60([^\x60]+)\x60', content)
phase = phase_match.group(1).strip() if phase_match else 'Unknown'

# Extract mode — STATE.md uses a table where the active mode has **YES**
mode = 'Unknown'
for line in content.split('\n'):
    if '**YES**' in line and '|' in line:
        parts = [p.strip() for p in line.split('|') if p.strip()]
        if parts:
            mode = parts[0]
        break

# Extract active task — STATE.md uses a table under ## Active Task
# The Description field holds the task name; ID field tells us if one is set
active = 'None'
in_active = False
active_id = None
active_desc = None
for line in content.split('\n'):
    if '## Active Task' in line:
        in_active = True
        continue
    if in_active and '|' in line and '---' not in line:
        parts = [p.strip() for p in line.split('|') if p.strip()]
        if len(parts) >= 2:
            key, val = parts[0], parts[1]
            if key == 'ID':
                active_id = val
            elif key == 'Description':
                active_desc = val
    elif in_active and line.startswith('##'):
        break
if active_id and active_id != chr(8212) and active_id != '-':
    active = f'{active_id}: {active_desc}' if active_desc else active_id

# Extract last 3 completed tasks from Completed Tasks Log table
completed = []
in_log = False
for line in content.split('\n'):
    if '## Completed Tasks Log' in line:
        in_log = True
        continue
    if in_log and '|' in line and '---' not in line:
        parts = [p.strip() for p in line.split('|') if p.strip()]
        if len(parts) >= 2 and parts[0] not in ('ID', chr(8212), '-'):
            completed.append(' | '.join(parts[:3]))
    elif in_log and line.startswith('##'):
        break

# Count pending tasks in Next Task Queue table
pending = 0
in_queue = False
for line in content.split('\n'):
    if '## Next Task Queue' in line:
        in_queue = True
        continue
    if in_queue and '|' in line and '---' not in line:
        parts = [p.strip() for p in line.split('|') if p.strip()]
        if len(parts) >= 2 and parts[0] not in ('#', chr(8212), '-'):
            pending += 1
    elif in_queue and line.startswith('##'):
        break

print(f'Phase: {phase} | Mode: {mode}')
print(f'Active Task: {active}')
print(f'Pending tasks: {pending}')
if completed:
    print('Last completed:')
    for c in completed[-3:]:
        print(f'  - {c}')
" 2>/dev/null || echo "Could not parse STATE.md"
else
  echo "No STATE.md found"
fi

# Pending event count
if [ -f "$EVENTS_FILE" ]; then
  # Count EVT- lines between "## Unprocessed Events" and "## Processed Events"
  PENDING_EVENTS=$($PYTHON -c "
in_unprocessed = False
count = 0
with open('$EVENTS_FILE', 'r', encoding='utf-8') as f:
    for line in f:
        if '## Unprocessed Events' in line:
            in_unprocessed = True
            continue
        if '## Processed Events' in line:
            break
        if in_unprocessed and line.strip().startswith('EVT-'):
            count += 1
print(count)
" 2>/dev/null || echo "0")
  echo "Pending events: $PENDING_EVENTS"
else
  echo "No EVENTS.md found"
fi

echo "--- End State Snapshot ---"

exit 0

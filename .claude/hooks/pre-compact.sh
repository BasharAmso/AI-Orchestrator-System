#!/usr/bin/env bash
# PreCompact Hook — preserves critical state context before CC auto-compacts
# When Claude Code compacts context (~75% utilization), key state references
# can be lost. This hook outputs a state summary that survives compaction.
# Exit code 0 = always allow compaction to proceed

set -euo pipefail

STATE_FILE=".claude/project/STATE.md"
EVENTS_FILE=".claude/project/EVENTS.md"

echo "=== Pre-Compact State Snapshot ==="

# Current phase and mode
if [ -f "$STATE_FILE" ]; then
  PYTHON=$(python3 -c "import sys" 2>/dev/null && echo python3 || echo python)
  $PYTHON -c "
import re

with open('$STATE_FILE', 'r', encoding='utf-8') as f:
    content = f.read()

# Extract phase
phase_match = re.search(r'\*\*Current Phase:\*\*\s*(.+)', content)
phase = phase_match.group(1).strip() if phase_match else 'Unknown'

# Extract mode
mode_match = re.search(r'\*\*Mode:\*\*\s*(.+)', content)
mode = mode_match.group(1).strip() if mode_match else 'Unknown'

# Extract active task
active_match = re.search(r'\*\*Active Task:\*\*\s*(.+)', content)
active = active_match.group(1).strip() if active_match else 'None'

# Extract last 3 completed tasks from history
completed = []
in_history = False
for line in content.split('\n'):
    if 'Completed' in line and '|' in line:
        in_history = True
        continue
    if in_history and '|' in line and '---' not in line:
        parts = [p.strip() for p in line.split('|') if p.strip()]
        if parts:
            completed.append(' | '.join(parts[:3]))
    elif in_history and not line.strip():
        break

# Count pending tasks
pending = 0
in_queue = False
for line in content.split('\n'):
    if 'Next Task Queue' in line or 'Task Queue' in line:
        in_queue = True
        continue
    if in_queue and '|' in line and '---' not in line:
        parts = [p.strip() for p in line.split('|') if p.strip()]
        if len(parts) >= 2 and parts[0].isdigit():
            pending += 1
    elif in_queue and not line.strip():
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
  PENDING_EVENTS=$(grep -c "Pending" "$EVENTS_FILE" 2>/dev/null || echo "0")
  echo "Pending events: $PENDING_EVENTS"
else
  echo "No EVENTS.md found"
fi

echo "=================================="

exit 0

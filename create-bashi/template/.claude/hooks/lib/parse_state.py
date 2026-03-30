#!/usr/bin/env python3
"""Shared STATE.md and EVENTS.md parser for shell hooks.

Provides robust markdown table parsing that handles:
- Variable column spacing and alignment
- Missing or reordered columns
- Placeholder rows like "(none yet)"
- Different heading levels and styles

Usage from bash:
  PYTHON=$(python3 -c "import sys" 2>/dev/null && echo python3 || echo python)
  $PYTHON .claude/hooks/lib/parse_state.py <file> <query>

STATE.md queries:
  phase            - Current phase name
  mode             - Current mode (Safe/Semi-Autonomous/Autonomous)
  active_id        - Active task ID
  active_desc      - Active task description
  completed        - Count of completed tasks
  completed_details - JSON array of all completed task rows
  completed_recent  - JSON array of last 3 completed task rows
  queued           - Count of queued tasks
  checkpointed     - Whether session was checkpointed (Yes/No)
  session_started  - When session started
  all              - JSON dump of all parsed fields

EVENTS.md queries (pass EVENTS.md as <file>):
  events_pending   - Count of unprocessed events
"""

import json
import re
import sys


def parse_table_section(content, section_heading):
    """Extract rows from a markdown table under a given heading.

    Returns a list of dicts, one per data row, keyed by column header.
    Handles variable spacing, missing columns, and separator rows.
    """
    lines = content.splitlines()
    in_section = False
    header_cols = None
    rows = []

    for line in lines:
        stripped = line.strip()

        # Detect section start (## or ### heading containing the target text)
        if re.match(r"^#{1,4}\s+", stripped) and section_heading.lower() in stripped.lower():
            in_section = True
            header_cols = None
            continue

        # Detect next section (any heading) — stop
        if in_section and re.match(r"^#{1,4}\s+", stripped) and section_heading.lower() not in stripped.lower():
            break

        # Detect --- separator between sections
        if in_section and stripped == "---":
            break

        if not in_section:
            continue

        # Skip empty lines
        if not stripped:
            continue

        # Table row?
        if "|" in stripped:
            cells = [c.strip() for c in stripped.split("|")]
            # Remove empty first/last from leading/trailing pipes
            if cells and cells[0] == "":
                cells = cells[1:]
            if cells and cells[-1] == "":
                cells = cells[:-1]

            # Skip separator rows (all dashes/colons)
            if all(re.match(r"^[-:]+$", c) for c in cells if c):
                continue

            # First table row = headers
            if header_cols is None:
                header_cols = [c.strip("*").strip() for c in cells]
                continue

            # Data row
            row = {}
            for i, col in enumerate(header_cols):
                row[col] = cells[i].strip() if i < len(cells) else ""
            rows.append(row)

    return rows


def parse_key_value_table(content, section_heading):
    """Parse a 2-column key-value table (| Key | Value |) under a heading.

    Returns a dict of key -> value.
    """
    rows = parse_table_section(content, section_heading)
    result = {}
    for row in rows:
        values = list(row.values())
        if len(values) >= 2:
            key = values[0].strip("*").strip()
            val = values[1].strip()
            result[key] = val
    return result


def find_field(content, field_pattern):
    """Find a **Field:** value or | Field | value | pattern."""
    # Try bold field pattern: **Field:** value
    match = re.search(rf"\*\*{field_pattern}:\*\*\s*(.+)", content)
    if match:
        return match.group(1).strip()
    return None


def parse_state(filepath):
    """Parse STATE.md and return a structured dict."""
    try:
        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()
    except FileNotFoundError:
        return {"error": "STATE.md not found"}

    result = {}

    # Phase — try multiple patterns
    phase = find_field(content, "Current Phase")
    if not phase:
        # Try section heading approach
        for line in content.splitlines():
            if "current phase" in line.lower() and not line.strip().startswith("#"):
                phase = line.split("|")[-2].strip() if "|" in line else line.strip()
                break
    result["phase"] = phase or "Not Started"

    # Mode — look for **YES** in the mode table
    mode = "Unknown"
    mode_rows = parse_table_section(content, "Execution Mode")
    if not mode_rows:
        mode_rows = parse_table_section(content, "Mode")
    for row in mode_rows:
        for key, val in row.items():
            if "YES" in val.upper() or "**YES**" in val:
                # The mode name is usually in the first column
                first_val = list(row.values())[0]
                mode = first_val.strip("*").strip()
                break
    result["mode"] = mode

    # Active task
    active = parse_key_value_table(content, "Active Task")
    result["active_id"] = active.get("ID", active.get("id", "—"))
    result["active_desc"] = active.get("Description", active.get("description", "—"))

    # Completed tasks — count and details
    completed_rows = parse_table_section(content, "Completed Tasks")
    completed_details = []
    for row in completed_rows:
        vals = " ".join(row.values()).lower()
        if "none yet" in vals or "---" in vals:
            continue
        completed_details.append(row)
    result["completed"] = len(completed_details)
    result["completed_details"] = completed_details
    result["completed_recent"] = completed_details[-3:] if completed_details else []

    # Queued tasks count
    queued_rows = parse_table_section(content, "Next Task Queue")
    if not queued_rows:
        queued_rows = parse_table_section(content, "Task Queue")
    queued_count = 0
    for row in queued_rows:
        vals = " ".join(row.values()).lower()
        if "none" in vals or "---" in vals:
            continue
        first_val = list(row.values())[0].strip()
        if first_val and first_val != "..." and first_val.isdigit():
            queued_count += 1
    result["queued"] = queued_count

    # Failed approaches count
    failed_rows = parse_table_section(content, "Failed Approaches")
    failed_count = 0
    for row in failed_rows:
        vals = " ".join(row.values()).lower()
        if "none yet" in vals or "---" in vals:
            continue
        failed_count += 1
    result["failed_approaches"] = failed_count

    # Session lock
    session = parse_key_value_table(content, "Session Lock")
    result["checkpointed"] = session.get("Checkpointed", session.get("checkpointed", ""))
    result["session_started"] = session.get("Session Started", session.get("session_started", ""))

    return result


def parse_events(filepath):
    """Parse EVENTS.md and return structured data."""
    try:
        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()
    except FileNotFoundError:
        return {"events_pending": 0}

    count = 0
    in_unprocessed = False
    for line in content.splitlines():
        stripped = line.strip()
        if "## Unprocessed Events" in stripped:
            in_unprocessed = True
            continue
        if in_unprocessed and (re.match(r"^#{1,4}\s+", stripped) or stripped == "---"):
            break
        if in_unprocessed and stripped.startswith("EVT-"):
            count += 1

    return {"events_pending": count}


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: parse_state.py <file> <query>", file=sys.stderr)
        sys.exit(1)

    filepath = sys.argv[1]
    query = sys.argv[2]

    if query.startswith("events_"):
        data = parse_events(filepath)
    else:
        data = parse_state(filepath)

    if query == "all":
        print(json.dumps(data))
    elif query in ("completed_details", "completed_recent"):
        print(json.dumps(data.get(query, [])))
    elif query in data:
        print(data[query])
    else:
        print(f"Unknown query: {query}", file=sys.stderr)
        sys.exit(1)

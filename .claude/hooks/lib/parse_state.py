#!/usr/bin/env python3
"""Shared STATE.md and EVENTS.md parser for shell hooks."""

import json
import re
import sys


def _heading_text(line):
    match = re.match(r"^#{1,4}\s+(.+?)\s*$", line.strip())
    return match.group(1).strip().lower() if match else None


def parse_table_section(content, section_heading):
    """Extract rows from a markdown table under an exact heading."""
    target = section_heading.strip().lower()
    lines = content.splitlines()
    in_section = False
    header_cols = None
    rows = []

    for line in lines:
        stripped = line.strip()
        heading = _heading_text(stripped)

        if heading == target:
            in_section = True
            header_cols = None
            continue

        if in_section and heading is not None and heading != target:
            break

        if in_section and stripped == "---":
            break

        if not in_section or not stripped or "|" not in stripped:
            continue

        cells = [c.strip() for c in stripped.split("|")]
        if cells and cells[0] == "":
            cells = cells[1:]
        if cells and cells[-1] == "":
            cells = cells[:-1]

        if all(re.match(r"^[-:]+$", c) for c in cells if c):
            continue

        normalized = [c.strip("*").strip() for c in cells]
        if header_cols is None:
            header_cols = normalized
            continue

        if normalized == header_cols:
            continue

        row = {}
        for i, col in enumerate(header_cols):
            row[col] = cells[i].strip() if i < len(cells) else ""
        rows.append(row)

    return rows


def parse_key_value_table(content, section_heading):
    rows = parse_table_section(content, section_heading)
    result = {}
    for row in rows:
        values = list(row.values())
        if len(values) >= 2:
            key = values[0].strip("*").strip()
            val = values[1].strip()
            result[key] = val
    return result


def parse_backticked_value(content, section_heading):
    pattern = rf"##\s+{re.escape(section_heading)}\s+`([^`]+)`"
    match = re.search(pattern, content)
    return match.group(1).strip() if match else None


def parse_state(filepath):
    try:
        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()
    except FileNotFoundError:
        return {"error": "STATE.md not found"}

    result = {}
    result["phase"] = parse_backticked_value(content, "Current Phase") or "Not Started"

    mode = "Unknown"
    for row in parse_table_section(content, "Current Mode"):
        values = list(row.values())
        if len(values) >= 3 and "YES" in values[2].upper():
            mode = values[0].strip("*").strip()
            break
    result["mode"] = mode

    active = parse_key_value_table(content, "Active Task")
    result["active_id"] = active.get("ID", active.get("id", "-"))
    result["active_desc"] = active.get("Description", active.get("description", "-"))

    completed_rows = parse_table_section(content, "Completed Tasks Log")
    completed_details = []
    for row in completed_rows:
        vals = " ".join(row.values()).lower()
        if "none yet" in vals or vals.replace("-", "").strip() == "":
            continue
        completed_details.append(row)
    result["completed"] = len(completed_details)
    result["completed_details"] = completed_details
    result["completed_recent"] = completed_details[-3:] if completed_details else []

    queued_rows = parse_table_section(content, "Next Task Queue")
    queued_count = 0
    for row in queued_rows:
        vals = " ".join(row.values()).lower()
        if "none" in vals:
            continue
        first_val = list(row.values())[0].strip()
        if first_val.isdigit():
            queued_count += 1
    result["queued"] = queued_count

    failed_rows = parse_table_section(content, "Failed Approaches")
    failed_count = 0
    for row in failed_rows:
        vals = " ".join(row.values()).lower()
        if "none yet" in vals:
            continue
        first_val = list(row.values())[0].strip()
        if first_val and first_val != "-":
            failed_count += 1
    result["failed_approaches"] = failed_count

    session = parse_key_value_table(content, "Session Lock")
    result["checkpointed"] = session.get("Checkpointed", session.get("checkpointed", ""))
    result["session_started"] = session.get("Session Started", session.get("session_started", ""))

    return result


def parse_events(filepath):
    try:
        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()
    except FileNotFoundError:
        return {"events_pending": 0}

    count = 0
    in_unprocessed = False
    for line in content.splitlines():
        stripped = line.strip()
        heading = _heading_text(stripped)
        if heading == "unprocessed events":
            in_unprocessed = True
            continue
        if in_unprocessed and heading is not None and heading != "unprocessed events":
            break
        if in_unprocessed and stripped == "---":
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

    data = parse_events(filepath) if query.startswith("events_") else parse_state(filepath)

    if query == "all":
        print(json.dumps(data))
    elif query in ("completed_details", "completed_recent"):
        print(json.dumps(data.get(query, [])))
    elif query in data:
        print(data[query])
    else:
        print(f"Unknown query: {query}", file=sys.stderr)
        sys.exit(1)
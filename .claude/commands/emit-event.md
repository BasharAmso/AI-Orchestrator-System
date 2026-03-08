# Command: /emit-event

> Append a new event to the Unprocessed Events section of `.claude/project/EVENTS.md`.

---

## Procedure

### Step 1: Gather Event Details

Prompt the user (or accept from arguments) for:
- **TYPE** — The event type (e.g., `IDEA_CAPTURED`, `QUALITY_REVIEW_REQUESTED`, `BUG_REPORTED`)
- **Description** — A brief summary of what happened or what needs to happen
- **Source** — Who/what created the event (default: `user`)

### Step 2: Generate Event ID

Read `.claude/project/EVENTS.md` and find the highest existing EVT-XXXX ID across both Unprocessed and Processed sections.
- If no events exist: start at `EVT-0001`.
- Otherwise: increment by 1 (e.g., `EVT-0003` -> `EVT-0004`).

### Step 3: Format and Append

Format the event line:
```
EVT-XXXX | TYPE | Description | Source | YYYY-MM-DD HH:MM
```

Append it under the `## Unprocessed Events` section in `.claude/project/EVENTS.md`.

If the section currently shows `*(none)*`, replace that placeholder with the new event.

### Step 4: Print Confirmation

Print:
```
Event emitted: EVT-XXXX | TYPE | Description

Last 3 unprocessed events:
- EVT-XXXX | ...
- EVT-XXXX | ...
- EVT-XXXX | ...
```

If fewer than 3 unprocessed events exist, show all of them.

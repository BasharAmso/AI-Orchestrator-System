# Command: /status

> Quick project dashboard. Read-only — never modifies any files.

---

## Procedure

### Step 1: Read State

Read `.claude/project/STATE.md` and extract:

- **Current Phase** (from `## Current Phase`)
- **Current Mode** (from `## Current Mode` — the row with `**YES**`)
- **Active Task** (from `## Active Task` — ID and Description fields)
- **Next Task Queue** count (number of rows with real task data)
- **Completed Tasks Log** count (number of rows with real task data, excluding placeholder rows)
- **Recent Completions** — the last 3–5 rows from the Completed Tasks Log table (ID, Description, and completion date if available)
- **Run Cycle** fields (Current Cycle, Max Cycles This Run, Last Run Status, Consecutive Failures, Phantom Completions, Run Type)
- **Blockers / Risks** (any content other than `*(none)*`)

### Step 2: Read Events

Read `.claude/project/EVENTS.md` and count:

- **Unprocessed Events** (number of event lines under `## Unprocessed Events`, excluding `*(none)*`)

### Step 3: Read Cycle Limit

Read `.claude/project/RUN_POLICY.md` and extract the Autonomous cycle limit from the Cycle Limits table.

### Step 4: Calculate Progress

- **Completed** = number of entries in Completed Tasks Log (excluding placeholders)
- **Remaining** = number of entries in Next Task Queue (excluding placeholders)
- **Total** = Completed + Remaining
- **Percentage** = (Completed / Total) × 100, rounded to nearest integer
- If Total = 0, show "No tasks tracked yet"

### Step 5: Print Dashboard

```
## Project Status

**Phase:** [Current Phase] | **Mode:** [Current Mode] | **Cycle Limit:** [Autonomous limit]
**Progress:** [Completed]/[Total] tasks ([percentage]%)
**Active Task:** [ID] — [Description] (or "None")
**Queue:** [Remaining] tasks remaining
**Pending Events:** [Unprocessed count]
**Last Run:** [Last Run Status] ([Current Cycle] of [Max Cycles] cycles)
**Blockers:** [Blocker summary or "None"]

**Recent completions:**
- [Task ID] — [Description] ([completion date])
- [Task ID] — [Description] ([completion date])
- [Task ID] — [Description] ([completion date])
```

If no tasks completed yet, show: `**Recent completions:** None yet`

If `Run Type = Overnight`, also display:

```
**Run Type:** Overnight
**Consecutive Failures:** [N] of 3 max
**Phantom Completions:** [N] of 2 max
**Time Remaining:** [calculated from Session Started + Time Limit Hours from RUN_POLICY.md]
```

Keep output compact — this is a glance-and-go dashboard, not a guidance tool. For recommendations, use `/start`.

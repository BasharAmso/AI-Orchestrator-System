# Command: /set-mode

> Switch the project's execution mode. Updates STATE.md and validates preconditions.

---

## Usage

```
/set-mode <mode>
```

Where `<mode>` is one of:

**Execution modes** (how fast work happens):
- `safe` — Propose only, no file changes (0 cycles)
- `semi` — Execute one unit of work, then stop for review (1 cycle)
- `auto` — Execute multiple units of work autonomously (cycle limit from RUN_POLICY.md)

**Framework modes** (how much planning happens):
- `full-planning` — Full planning pipeline: PRD → architecture → design → tasks → build
- `quick-start` — Scaffold first, plan as you go: idea → immediate build → docs evolve

---

## Procedure

### Step 1: Validate Argument

If `<mode>` is one of `full-planning` or `quick-start`:
- This is a **framework mode** switch (not an execution mode switch).
- Update STATE.md `## Framework Mode` to `Full Planning` or `Quick Start`.
- Print: `"Framework mode switched to [mode]. This changes how much planning happens before building."`
- Stop (do not proceed to Step 2-6).

If `<mode>` is not one of `safe`, `semi`, `auto`, `full-planning`, or `quick-start`:
- Print: "Invalid mode. Use: `safe`, `semi`, `auto`, `architect`, or `beginner`."
- Stop.

### Step 2: Read Current State

Read `.claude/project/STATE.md` to determine:
- Current Mode (which row has `**YES**`)
- Current Phase

### Step 3: Check Preconditions

Before switching, evaluate these warnings (warn but do not block):

| Target Mode | Warning Condition | Message |
|-------------|-------------------|---------|
| `auto` | Current Phase is `Not Started` or `Planning` | "Phase is still `[phase]`. Consider completing planning before switching to Autonomous — unreviewed PRDs and task queues may need manual correction." |
| `auto` | No tasks in Next Task Queue and no Active Task | "No tasks queued. Autonomous mode works best with a populated task queue." |
| `safe` | Active Task has Status = `In Progress` | "There is an active task in progress. Switching to Safe mode will not cancel it, but the next `/run-project` will only propose actions." |

If a warning fires: print the warning, then proceed with the mode switch (do not block).

### Step 4: Update STATE.md

In `.claude/project/STATE.md`, update the Current Mode table:
- Remove `**YES**` from the currently active row.
- Add `**YES**` to the target mode row.

Map argument to table row:
- `safe` → Safe
- `semi` → Semi-Autonomous
- `auto` → Autonomous

Also update the Run Cycle section:
- Update the mode mapping note to reflect the new cycle limit.

### Step 5: CC Permissions Reminder

If switching to `auto`, print:

```
Heads up: Autonomous mode runs multiple cycles without stopping, but Claude
Code may still ask permission for each file write or command.

To get the most out of Autonomous mode:
  1. When Claude Code prompts "Allow this action?", select "Allow for this session"
  2. This only lasts until you close the session — your files stay safe
  3. You can always say "stop" to pause at any time

Without this, Autonomous mode will feel the same as Semi-Autonomous because
every action still requires your approval.
```

### Step 6: Print Confirmation

```
Mode switched: [Old Mode] → [New Mode]

Next /run-project will execute in [New Mode] mode ([cycle description]).
```

Where `[cycle description]` is:
- Safe: "proposal only, no changes"
- Semi-Autonomous: "1 cycle, then stop for review"
- Autonomous: "up to [limit] cycles per run"

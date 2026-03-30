# Command: /save

> Save your progress so you can pick up later in a new session.
> *(Replaces `/checkpoint`.)*

---

## Procedure

### Step 1: Load Current State

Read `.claude/project/STATE.md` to gather:
- Active Task (if any)
- Completed Tasks Log (recently completed tasks this session)
- Current Mode
- Last Run Status

### Step 2: Persist Unsaved Decisions

Review the current session for any architectural, product, or design decisions that were made but not yet written to `.claude/project/knowledge/DECISIONS.md`.

For each unsaved decision:
1. Format it using the entry template in `DECISIONS.md`.
2. Append it to the file.

If no unsaved decisions exist, skip this step.

### Step 3: Verify Artifact Persistence

Confirm that all substantial work products from this session are written to canonical files:

| Artifact Type | Expected Location |
|---------------|-------------------|
| Documentation | `docs/` |
| Task definitions | `tasks/` |
| Research notes | `.claude/project/knowledge/RESEARCH.md` |
| Glossary terms | `.claude/project/knowledge/GLOSSARY.md` |
| Open questions | `.claude/project/knowledge/OPEN_QUESTIONS.md` |

If any artifact exists only in chat and not in a file, write it now.

### Step 4: Update STATE.md

Ensure `.claude/project/STATE.md` accurately reflects:
- The current Active Task (status, outputs, files modified)
- The Next Task Queue (correct ordering)
- Last Run Status set to `Checkpointed`
- **Session Lock:** Set `Checkpointed = Yes` and update `Last Activity` to the current timestamp. This signals to the next session that this session exited cleanly.
- **Failed Approaches:** If any approaches were tried and abandoned during this session, append them to the `## Failed Approaches` table in STATE.md with a one-line description, why it failed, and today's date. Ask the user: "Were any approaches tried and abandoned this session?"

### Step 5: Log Checkpoint Event

Append a `CHECKPOINT` event to `.claude/project/EVENTS.md` using the standard format:

```
EVT-XXXX | CHECKPOINT | Session checkpoint: [brief summary of work done] | system | YYYY-MM-DD HH:MM
```

Follow the same ID-generation logic as `/trigger` (find highest EVT-XXXX, increment by 1).

### Step 6: Session Usage Report

Generate a compact usage report to help identify unused framework components:

1. Read `/tmp/bashi-hook-usage.log` if it exists. Count occurrences of each hook filename.
2. Review the current session: which agents and skills were dispatched? (Introspect the conversation.)
3. Print a usage summary:

```
## Session Usage

**Hooks fired:** [hook-name (Nx) | hook-name (Nx) | ...]
**Hooks NOT fired:** [list hooks that didn't fire this session]
**Agents used:** [agent names] (N of 12)
**Skills used:** [skill names] (N of 26)
```

This helps the user identify dead weight in the framework over time.

### Step 7: Print Save Summary

Print the following (must stay under 200 words):

```
## Progress Saved

**Files updated:**
- .claude/project/STATE.md
- .claude/project/EVENTS.md
- .claude/project/knowledge/DECISIONS.md (if applicable)
- [any other files updated during save]

**Summary:**
[1-3 sentences describing work completed this session]

**Next task:** [Task ID + one-line description, or "None queued"]

You may safely start a new Claude Code session and continue with /run-project.
```

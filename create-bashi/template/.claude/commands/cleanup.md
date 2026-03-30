# Command: /cleanup

> Check for outdated notes and suggest cleanup. Read-only — suggests changes but never deletes.
> *(Replaces `/prune-knowledge`.)*

---

## Procedure

### Step 1: Scan Knowledge Files

Read each file in `.claude/project/knowledge/` and collect metrics:

| File | Metrics to Collect |
|------|--------------------|
| `DECISIONS.md` | Entry count, any entries marked `Superseded` |
| `RESEARCH.md` | Entry count, any entries older than 30 days without updates |
| `GLOSSARY.md` | Entry count |
| `OPEN_QUESTIONS.md` | Total count, count with Status = `Open`, count with Status = `Resolved`, count open > 30 days |

### Step 2: Flag Staleness

Flag items that may need attention:

| Condition | Flag |
|-----------|------|
| Open question with Status = `Open` and Date Raised > 30 days ago | `Stale question` |
| Research entry with no update in > 30 days | `Potentially outdated research` |
| Decision marked `Superseded` | `Superseded decision (can be archived)` |
| Any single knowledge file exceeding 50 entries | `File bloat — consider archiving older entries` |

### Step 3: Scan Processed Events

Read `.claude/project/EVENTS.md` and count processed events. If more than 50 processed events exist, flag: `Event log bloat — consider archiving processed events to a separate file.`

### Step 4: Print Diagnostic Report

```
## Knowledge Health Report

### File Sizes
- **DECISIONS.md:** [count] entries ([superseded] superseded)
- **RESEARCH.md:** [count] entries
- **GLOSSARY.md:** [count] entries
- **OPEN_QUESTIONS.md:** [count] entries ([open] open, [resolved] resolved)

### Flags
- [list each flag with the specific item name/ID and reason]
- (or "No issues found — knowledge base is healthy.")

### Suggestions
- [actionable suggestions based on flags, e.g., "Resolve or close OQ-003 (open 45 days)"]
- (or "No action needed.")
```

---

## Constraints

- **Never delete or modify** any knowledge file. This is a diagnostic-only command.
- Report findings and let the user decide what to clean up.
- If a knowledge file doesn't exist, skip it without error — not all projects use all knowledge files.

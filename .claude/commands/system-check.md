# Command: /system-check

> Diagnose the health of the AI Builder System environment. Read-only — never modifies any files.

---

## Procedure

### Step 1: Verify Required Directories

Check that each directory exists. Record pass/fail for each:

- `.claude/`
- `.claude/commands/`
- `.claude/skills/`
- `.claude/rules/`
- `.claude/agents/`
- `.claude/project/`
- `.claude/project/knowledge/`
- `docs/`

If any are missing, record the directory name for the suggested fixes list.

### Step 2: Verify Required Files

Check that each core file exists. Record pass/fail for each:

- `.claude/project/STATE.md`
- `.claude/project/EVENTS.md`
- `.claude/skills/REGISTRY.md`
- `.claude/agents/orchestrator.md`
- `.claude/CLAUDE.md`
- `.claudeignore`

If any are missing, record the filename for the suggested fixes list.

### Step 3: Verify PROJECT_TYPE.md

- If `PROJECT_TYPE.md` exists in the repo root: read the `Project Type:` line and record the value.
- If missing: check whether `README.md` at the repo root contains the text `AI Builder System`.
  - If yes: this is the framework template itself. Record project type as `Framework Template` and treat as healthy (no warning, no suggested fix).
  - If no: record status as `Not initialized` and add `/init-project` to suggested fixes.

### Step 4: Verify Skills Registry Consistency

1. Scan `.claude/skills/` for all subfolders containing a `SKILL.md` file (excluding `REGISTRY.md`).
2. Read `.claude/skills/REGISTRY.md` and check the Skills Index table.
3. For each skill folder found on disk, confirm its folder path appears in the Skills Index.
4. Results:
   - If all skill files are listed: status = `OK`
   - If any skill file is missing from the index: status = `Stale` and add `/refresh-skills` to suggested fixes.
   - If `REGISTRY.md` is missing or empty: status = `Missing` and add `/refresh-skills` to suggested fixes.

### Step 5: Verify STATE.md Structure

Read `.claude/project/STATE.md` and confirm these sections exist (check for the heading text):

- `## Current Mode`
- `## Active Task`
- `## Next Task Queue`
- `## Completed Tasks Log`

If any section is missing, print a warning naming the missing section. Do not modify the file.

### Step 6: Verify EVENTS.md Structure

Read `.claude/project/EVENTS.md` and confirm these sections exist:

- `## Unprocessed Events`
- `## Processed Events`

If either section is missing, print a warning. Do not modify the file.

### Step 7: Print System Health Summary

Compile all results into this format:

```
## System Check

- **Directories:** [OK | X missing]
- **Core Files:** [OK | X missing]
- **Project Type:** [Book | Web App | Mobile App | Framework Template | Not initialized]
- **Skills Registry:** [OK | Stale | Missing]
- **State File:** [OK | X sections missing]
- **Events Log:** [OK | X sections missing]

**System Status:** [Healthy | Needs Attention]
```

If System Status is `Needs Attention`, also print:

```
### Suggested Fixes

- [list each fix command with a short reason]
```

Common suggested fixes:

| Problem | Fix |
|---------|-----|
| Project type not set | Run `/init-project` |
| Skills registry stale or missing | Run `/refresh-skills` |
| Directories or core files missing | Run `/bootstrap` |
| STATE.md sections missing | Manually verify `.claude/project/STATE.md` structure |
| EVENTS.md sections missing | Manually verify `.claude/project/EVENTS.md` structure |

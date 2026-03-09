# Command: /system-check

> Diagnose the health of the AI Builder System environment. Includes functional verification and optional self-healing for STATE.md inconsistencies.

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
- `## Current Phase`
- `## Active Task`
- `## Next Task Queue`
- `## Completed Tasks Log`
- `## Run Cycle`

If any section is missing, print a warning naming the missing section.

### Step 6: Verify EVENTS.md Structure

Read `.claude/project/EVENTS.md` and confirm these sections exist:

- `## Unprocessed Events`
- `## Processed Events`

If either section is missing, print a warning.

### Step 7: Functional Verification

Go beyond file presence — verify the dispatch chain and cross-references actually work.

#### 7a. Dispatch Chain Test

1. Pick the first skill listed in `REGISTRY.md` (the first row of the Skills Index table).
2. Verify that the skill's folder path exists on disk and contains a `SKILL.md` file.
3. Verify that the skill's `SKILL.md` references a valid agent (check that `.claude/agents/<agent-name>.md` exists).
4. Result: `Dispatch chain: OK` or `Dispatch chain: BROKEN — [reason]`

#### 7b. State Consistency Test

1. **Orphaned Active Task:** If Active Task has an ID (not `—`), verify the task is NOT also listed in the Completed Tasks Log with the same ID. An active task that's already completed is orphaned.
2. **Duplicate Task IDs:** Scan the Completed Tasks Log for duplicate IDs. Each ID should appear at most once.
3. **Mode consistency:** Exactly one row in the Current Mode table should have `**YES**`. If zero or multiple rows have it, flag as inconsistent.
4. **Phase validity:** Current Phase should be one of: `Not Started`, `Planning`, `Building`, `Ready for Deploy`, `Deploying`, `Live`. Flag unknown values.
5. Result: `State consistency: OK` or `State consistency: X issues found`

#### 7c. Cross-Reference Test

1. Every skill folder referenced in `REGISTRY.md` should exist on disk.
2. Every agent referenced in `orchestration-routing.md` should have a matching `.claude/agents/<name>.md` file.
3. Result: `Cross-references: OK` or `Cross-references: X broken links`

### Step 8: STATE.md Repair (Optional)

If Step 7b found consistency issues, offer repairs. **Behavior depends on mode:**

- **Safe / Semi-Autonomous mode:** Print each issue with a proposed fix. Ask the user to confirm before applying any repair.
- **Autonomous mode:** Apply repairs automatically and log each one.

#### Repairable Issues

| Issue | Repair |
|-------|--------|
| Orphaned Active Task (ID exists but is also in Completed Log) | Clear Active Task fields (set all to `—`) |
| Duplicate Task IDs in Completed Log | Remove the duplicate row (keep the first occurrence) |
| Multiple modes marked `**YES**` | Keep only `Semi-Autonomous` as active (safe default) |
| No mode marked `**YES**` | Set `Semi-Autonomous` as active (safe default) |
| Invalid Current Phase value | Reset to `Not Started` |

**Do not repair** issues from Steps 7a or 7c — those require `/refresh-skills` or manual intervention.

### Step 9: Print System Health Summary

Compile all results into this format:

```
## System Check

- **Directories:** [OK | X missing]
- **Core Files:** [OK | X missing]
- **Project Type:** [Book | Web App | Mobile App | Framework Template | Not initialized]
- **Skills Registry:** [OK | Stale | Missing]
- **State File:** [OK | X sections missing]
- **Events Log:** [OK | X sections missing]
- **Dispatch Chain:** [OK | BROKEN]
- **State Consistency:** [OK | X issues found (Y repaired)]
- **Cross-References:** [OK | X broken links]

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
| Project type not set | Run `/setup` |
| Skills registry stale or missing | Run `/refresh-skills` |
| Directories or core files missing | Run `/setup` |
| STATE.md sections missing | Run `/setup` to regenerate, or manually fix |
| EVENTS.md sections missing | Run `/setup` to regenerate, or manually fix |
| Dispatch chain broken | Run `/refresh-skills` to rebuild registry |
| Cross-references broken | Check agent files exist; run `/refresh-skills` |
| State consistency issues | Re-run `/system-check` — repairs are offered automatically |

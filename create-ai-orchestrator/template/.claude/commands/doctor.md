# Command: /doctor

> Run a health check on the system — verify files, test connections, and offer to fix inconsistencies.
> *(Replaces `/system-check`.)*

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
- `FRAMEWORK_VERSION`

If any are missing, record the filename for the suggested fixes list. If `FRAMEWORK_VERSION` is missing, add a note: `"No FRAMEWORK_VERSION file found. Run /clone-framework --upgrade from the source framework to add versioning."`

If `FRAMEWORK_VERSION` exists, read and display the version number in the health summary.

### Step 3: Verify PROJECT_TYPE.md

- If `PROJECT_TYPE.md` exists in the repo root: read the `Project Type:` line and record the value.
- If missing: check whether `README.md` at the repo root contains the text `The AI Orchestrator System`.
  - If yes: this is the framework template itself. Record project type as `Framework Template` and treat as healthy (no warning, no suggested fix).
  - If no: record status as `Not initialized` and add `/setup` to suggested fixes.

### Step 4: Verify Skills Registry Consistency

1. Scan `.claude/skills/` for all subfolders containing a `SKILL.md` file (excluding `REGISTRY.md`).
2. Read `.claude/skills/REGISTRY.md` and check the Skills Index table.
3. For each skill folder found on disk, confirm its folder path appears in the Skills Index.
4. Results:
   - If all skill files are listed: status = `OK`
   - If any skill file is missing from the index: status = `Stale` and add `/fix-registry` to suggested fixes.
   - If `REGISTRY.md` is missing or empty: status = `Missing` and add `/fix-registry` to suggested fixes.

### Step 5: Verify STATE.md Structure

Read `.claude/project/STATE.md` and confirm these sections exist (check for the heading text):

- `## Current Mode`
- `## Current Phase`
- `## Active Task`
- `## Next Task Queue`
- `## Completed Tasks Log`
- `## Run Cycle`

Additionally, verify that `## Run Cycle` includes these fields: `Current Cycle`, `Max Cycles This Run`, `Last Run Status`, `Consecutive Failures`, `Phantom Completions`, `Run Type`. If any field is missing, print a warning naming the missing field(s).

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
5. **Run Cycle consistency:** `Run Type` must be `Standard` or `Overnight`. If `Run Type` is `Overnight` but Current Mode is not Autonomous, flag as inconsistent: `"Run Type is Overnight but mode is not Autonomous — these should always be paired."`
6. Result: `State consistency: OK` or `State consistency: X issues found`

#### 7c. Cross-Reference Test

1. Every skill folder referenced in `REGISTRY.md` should exist on disk. **Resolve paths from the project root** (the directory containing `.claude/`), not the shell's current working directory.
2. Every agent referenced in `orchestration-routing.md` should have a matching `.claude/agents/<name>.md` file.
3. Result: `Cross-references: OK` or `Cross-references: X broken links`

#### 7d. Event Health Test

1. **Orphaned events:** Check if any event in `## Processed Events` has no corresponding task in the Completed Tasks Log. Flag as informational (not an error — some events don't produce tasks).
2. **Stale unprocessed events:** If any unprocessed event has a timestamp older than 7 days, flag as stale: "Event [ID] has been pending for [N] days. It may need manual attention or removal."
3. **Duplicate events:** Check for duplicate event IDs across both sections. Flag duplicates.
4. Result: `Event health: OK` or `Event health: X issues found`

#### 7e. Phase-Progress Consistency Test

1. **Phase vs. completed tasks:** If Current Phase is `Building` but Completed Tasks Log is empty, flag: "Phase is Building but no tasks have been completed yet — phase may have been set prematurely."
2. **Phase vs. queue:** If Current Phase is `Ready for Deploy` but Next Task Queue still has items, flag: "Phase is Ready for Deploy but tasks remain in the queue."
3. **Stale Active Task:** If Active Task has Status = `In Progress` but no `Started` timestamp, flag as inconsistent.
4. Result: `Phase-progress consistency: OK` or `Phase-progress consistency: X issues found`

#### 7f. Task Format Validation

1. Read STATE.md `## Next Task Queue` section.
2. Check if the table header includes a `| Skill |` column (4 columns: `#`, `Task`, `Priority`, `Skill`).
3. If the Skill column is missing: flag as warning.
4. If any task rows exist but are missing the Skill column value: flag as informational.
5. Reference: `.claude/project/knowledge/TASK-FORMAT.md` defines the canonical format.
6. Result: `Task format: OK` or `Task format: Skill column missing`

#### 7g. Skill ID Validation

1. Read STATE.md `## Next Task Queue` section.
2. For each task row that has a Skill column value (not `—`):
   - Check that the Skill ID (e.g., `SKL-0006`) exists in REGISTRY.md's Skills Index table.
   - If the ID is not found: flag as warning: `"Task #X references SKL-XXXX but this skill is not in REGISTRY.md. Run /fix-registry or update the task."`
3. Also check the Completed Tasks Log `Skill Used` column for unknown IDs (informational only).
4. Result: `Skill IDs: OK` or `Skill IDs: X unknown references`

#### 7h. Knowledge File Health Test

1. **Empty knowledge files:** Check each file in `.claude/project/knowledge/`. If a file exists but contains only its template header (no actual entries), flag as informational: "[filename] exists but has no entries yet."
2. **Broken decision references:** Scan `DECISIONS.md` for any entry with Status = `Superseded`. Verify the superseding decision ID exists. Flag broken references.
3. Result: `Knowledge health: OK` or `Knowledge health: X notes`

#### 7i. Progress Tracking Health

1. Check if `~/.claude/logs/framework-progress.csv` exists.
2. If it exists, validate the first line matches the expected header: `date,project,duration_min,quality,iterations,bugs_rework,notes`
3. Count data rows (excluding header). If count > 0 but the last entry's date is older than 14 days, flag as inactive.
4. Result: `Progress tracking: OK (X entries)` or `Progress tracking: Not initialized` or `Progress tracking: Inactive since [date]`

#### 7j. Hook Registration Validation

1. Check if `.claude/settings.json` exists and is valid JSON.
2. Extract all hook command paths from settings.json (entries under `hooks` keys like `PreToolUse`, `PostToolUse`, `Stop`, `PreCompact`, `SessionStart`, `SubagentStop`).
3. For each hook command path, verify the referenced file exists. Report missing files as errors.
4. List all `.sh` files in `.claude/hooks/` (excluding the `lib/` subdirectory). For each, check if it's registered in settings.json. Report unregistered hooks as warnings.
5. Result: `Hook registration: OK (X hooks registered, all files present)` or `Hook registration: X issues (list missing/unregistered)`

#### 7k. Knowledge Source Test

1. Read RUN_POLICY.md Knowledge Loading settings (use defaults if section missing).
2. If Preferred Source = Files: report `"Knowledge Source: Files (configured)"`.
3. If Preferred Source = Auto:
   a. Attempt to call `list_categories` on the MCP server named in `MCP Server Name`.
   b. If available: report `"Cortex MCP: Connected ([X] fragments across [N] categories)"`.
   c. If not available: report `"Cortex MCP: Not connected (using file-based loading)"`.
4. This is **informational, not an error** — both modes are valid.

### Step 8: Repair (Optional)

If Steps 7b, 7d, or 7e found repairable issues, offer repairs. **Behavior depends on mode:**

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
| Duplicate event IDs | Remove the duplicate (keep the first occurrence) |
| Stale unprocessed events (>7 days) | Offer to move to Processed with note: `"Auto-expired by /doctor"` |
| Active Task with no Started timestamp | Set Started to current timestamp |
| Phase `Ready for Deploy` with tasks remaining | Reset phase to `Building` |

**Do not repair** issues from Steps 7a or 7c — those require `/fix-registry` or manual intervention.
**Do not repair** knowledge health notes (7f) — those are informational only.

### Step 9: Print System Health Summary

Compile all results into this format:

```
## System Health

- **Framework Version:** [version from FRAMEWORK_VERSION | Not found]
- **Directories:** [OK | X missing]
- **Core Files:** [OK | X missing]
- **Project Type:** [Web App | Mobile App | API / Backend | SaaS (Full-Stack) | Framework Template | Not initialized]
- **Skills Registry:** [OK | Stale | Missing]
- **State File:** [OK | X sections missing]
- **Events Log:** [OK | X sections missing]
- **Dispatch Chain:** [OK | BROKEN]
- **State Consistency:** [OK | X issues found (Y repaired)]
- **Cross-References:** [OK | X broken links]
- **Event Health:** [OK | X issues found]
- **Task Format:** [OK | Skill column missing]
- **Skill IDs:** [OK | X unknown references]
- **Phase-Progress:** [OK | X issues found]
- **Knowledge Health:** [OK | X notes]
- **Progress Tracking:** [OK (X entries) | Not initialized | Inactive since date]

**System Status:** [Healthy | Needs Attention]
```

If System Status is `Needs Attention`, also print:

```
### Suggested Fixes

- [list each fix command with a short reason]
```

Common suggested fixes (use plain language — the user may be a technical non-programmer — assume systems literacy, not syntax fluency):

| Problem | User-Facing Message |
|---------|-------------------|
| Project type not set | "Your project type hasn't been set yet. Run `/setup` to choose one — it only takes a moment." |
| Skills registry stale or missing | "The skill registry is out of date. Run `/fix-registry` to update it — this takes a few seconds." |
| Directories or core files missing | "Some system files are missing. Run `/setup` to recreate them — it won't overwrite your existing work." |
| STATE.md sections missing | "The project state file is incomplete. Run `/setup` to regenerate it." |
| EVENTS.md sections missing | "The events log is incomplete. Run `/setup` to regenerate it." |
| Dispatch chain broken | "The system can't route tasks to skills properly. Run `/fix-registry` to rebuild the connections." |
| Cross-references broken | "Some internal references are broken. Run `/fix-registry` first, then `/doctor` again." |
| Task format missing Skill column | "Your task queue is using an older format without the Skill column. Run `/clone-framework --upgrade` to patch it, or see `.claude/project/knowledge/TASK-FORMAT.md` for the current format." |
| State consistency issues | "Found some inconsistencies in your project state. Run `/doctor` again — it will offer to fix them automatically." |

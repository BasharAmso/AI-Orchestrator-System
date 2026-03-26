# Command: /overnight

> Run the project unattended until the task queue is empty or a circuit breaker triggers. Combines Autonomous mode with execution hardening, auto-learning, and a morning summary.

---

## When to Use

Before stepping away for an extended period (overnight, lunch, etc.) when you have a populated task queue and want the system to make progress without you.

---

## Arguments

- `/overnight` — Run with defaults (50 cycles, 4 hours)
- `/overnight --cycles N` — Override cycle limit (default 50)
- `/overnight --hours N` — Override time limit in hours (default 4)
- `/overnight --pr` — Create a PR with all changes when done

---

## Procedure

### Step 1: Validate Preconditions

Read `.claude/project/STATE.md` and check:

| Check | Condition | If Failed |
|-------|-----------|-----------|
| Task queue | Next Task Queue has >= 1 task | Print: "No tasks queued. Run `/run-project` to generate tasks first." Stop. |
| No blockers | Active Task status is not `Blocked` | Print: "Active task is blocked. Resolve the blocker first." Stop. |
| Git clean | `git status --porcelain` returns empty | Print: "Working tree has uncommitted changes. Commit or stash them first." Stop. |

If any hard check fails, stop and do not proceed.

If there are unprocessed events in EVENTS.md: warn but proceed (events will be processed first, which is correct).

### Step 1.5: Verify CC Permissions

Overnight mode requires broad tool access to run unattended. Check whether permissions are configured:

1. Read `~/.claude/settings.json` (user settings).
2. Check if the `permissions.allow` array includes broad entries for: `Bash`, `Read`, `Edit`, `Write`.
3. **If any are missing or restricted by patterns** (e.g., `Bash(git *)` instead of `Bash`):
   - Print warning:
     ```
     Your Claude Code permissions use granular patterns that will prompt during overnight execution.
     Overnight mode needs broad tool access to run unattended.

     Current: [list restricted tools]
     Recommended: Broad "Bash", "Read", "Edit", "Write" allows with deny/ask guardrails

     Note: This changes your global permissions for all sessions, not just overnight.
     Your deny and ask lists are preserved as safety guardrails.

     Want me to update your permissions for unattended mode?
     ```
   - If user agrees: update `~/.claude/settings.json` to use broad allows while preserving existing deny/ask lists.
   - If user declines: print "Proceeding, but expect permission prompts during execution." Continue (don't block). Do not modify settings.
4. **If already configured:** skip silently.

### Step 2: Configure Overnight Mode

1. Set Current Mode to **Autonomous** in STATE.md (same as `/set-mode auto`).
2. Set `Run Type = Overnight` in STATE.md Run Cycle section.
3. Set `Max Cycles This Run` = 50 (or `--cycles` argument).
4. Set `Time Limit Hours` = 4 (or `--hours` argument) — write to STATE.md Run Cycle as a temporary field.
5. Set `Consecutive Failures = 0` and `Phantom Completions = 0`.
6. Set `Session Started` = current timestamp, `Checkpointed = No`.
7. Set environment variable `AOS_OVERNIGHT_MODE=true` (enables git guard override for inter-cycle commits).

Record the task count from Next Task Queue for later reporting.

### Step 3: Print Configuration

```
## Overnight Mode Activated

- **Cycle limit:** [N] cycles
- **Time limit:** [N] hours
- **Tasks in queue:** [count]
- **Git verification:** Enabled
- **Circuit breakers:** Consecutive failures (3), time limit, phantom completions (2)
- **Auto-compaction:** Every 8 cycles
- **Auto-learning:** Will run at completion
- **CC Permissions:** Verified (broad access) | Warning (granular patterns, expect prompts)

Important: This run depends on your Claude Code session staying active.
- Disable sleep/hibernation, or use a keep-awake tool
- Do not close the terminal or VS Code window
- You can check progress anytime by opening STATE.md

Starting unattended execution...
```

### Step 4: Create Git Marker Commit

Run:
```bash
git commit --allow-empty -m "overnight: starting — [count] tasks queued"
```

Record the marker commit hash for later use in the morning summary (`git diff --stat`).

### Step 5: Execute

Run the `/run-project` procedure. The existing run-project loop handles everything:
- Cycle execution with pre-cycle snapshots
- Stop condition evaluation (now including circuit breakers, time limit, phantom completions)
- Git verification after each task (triggered by `Run Type = Overnight`)
- Inter-cycle commits (one commit per completed task)
- Auto-compaction every 8 cycles
- Planning review gate for planning skills
- State updates

The `/run-project` loop will continue until a stop condition triggers or cycles are exhausted.

### Step 6: On Completion — Auto-Learn

When the run ends (for any reason):

1. Read STATE.md: `Completed Tasks Log` (filter tasks with completion timestamp >= Session Started from this run).
2. Read `Failed Approaches` table for entries from this run.
3. Analyze patterns:
   - Which skills succeeded vs failed? Are there common failure reasons?
   - Did the same agent/skill fail repeatedly?
   - Are there reusable insights about the tech stack, architecture, or workflow?
4. Write lessons to AI-Memory automatically using the analysis procedure from `/learn` (Steps 1-2) — no user confirmation needed.
5. Log: `"Auto-learning: [N] lessons extracted and saved to AI-Memory."`

If no extractable patterns found: log `"Auto-learning: no notable patterns this run."`

> Uses STATE.md data, not conversation history (which may have been compacted during the run).

### Step 7: Generate Morning Summary

Write `docs/OVERNIGHT_SUMMARY.md`:

```markdown
# Overnight Run Summary

> Generated: [timestamp]
> Duration: [elapsed time from Session Started to now]
> Run Type: Overnight

## Results

| Metric | Value |
|--------|-------|
| Tasks Completed | [count] |
| Tasks Failed/Blocked | [count] |
| Cycles Executed | [X of Y max] |
| Stop Reason | [reason from Last Run Status] |
| Consecutive Failures | [final count] |
| Phantom Completions | [final count] |
| Auto-Compactions | [count of compactions performed] |

## Git Impact

[Output of `git diff --stat [marker-commit]..HEAD`]

## Tasks Completed

| ID | Description | Skill Used |
|----|-------------|------------|
[From Completed Tasks Log, filtered to this run]

## Tasks Failed

| ID | Description | Failure Reason |
|----|-------------|----------------|
[From Failed Approaches + any tasks that ended Blocked during this run]

## Files Modified

[Deduplicated list of all files modified across all cycles]

## Lessons Extracted

[Summary of auto-learning output — count and titles of lessons saved]

## Remaining Queue

| # | Task | Priority | Skill |
|---|------|----------|-------|
[Current Next Task Queue contents]

## Suggested Next Steps

[Based on remaining queue, failures, and current phase — 2-3 actionable suggestions.
Examples:
- "3 tasks remain in queue. Run `/run-project` to continue."
- "2 consecutive failures on database tasks. Check the database connection before continuing."
- "All build tasks complete. Consider `/trigger DEPLOYMENT_REQUESTED` to begin deployment."
- "Planning review flagged scope issues in the PRD. Review docs/PRD.md before building."]
```

### Step 8: Final Commit and Optional PR

1. Reset overnight mode: Set `AOS_OVERNIGHT_MODE=false`, set `Run Type = Standard` in STATE.md.
2. Stage changes: `git add -u` (tracked files) + `git add docs/OVERNIGHT_SUMMARY.md` and any new project files.
3. Commit: `git commit -m "overnight: [N] tasks completed, [M] remaining — [stop reason]"`
4. If `--pr` flag was passed:
   a. Push the current branch: `git push -u origin HEAD`
   b. Create a PR: `gh pr create --title "overnight: [N] tasks completed" --body "$(cat docs/OVERNIGHT_SUMMARY.md)"`
   c. Print the PR URL.

### Step 9: Print Final Report

```
## Overnight Run Complete

- **Duration:** [elapsed time]
- **Completed:** [N] tasks
- **Failed:** [M] tasks
- **Stop reason:** [reason]
- **Morning summary:** docs/OVERNIGHT_SUMMARY.md
- **Lessons saved:** [count] (to AI-Memory)
- **Commits:** [count] (1 per task + 1 final)
[- **PR:** [URL] (if --pr was used)]

Review docs/OVERNIGHT_SUMMARY.md for full details.
```

---

## Constraints

- Never remove existing stop conditions — overnight mode adds to safety, never reduces it.
- Force push is blocked even in overnight mode (git guard still protects against this).
- If the Claude Code session disconnects mid-run, STATE.md will have `Checkpointed = No` and `Run Type = Overnight`. The next session start will warn about the incomplete run.
- The `/overnight` command does not modify RUN_POLICY.md — it uses temporary overrides in STATE.md for this run only.
- Auto-learning writes to AI-Memory but never modifies skill files or framework files.

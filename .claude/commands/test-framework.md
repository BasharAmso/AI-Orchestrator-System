# Command: /test-framework

> Validate the framework's dispatch chain, hook wiring, and cross-references by running automated checks. Read-only - never modifies files.

---

## Procedure

### Step 1: Announce

Print:
```
## Framework Test Suite
Running automated validation...
```

### Step 2: Structural Tests

Run these checks and record pass/fail for each:

#### T1. Required Files Exist

Verify these files exist:

- `FRAMEWORK_VERSION`
- `.claude/CLAUDE.md`
- `.claude/settings.json`
- `.claude/agents/orchestrator.md`
- `.claude/skills/REGISTRY.md`
- `.claude/project/STATE.md`
- `.claude/project/EVENTS.md`
- `.claude/hooks/lib/detect-python.sh`
- `.claude/hooks/lib/parse_state.py`
- `.claudeignore`

Result: `PASS` if all exist, `FAIL (missing: X)` if any are missing.

#### T2. Settings.json Hook Wiring

Read `.claude/settings.json` and verify:

1. `hooks.PreToolUse` contains entries for: `pre-bash-firewall.sh`, `pre-bash-git-guard.sh`, `pre-write-secrets-scan.sh`, `pre-write-size-guard.sh`
2. `hooks.PostToolUse` contains entry for: `post-edit-quality.sh`
3. `hooks.Stop` contains entries for: `final-validation.sh`, `stop-cost-tracker.sh`
4. `hooks.SessionStart` contains entry for: `session-start.sh`
5. `hooks.PreCompact` contains entry for: `pre-compact.sh`
6. Every hook script referenced in settings.json actually exists on disk.

Result: `PASS` if all wired correctly, `FAIL (X issues)` with details.

#### T3. Hook Syntax Validation

Run `bash -n <file>` on every `.sh` file in `.claude/hooks/` (including `lib/`).
Run `python -c "import py_compile; py_compile.compile('<file>', doraise=True)"` on every `.py` file in `.claude/hooks/lib/`.

Result: `PASS` if all pass syntax check, `FAIL (X files)` with details.

### Step 3: Dispatch Chain Tests

#### T4. Registry-to-Disk Consistency

For every skill listed in `.claude/skills/REGISTRY.md`:
1. Extract the skill folder path.
2. Verify the folder exists and contains `SKILL.md`.
3. Read `SKILL.md` and verify it has YAML frontmatter with `id`, `name`, `owner`, and `triggers` fields.

Result: `PASS` if all skills resolve, `FAIL (X broken)` with details.

#### T5. Skill-to-Agent Resolution

For every skill in the REGISTRY:
1. Read the `owner` field from its `SKILL.md` frontmatter.
2. Verify `.claude/agents/<owner>.md` exists.

Result: `PASS` if all agents resolve, `FAIL (X missing agents)` with details.

#### T6. Routing Table Coverage

Read `.claude/rules/orchestration-routing.md` and extract agent names from the Primary Agent column.
For each agent name:
1. Verify `.claude/agents/<name>.md` exists.

Result: `PASS` if all agents resolve, `FAIL (X missing)` with details.

#### T7. Event Hook Coverage

Read `.claude/rules/event-hooks.md` and extract agent names from the Primary Agent column.
For each agent name:
1. Verify `.claude/agents/<name>.md` exists.

Result: `PASS` if all agents resolve, `FAIL (X missing)` with details.

### Step 4: Mock Dispatch Tests

Simulate the dispatch chain with 3 mock tasks to verify end-to-end resolution:

#### T8. Mock Task: Frontend Build

Mock task: `"Build login page (src/app/login/)"` with `Skill: SKL-0005`
1. Look up SKL-0005 in REGISTRY.md - verify it exists and has a valid folder.
2. Read the skill's `owner` field - verify the agent file exists.
3. Trace: `SKL-0005 -> [skill name] -> [owner agent] -> .claude/agents/[owner].md`
4. Result: `PASS` with the full trace, or `FAIL` at the broken link.

#### T9. Mock Task: Bug Fix

Mock task: `"Fix authentication redirect loop"` with `Skill: SKL-0020`
1. Same resolution as T8 but for SKL-0020.
2. Result: `PASS` with trace or `FAIL`.

#### T10. Mock Task: Deployment

Mock task: `"Deploy v1.0 to production"` with `Skill: SKL-0021`
1. Same resolution as T8 but for SKL-0021.
2. Result: `PASS` with trace or `FAIL`.

### Step 5: Parse State Tests

#### T11. parse_state.py Smoke Test

Run the state parser against the current STATE.md:
```
python .claude/hooks/lib/parse_state.py .claude/project/STATE.md all
```

Verify the output is valid JSON containing keys: `phase`, `mode`, `active_id`, `queued`, `completed`.

Result: `PASS` if valid JSON with expected keys, `FAIL` with error details.

#### T12. parse_state.py Events Test

Run:
```
python .claude/hooks/lib/parse_state.py .claude/project/EVENTS.md events_pending
```

Verify the output is a non-negative integer.

Result: `PASS` if valid integer, `FAIL` with error details.

### Step 5.5: Methodology Tests

#### T13. Kanban WIP Gate (Mock)

Simulate the Kanban WIP limit check from orchestrator step 1.5:

1. Read `.claude/rules/methodology-policies.md` and verify the Kanban Policy section exists and contains: WIP Counting Rules, Priority-Pull Ordering, and Migration subsections.
2. Verify the policy states that WIP count includes Active Task with Status = `In Progress` and Parallel Task Slots with Status = `Dispatched`.
3. Mock scenario: WIP Limit = 2, Active Task Status = `In Progress`, 1 Parallel Slot with Status = `Dispatched`. Total WIP = 2. Verify the policy would block selection (count >= limit).
4. Mock scenario: WIP Limit = 2, Active Task Status = `Completed`, 0 Dispatched slots. Total WIP = 0. Verify the policy would allow selection (count < limit).

Result: `PASS` if policy file is well-formed and both mock scenarios resolve correctly per the documented rules. `FAIL` with details.

#### T14. Scrum Sprint Scope (Mock)

Simulate the Scrum sprint-scope filter from orchestrator step 1.5:

1. Read `.claude/rules/methodology-policies.md` and verify the Scrum Policy section exists and contains: Sprint Metadata, Sprint Column Format, and Migration subsections.
2. Verify the policy states that tasks not in the current sprint are skipped during step 1.5.
3. Mock scenario: Sprint = S1, task queue has tasks tagged S1, S2, and `—`. Verify the policy would select only S1-tagged tasks and skip S2 and `—` tasks.
4. Mock scenario: All S1-tagged tasks are completed. Verify the policy would emit `SPRINT_COMPLETE` and stop.

Result: `PASS` if policy file is well-formed and both mock scenarios resolve correctly. `FAIL` with details.

#### T15. Methodology Switch Round-Trip

Verify the `/methodology` command supports reversible transitions:

1. Read `.claude/commands/methodology.md` and verify migration logic exists for:
   - Waterfall → Scrum (sprint sizing prompts)
   - Scrum → Kanban (dissolve sprints, set WIP)
   - Kanban → Waterfall (remove WIP limit)
2. Verify each migration path describes both the STATE.md changes and the user prompts required.
3. Verify FDD ↔ Scrum is blocked in Step 3 (blocked transitions table).

Result: `PASS` if all 3 transition paths are documented with STATE.md changes and user prompts, and FDD ↔ Scrum is blocked. `FAIL` with details.

#### T16. Methodology Switch While Task In Progress

Read `.claude/commands/methodology.md` Step 4 (Check Preconditions) and verify:

1. A precondition check exists for `Active Task has Status = In Progress`.
2. The check fires a warning (not a block): the message must state the active task completes under the old methodology's rules.
3. The switch proceeds after the warning (warn but do not block).

Result: `PASS` if the warning exists, mentions old-methodology completion semantics, and does not block. `FAIL` with details.

#### T17. Scrum with Missing SPRINT.md

Read `.claude/rules/methodology-policies.md` Scrum Policy section and verify:

1. The policy defines two fallback sources for sprint assignment: `Sprint` column in Next Task Queue (primary) and SPRINT.md task list (fallback).
2. Read `.claude/rules/event-hooks.md` and verify `SPRINT_COMPLETE` and `SPRINT_TIMEBOX_EXPIRED` event types are routed to `project-manager`.
3. Verify the Scrum sprint metadata format includes `> Sprint:`, `> Sprint End Date:`, and `> Sprint Goal:` fields in STATE.md.

Result: `PASS` if sprint assignment has defined sources, events are routed, and metadata format is specified. `FAIL` with details.

> Note: Full `/doctor` validation for missing SPRINT.md (refuse to dispatch) ships in Phase 3.

#### T18. Kanban WIP=0 Validation

Read `.claude/commands/methodology.md` and verify:

1. Step 5 (Validate Methodology-Specific Parameters) contains a Kanban section.
2. The Kanban section states that `--wip` must be a positive integer (>= 1).
3. The section explicitly rejects `--wip 0` with the message `"WIP limit must be at least 1."`.

Result: `PASS` if the validation rule exists in the command procedure. `FAIL` if missing or incomplete.

#### T19. Corrupted Methodology Value

Read `.claude/agents/orchestrator.md` step 1.5 ("Apply Methodology Filter") and verify:

1. An "Invalid value" branch exists that handles unrecognized methodology values.
2. The branch logs a warning with the unrecognized value.
3. The branch falls back to Waterfall behavior (does not crash or block dispatch).

Result: `PASS` if the graceful fallback is documented in the orchestrator procedure. `FAIL` with details.

### Step 5.6: Template Sync Test

#### T20. Template Sync Check

Compare `.claude/` against `create-bashi-app/template/.claude/` and flag drift.

1. Verify `create-bashi-app/template/.claude/` exists. If not: `SKIPPED (no template directory)`.

2. For every file in `.claude/`, check if a corresponding file exists in `create-bashi-app/template/.claude/`. **Exclude** these instance-specific paths from comparison:
   - `.claude/project/STATE.md`
   - `.claude/project/EVENTS.md`
   - `.claude/project/RUN_POLICY.md`
   - `.claude/project/session-log.csv`
   - `.claude/project/knowledge/DECISIONS.md`
   - `.claude/project/knowledge/RESEARCH.md`
   - `.claude/project/knowledge/OPEN_QUESTIONS.md`
   - `.claude/project/IDENTITY.md`
   - `.claude/settings.local.json`
   - Any `__pycache__/` directories
   - Any `.pyc` files

3. For each non-excluded file that exists in **both** trees, compare content. Record files that differ.

4. For each non-excluded file that exists in `.claude/` but **not** in the template, record as "missing from template."

5. For each file that exists in the template but **not** in `.claude/`, record as "missing from working copy."

Result:
- `PASS` if zero drift (all shared files match, no unexpected missing files).
- `WARN (N files drifted)` if files differ — list up to 5 drifted filenames. This is a warning, not a failure, because some drift is expected during development before a sync commit.
- `FAIL` only if the template directory is missing entirely.

> This test catches template sync drift early. Run `/clone-framework` or manually copy drifted files to resolve.

#### T20-git. Uncommitted Sync Set Check

Detect when files in the sync set are modified in working tree but not committed — the blind spot that let 44175e7 ship with unstaged changes.

1. Run: `git status --porcelain -- .claude/ create-bashi-app/template/.claude/`
2. From the output, keep only lines starting with ` M`, `M`, `A`, `D`, `R` (tracked file changes). Discard `??` (untracked).
3. Filter out the same exclusion list as T20:
   - `.claude/project/STATE.md`
   - `.claude/project/EVENTS.md`
   - `.claude/project/RUN_POLICY.md`
   - `.claude/project/session-log.csv`
   - `.claude/project/knowledge/DECISIONS.md`
   - `.claude/project/knowledge/RESEARCH.md`
   - `.claude/project/knowledge/OPEN_QUESTIONS.md`
   - `.claude/project/IDENTITY.md`
   - `.claude/settings.local.json`
   - Any `__pycache__/` directories
   - Any `.pyc` files
4. If any files remain after filtering, report:
   `T20-git: WARN (N files have uncommitted changes: <list up to 5>)`
5. If no files remain:
   `T20-git: PASS (no uncommitted tracked changes in sync set)`

T20-git is **informational only** — it does not cause the overall test suite to fail. It warns so the user can commit before a release.

#### T21. FDD Feature Group Filter (Mock)

Simulate the FDD feature-group filter from orchestrator step 1.5:

1. Read `.claude/rules/methodology-policies.md` and verify the FDD Policy section exists and contains: Feature Metadata, Feature Column Format, Feature Decomposition, and Migration subsections.
2. Verify the policy states that the orchestrator selects tasks only from the current feature group (lowest-numbered incomplete feature).
3. Mock scenario: Current Feature = F1, task queue has tasks tagged F1, F2, and `—`. Verify the policy would select only F1-tagged tasks and skip F2 and `—` tasks.
4. Mock scenario: All F1-tagged tasks are completed. Verify the policy would emit `FEATURE_COMPLETE` and stop.
5. Read `.claude/rules/event-hooks.md` and verify `FEATURE_COMPLETE` is routed to `reviewer`.

Result: `PASS` if policy file is well-formed, both mock scenarios resolve correctly, and event routing exists. `FAIL` with details.

### Step 6: Print Results

```
## Test Results

| # | Test | Result |
|---|------|--------|
| T1 | Required files exist | [PASS/FAIL] |
| T2 | Hook wiring in settings.json | [PASS/FAIL] |
| T3 | Hook syntax validation | [PASS/FAIL] |
| T4 | Registry-to-disk consistency | [PASS/FAIL] |
| T5 | Skill-to-agent resolution | [PASS/FAIL] |
| T6 | Routing table coverage | [PASS/FAIL] |
| T7 | Event hook coverage | [PASS/FAIL] |
| T8 | Mock dispatch: frontend build | [PASS/FAIL + trace] |
| T9 | Mock dispatch: bug fix | [PASS/FAIL + trace] |
| T10 | Mock dispatch: deployment | [PASS/FAIL + trace] |
| T11 | State parser smoke test | [PASS/FAIL] |
| T12 | Events parser test | [PASS/FAIL] |
| T13 | Kanban WIP gate (mock) | [PASS/FAIL] |
| T14 | Scrum sprint scope (mock) | [PASS/FAIL] |
| T15 | Methodology switch round-trip | [PASS/FAIL] |
| T16 | Switch while task In Progress | [PASS/FAIL] |
| T17 | Scrum with missing SPRINT.md | [PASS/FAIL] |
| T18 | Kanban WIP=0 validation | [PASS/FAIL] |
| T19 | Corrupted methodology value | [PASS/FAIL] |
| T20 | Template sync check | [PASS/WARN/SKIP] |
| T20-git | Uncommitted sync set check | [PASS/WARN] |
| T21 | FDD feature group filter (mock) | [PASS/FAIL] |

**Result: [X/21 passed]** - [All clear / X issues need attention]
```

If any tests failed, add a `### Issues` section listing each failure with a suggested fix command.

---

## Constraints

- This command is **read-only** - it never modifies any files.
- All tests should complete in under 30 seconds.
- If Python is not available, skip T11 and T12 and note them as `SKIPPED (no Python)`.
- T20 uses `WARN` (not `FAIL`) for drift because development-time drift is expected. It becomes actionable before releases or after `/clone-framework --upgrade`.

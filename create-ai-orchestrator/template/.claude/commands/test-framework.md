# Command: /test-framework

> Validate the framework's dispatch chain, hook wiring, and cross-references by running automated checks. Read-only — never modifies files.

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
1. Look up SKL-0005 in REGISTRY.md — verify it exists and has a valid folder.
2. Read the skill's `owner` field — verify the agent file exists.
3. Trace: `SKL-0005 → [skill name] → [owner agent] → .claude/agents/[owner].md`
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

**Result: [X/12 passed]** — [All clear / X issues need attention]
```

If any tests failed, add a `### Issues` section listing each failure with a suggested fix command.

---

## Constraints

- This command is **read-only** — it never modifies any files.
- All tests should complete in under 30 seconds.
- If Python is not available, skip T11 and T12 and note them as `SKIPPED (no Python)`.

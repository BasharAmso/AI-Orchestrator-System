# Command: /test-hooks

> Verify that all framework hooks are correctly wired, syntactically valid, and functionally working.
> Run this after every `/clone-framework --upgrade` to confirm hooks are operating correctly.
> Read-only — never modifies files.

---

## Procedure

### Step 1: Announce

Print:
```
## Hook Test Suite
Running hook verification (12 tests)...
```

### Step 2: Structural Tests

#### T1. Hook Files Present

Verify all 12 expected hook files exist:

**Shell scripts (10):**
- `.claude/hooks/pre-bash-firewall.sh`
- `.claude/hooks/pre-bash-git-guard.sh`
- `.claude/hooks/pre-write-secrets-scan.sh`
- `.claude/hooks/pre-write-size-guard.sh`
- `.claude/hooks/post-edit-quality.sh`
- `.claude/hooks/final-validation.sh`
- `.claude/hooks/stop-cost-tracker.sh`
- `.claude/hooks/pre-compact.sh`
- `.claude/hooks/session-start.sh`
- `.claude/hooks/post-subagent-validation.sh`

**Library files (2):**
- `.claude/hooks/lib/detect-python.sh`
- `.claude/hooks/lib/parse_state.py`

Result: `PASS` if all 12 exist. `FAIL (missing: X, Y)` listing any absent files.

#### T2. Settings.json Registration

Read `.claude/settings.json` and verify:

1. `hooks.PreToolUse` contains entries referencing: `pre-bash-firewall.sh`, `pre-bash-git-guard.sh`, `pre-write-secrets-scan.sh`, `pre-write-size-guard.sh`
2. `hooks.PostToolUse` contains entry referencing: `post-edit-quality.sh`
3. `hooks.Stop` contains entries referencing: `final-validation.sh`, `stop-cost-tracker.sh`
4. `hooks.SessionStart` contains entry referencing: `session-start.sh`
5. `hooks.PreCompact` contains entry referencing: `pre-compact.sh`
6. `hooks.SubagentStop` contains entry referencing: `post-subagent-validation.sh`

Result: `PASS` if all registered. `FAIL (X unregistered)` with details.

#### T3. No Orphaned Registrations

For every hook path referenced in `settings.json`, verify the file exists on disk.

Result: `PASS` if all registered paths resolve. `FAIL (X broken paths)` with details.

#### T4. Bash Syntax Validation

Run `bash -n <file>` on all `.sh` files in `.claude/hooks/` (including `lib/`).

Result: `PASS` if all pass. `FAIL (X files with syntax errors)` with filenames.

### Step 3: Functional Tests

Test actual hook behavior by piping mock JSON payloads via stdin and checking exit codes.
All functional tests run from the framework root directory.

#### T5. Secrets Scan — Blocks Known Pattern

Run:
```bash
echo '{"file_path": "test.env", "content": "STRIPE_KEY=sk_live_testABCDEFGHIJKLMNOPQRST"}' \
  | bash .claude/hooks/pre-write-secrets-scan.sh
```

Expected: exit code `2` (blocked).

Result: `PASS` if exit code is 2. `FAIL` if exit code is 0 (scan not detecting secrets).

#### T6. Git Guard — Blocks Bare Commit

Run:
```bash
echo '{"command": "git commit -m \"test\""}' \
  | bash .claude/hooks/pre-bash-git-guard.sh
```

Expected: exit code `2` (blocked — no explicit user instruction in context).

Result: `PASS` if exit code is 2. `FAIL` if exit code is 0 (guard not blocking).

#### T7. Bash Firewall — Blocks Dangerous Pattern

Run:
```bash
echo '{"command": "rm -rf /"}' \
  | bash .claude/hooks/pre-bash-firewall.sh
```

Expected: exit code `2` (blocked — exact root-wipe pattern `rm -rf /[[:space:]]*$`).

Result: `PASS` if exit code is 2. `FAIL` if exit code is 0 (firewall not blocking).

#### T8. Size Guard — Flags Oversized Write

Construct a payload with content exceeding 500 lines, then run:
```bash
python -c "
import json, sys
content = '\n'.join([f'line {i}' for i in range(501)])
print(json.dumps({'file_path': 'test.md', 'content': content}))
" | bash .claude/hooks/pre-write-size-guard.sh
```

Expected: exit code `2` (blocked — 501 lines exceeds limit).

Result: `PASS` if exit code is 2. `FAIL` if exit code is 0 (guard not triggering).

### Step 4: Runtime Tests

#### T9. session-start.sh Executes Clean

Run:
```bash
bash .claude/hooks/session-start.sh </dev/null
```

Expected: exit code `0`. Output should contain project state information.

Result: `PASS` if exit code is 0. `FAIL` with error output if it crashes.

#### T10. stop-cost-tracker.sh Executes Clean

Run:
```bash
bash .claude/hooks/stop-cost-tracker.sh </dev/null
```

Expected: exit code `0`.

Result: `PASS` if exit code is 0. `FAIL` with error output if it crashes.

#### T11. lib/detect-python.sh Resolves

Run:
```bash
source .claude/hooks/lib/detect-python.sh && echo "$PYTHON"
```

Expected: exit code `0` and `$PYTHON` is non-empty (a path to a Python executable).

Result: `PASS` if Python found. `SKIPPED (no Python available)` if not found — note that T5, T7, T8 may also be affected.

#### T12. lib/parse_state.py Imports Cleanly

Run:
```bash
python -c "import sys; sys.path.insert(0, '.claude/hooks/lib'); import parse_state; print('ok')"
```

Expected: prints `ok`, exit code `0`.

Result: `PASS` if clean import. `FAIL` with import error. `SKIPPED (no Python)` if Python unavailable.

### Step 5: Print Results

```
## Hook Test Results

| # | Test | Status | Notes |
|---|------|--------|-------|
| T1 | Hook files present | [PASS/FAIL] | [X/12 files found] |
| T2 | Settings.json registration | [PASS/FAIL] | |
| T3 | No orphaned registrations | [PASS/FAIL] | |
| T4 | Bash syntax validation | [PASS/FAIL] | |
| T5 | Secrets scan blocks known pattern | [PASS/FAIL] | |
| T6 | Git guard blocks bare commit | [PASS/FAIL] | |
| T7 | Bash firewall blocks dangerous pattern | [PASS/FAIL] | |
| T8 | Size guard flags oversized write | [PASS/FAIL] | |
| T9 | session-start.sh executes clean | [PASS/FAIL] | |
| T10 | stop-cost-tracker.sh executes clean | [PASS/FAIL] | |
| T11 | lib/detect-python.sh resolves | [PASS/SKIP/FAIL] | |
| T12 | lib/parse_state.py imports cleanly | [PASS/SKIP/FAIL] | |

**Result: [X/12 passed]** — [All hooks operational / X issues need attention]
```

If any tests failed, add a `### Issues` section listing each failure with a suggested fix:
- Missing file → `Run /clone-framework [source] --upgrade to restore missing hooks`
- Missing registration → `Add hook entry to .claude/settings.json hooks section`
- Syntax error → `Run bash -n .claude/hooks/<file>.sh and fix the error on the reported line`
- Functional test failed → `Inspect the hook output above for the specific error message`

---

## Constraints

- This command is **read-only** — it never modifies any files.
- All tests should complete in under 20 seconds.
- If Python is unavailable, T11 and T12 are `SKIPPED` — note this does not count against the pass score.
- Run from the framework root directory (where `.claude/` lives).
- Functional tests (T5–T8) use synthetic payloads — they do not affect real files.

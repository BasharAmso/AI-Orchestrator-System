# Run Policy

> Defines execution boundaries for the orchestrator. Read by the orchestrator at the start of every `/run-project` invocation.

---

## Default Mode

Semi-Autonomous

---

## Cycle Limits

| Mode | Cycles per /run-project |
|------|------------------------|
| Safe | 0 (proposal only) |
| Semi-Autonomous | 1 |
| Autonomous | 5 |

> **Configurable:** To change the Autonomous cycle limit, edit the value above. The orchestrator reads this table at the start of each `/run-project` invocation. Default: 5.

---

## Stop Conditions

The orchestrator must stop immediately if any of the following occur:

1. The user says stop.
2. The current task becomes Blocked.
3. A single file modification exceeds 500 lines.
4. The Next Task Queue becomes empty and no next tasks can be proposed.
5. A required artifact is missing and cannot be created safely.
6. The project goal exit condition is satisfied (if `GOAL.md` exists).
7. Consecutive failure limit reached (default 3 - see Circuit Breakers).
8. Time limit exceeded (Overnight mode, default 4 hours - see Circuit Breakers).
9. Phantom completion limit reached (Overnight mode, default 2 - see Circuit Breakers).

---

## Circuit Breakers

Additional stop conditions for Autonomous and Overnight runs.

| Breaker | Default | Scope | Description |
|---------|---------|-------|-------------|
| Consecutive Failure Limit | 3 | All Autonomous | Stop if N tasks in a row are Blocked or rolled back. |
| Time Limit | 4 hours | Overnight only | Maximum wall-clock duration. |
| Phantom Completion Limit | 2 | Overnight only | Stop if N tasks claim changes git can't verify. |
| Compaction Interval | 8 cycles | Autonomous (10+ cycles) | Auto-compact every N cycles to prevent context degradation. |

> **Configurable:** Edit the defaults above. The orchestrator reads this table at the start of each `/run-project` invocation.

---

## Review Gates

| Task Type | Review Agents |
|-----------|--------------|
| Writing / content tasks | Orchestrator (self-review for clarity and beginner-friendliness) |
| Conceptual / framework tasks | Orchestrator (self-review for consistency and coherence) |
| Implementation / build tasks | Defined by routing rules or skills |

---

## Claude Code Permissions

> The framework's Autonomous mode and Claude Code's tool permissions are **two independent layers**. Even in Autonomous mode, CC may prompt for every file write or bash command.

**Why this matters:** If CC prompts on each tool call, Autonomous mode's multi-cycle runs are interrupted constantly, defeating the purpose.

**Recommended approach before entering Autonomous mode:**
1. When CC prompts for a tool permission, select **"Allow for this session"** for common operations (file writes, reads, bash commands in the project directory).
2. For persistent permissions, configure your `.claude/settings.json` allow list with patterns matching your project's file types.
3. The `/set-mode auto` command will remind you about this.

**Note:** This only affects CC-level permissions. The framework's own stop conditions, review gates, and circuit breakers still apply regardless of CC permission settings.

---

## Mode Escalation

At the start of each `/run-project` invocation, check if the current phase suggests a mode change. **Suggest, never force.**

| Current Phase | Current Mode | Suggestion |
|---------------|-------------|------------|
| `Building` | Semi-Autonomous | "Planning is complete and you're in Building phase. Consider `/set-mode auto` for faster progress through the task queue." |
| `Ready for Deploy` | Autonomous | "Build tasks are done. Consider `/set-mode semi` for more careful oversight during deployment." |
| `Deploying` | Autonomous | "Deployment in progress. Consider `/set-mode semi` to review each deploy step." |

If a suggestion applies: print it once at the top of the run output, then proceed normally. Do not re-suggest on consecutive runs if the user has not changed mode (they chose to keep their current mode).

---

## Execution Rule

After every cycle the orchestrator must:

1. Update `.claude/project/STATE.md` (Active Task, Outputs, Files Modified, Completed Tasks Log, Run Cycle).
2. Print an Execution Summary.
3. Evaluate stop conditions before starting the next cycle.

---

## Overnight Mode

Activated by `/overnight`. Uses Autonomous mode with these overrides:

| Setting | Overnight | Regular Autonomous |
|---------|----------|--------------------|
| Cycle limit | 50 | 5 |
| Time limit | 4 hours | None |
| Git verification | Enabled | Disabled |
| Inter-cycle commits | After each task | Not committed |
| Auto-compaction | Every 8 cycles | Disabled (too few cycles) |
| Planning review gate | Enabled (auto-proceed if flagged) | Enabled (stops if flagged) |
| Auto-learning | Automatic | Manual (/learn) |
| Morning summary | Generated | Not generated |

All standard stop conditions still apply. Overnight mode adds to them; it never removes safety.

---

## Parallel Execution

When the Next Task Queue contains 2+ independent tasks at the same priority level, the orchestrator can dispatch them simultaneously in separate git worktrees.

| Setting | Default | Description |
|---------|---------|-------------|
| Max Parallel Slots | 3 | Maximum concurrent agent dispatches per cycle |
| Parallel Enabled | Yes | Set to No to force sequential execution |
| Merge Conflict Limit | 2 | Stop if N+ merge conflicts in a single parallel cycle |

> **Configurable:** Edit the defaults above. The orchestrator reads this table at the start of each `/run-project` invocation.

### Parallel Circuit Breakers

| Breaker | Default | Description |
|---------|---------|-------------|
| Merge Conflict Limit | 2 | Stop if N+ tasks conflict during a single parallel merge cycle. Indicates tasks are not truly independent. |
| All-Slots-Failed | - | If every slot in a parallel dispatch fails or conflicts, count as 1 consecutive failure toward the standard Consecutive Failure Limit. |

### Parallel Preconditions

Before dispatching parallel agents, the orchestrator verifies:

1. `Parallel Enabled = Yes` in this table.
2. `git status --porcelain` returns empty (working tree is clean). If dirty: fall back to sequential mode with a warning.
3. At least 2 tasks in the highest-priority group are independent (different skill IDs, no shared file references, no dependency keywords).

If any precondition fails, the orchestrator falls back to standard sequential execution without error.

---

## Knowledge Loading

How the orchestrator loads agent and skill knowledge. Cortex MCP provides on-demand knowledge with smart context; file-based loading is the default and fallback.

| Setting | Value |
|---------|-------|
| Preferred Source | Auto (MCP if available, files as fallback) |
| MCP Server Name | cortex |
| Fallback to Files | Yes |

> **Configurable:** Set Preferred Source to `Files` to skip MCP detection entirely (useful for overnight stability). The orchestrator reads this table at startup.

---

## Self-Improvement

Agents evaluate their own work and capture feedback for continuous improvement. All improvements are proposals - never auto-applied.

| Setting | Default | Description |
|---------|---------|-------------|
| Self-Review Enabled | Yes | Agents self-evaluate after each task |
| Pattern Detection Threshold | 3 | Number of same-pattern feedback items before proposing improvement |
| Auto-Rework on NEEDS_WORK | Yes | Automatically re-queue tasks that fail review |
| Max Rework Attempts | 2 | Block task after N failed reviews (prevents infinite rework loops) |

> **Configurable:** Edit the defaults above. The orchestrator reads this table at the start of each `/run-project` invocation.

### Pattern Tags

Standard tags for categorizing feedback. Orchestrator picks the closest match.

| Tag | When to use |
|-----|------------|
| `missing-tests` | No tests written, or tests don't cover the change |
| `missing-error-handling` | No error handling for failure cases |
| `incomplete-implementation` | Task partially done, features missing |
| `wrong-api-usage` | Incorrect use of framework, library, or platform API |
| `security-gap` | Missing auth, validation, or secrets exposure |
| `style-violation` | Formatting, naming, or convention issues |
| `scope-creep` | Agent did more than asked |
| `missing-docs` | No documentation for new functionality |
| `other` | Doesn't fit above categories |

---

## Methodology Circuit Breakers

> Active ONLY when a methodology is explicitly set in STATE.md via `/methodology`.
> These compose with (do not replace) the global Circuit Breakers above.
> Evaluation order: global breakers first, then methodology breakers. Any single breaker firing stops execution.

| Methodology | Breaker | Type | Default | Status |
|-------------|---------|------|---------|--------|
| Kanban | WIP limit reached | Soft stop (selection gate) | WIP = 3 | **Enforced** — filter logic in orchestrator step 1.5 |
| Scrum | Sprint boundary reached | Hard stop | Active | **Enforced** — filter logic in orchestrator step 1.5 |
| Scrum | Sprint timebox expired | Hard stop | Active | **Enforced** — filter logic in orchestrator step 1.5 |
| FDD | Feature group boundary | Hard stop | Active | **Enforced** — filter logic in orchestrator step 1.5 |

> **Kanban WIP:** Set via `/methodology kanban --wip N`. Enforced in orchestrator step 1.5.
> **Scrum:** Sprint boundary and timebox breakers enforced in orchestrator step 1.5. Sprint metadata set via `/methodology scrum`.
> **FDD:** Feature group boundary enforced in orchestrator step 1.5. Feature metadata set via `/methodology fdd`.

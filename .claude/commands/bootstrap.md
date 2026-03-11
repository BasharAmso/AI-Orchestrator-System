# Command: /bootstrap

> **Deprecated:** Use `/setup` instead, which combines `/bootstrap` and `/init-project` into a single command.

> Initialize or verify the AI Builder System project structure. Safe to run multiple times (idempotent).

---

## Procedure

### Step 1: Verify Directory Structure

Ensure these directories exist (create if missing):

```
.claude/
  agents/
  commands/
  rules/
  skills/
  project/
    knowledge/
```

### Step 2: Verify and Create Required Files

Check that each required file exists. If a runtime file is missing, **create it from the clean template** below. If a framework file (agent, command, rule, skill) is missing, report it as `MISSING` — those require the full framework overlay, not bootstrap.

#### Framework Files (verify only — do not create)

| File | Required |
|------|----------|
| `.claude/CLAUDE.md` | Yes |
| `.claude/agents/orchestrator.md` | Yes |
| `.claude/commands/run-project.md` | Yes |
| `.claude/commands/trigger.md` | Yes |
| `.claude/commands/fix-registry.md` | Yes |
| `.claude/commands/bootstrap.md` | Yes |
| `.claude/rules/orchestration-routing.md` | Yes |
| `.claude/rules/event-hooks.md` | Yes |
| `.claude/rules/knowledge-policy.md` | Yes |
| `.claude/rules/context-policy.md` | Yes |
| `.claude/skills/REGISTRY.md` | Yes |
| `.claudeignore` | Yes |

#### Runtime Files (create from template if missing)

| File | Required |
|------|----------|
| `.claude/project/STATE.md` | Yes |
| `.claude/project/EVENTS.md` | Yes |
| `.claude/project/RUN_POLICY.md` | Yes |
| `.claude/project/knowledge/DECISIONS.md` | Yes |
| `.claude/project/knowledge/RESEARCH.md` | Yes |
| `.claude/project/knowledge/GLOSSARY.md` | Yes |
| `.claude/project/knowledge/OPEN_QUESTIONS.md` | Yes |

If a runtime file is missing, create it using the corresponding clean template from the **Runtime File Templates** section below. Report each created file as `CREATED`.

### Step 3: Initialize REGISTRY

If `.claude/skills/REGISTRY.md` is missing or contains only `(none)` placeholders:
- Run the `/fix-registry` procedure to scan skill files and populate the registry.

### Step 4: Print "Project Ready" Summary

```
## Project Ready

- **Current Mode:** [from STATE.md, e.g., Semi-Autonomous]
- **Unprocessed Events:** [count from EVENTS.md]
- **Skills Registered:** [count from REGISTRY.md]
- **Files Verified:** [pass count] / [total count]
- **Files Created:** [list, or "None"]
- **Missing Files:** [list, or "None"]

### Recommended Next Actions

1. [First recommended action based on project state]
2. [Second recommended action]
3. [Third recommended action]
```

Default recommended actions for a fresh project:
1. Run `/trigger` with type `IDEA_CAPTURED` to describe your project idea.
2. Run `/run-project` to process the event and generate a plan.
3. Review the generated PRD and task queue, then run `/run-project` again.

---

## Runtime File Templates

### STATE.md Template

```markdown
# Project State

> Single source of truth for the current project status. Updated by every action.

---

## Current Mode

| Mode | Description | Active |
|------|-------------|--------|
| Safe | Propose only, no file changes | |
| Semi-Autonomous | Execute one unit of work, then stop for review | **YES** |
| Autonomous | Execute up to N units (see RUN_POLICY.md), then stop | |

---

## Current Phase

`Not Started`

---

## Active Task

| Field | Value |
|-------|-------|
| ID | — |
| Description | — |
| Owner Agent | — |
| Started | — |
| Status | — |

### Status Lifecycle

| Status | Meaning |
|--------|---------|
| In Progress | Work is actively being done |
| Review | Work is done, awaiting review |
| Completed | Reviewed and accepted |
| Blocked | Cannot proceed; see Blockers/Risks |

> **Lifecycle Rule:** When promoting a task into Active Task, set Status = `In Progress` and Started = current timestamp.

### Definition of Done

- [ ] *(populated per task)*

### Inputs / Context Used

*(none)*

### Outputs Produced

*(none)*

---

## Files Modified (Last Task)

*(none)*

---

## Blockers / Risks

*(none)*

---

## Next Task Queue

| # | Task | Priority |
|---|------|----------|
| 1 | Run /bootstrap to initialize the project | High |
| 2 | Emit an IDEA_CAPTURED event with the project concept | High |
| 3 | Run /run-project to process the first event | Medium |

---

## Completed Tasks Log

| ID | Description | Completed | Skill Used |
|----|-------------|-----------|------------|
| — | *(none yet)* | — | — |

---

## Run Cycle

| Field | Value |
|-------|-------|
| Current Cycle | 0 |
| Max Cycles This Run | 1 |
| Last Run Status | Idle |

> **Mode mapping:** Safe = 0 cycles, Semi-Autonomous = 1 cycle, Autonomous = cycle limit from RUN_POLICY.md (default 10).

---

## Goal Alignment

| Field | Value |
|-------|-------|
| Current Goal | — |
| Current Milestone | — |
| Last Step Advanced | — |
```

### EVENTS.md Template

```markdown
# Events Log

> Events represent things that happened or need to happen. They are processed FIFO (oldest first).

---

## Event Format

EVT-XXXX | <TYPE> | <Description> | <Source> | <Timestamp> | <Priority>

- **EVT-XXXX** — Auto-incremented event ID (e.g., EVT-0001)
- **TYPE** — Event type matching a skill trigger or routing rule
- **Description** — Brief summary of what happened or what needs to happen
- **Source** — Who/what created the event (user, agent, system)
- **Timestamp** — When the event was created
- **Priority** — Optional: `high`, `normal`, or `low` (default: `normal` if omitted)

---

## Unprocessed Events

*(none)*

---

## Processed Events

*(none)*
```

### RUN_POLICY.md Template

```markdown
# Run Policy

> Defines execution boundaries for the orchestrator.

---

## Default Mode

Semi-Autonomous

---

## Cycle Limits

| Mode | Cycles per /run-project |
|------|------------------------|
| Safe | 0 (proposal only) |
| Semi-Autonomous | 1 |
| Autonomous | 10 |

> **Configurable:** To change the Autonomous cycle limit, edit the value above. The orchestrator reads this table at the start of each `/run-project` invocation. Default: 10.

---

## Stop Conditions

The orchestrator must stop immediately if any of the following occur:

1. The user says stop.
2. The current task becomes Blocked.
3. A single file modification exceeds 500 lines.
4. The Next Task Queue becomes empty and no next tasks can be proposed.
5. A required artifact is missing and cannot be created safely.
6. The project goal exit condition is satisfied (if GOAL.md exists).

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

If a suggestion applies: print it once at the top of the run output, then proceed normally. Do not re-suggest on consecutive runs if the user has not changed mode.

---

## Execution Rule

After every cycle the orchestrator must:

1. Update `.claude/project/STATE.md` (Active Task, Outputs, Files Modified, Completed Tasks Log, Run Cycle).
2. Print an Execution Summary.
3. Evaluate stop conditions before starting the next cycle.
```

### DECISIONS.md Template

```markdown
# Decisions Log

> Record architectural and design decisions here.

---

## Decision Template

### DEC-XXXX: [Title]

- **Status:** Proposed | Accepted | Superseded
- **Date:** YYYY-MM-DD
- **Context:** Why this decision was needed
- **Decision:** What was decided
- **Consequences:** What follows from this decision

---

*(No decisions recorded yet.)*
```

### RESEARCH.md Template

```markdown
# Research Notes

> Store research findings, references, and external knowledge here.

---

## Research Entry Template

### RES-XXXX: [Title]

- **Date:** YYYY-MM-DD
- **Source:** URL, book, or reference
- **Summary:** Key findings in 2-3 sentences
- **Relevance:** How this applies to the current project
- **Status:** Active | Outdated | Unverified

---

*(No research entries yet.)*
```

### GLOSSARY.md Template

```markdown
# Glossary

> Definitions of key terms. Keep entries beginner-friendly.

---

| Term | Definition |
|------|------------|
| **Orchestrator** | The central agent that runs the system. It reads STATE, processes events, routes tasks to skills, and updates everything. |
| **Agent** | A specialized role that performs a specific type of work (e.g., planning, building, reviewing). Defined in .claude/agents/. |
| **Skill** | A reusable procedure for a specific task. Skills have triggers, inputs, outputs, and a definition of done. They live in .claude/skills/. |
| **Event** | Something that happened or needs to happen, logged in EVENTS.md. Events trigger skills. |
| **State** | The current status of the project, tracked in STATE.md. Includes the active task, mode, blockers, and history. |
| **SDLC** | Software Development Life Cycle. The phases a project goes through: planning, building, testing, deploying, maintaining. |
| **PRD** | Product Requirements Document. Describes what you're building, who it's for, and what it should do. |
```

### OPEN_QUESTIONS.md Template

```markdown
# Open Questions

> Unresolved questions and uncertainties. Review these when making decisions. Close them when answered.

---

## Question Template

### OQ-XXXX: [Question]

- **Status:** Open | Resolved | Deferred
- **Date Raised:** YYYY-MM-DD
- **Context:** Why this question matters
- **Resolution:** (filled in when resolved)

---

*(No open questions yet.)*
```

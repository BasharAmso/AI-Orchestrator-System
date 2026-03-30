# Project State

> Single source of truth for the current project status. Updated by every action.

---

## Framework Mode

`Full Planning`

> **Full Planning** — Full planning pipeline: charter -> PRD -> architecture -> design -> tasks -> build. Best for complex projects.
> **Quick Start** — Scaffold first, plan as you go: idea -> immediate app scaffold -> build features one at a time. Best for learning and simple projects.
> Set during `/start`. Change with `/set-mode quick-start` or `/set-mode full-planning`.

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

## Parallel Task Slots

| Slot | Task ID | Description | Owner Agent | Worktree Branch | Status | Started |
|------|---------|-------------|-------------|-----------------|--------|---------|
| — | — | — | — | — | — | — |

> Status values: Dispatched | Completed | Failed | Merged | Conflict
> Empty table (single "—" row) = parallel mode not active this cycle.
> Max slots governed by RUN_POLICY.md (default 3).

---

## Files Modified (Last Task)

*(none)*

---

## Blockers / Risks

*(none)*

---

## Failed Approaches

| Approach | Why It Failed | Date |
|----------|---------------|------|
| *(none yet)* | — | — |

---

## Next Task Queue

| # | Task | Priority | Skill |
|---|------|----------|-------|
| — | *(none yet)* | — | — |

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
| Last Run Status | — |

| Consecutive Failures | 0 |
| Phantom Completions | 0 |
| Run Type | Standard |
| Max Parallel Slots | 3 |
| Parallel Merges Completed | 0 |
| Parallel Merge Conflicts | 0 |

> **Mode mapping:** Safe = 0 cycles, Semi-Autonomous = 1 cycle, Autonomous = cycle limit from RUN_POLICY.md (default 10).

---

## Session Lock

| Field | Value |
|-------|-------|
| Session Started | — |
| Last Activity | — |
| Checkpointed | — |

> **How it works:** When a session starts, the orchestrator writes the current timestamp to `Session Started` and sets `Checkpointed = No`. When `/save` runs, it sets `Checkpointed = Yes`. On the next session start, if `Checkpointed = No` and `Session Started` has a value, the system warns that the previous session may not have saved all progress.

---

## Goal Alignment

| Field | Value |
|-------|-------|
| Current Goal | — |
| Current Milestone | — |
| Last Step Advanced | — |

# Project State

> Single source of truth for the current project status. Updated by every action.

---

## Framework Mode

`Full Planning`

> **Full Planning** — Full planning pipeline: charter → PRD → architecture → design → tasks → build. Best for complex projects.
> **Quick Start** — Scaffold first, plan as you go: idea → immediate app scaffold → build features one at a time. Best for learning and simple projects.
> Set during `/start`. Change with `/set-mode quick-start` or `/set-mode full-planning`.

---

## Current Mode

| Mode | Description | Active |
|------|-------------|--------|
| Safe | Propose only, no file changes | |
| Semi-Autonomous | Execute one unit of work, then stop for review | |
| Autonomous | Execute up to N units (see RUN_POLICY.md), then stop | **YES (Overnight)** |

---

## Current Phase

`Not Started`

---

## Active Task

| Field | Value |
|-------|-------|
| Field | Value |
|-------|-------|
| Field | Value |
|-------|-------|
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
| 1 | Submit to awesome-claude-code lists (3 PRs) | Medium | — |

---

## Completed Tasks Log

| ID | Description | Completed | Skill Used |
|----|-------------|-----------|------------|
| T1 | Design parallel agent dispatch for orchestrator (worktree-based, state-tracked) | 2026-03-27 | — |
| T2 | Implement parallel execution in orchestrator.md dispatch chain | 2026-03-27 | — |
| T3 | Add parallel task tracking to STATE.md (concurrent task slots, merge status) | 2026-03-27 | — |
| T4 | Build merge conflict resolution for parallel worktree results | 2026-03-27 | — |
| T5 | Create one-command install experience (npx create-bashi) | 2026-03-27 | — |
| T6 | Update README with install command, parallel execution, and demo instructions | 2026-03-27 | SKL-0024 |
| T7 | Design agent self-improvement system (self-review, cross-agent feedback, pattern detection) | 2026-03-28 | — |
| T8 | Implement agent self-review step in orchestrator (step 5.6) | 2026-03-28 | — |
| T9 | Implement cross-agent feedback capture with auto-rework (step 5.7) | 2026-03-28 | — |
| T10 | Add pattern detection with improvement proposals (step 5.8) | 2026-03-28 | — |
| T11 | Add global user profile to framework (setup.md, start.md, orchestrator, coach) | 2026-03-28 | — |
| T12 | Implement friction reduction as cross-cutting concern (SKL-0037 + 8 file updates) | 2026-03-28 | — |
| T13 | npm publish create-bashi@1.9.0 to npm registry | 2026-03-29 | — |
| T14 | Git commit + push v1.9.0 to GitHub | 2026-03-29 | — |
| T15 | Growth skill Premium Visual Tier (glassmorphism, gradients, animations) | 2026-03-29 | SKL-0013 |
| T16 | AI-Memory creation in /setup (Step 2.7 + 3 seed files + session-start hook update) | 2026-03-29 | — |
| T17 | Fix-registry and doctor path resolution for custom-skills | 2026-03-29 | — |
| T18 | Framework synced to Frame_Brain, Dolce Stella Events, Dario Mathias, Ritas, Grace's Unicorn Game | 2026-03-29 | — |
| T19 | Two-mode knowledge loading plan (100 reviews, approved) | 2026-03-30 | — |
| T20 | Cortex MCP pre-requisites: re-number IDs, add owner field, sync content, rebuild indexes | 2026-03-30 | — |
| T21 | Implement two-mode knowledge loading in orchestrator.md | 2026-03-30 | — |
| T22 | Update doctor, CLAUDE.md, RUN_POLICY, session-start, pre-compact, start, setup for MCP mode | 2026-03-30 | — |
| T23 | README rewrite for discovery and conversion | 2026-03-30 | SKL-0024 |
| T25 | Game-dev skill (SKL-0038) -- adventure, sandbox, action, educational modes | 2026-03-30 | — |

---

## Run Cycle

| Field | Value |
|-------|-------|
| Current Cycle | 5 |
| Max Cycles This Run | 50 |
| Last Run Status | Completed |
| Knowledge Source | Files |
| Time Limit Hours | 4 |

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
| Session Started | 2026-03-30 01:15 |
| Last Activity | 2026-03-30 |
| Checkpointed | No |


> **How it works:** When a session starts, the orchestrator writes the current timestamp to `Session Started` and sets `Checkpointed = No`. When `/save` runs, it sets `Checkpointed = Yes`. On the next session start, if `Checkpointed = No` and `Session Started` has a value, the system warns that the previous session may not have saved all progress.

---

## Goal Alignment

| Field | Value |
|-------|-------|
| Current Goal | — |
| Current Milestone | — |
| Last Step Advanced | — |

# Methodology Dispatch Policies

> Defines how each methodology modifies the orchestrator's task selection logic.
> Read by orchestrator.md step 1.5 ("Apply Methodology Filter").
> This file is a rules file — auto-loaded by Claude Code when methodology-aware dispatch is active.

---

## Policy Lookup

The orchestrator reads `## Methodology` from STATE.md to determine the active methodology. If the section is absent, the methodology is **Waterfall** (default).

| Methodology | Selection Policy | Stop Behavior |
|-------------|-----------------|---------------|
| Waterfall | No filter — pass through to step 2 | No methodology-specific stops |
| Kanban | Priority-pull with WIP gate | Soft stop when WIP limit reached |
| Scrum | Sprint-scoped selection | Hard stop at sprint boundary |
| FDD | Feature-group-scoped selection | Hard stop at feature boundary |

---

## Waterfall Policy (Default)

**Selection:** Sequential. Pick the next task from the queue in row order. No reordering, no batching, no limits.

**Gating:** None. The methodology filter is a no-op — all tasks are eligible.

**Circuit Breakers:** None beyond global breakers (consecutive failures, time limit, phantom completions).

**This is identical to the pre-methodology dispatch behavior.** Existing projects with no `## Methodology` section run this policy implicitly.

---

## Kanban Policy

**Selection:** Priority-pull. Always select the highest-priority eligible task regardless of queue position. Within the same priority level, respect queue order (FIFO).

**Gating:** WIP limit. Before selecting a new task, count all tasks with Status = `In Progress` (including parallel task slots with Status = `Dispatched`). If count >= WIP Limit (from STATE.md `> WIP Limit: N`), block selection.

**When blocked:** Do not start a new cycle. Print: `"WIP limit reached ([count]/[limit]). Complete an in-progress task before starting new work."` Set `Last Run Status = WIP Limit`.

**Circuit Breakers:** WIP limit is a selection gate (step 1.5), not a between-cycles breaker.

### Kanban WIP Counting Rules

WIP count = number of tasks actively consuming work capacity. Two sources:

1. **Active Task** (STATE.md `## Active Task`): counts as 1 if Status = `In Progress`. The Active Task status lifecycle is: `In Progress | Review | Completed | Blocked` — only `In Progress` counts toward WIP.
2. **Parallel Task Slots** (STATE.md `## Parallel Task Slots`): each slot with Status = `Dispatched` counts as 1. Parallel slot statuses are: `Dispatched | Completed | Failed | Merged | Conflict` — only `Dispatched` counts toward WIP.

The WIP count does NOT include:
- Active Task with Status = `Review`, `Completed`, or `Blocked`
- Parallel slots with Status = `Completed`, `Failed`, `Merged`, or `Conflict`
- Queued tasks in the Next Task Queue (not yet promoted)

### Kanban Priority-Pull Ordering

When selecting the next task from the Next Task Queue:
1. Sort eligible tasks by Priority: High > Medium > Low
2. Within the same priority level, respect queue row order (FIFO)
3. This overrides the default sequential (row-order) selection used by Waterfall

### Migration: Switching to Kanban

**From Waterfall:** No structural change. Set WIP Limit (default 3 or user-specified via `--wip N`). Tasks remain in queue order but selection becomes priority-pull.

**From Scrum:** Dissolve sprint boundaries. All tasks from the current sprint and backlog merge into a single flat queue, preserving their existing priority values. Remove sprint metadata from STATE.md (Sprint number, Sprint End Date). SPRINT.md is preserved as history but no longer consulted by the dispatch filter. Set WIP Limit.

**From FDD:** Dissolve feature groups. All tasks flatten into a single queue. Remove the `Feature` column from the Next Task Queue. Set WIP Limit.

### Migration: Switching away from Kanban

**To Waterfall:** Remove `> WIP Limit: N` from STATE.md. Tasks return to sequential row-order selection.

**To Scrum:** Remove `> WIP Limit: N`. Prompt user for sprint sizing (tasks per sprint, sprint duration). Create SPRINT.md with Sprint 1 from the top of the queue. Add sprint metadata to STATE.md.

---

## Scrum Policy

**Selection:** Sprint-scoped. Only select tasks assigned to the current sprint. Sprint assignment is determined by:
1. A `Sprint` column in the Next Task Queue (e.g., `S1`, `S2`). Tasks without a sprint tag or with a different sprint tag are skipped.
2. If no `Sprint` column exists, fall back to the task list in SPRINT.md under the current sprint heading.

Tasks not in the current sprint are skipped during step 1.5. Within the sprint, respect queue row order (FIFO).

**Sprint boundary:** When all tasks tagged with the current sprint are completed (Status = `Completed` in the Completed Tasks Log or no remaining sprint-tagged tasks in the Next Task Queue), emit `SPRINT_COMPLETE` event to EVENTS.md and stop. Do not automatically advance to the next sprint — the user or `/methodology sprint-next` must explicitly start the next sprint.

**Sprint timebox:** At the start of each cycle, check `> Sprint End Date: YYYY-MM-DD` in STATE.md. If today's date is past the Sprint End Date, emit `SPRINT_TIMEBOX_EXPIRED` event and stop, even if sprint tasks remain incomplete. Incomplete sprint tasks stay in the queue for the next sprint.

**Circuit Breakers:** Sprint boundary reached (hard stop), sprint timebox expired (hard stop). Both compose with global breakers via AND-logic.

**Missing sprint data at dispatch time:** If Scrum is the active methodology but no sprint assignment source exists (no `Sprint` column in Next Task Queue AND no SPRINT.md), the orchestrator must not silently fall through to Waterfall. Instead:
1. Print: `"Scrum is active but no sprint assignments found. Run /methodology scrum to set up Sprint 1, or /methodology waterfall to switch back."`
2. Set `Last Run Status = Missing Sprint Data` and stop the cycle.

This prevents the filter from having nothing to filter on while Scrum is nominally active.

### Scrum Sprint Metadata

When Scrum is active, STATE.md contains these fields below the Methodology table:

```markdown
> Sprint: 1
> Sprint End Date: 2026-04-26
> Sprint Goal: [one-line goal from user]
```

SPRINT.md (created by the project-manager agent or during migration) contains the full sprint plan:
- Sprint number, goal, start/end dates
- Task list with IDs mapping to Next Task Queue entries
- Velocity data from prior sprints (if available)

### Scrum Sprint Column Format

When Scrum is active, the Next Task Queue gains an optional `Sprint` column:

```markdown
| # | Task | Priority | Skill | Sprint |
|---|------|----------|-------|--------|
| 1 | Build login screen | High | SKL-0005 | S1 |
| 2 | Add OAuth provider | High | SKL-0010 | S1 |
| 3 | Write API tests | Medium | SKL-0017 | S2 |
| 4 | Add analytics | Low | SKL-0012 | — |
```

Tasks with `—` in the Sprint column are backlog items — not assigned to any sprint.

### Migration: Switching to Scrum

**From Waterfall:**
1. Ask user: "How many tasks per sprint?" (suggest default based on completed task count / number of weeks if velocity data exists, otherwise suggest 5).
2. Ask user: "Sprint duration in weeks?" (default: 2).
3. Take the top N tasks from the queue and assign them to Sprint 1.
4. Add `Sprint` column to Next Task Queue. Mark Sprint 1 tasks with `S1`, remaining tasks with `—`.
5. Create or update SPRINT.md with Sprint 1 metadata.
6. Add sprint metadata to STATE.md: `> Sprint: 1`, `> Sprint End Date: [today + duration]`, `> Sprint Goal: [ask user]`.

**From Kanban:**
1. Remove `> WIP Limit: N` from STATE.md.
2. Follow the same sprint sizing prompts as Waterfall → Scrum (steps 1-6 above).

**From FDD:** Blocked — must route through Waterfall first.

### Migration: Switching away from Scrum

**To Waterfall:**
1. Remove sprint metadata from STATE.md (`> Sprint:`, `> Sprint End Date:`, `> Sprint Goal:`).
2. Remove the `Sprint` column from the Next Task Queue (all tasks become unsorted backlog).
3. SPRINT.md is preserved as history but no longer consulted.

**To Kanban:**
1. Read all sprint-assigned tasks and backlog tasks.
2. Merge into a single flat queue preserving priority and order.
3. Remove sprint metadata and `Sprint` column.
4. Add `> WIP Limit: [N]` (default 3, or ask user).
5. SPRINT.md preserved as history.

**To FDD:** Blocked — must route through Waterfall first.

---

## FDD Policy

> Implemented in Phase 2.

**Selection:** Feature-group-scoped. Tasks are organized into feature groups (identified by a `Feature` column in the Next Task Queue). Select only from the current feature group. Within a group, respect queue order.

**Feature boundary:** When all tasks in the current feature group are completed, emit `FEATURE_COMPLETE` event and stop for a feature review gate before proceeding to the next group.

**Circuit Breakers:** Feature group boundary (hard stop). Composes with global breakers via AND-logic.

---

## Validation Rules

These are enforced by the `/methodology` command and by the orchestrator at dispatch time:

| Rule | Enforced By | Behavior on Violation |
|------|-------------|----------------------|
| WIP limit must be >= 1 | `/methodology` command | Reject with error message |
| Methodology value must be one of: Waterfall, Kanban, Scrum, FDD | Orchestrator step 1.5 | Fall back to Waterfall with warning |
| FDD ↔ Scrum direct switch blocked | `/methodology` command | Reject with migration instructions |
| Sprint metadata required for Scrum | `/doctor` (Phase 3) | Flag as error |

---

## Composition with Global Circuit Breakers

Methodology-specific breakers are evaluated AFTER global breakers. The evaluation order in the orchestrator's Between-Cycles check is:

1. Global breakers: consecutive failure limit, time limit, phantom completion limit
2. Methodology breakers: sprint boundary, WIP limit, feature group boundary

**Any single breaker firing stops execution.** Methodology breakers only ADD restrictions — they never relax or override global breakers.

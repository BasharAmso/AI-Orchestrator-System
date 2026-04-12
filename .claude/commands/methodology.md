# Command: /methodology

> Switch the project's dispatch methodology. Updates STATE.md and validates preconditions.

---

## Usage

```
/methodology <methodology>
```

Where `<methodology>` is one of:

- `waterfall` — Sequential task processing, no batching or limits (default)
- `kanban` — Continuous flow with WIP limits and priority-pull dispatch
- `scrum` — Sprint-based dispatch with timebox boundaries and ceremony injection
- `fdd` — Feature-driven development with feature-group-first decomposition

---

## Procedure

### Step 1: Validate Argument

If `<methodology>` is not one of `waterfall`, `kanban`, `scrum`, `fdd`:
- Print: `"Invalid methodology. Use: waterfall, kanban, scrum, or fdd."`
- Stop.

### Step 2: Read Current State

Read `.claude/project/STATE.md` to determine:
- Current Methodology (from `## Methodology` section, default `Waterfall` if section is absent)
- Active Task status (is anything `In Progress`?)

### Step 3: Check Blocked Transitions

Some methodology transitions are blocked because they have incompatible task grouping structures:

| From | To | Blocked? | Message |
|------|----|----------|---------|
| FDD | Scrum | Yes | "Cannot switch directly from FDD to Scrum. These methodologies use incompatible task grouping. Switch to Waterfall first to flatten the queue, then to Scrum:\n  /methodology waterfall\n  /methodology scrum" |
| Scrum | FDD | Yes | "Cannot switch directly from Scrum to FDD. These methodologies use incompatible task grouping. Switch to Waterfall first to flatten the queue, then to FDD:\n  /methodology waterfall\n  /methodology fdd" |

If the transition is blocked: print the message and stop.

### Step 4: Check Preconditions

Evaluate these warnings (warn but do not block):

| Condition | Message |
|-----------|---------|
| Active Task has Status = `In Progress` | "A task is currently in progress. It will complete under the current methodology's rules. The new methodology takes effect on the next dispatch cycle." |
| Target is same as current | "Already using [methodology]. No change needed." (then stop) |

If a warning fires: print the warning, then proceed with the switch.

### Step 5: Validate Methodology-Specific Parameters

**Kanban:**
- If `--wip` flag is provided, validate that the value is a positive integer (>= 1).
- If `--wip 0` or a non-positive value: print `"WIP limit must be at least 1."` and stop.
- If no `--wip` flag: default WIP limit is 3.

**Scrum:**
- Ask user: "How many tasks per sprint?" Suggest a default based on completed task velocity (Completed Tasks Log count / weeks elapsed) if available, otherwise suggest 5.
- Ask user: "Sprint duration in weeks?" Default: 2.
- Ask user: "Sprint goal? (one line describing what this sprint delivers)" No default — user must provide.
- If the Next Task Queue is empty: print `"No tasks in queue. Add tasks first, then run /methodology scrum."` and stop.
- Store the answers as `sprint_size`, `sprint_duration`, `sprint_goal` for use in Step 6b.

**FDD:**
- If the Next Task Queue is empty: print `"No tasks in queue. Add tasks first, then run /methodology fdd."` and stop.
- Present the task queue to the user and ask: "Group these tasks into features. A feature is a user-visible capability (e.g., 'User Authentication', 'Dashboard', 'Export')."
- If tasks contain file path hints (e.g., `src/auth/`, `src/dashboard/`), suggest auto-grouping by path prefix. Ask user to confirm or override.
- Record the feature assignments as `feature_groups` (a mapping of feature name → task numbers) for use in Step 6b.

### Step 6: Update STATE.md

#### 6a: Create or update the `## Methodology` section

If `## Methodology` does not exist in STATE.md, insert it after `## Framework Mode` and before `## Current Mode`:

```markdown
---

## Methodology

| Methodology | Description | Active |
|-------------|-------------|--------|
| Waterfall | Sequential task processing, no batching or limits | |
| Kanban | Continuous flow with WIP limits, priority-pull dispatch | |
| Scrum | Sprint-based dispatch with timebox boundaries | |
| FDD | Feature-driven, feature-group-first decomposition | |
```

Then set `**YES**` on the target methodology row.

If `## Methodology` already exists:
- Remove `**YES**` from the currently active row.
- Add `**YES**` to the target methodology row.

#### 6b: Set methodology-specific fields

**Kanban:** Add or update a `WIP Limit` field below the methodology table:
```markdown
> WIP Limit: 3
```

**Scrum:** Perform sprint setup using the values collected in Step 5:

1. Add `Sprint` column to the Next Task Queue if not present. Take the top `sprint_size` tasks and mark them `S1`. Mark remaining tasks `—` (backlog).
2. Add sprint metadata below the Methodology table:
   ```markdown
   > Sprint: 1
   > Sprint End Date: [today + sprint_duration weeks, formatted YYYY-MM-DD]
   > Sprint Goal: [sprint_goal from Step 5]
   ```
3. Create `.claude/project/knowledge/SPRINT.md` with the sprint plan:
   ```markdown
   # Sprint Plan

   ## Sprint 1

   - **Goal:** [sprint_goal]
   - **Start:** [today, YYYY-MM-DD]
   - **End:** [today + sprint_duration weeks, YYYY-MM-DD]
   - **Tasks:** [list the S1-tagged task descriptions from Next Task Queue]

   ## Velocity

   *(no data yet — populated after first sprint completes)*
   ```

**FDD:** Perform feature setup using the assignments collected in Step 5:

1. Add `Feature` column to the Next Task Queue if not present. Tag each task with its feature group (`F1`, `F2`, etc.) per the user's assignments. Ungrouped tasks get `—`.
2. Add feature metadata below the Methodology table:
   ```markdown
   > Current Feature: F1
   > Feature Count: [number of feature groups]
   ```
3. Create `.claude/project/knowledge/FEATURES.md` with the feature plan:
   ```markdown
   # Feature Plan

   ## F1: [Feature Name]
   - **Description:** [one-line description]
   - **Tasks:** [list of F1-tagged task descriptions from Next Task Queue]
   - **Review:** Pending

   ## F2: [Feature Name]
   - **Description:** [one-line description]
   - **Tasks:** [list of F2-tagged task descriptions]
   - **Review:** Pending

   ## Ungrouped Backlog
   - [any tasks tagged —]
   ```

**Waterfall:** Remove any methodology-specific fields (WIP Limit, Sprint metadata, Feature metadata) if present. Remove `Sprint` or `Feature` column from Next Task Queue if present.

#### 6c: Update Methodology History

If `## Methodology History` does not exist, create it at the bottom of STATE.md:

```markdown
---

## Methodology History

| Date | From | To | Reason |
|------|------|----|--------|
```

Append a row with the current date, old methodology, new methodology, and `"User switched via /methodology"`.

### Step 7: Print Confirmation

```
Methodology switched: [Old] → [New]

[Methodology-specific message]
```

Where methodology-specific messages are:

- **Waterfall:** "Tasks will be processed sequentially from the queue. No batching or WIP constraints."
- **Kanban:** "Dispatch uses priority-pull with a WIP limit of [N]. The orchestrator will block new task selection when [N] tasks are in progress."
- **Scrum:** "Sprint-based dispatch is active. The project-manager will prompt for sprint planning on the next /run-project cycle."
- **FDD:** "Feature-driven dispatch is active. Tasks will be grouped by feature and processed feature-by-feature."

---

## Migration Logic

### Kanban → Waterfall

1. Remove `> WIP Limit: N` line from STATE.md (below the Methodology table).
2. Tasks remain in queue as-is. Selection reverts to sequential row-order.

### Waterfall → Kanban

1. No structural change to the task queue.
2. Add `> WIP Limit: [N]` below the Methodology table (default 3, or user-specified via `--wip`).
3. Selection switches to priority-pull.

### Scrum → Kanban

1. Read SPRINT.md to find all sprint-assigned tasks.
2. Merge sprint tasks and backlog into a single flat Next Task Queue, preserving priority values and original order within each priority level.
3. Remove sprint metadata from STATE.md (Sprint number, Sprint End Date, Sprint Goal — if present).
4. Remove `Sprint` column from Next Task Queue table (if present).
5. SPRINT.md is NOT deleted (preserves history) but is no longer consulted by the dispatch filter.
6. Add `> WIP Limit: [N]` (default 3, or ask user).
7. Print: `"Sprint boundaries dissolved. [N] tasks merged into prioritized queue. WIP limit set to [limit]."`

### Kanban → Scrum

1. Remove `> WIP Limit: N` from STATE.md.
2. Ask user: "How many tasks per sprint?" (suggest default based on completed task velocity if available).
3. Ask user: "Sprint duration in weeks?" (default: 2).
4. Take the top N tasks from the queue and assign them to Sprint 1.
5. Create or update SPRINT.md with Sprint 1 metadata (goal, start date, end date, task list).
6. Add `Sprint` column to Next Task Queue if not present. Mark Sprint 1 tasks with `S1`.
7. Add sprint metadata to STATE.md: `> Sprint: 1` and `> Sprint End Date: [calculated]`.
8. Print: `"Sprint 1 created with [N] tasks. Sprint ends [date]."`

### FDD → Kanban

1. Dissolve feature groups. Remove the `Feature` column from Next Task Queue.
2. Tasks flatten into a single queue, preserving priority and order.
3. Add `> WIP Limit: [N]` (default 3, or ask user).
4. Print: `"Feature groups dissolved. [N] tasks in prioritized queue. WIP limit set to [limit]."`

### Waterfall → FDD

1. Follow the feature decomposition prompts from Step 5 (FDD section).
2. Apply Step 6b (FDD section): add Feature column, metadata, and create FEATURES.md.

### Kanban → FDD

1. Remove `> WIP Limit: N` from STATE.md.
2. Follow the feature decomposition prompts from Step 5 (FDD section).
3. Apply Step 6b (FDD section): add Feature column, metadata, and create FEATURES.md.
4. Print: `"WIP limit removed. [N] tasks grouped into [M] features. Starting with F1."`

### FDD → Waterfall

1. Remove feature metadata from STATE.md (`> Current Feature:`, `> Feature Count:`).
2. Remove the `Feature` column from the Next Task Queue (all tasks become flat backlog).
3. FEATURES.md is preserved as history but no longer consulted.

### FDD ↔ Scrum

Blocked. See Step 3 (blocked transitions).

---

## Examples

```
/methodology kanban --wip 5
/methodology scrum
/methodology waterfall
/methodology fdd
```

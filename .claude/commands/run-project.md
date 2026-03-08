# Command: /run-project

> Execute one or more orchestration cycles, respecting the current mode and run policy. This is the main entry point for project execution.

---

## Procedure

### Step 1: Load State and Policy

Read `.claude/project/STATE.md` to determine:
- Current Mode (Safe / Semi-Autonomous / Autonomous)
- Active Task (if any is already in progress)
- Next Task Queue
- Run Cycle fields

Read `.claude/project/RUN_POLICY.md` to determine:
- Cycle limit for the current mode
- Stop conditions
- Review gates

Read `.claude/project/EVENTS.md` to check for unprocessed events.

Initialize the run:
- Set Current Cycle = 0 in .claude/project/STATE.md Run Cycle section.
- Set Max Cycles This Run per mode (Safe = 0, Semi-Autonomous = 1, Autonomous = 5).
- Set Last Run Status = `Running`.

### Step 2: Determine What to Process

**Priority order:**
1. If there is an **Active Task** with Status = `In Progress`: resume it.
2. If there are **unprocessed events**: select the oldest (FIFO).
3. If no events: **promote the next task** from the Next Task Queue to Active Task.
4. If nothing to do: print "Nothing to process. Emit an event or add tasks to the queue." and stop.

### Step 3: Route and Execute

Follow the Orchestrator's routing logic (see `.claude/agents/orchestrator.md`):

1. Look up the event TYPE or task description in `.claude/skills/REGISTRY.md` trigger column.
2. If a skill matches: execute that skill's procedure.
3. If no match: fall back to `.claude/rules/event-hooks.md`, then `.claude/rules/orchestration-routing.md`.
4. Execute the routed action.

### Step 4: Update State

After execution:
- Update Active Task fields in `.claude/project/STATE.md` (Status, Outputs Produced, Files Modified).
- If processing an event: move it from Unprocessed to Processed in `.claude/project/EVENTS.md`.
- If task is complete: move it to Completed Tasks Log and clear Active Task.
- Promote the next task if appropriate.

### Step 5: Execute Cycles

Follow the Autonomous Run Cycles procedure defined in `.claude/agents/orchestrator.md`:

| Mode | Behavior |
|------|----------|
| Safe | Propose the next action but do NOT execute. Print what would happen. Stop after proposal. |
| Semi-Autonomous | Execute exactly **1 cycle** (one event or one task), then stop. |
| Autonomous | Execute up to **5 cycles**, evaluating stop conditions between each. |

For each cycle:
1. Select → Route → Execute → Review → Update .claude/project/STATE.md → Increment Current Cycle → Print Execution Summary.
2. Before starting the next cycle, evaluate all stop conditions from `.claude/project/RUN_POLICY.md`.

### Step 6: Check Stop Conditions

Stop immediately if any condition from `.claude/project/RUN_POLICY.md` is met:
- The user says stop
- A task becomes Blocked
- A single file change exceeds 500 lines
- The queue is empty and no next tasks can be proposed
- A required artifact is missing and cannot be created safely
- The project goal exit condition is satisfied (if `GOAL.md` exists)
- Max Cycles This Run is reached

Set Last Run Status in .claude/project/STATE.md accordingly.

### Output Policy

> **Goal:** Minimize chat context usage during multi-task runs. Write artifacts to files, not chat.

**1. Write artifacts to canonical files, never to chat.**

All substantial output (documents, plans, code, analysis) must be written to the appropriate repository file:

| Artifact Type | Destination |
|---------------|-------------|
| Documentation | `docs/` |
| Task status & progress | `.claude/project/STATE.md` |
| Event records | `.claude/project/EVENTS.md` |
| Decisions (architectural, product, design) | `.claude/project/knowledge/DECISIONS.md` |
| Research, glossary, open questions | `.claude/project/knowledge/` |
| Task definitions & breakdowns | `tasks/` |

**2. Never print full documents in chat.**

Do not echo file contents, full plans, full PRDs, or generated documents into the chat window. Write them to files and reference the file path.

**3. Chat output per cycle must contain ONLY:**

- Task completed (ID + one-line description)
- Files changed (list of paths)
- Decisions made (one-line each)
- Next task (ID + one-line description)

**4. Chat summaries must stay under 200 words** unless the user explicitly requests more detail.

**5. All architectural or product decisions must be persisted** to `.claude/project/knowledge/DECISIONS.md` using the entry template defined in that file.

**6. Project progress must always update:**

- `.claude/project/STATE.md` — active task, status, outputs, files modified
- `.claude/project/EVENTS.md` — event processing status

---

### Step 7: Print Final Run Summary

```
## Run Summary

- **Mode:** [Safe | Semi-Autonomous | Autonomous]
- **Cycles Executed:** [X of Y max]
- **Last Run Status:** [Running | Completed | Stopped | Blocked]
- **Completed This Run:** [List of Task/Event IDs and descriptions]
- **Skill(s) Used:** [Skill IDs and names | none]
- **Files Modified:** [List of files changed across all cycles]
- **Next Task:** [Description of next queued task]
- **Remaining Tasks:** [Count of tasks in queue]
- **Warnings:** [Any warnings or notes]
```

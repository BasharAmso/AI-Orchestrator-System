---
id: SKL-0025
name: Project Planning
description: |
  Manage project planning, sprint reviews, and status tracking. Produces
  sprint plans, velocity reports, and updates the STATE.md task queue. Use
  this skill when project planning is requested, a status update is needed,
  or a sprint review is due.
version: 1.0
owner: project-manager
triggers:
  - PROJECT_PLANNING_REQUESTED
  - STATUS_UPDATE_NEEDED
  - SPRINT_REVIEW_REQUESTED
inputs:
  - Task description (from active task or event)
  - .claude/project/STATE.md
  - .claude/project/knowledge/DECISIONS.md
  - .claude/project/knowledge/SPRINT.md (if exists)
  - docs/PRD.md (if available)
outputs:
  - .claude/project/knowledge/SPRINT.md (created or updated)
  - .claude/project/STATE.md (updated with project status)
  - Optional: stakeholder update or escalation message
tags:
  - planning
  - sprint
  - status
  - estimation
  - risk
---

# Skill: Project Planning

## Metadata

| Field | Value |
|-------|-------|
| **Skill ID** | SKL-0025 |
| **Version** | 1.0 |
| **Owner** | project-manager |
| **Inputs** | Task description, STATE.md, DECISIONS.md, SPRINT.md, PRD |
| **Outputs** | SPRINT.md, STATE.md updated, optional stakeholder update |
| **Triggers** | `PROJECT_PLANNING_REQUESTED`, `STATUS_UPDATE_NEEDED`, `SPRINT_REVIEW_REQUESTED` |

---

## Purpose

Turn a pile of tasks into an ordered, trackable plan — and keep it honest as work progresses. Scale planning depth to team size: 1 person = lightweight task list; 3+ people = structured sprints.

---

## Planning Modes

| Mode | Triggered by | Output |
|------|-------------|--------|
| New project plan | "plan this project", PRD just created | Full SPRINT.md from scratch |
| Sprint planning | "plan this sprint", new cycle start, `SPRINT_COMPLETE` | Next sprint tasks + estimates |
| Sprint review | `SPRINT_COMPLETE`, `SPRINT_TIMEBOX_EXPIRED` | Sprint retrospective + next sprint proposal |
| Feature review | `FEATURE_COMPLETE` | Feature review gate + next feature proposal |
| Feature planning | New feature group start | Feature task verification + dependency check |
| Status check | "what's the status", "are we on track" | Progress summary + risk update |
| Stakeholder update | "write a status update" | Plain-language summary (no jargon) |
| Re-prioritization | "we're behind", "scope change" | Revised task order + impact assessment |

---

## Procedure

1. **Determine planning mode** from the request.

2. **Read existing project state:**
   - STATE.md — active tasks, completed work, blockers
   - DECISIONS.md — what's been decided
   - SPRINT.md — existing plan (if any)
   - PRD — full feature scope (if available)
   - Note: what's done, in progress, not started, blocked
   - Check previous blockers for resolution status; flag overdue ones for escalation

2.5. **Check active methodology** (read `## Methodology` from STATE.md, default Waterfall if absent):
   - **Waterfall/Kanban:** No methodology-specific planning behavior. Proceed normally.
   - **Scrum:** Read sprint metadata from STATE.md (`> Sprint:`, `> Sprint End Date:`, `> Sprint Goal:`). If sprint metadata exists, scope planning to the current sprint. If triggered by `SPRINT_COMPLETE` or `SPRINT_TIMEBOX_EXPIRED`, enter Sprint Review mode (see step 3).
   - **FDD:** Read feature metadata from STATE.md (`> Current Feature:`, `> Feature Count:`). If feature metadata exists, scope planning to the current feature group. If triggered by `FEATURE_COMPLETE`, enter Feature Review mode (see step 3).

3. **Build or update the plan:**
   - **New project:** Goal, Milestones table, Current Sprint (tasks with owner/estimate/status), Backlog, Risks table, Assumptions
   - **Sprint review** (Scrum, triggered by `SPRINT_COMPLETE` or `SPRINT_TIMEBOX_EXPIRED`):
     1. Summarize completed vs incomplete tasks for the ended sprint.
     2. Calculate velocity: tasks completed / sprint duration.
     3. Update SPRINT.md with sprint results and velocity data.
     4. Propose next sprint: ask user how many tasks (suggest based on velocity), which backlog tasks to pull in, and sprint goal.
     5. On user approval: increment `> Sprint:` in STATE.md, set new `> Sprint End Date:`, update `> Sprint Goal:`, re-tag tasks in Next Task Queue (`S[N]` for new sprint, `—` for remaining backlog).
   - **Sprint planning** (Scrum, new sprint start): Same as sprint review step 4-5 but without the retrospective.
   - **Feature review** (FDD, triggered by `FEATURE_COMPLETE`):
     1. Summarize completed tasks for the finished feature group.
     2. Update FEATURES.md — set the feature's Review status to `Reviewed`.
     3. Present review to user for approval. On approval, update Review status to `Approved` and advance `> Current Feature:` in STATE.md to the next feature group.
     4. If all feature groups are approved, note that all features are complete.
   - **Feature planning** (FDD, new feature group): Present the next feature group's tasks, verify ordering and dependencies, update estimates if needed.
   - **Status check:** Overall status (on track/at risk/behind), completed, in progress, blocked, risks updated, next actions
   - **Stakeholder update:** Plain language — what's done, what's next, decisions needed
   - **Blocker escalation:** Subject line, what's blocked, what's needed, by when, impact if delayed

4. **Estimate tasks:**
   - Break tasks >2 days into subtasks
   - Express as ranges: "1-2 days" not "1.5 days"
   - State what the range depends on
   - Flag high uncertainty (>3x range) as a risk

5. **Update STATE.md** with project status section:
   - Current sprint + goal
   - Sprint end date
   - Overall status
   - Active risk count
   - Next milestone

6. **Surface blockers and risks:**
   - Name each blocker explicitly
   - State what's needed and who acts
   - Propose specific resolution action
   - Set follow-up date in SPRINT.md
   - Generate escalation message if overdue
   - Rate risks: likelihood + impact (Low/Medium/High)
   - Never soften risks to sound reassuring

---

## Estimation Calibration

| Task type | Typical range |
|-----------|--------------|
| Simple UI component | 2-4 hours |
| Complex UI with state | 0.5-1 day |
| New API integration | 1-3 days |
| Authentication flow | 1-2 days |
| Database schema + migrations | 0.5-1 day |
| Deployment setup | 0.5-2 days |
| Bug of unknown cause | 0.5-3 days |

---

## Constraints

- Never blocks building work to create planning artifacts
- Never produces plans more complex than the project warrants
- Never commits to exact delivery dates — always ranges with assumptions
- Never buries risks — surface early and explicitly
- Never writes code or modifies app files
- Always reads STATE.md and SPRINT.md before creating/updating a plan

---

## Primary Agent

project-manager

---

## Definition of Done

- [ ] Planning mode identified and appropriate output produced
- [ ] Existing state read before planning (no overwriting progress)
- [ ] All tasks estimated with ranges and dependencies
- [ ] Risks surfaced with likelihood, impact, and mitigation
- [ ] Blockers named with specific resolution actions and follow-up dates
- [ ] SPRINT.md created or updated
- [ ] STATE.md updated with project status

## Output Contract

| Field | Value |
|-------|-------|
| **Artifacts** | `.claude/project/knowledge/SPRINT.md` (created or updated), sprint plan or status report |
| **State Update** | `.claude/project/STATE.md` — mark task complete, log files modified |
| **Handoff Event** | `TASK_COMPLETED` (no mandatory next step) |

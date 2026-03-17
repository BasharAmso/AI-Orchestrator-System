---
id: SKL-0003
name: PRD to Tasks
description: |
  Break down a Product Requirements Document into executable tasks with
  priorities and dependencies. Use this skill when a PRD has been created or
  updated and needs to be converted into a task queue.
version: 1.0
owner: Orchestrator
triggers:
  - PRD_UPDATED
inputs:
  - docs/PRD.md
  - .claude/project/STATE.md
  - .claude/project/knowledge/OPEN_QUESTIONS.md (optional)
outputs:
  - .claude/project/STATE.md (Next Task Queue updated)
  - .claude/project/knowledge/OPEN_QUESTIONS.md (optional new entries)
tags:
  - planning
  - tasks
  - prd
---

# Skill: PRD to Tasks

## Metadata

| Field | Value |
|-------|-------|
| **Skill ID** | SKL-0003 |
| **Version** | 1.0 |
| **Owner** | Orchestrator |
| **Inputs** | `docs/PRD.md`, `.claude/project/STATE.md`, `.claude/project/knowledge/OPEN_QUESTIONS.md` (optional) |
| **Outputs** | Updated `.claude/project/STATE.md` Next Task Queue (8-15 tasks), optional new entries in `.claude/project/knowledge/OPEN_QUESTIONS.md` |
| **Triggers** | `PRD_UPDATED` |

---

## Purpose

Convert a completed or updated PRD into a concrete, ordered, beginner-friendly task queue so the system becomes self-planning. This eliminates the need for manual task creation after writing a PRD.

---

## Procedure

### A) Extract PRD Content

Read `docs/PRD.md` and extract:

1. **Core goal** — from the Overview or Goals section.
2. **Target user** — from the Target Users section.
3. **MVP scope** — individual features from the MVP Scope section.
4. **Non-goals** — from the Non-Goals section (to avoid generating tasks for these).
5. **Risks and assumptions** — from the Risks and Assumptions section.

If any section is missing, proceed with what is available and note the gap.

### B) Generate Task List

Produce an ordered list of **8 to 15 tasks** following these rules:

1. **Beginner-friendly titles** — Use short, plain language. Write "Build login screen", not "Implement authentication UI component with OAuth flow".
2. **Name the target file or folder** — Each task must reference the expected output location when known (e.g., `src/`, `docs/`, `lib/`, `manuscript/`, `tests/`).
3. **Priority tagging** — Assign each task one of: `High`, `Medium`, or `Low`.
4. **Logical order** — Tasks should follow a natural build sequence:
   - Planning and design tasks first (High priority)
   - Core feature build tasks next (High/Medium priority)
   - Polish, testing, and review tasks last (Medium/Low priority)
5. **No tasks for non-goals** — Cross-check against the Non-Goals section. Do not generate tasks for anything explicitly excluded.

6. **Skill assignment** — Assign each task a Skill ID from `.claude/skills/REGISTRY.md`. The planner has full PRD context (architecture, features, tech stack) and should map each task to the most relevant skill. This is the **primary mechanism** by which skills are invoked during the build phase.
   - Read REGISTRY.md and match the task's domain to the closest skill.
   - If a task spans multiple skills, assign the **primary** skill (the one that covers the most work).
   - If no skill clearly applies, leave the Skill column as `—` (the orchestrator will use fallback routing).

**Task format** (matches STATE.md Next Task Queue table):

```
| # | Task | Priority | Skill |
|---|------|----------|-------|
| 1 | <short title> (<target file/folder>) | High | SKL-0006 |
```

### C) Write to STATE.md (Idempotency Rules)

Read `.claude/project/STATE.md` and locate the `## Next Task Queue` section.

**Determine queue state using these patterns:**

A queue is **empty/placeholder-only** if it matches ANY of:
- Contains only `(none)` or `*(none)*`
- Contains only `- (none)`
- Contains only table headers with no data rows
- The section is completely empty

**If the queue is empty or placeholder-only:**
- Replace the placeholder content with the generated task table.

**If the queue already contains real tasks:**
- Do NOT replace the existing queue.
- Instead, append a new section below the Completed Tasks Log:

```
---

## Proposed Task Queue (from PRD_UPDATED — YYYY-MM-DD)

| # | Task | Priority | Skill |
|---|------|----------|-------|
| 1 | ... | ... | SKL-XXXX |
| ... | ... | ... | ... |

> These tasks were auto-generated from docs/PRD.md. Review and merge into the Next Task Queue manually or by running /run-project.
```

### D) Handle Open Questions

While reading the PRD, if any requirements are ambiguous or underspecified:

1. Read `.claude/project/knowledge/OPEN_QUESTIONS.md`.
2. Check if the question already exists (avoid duplicates).
3. If the question is novel, append it using the next available `OQ-XXXX` ID:

```
---

### OQ-XXXX: <Question title>

- **Date:** YYYY-MM-DD
- **Source:** PRD analysis via skill-prd-to-tasks
- **Context:** <What prompted this question>
- **Status:** Open
- **Impact:** <What decision is blocked by this question>
```

### E) Event Suggestion

After completing task generation, recommend emitting:

```
TASK_QUEUE_PROPOSED | .claude/project/STATE.md updated with tasks from PRD
```

Print: `"Suggest emitting: TASK_QUEUE_PROPOSED — use /trigger to create it."`

(Skills do not emit events directly; the orchestrator or user handles emission.)

---

## Primary Agent

Orchestrator (handles PRD analysis and task decomposition internally).

## Review

Orchestrator self-reviews task titles for beginner clarity. For deeper quality review, emit `QUALITY_REVIEW_REQUESTED` via `/trigger`.

---

## Definition of Done

- [ ] 8-15 tasks generated from PRD content
- [ ] Tasks written to .claude/project/STATE.md (seeded or proposed, per idempotency rules)
- [ ] Each task has a plain-language title, target location, priority, and Skill ID
- [ ] Skill IDs assigned by cross-referencing REGISTRY.md (or `—` if no skill applies)
- [ ] No tasks generated for items listed in Non-Goals
- [ ] Any ambiguous requirements logged to .claude/project/knowledge/OPEN_QUESTIONS.md
- [ ] Event suggestion printed for TASK_QUEUE_PROPOSED
- [ ] .claude/project/STATE.md updated with outputs produced and files modified

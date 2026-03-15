---
id: SKL-0001
name: Plan From Idea
description: |
  Transform a captured project idea into an actionable plan with PRD and task
  breakdown. Use this skill when a new idea has been captured and needs to be
  developed into a structured project plan.
version: 1.0
owner: Orchestrator
triggers:
  - IDEA_CAPTURED
inputs:
  - Idea description (from event or user input)
outputs:
  - docs/PRD.md
  - .claude/project/STATE.md (Next Task Queue updated)
tags:
  - planning
  - ideation
---

# Skill: Plan From Idea

## Metadata

| Field | Value |
|-------|-------|
| **Skill ID** | SKL-0001 |
| **Version** | 1.0 |
| **Owner** | Orchestrator |
| **Inputs** | Idea description (from event or user input) |
| **Outputs** | PRD stub (`docs/PRD.md` or equivalent), initial task queue items |
| **Triggers** | `IDEA_CAPTURED` |

---

## Purpose

Turn a rough idea into a structured plan. This skill takes a freeform idea description and produces:
1. A short PRD (Product Requirements Document) stub.
2. An initial set of tasks added to the Next Task Queue in STATE.md.

---

## Procedure

1. **Read the idea** from the event description or user input.
2. **Create a PRD stub** at `docs/PRD.md` (or the project's preferred location) with:
   - Project name
   - One-sentence summary
   - Target audience
   - Core features (3-5 bullet points)
   - Out of scope (2-3 items)
   - Success criteria
3. **Generate 3-5 initial tasks** based on the PRD and add them to the Next Task Queue in `STATE.md`.
4. **Log a decision** in `DECISIONS.md` noting the project direction chosen.
5. **Update STATE.md** with outputs produced and files modified.

---

## Primary Agent

Orchestrator (dispatches to product-manager for PRD work via SKL-0004)

## Review

None required for v1. The user reviews the PRD and task queue after execution.

---

## Definition of Done

- [ ] PRD stub exists at `docs/PRD.md` (or equivalent project brief)
- [ ] At least 3 tasks are added to the Next Task Queue
- [ ] STATE.md is updated with outputs and files modified
- [ ] Decision logged in DECISIONS.md

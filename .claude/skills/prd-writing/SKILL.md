---
id: SKL-0004
name: PRD Writing
description: |
  Write a Product Requirements Document through user interview, including user
  stories, requirements, and acceptance criteria. Use this skill when a new PRD
  needs to be created for a project.
version: 1.0
owner: project-manager
triggers:
  - PRD_CREATION_REQUESTED
inputs:
  - User's product idea or description
  - docs/PRD.md (if exists)
outputs:
  - docs/PRD.md (created or updated)
  - .claude/project/STATE.md (updated)
tags:
  - planning
  - prd
---

# Skill: PRD Writing

## Metadata

| Field | Value |
|-------|-------|
| **Skill ID** | SKL-0004 |
| **Version** | 1.0 |
| **Owner** | project-manager |
| **Inputs** | User's product idea, existing PRD (if any) |
| **Outputs** | `docs/PRD.md`, STATE.md updated |
| **Triggers** | `PRD_CREATION_REQUESTED` |

---

## Purpose

Interview the user conversationally and produce a structured PRD at `docs/PRD.md` that downstream skills can parse.

---

## Procedure

### Step 1 — Check for existing PRD

Read `docs/PRD.md` if it exists. If found, summarize and ask whether to update or start fresh.

### Step 2 — Run the interview in four rounds

Wait for the user's response after each round.

**Round 1 — Problem and Users:** What problem? Who has it? How do you know?
**Round 2 — Goals and Scope:** Success metric? 3-5 MVP features? What's NOT in v1?
**Round 3 — AI Features (conditional):** Only if AI/LLM involved. What does AI do? Fallback? Trust signals?
**Round 4 — Constraints and Kill Rule:** Real constraints? Biggest risk? Kill rule?

### Step 3 — Confirm before writing

Summarize in 5-8 bullets. Ask: "Anything wrong or missing?"

### Step 4 — Write docs/PRD.md

Use exact section headings (prd-to-tasks skill depends on them):
Overview, Problem Statement, Goals, Target Users, MVP Scope, Non-Goals, User Stories, Risks and Assumptions (with Kill Rule), Constraints, Open Questions, AI/ML Requirements (if applicable).

### Step 5 — Emit event and update STATE.md

Print: `"Suggest emitting: PRD_UPDATED — use /emit-event to create it."`

---

## Constraints

- Never overwrites existing PRD without confirmation
- Interview is conversational — never dump all questions at once
- Never skip the problem statement
- Never write solutions before the problem is established
- Scale to context: solo = lean PRD, AI product = add AI sections

---

## Primary Agent

project-manager

---

## Definition of Done

- [ ] docs/PRD.md exists with all required sections
- [ ] Problem statement includes evidence
- [ ] Success metric has baseline, target, timeframe
- [ ] Non-Goals has at least 3 exclusions
- [ ] Kill rule defined
- [ ] STATE.md updated
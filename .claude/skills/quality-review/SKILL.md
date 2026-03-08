---
id: SKL-0002
name: Quality Review
version: 1.0
owner: Orchestrator
triggers:
  - QUALITY_REVIEW_REQUESTED
inputs:
  - Files or content to review (from event description or active task)
outputs:
  - Review summary
  - .claude/project/STATE.md (updated with findings)
tags:
  - quality
  - review
---

# Skill: Quality Review

## Metadata

| Field | Value |
|-------|-------|
| **Skill ID** | SKL-0002 |
| **Version** | 1.0 |
| **Owner** | Orchestrator |
| **Inputs** | Files or content to review (from event description or active task) |
| **Outputs** | Review summary with findings and suggestions |
| **Triggers** | `QUALITY_REVIEW_REQUESTED` |

---

## Purpose

Run a lightweight review loop for quality and clarity on any project artifact — code, documentation, plans, or content. Produces a short review summary and updates STATE.

---

## Procedure

1. **Identify the target** from the event description or active task. This could be:
   - A specific file or set of files
   - A recent set of changes
   - A document or plan
2. **Review for quality:**
   - Is it clear and understandable?
   - Is it complete (no missing sections or TODO placeholders)?
   - Is it consistent with existing project patterns?
   - Are there obvious errors or issues?
3. **Review for clarity (beginner-friendly check):**
   - Would a newcomer understand this?
   - Are terms defined or linked to the glossary?
   - Is the structure logical and scannable?
4. **Produce a review summary** with:
   - What was reviewed
   - Findings (categorized: Good / Needs Improvement / Issue)
   - Suggested actions (if any)
5. **Update STATE.md** with the review summary as output.

---

## Primary Agent

Orchestrator (acts in a clarity/editor role). No specialized agent required.

## Review

Beginner-friendly check: the Orchestrator self-verifies that the review summary is understandable by a non-technical reader.

---

## Definition of Done

- [ ] Review summary is produced and logged
- [ ] Any issues found are either fixed or added as tasks to the Next Task Queue
- [ ] STATE.md is updated with outputs produced and files modified

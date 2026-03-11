---
id: SKL-0016
name: Code Review
description: |
  Review code for correctness, maintainability, and best practices. Use this
  skill when a code review is requested on new or modified code.
version: 1.0
owner: reviewer
triggers:
  - CODE_REVIEW_REQUESTED
inputs:
  - Target files (from active task or event)
  - .claude/project/STATE.md
  - .claude/project/knowledge/DECISIONS.md
  - Existing project source files
outputs:
  - Review summary (Must Fix / Should Fix / Consider)
  - Verdict (APPROVED / NEEDS WORK)
  - .claude/project/STATE.md (updated)
tags:
  - review
  - quality
  - code
---

# Skill: Code Review

## Metadata

| Field | Value |
|-------|-------|
| **Skill ID** | SKL-0016 |
| **Version** | 1.0 |
| **Owner** | reviewer |
| **Inputs** | Target files, STATE.md, DECISIONS.md, existing source files |
| **Outputs** | Review summary, STATE.md updated |
| **Triggers** | `CODE_REVIEW_REQUESTED` |

---

## Purpose

Review code for quality, consistency, bugs, and adherence to project conventions. Read-only analysis — never modifies source files. Report findings for the appropriate agent to act on.

---

## Procedure

1. **Read DECISIONS.md** — understand naming patterns, file structure, coding style, framework choices, architecture patterns.
2. **Review target files systematically:**
   - **Correctness:** Does the code do what it claims?
   - **Edge cases:** Are boundary conditions handled?
   - **Error handling:** Are failures caught and reported properly?
   - **Naming:** Are names clear and consistent?
   - **Duplication:** Repeated logic that should be extracted?
   - **Complexity:** Functions doing too many things?
3. **Security check:**
   - Unsanitized inputs
   - Hardcoded credentials
   - SQL injection, XSS, OWASP Top 10 risks
4. **Consistency check:**
   - Does new code match existing patterns?
   - Are imports and dependencies consistent?
   - Does file structure follow conventions?
5. **Produce review summary** categorized as:
   - **Must Fix:** Bugs, security issues, broken functionality
   - **Should Fix:** Inconsistencies, poor naming, missing error handling
   - **Consider:** Style improvements, potential simplifications
6. **Issue verdict:**
   - Default verdict is **NEEDS WORK**. The code must earn approval.
   - To issue **APPROVED**, cite evidence for each: all Definition of Done items satisfied, zero Must Fix issues, code works per PRD, edge cases handled.
   - If any item lacks evidence, verdict remains NEEDS WORK with specific, actionable feedback.
7. **Update STATE.md** with review summary and verdict.

---

## Constraints

- Never modifies source files — read-only analysis
- Never approves code without actually reading it
- Always checks DECISIONS.md for conventions before reviewing

---

## Primary Agent

reviewer

---

## Definition of Done

- [ ] All target files read and reviewed
- [ ] Findings categorized (Must Fix / Should Fix / Consider)
- [ ] Security check performed
- [ ] Consistency with conventions checked
- [ ] Review summary written to STATE.md

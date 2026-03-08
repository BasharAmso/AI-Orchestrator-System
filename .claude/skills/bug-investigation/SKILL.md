---
id: SKL-0020
name: Bug Investigation
version: 1.0
owner: fixer
triggers:
  - BUG_REPORTED
inputs:
  - Bug description (from active task or event)
  - .claude/project/STATE.md
  - Relevant source files
  - Test files and error logs
outputs:
  - Bug fix applied to source files
  - .claude/project/STATE.md (updated with root cause and fix)
tags:
  - maintenance
  - debugging
  - bugfix
---

# Skill: Bug Investigation

## Metadata

| Field | Value |
|-------|-------|
| **Skill ID** | SKL-0020 |
| **Version** | 1.0 |
| **Owner** | fixer |
| **Inputs** | Bug description, STATE.md, source files, tests/logs |
| **Outputs** | Bug fix, STATE.md updated |
| **Triggers** | `BUG_REPORTED` |

---

## Purpose

Systematically isolate and fix bugs. Hypothesis first, evidence second, fix third. Never guess — find the root cause, not just the symptom.

---

## Procedure

1. **Reproduce the bug** before touching any code.
   - Can it be reproduced consistently? What are the exact steps?
   - If not reproducible: log as intermittent and request more info.
2. **Form a hypothesis** about the root cause:
   - Check STATE.md for recent changes that may have introduced it
   - State explicitly: "I believe the bug is caused by X because Y."
3. **Gather evidence** to confirm or reject:
   - Read relevant code carefully
   - Trace execution path from input to failure
   - Check: off-by-one errors, null handling, async timing, data shape assumptions
4. **Confirm root cause before fixing.** If the fix isn't obvious, the root cause hasn't been found.
5. **Apply the minimal fix:**
   - Fix only what is broken — do not refactor surrounding code
   - If larger change needed: note it and add a refactor task instead
6. **Verify the fix:**
   - Does it resolve the bug? Does it break anything else?
   - If tests exist: do they pass?
7. **Document in STATE.md Completed Tasks Log:**
   - Root cause: [what caused it]
   - Fix applied: [what changed and why]
8. **Update STATE.md.**

---

## Constraints

- Never refactors while fixing a bug — separate tasks
- Never applies a fix without confirming root cause
- Never silently swallows errors

---

## Primary Agent

fixer

---

## Definition of Done

- [ ] Bug reproduced before fixing
- [ ] Root cause confirmed (not just symptom treated)
- [ ] Minimal fix applied
- [ ] Fix verified against original bug report
- [ ] Finding documented in STATE.md
- [ ] STATE.md updated

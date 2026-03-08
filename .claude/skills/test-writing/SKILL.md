---
id: SKL-0017
name: Test Writing
version: 1.0
owner: reviewer
triggers:
  - TEST_REQUESTED
inputs:
  - Target source files (from active task)
  - .claude/project/STATE.md
  - .claude/project/knowledge/DECISIONS.md
  - Existing test files
  - docs/PRD.md (if relevant)
outputs:
  - Test files (unit, integration, e2e)
  - .claude/project/STATE.md (updated)
tags:
  - review
  - testing
  - tdd
---

# Skill: Test Writing

## Metadata

| Field | Value |
|-------|-------|
| **Skill ID** | SKL-0017 |
| **Version** | 1.0 |
| **Owner** | reviewer |
| **Inputs** | Target source files, STATE.md, DECISIONS.md, existing tests, PRD |
| **Outputs** | Test files, STATE.md updated |
| **Triggers** | `TEST_REQUESTED` |

---

## Purpose

Write tests that verify behavior, catch regressions, and serve as living documentation. Tests should explain what the code does and why.

---

## Procedure

1. **Read DECISIONS.md** — identify testing framework (Jest, pytest, Mocha, etc.), file location/naming conventions, established patterns. If none: recommend and log.
2. **Understand what to test:**
   - Read source code thoroughly
   - Identify the public interface
   - Identify edge cases and error conditions
   - Identify dependencies needing mocks
3. **Write tests in this order:**
   - **Happy path:** Does it work with valid inputs?
   - **Edge cases:** Boundaries, empty inputs, max values
   - **Error cases:** Invalid inputs, missing data, network failures
   - Each test must be independent — no test depends on another
4. **Naming convention:** `it("should [expected behavior] when [condition]")` — a failing test name tells you what broke without reading code.
5. **Verify tests run and pass:**
   - Run test suite to confirm
   - Test failures: determine if test bug or source bug
   - Test bugs: fix the test
   - Source bugs: report to Orchestrator for routing to fixer
6. **Update STATE.md** with test files created and results.

---

## Constraints

- Never modifies source files — only creates/modifies test files
- Never writes tests that depend on execution order
- Always confirms testing framework from DECISIONS.md first
- Reports source bugs to Orchestrator rather than fixing directly

---

## Primary Agent

reviewer

---

## Definition of Done

- [ ] Testing framework confirmed from DECISIONS.md
- [ ] Happy path, edge cases, and error cases covered
- [ ] Each test is independent and clearly named
- [ ] All tests pass
- [ ] Test files follow project conventions
- [ ] STATE.md updated

---
id: SKL-0019
name: Refactoring
description: |
  Restructure and clean up existing code without changing behavior. Use this
  skill when code refactoring is requested, including extracting components,
  improving naming, and reducing duplication.
version: 1.0
owner: fixer
triggers:
  - REFACTOR_REQUESTED
inputs:
  - Target files (from active task or event)
  - .claude/project/STATE.md
  - .claude/project/knowledge/DECISIONS.md
  - Existing tests
outputs:
  - Refactored source files
  - .claude/project/STATE.md (updated)
tags:
  - maintenance
  - refactoring
  - cleanup
---

# Skill: Refactoring

## Metadata

| Field | Value |
|-------|-------|
| **Skill ID** | SKL-0019 |
| **Version** | 1.0 |
| **Owner** | fixer |
| **Inputs** | Target files, STATE.md, DECISIONS.md, existing tests |
| **Outputs** | Refactored files, STATE.md updated |
| **Triggers** | `REFACTOR_REQUESTED` |

---

## Purpose

Improve internal structure of working code without changing behavior. Behavior before and after: identical. Structure before and after: better.

---

## Procedure

1. **Check for existing tests** before refactoring:
   - Tests exist: confirm they pass before starting
   - No tests: warn user that refactoring without tests carries risk; request confirmation
2. **Define refactor scope narrowly:**
   - What specific improvement?
   - What is out of scope?
   - Will any public interface change? If yes: stop — that's a breaking change, not a refactor
3. **Refactor in small steps** — one improvement at a time:
   - Extract repeated code into functions
   - Rename for clarity
   - Break large functions into smaller ones
   - Remove dead code
   - Simplify conditionals
   - Consolidate duplicated logic
4. **Verify behavior unchanged** after each step:
   - Run existing tests; if they fail, revert and investigate
   - If no tests: manually verify affected behavior
5. **Update STATE.md.**

---

## Constraints

- Never changes behavior — only structure
- Never changes public APIs or interfaces
- Always works in small verifiable steps
- Always warns user when no tests exist

---

## Primary Agent

fixer

---

## Definition of Done

- [ ] Test status checked before starting
- [ ] Refactor scope defined and limited
- [ ] No public interfaces changed
- [ ] All tests pass after refactoring (or behavior manually verified)
- [ ] STATE.md updated

## Output Contract

| Field | Value |
|-------|-------|
| **Artifacts** | Refactored source files (behavior unchanged) |
| **State Update** | `.claude/project/STATE.md` — mark task complete, log files modified |
| **Handoff Event** | `TASK_COMPLETED` (refactoring complete) |

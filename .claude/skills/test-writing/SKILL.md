---
id: SKL-0017
name: Test Writing
description: |
  Write automated tests for existing or new functionality. Use this skill
  when tests are requested, including unit tests, integration tests, and
  end-to-end tests.
version: 2.0
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
  - mobile-testing
  - swift-testing
  - android-testing
---

# Skill: Test Writing

## Metadata

| Field | Value |
|-------|-------|
| **Skill ID** | SKL-0017 |
| **Version** | 2.0 |
| **Owner** | reviewer |
| **Inputs** | Target source files, STATE.md, DECISIONS.md, existing tests, PRD |
| **Outputs** | Test files, STATE.md updated |
| **Triggers** | `TEST_REQUESTED` |

---

## Purpose

Write tests that verify behavior, catch regressions, and serve as living documentation. Tests should explain what the code does and why.

---

## Procedure

1. **Read DECISIONS.md** — identify testing framework (Jest, pytest, Mocha, Swift Testing, JUnit4 + MockK, etc.), file location/naming conventions, established patterns. If none: recommend and log.
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

## Mobile Testing Guide

When the target is a mobile app, apply these platform-specific strategies in addition to the general procedure above.

### Testing Priority (all mobile platforms)

Follow the "testing trophy" — highest ROI first:
1. **ViewModel / business logic tests** — fastest to run, highest value per test
2. **Screenshot / snapshot tests** — one test catches visual regressions across themes, sizes, and modes
3. **UI smoke tests** — critical flows only (onboarding, core action, purchase); slow and brittle, so minimize
4. **Integration tests** — API + data layer

**Coverage targets:** 70-80% on ViewModels and business logic, 50-60% overall.

### Swift/iOS Testing

| Layer | Framework | What to test |
|-------|-----------|-------------|
| Unit (ViewModel) | Swift Testing (`@Test`, `#expect`) | State transitions, business logic, data transformations |
| Snapshot | swift-snapshot-testing (Point-Free) | View appearance across devices, Dynamic Type sizes, dark mode |
| UI | XCUITest | Critical user flows only (sign in, core action, navigation) |

- Use `@Test` and `#expect` (Swift Testing) for all new tests — not XCTest assertions
- Use `@MainActor` on ViewModel tests that touch UI state
- Mock dependencies via protocol conformance, not subclassing
- Pin CI to a specific Xcode/OS version for snapshot consistency
- Note: XCUITest and snapshot tests require a simulator — flag if unavailable

### Kotlin/Android Testing

| Layer | Framework | What to test |
|-------|-----------|-------------|
| Unit (ViewModel) | JUnit4 + MockK + Turbine | StateFlow emissions, use case logic, repository behavior |
| Snapshot | Roborazzi | Compose component screenshots across themes and font scales |
| UI | Compose Testing + Robolectric | Component rendering, user interactions, navigation |

- Use `runTest` from `kotlinx-coroutines-test` for coroutine tests
- Use Turbine's `.test {}` block for Flow assertions
- Use `createComposeRule()` for Compose UI tests
- Use MockK (`every`, `coEvery`) — not Mockito
- Robolectric runs Compose tests 10x faster than emulator — prefer it for CI
- Exclude generated code from coverage (R.class, BuildConfig, Hilt generated)

### React Native Testing

| Layer | Framework | What to test |
|-------|-----------|-------------|
| Unit | Jest | Business logic, utility functions, custom hooks |
| Component | React Native Testing Library | Component rendering, user interactions |
| E2E | Detox or Maestro | Full app flows on simulator/emulator |

---

## Constraints

- Never modifies source files — only creates/modifies test files
- Never writes tests that depend on execution order
- Always confirms testing framework from DECISIONS.md first
- Always confirms mobile testing framework (Swift Testing vs XCTest, JUnit4 vs JUnit5) before writing mobile tests
- Never mixes Swift Testing (`@Test`) with XCTest assertions in the same test file
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
- [ ] Mobile testing priority followed (ViewModel tests first) — if mobile project
- [ ] Platform-appropriate test framework used (Swift Testing / JUnit4+MockK / Jest) — if mobile project
- [ ] STATE.md updated

## Output Contract

| Field | Value |
|-------|-------|
| **Artifacts** | Test files (unit, integration, e2e) matching project conventions |
| **State Update** | `.claude/project/STATE.md` — mark task complete, log files modified |
| **Handoff Event** | `TASK_COMPLETED` (tests written, ready for review) |

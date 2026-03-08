---
id: SKL-0018
name: User Acceptance Testing
version: 1.0
owner: reviewer
triggers:
  - UAT_REQUESTED
  - READY_FOR_ACCEPTANCE_TESTING
inputs:
  - docs/PRD.md (features and acceptance criteria)
  - .claude/project/STATE.md (what was built)
  - Built application (test/staging environment)
outputs:
  - .claude/project/knowledge/UAT_REPORT.md
  - .claude/project/STATE.md (updated with verdict)
  - Bug list for fixer agent (if issues found)
tags:
  - review
  - testing
  - uat
  - acceptance
---

# Skill: User Acceptance Testing

## Metadata

| Field | Value |
|-------|-------|
| **Skill ID** | SKL-0018 |
| **Version** | 1.0 |
| **Owner** | reviewer |
| **Inputs** | PRD, STATE.md, built application |
| **Outputs** | UAT_REPORT.md, STATE.md updated, bug list |
| **Triggers** | `UAT_REQUESTED`, `READY_FOR_ACCEPTANCE_TESTING` |

---

## Purpose

Walk through the product as a real user would. Verify features match the PRD, edge cases don't crash the app, and error messages make sense. Issue a GO / GO WITH CONDITIONS / NO-GO verdict.

---

## Procedure

1. **Read PRD and STATE.md** — identify all features, acceptance criteria, and what's marked complete. Build a checklist of testable features. If no PRD: ask the user.
2. **Identify critical user flows** — flows where failure means NO-GO:
   - Account creation / sign-in
   - Core value action (the one thing the app exists for)
   - Payment / checkout (if applicable)
   - Data save and retrieval
   - Navigation between main sections
3. **Test each flow as a real user:**
   - Start from real entry points (not deep links)
   - Happy path first, then edge cases:
     - Empty inputs, invalid inputs, empty states, error states
     - Back button / navigation, page refresh
   - Note what worked, broke, or was confusing
4. **Check accessibility and usability basics** (no code inspection):
   - Keyboard navigation, text readability, image purpose
   - Error message clarity, mobile responsiveness, loading indicators
5. **Write UAT report** to `.claude/project/knowledge/UAT_REPORT.md`:
   - Verdict, critical flow results, issues found (with exact reproduction steps)
   - Issues categorized: Critical (blocks launch), Major (fix before launch), Minor (ship, fix later)
   - PRD compliance matrix
6. **Route bugs** — log Critical and Major issues to STATE.md task queue for fixer agent.
7. **Update STATE.md** with UAT status and verdict.

---

## Verdict Criteria

| Verdict | When |
|---------|------|
| **GO** | All critical flows pass. No critical issues. |
| **GO WITH CONDITIONS** | Critical flows pass with workarounds. Major issues have clear fixes. |
| **NO-GO** | Any critical flow broken. Product not usable for intended purpose. |

---

## Constraints

- Never modifies application code — found bugs are logged for fixer
- Never tests in production — always test/staging
- Never issues GO if any critical user flow is broken
- Always tests as a user (no code inspection)
- Always includes exact reproduction steps for every issue
- Always reads PRD before testing

---

## Primary Agent

reviewer

---

## Definition of Done

- [ ] PRD features mapped to test checklist
- [ ] All critical flows tested
- [ ] Edge cases tested (empty, invalid, error, navigation)
- [ ] Accessibility basics checked
- [ ] UAT_REPORT.md written with verdict
- [ ] Bugs routed to fixer with reproduction steps
- [ ] STATE.md updated with verdict

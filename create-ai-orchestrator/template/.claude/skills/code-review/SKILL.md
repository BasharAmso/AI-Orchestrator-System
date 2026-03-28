---
id: SKL-0016
name: Code Review
description: |
  Review code for correctness, maintainability, and best practices. Uses a
  structured two-pass review (CRITICAL then INFORMATIONAL) with interactive
  issue resolution. Includes scope challenge, failure mode analysis, and
  TODOS.md cross-reference. Use this skill when a code review is requested
  on new or modified code.
version: 2.0
owner: reviewer
triggers:
  - CODE_REVIEW_REQUESTED
inputs:
  - Target files (from active task or event)
  - .claude/project/STATE.md
  - .claude/project/knowledge/DECISIONS.md
  - .claude/skills/code-review/checklist.md
  - TODOS.md (if exists)
  - Existing project source files
outputs:
  - Review summary (CRITICAL / INFORMATIONAL findings)
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
| **Version** | 2.0 |
| **Owner** | reviewer |
| **Inputs** | Target files, STATE.md, DECISIONS.md, checklist.md, TODOS.md |
| **Outputs** | Review summary, verdict, STATE.md updated |
| **Triggers** | `CODE_REVIEW_REQUESTED` |

---

## Purpose

Review code for quality, security, and correctness using a structured two-pass approach. Read-only analysis by default — only modifies files if the user explicitly chooses to fix an issue. Produces actionable findings categorized by severity.

---

## Cognitive Mode

**Paranoid Staff Engineer.** You are looking for the bugs that pass CI, the security holes that look like features, the edge cases that only surface in production at 2am. Be thorough. Be skeptical. Be kind in delivery.

---

## Procedure

### Step 0 — Scope Challenge

Before reviewing any code, answer these questions:

1. **What changed?** Get the diff: `git diff origin/main --stat` and `git diff origin/main` for the full diff. If reviewing specific files rather than a branch diff, read those files.
2. **What existing code already handles this concern?** Check if the new code duplicates existing patterns. Flag any unnecessary rebuilding.
3. **Read DECISIONS.md** — understand naming patterns, architecture choices, and conventions the code should follow.
4. **Read TODOS.md** (if exists) — does this change address any open TODOs? Does it create work that should become a TODO?

---

### Step 1 — Read the Checklist

Read `.claude/skills/code-review/checklist.md`.

**If the file cannot be read, STOP and report the error.** Do not proceed without the checklist.

Note the suppressions — items listed under "DO NOT Flag" should be skipped.

---

### Step 2 — Read the Full Diff

Read the complete diff before making any comments. This prevents flagging issues that are already addressed elsewhere in the same change.

---

### Step 3 — Two-Pass Review

Apply the checklist against the diff in two passes:

#### Pass 1 — CRITICAL (Must Fix)
- Security vulnerabilities
- Data safety issues
- Trust boundary violations

For each CRITICAL finding:
- State the problem: `file:line` + one-line description
- Explain the risk: what could go wrong in production
- Recommend a fix: specific, actionable

#### Pass 2 — INFORMATIONAL (Should Fix / Consider)
- Logic & edge cases
- Code quality
- Consistency
- Test gaps
- Performance
- Interaction friction (user-facing code only): unnecessary steps, hardcoded workflows, deferred permission asks. Reference: `.claude/skills/friction-audit/CHECKLIST.md`

For each INFORMATIONAL finding:
- State the problem: `file:line` + one-line description
- Suggest improvement: one-line recommendation

**Be terse.** One line problem, one line fix. No preamble.

---

### Step 4 — Failure Mode Analysis

For each new codepath introduced in the diff:

1. Describe one realistic way it could fail in production (timeout, null reference, race condition, stale data, etc.)
2. Check whether:
   - A test covers that failure
   - Error handling exists for it
   - The user would see a clear error or a silent failure

If any failure mode has **no test AND no error handling AND would be silent**, flag it as a **CRITICAL GAP**.

---

### Step 5 — Output Findings

**Always output ALL findings** — both critical and informational.

Format the output as:

```
## Code Review: [N] issues ([X] critical, [Y] informational)

### CRITICAL
1. [file:line] — [problem] → [fix]
2. ...

### INFORMATIONAL
1. [file:line] — [problem] → [suggestion]
2. ...

### Failure Modes
[codepath] — [failure scenario] — [covered? / gap?]

### TODOS Cross-Reference
- Addresses: [TODO items this change completes]
- Creates: [new work that should become a TODO]
```

**If CRITICAL issues found:** For EACH critical issue, present it individually with:
- The problem and recommended fix
- Options: A) Fix it now, B) Acknowledge and proceed, C) False positive — skip
- If the user chooses A (fix), apply the fix. This is the ONLY case where this skill modifies files.

**If only informational issues found:** Output findings. No further action needed.

**If no issues found:** Output `Code Review: No issues found.`

---

### Step 6 — Unresolved Decisions

If any critical issue was presented but the user did not respond or interrupted, list it under "Unresolved decisions that may surface later." Never silently default.

---

### Step 7 — Issue Verdict

- Default verdict is **NEEDS WORK**. The code must earn approval.
- To issue **APPROVED**, cite evidence for each:
  - Zero CRITICAL issues (or all fixed/acknowledged)
  - Code works per requirements
  - Edge cases handled
  - All Definition of Done items satisfied
- If any item lacks evidence, verdict remains **NEEDS WORK** with specific, actionable feedback.

---

### Step 8 — Update STATE.md

Write review summary and verdict to STATE.md.

---

## Constraints

- Read-only by default — only modifies files if user explicitly chooses "Fix it now"
- Never approves code without actually reading it
- Always reads the checklist before reviewing
- Always reads the full diff before commenting — do not flag issues already addressed in the diff
- Never commits, pushes, or creates PRs — review only
- Respect suppressions — do not flag items listed in the suppressions section

---

## Primary Agent

reviewer

---

## Definition of Done

- [ ] Scope challenge completed (Step 0)
- [ ] Checklist read
- [ ] Full diff read before any comments
- [ ] Pass 1 (CRITICAL) completed
- [ ] Pass 2 (INFORMATIONAL) completed
- [ ] Failure mode analysis completed
- [ ] TODOS.md cross-referenced (if exists)
- [ ] All findings categorized and output
- [ ] Critical issues presented individually for user decision
- [ ] Verdict issued with evidence
- [ ] STATE.md updated with review summary

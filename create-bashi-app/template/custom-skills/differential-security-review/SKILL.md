---
id: SKL-0030
name: Differential Security Review
description: |
  Security-focused review of code changes using git diff analysis. Identifies
  security implications of recent modifications — new attack surfaces, removed
  protections, changed auth logic, and risky refactors. Complements SKL-0016
  (Code Review) with a security lens on diffs.
version: 1.0
owner: reviewer
triggers:
  - DIFF_SECURITY_REVIEW_REQUESTED
inputs:
  - Git diff (staged, unstaged, or branch comparison)
  - .claude/project/STATE.md
  - .claude/project/knowledge/DECISIONS.md
outputs:
  - Differential security report
  - .claude/project/STATE.md (updated)
tags:
  - security
  - review
  - diff
  - custom
---

# Skill: Differential Security Review

## Metadata

| Field | Value |
|-------|-------|
| **Skill ID** | SKL-0030 |
| **Version** | 1.0 |
| **Owner** | reviewer |
| **Inputs** | Git diff, STATE.md, DECISIONS.md |
| **Outputs** | Differential security report, STATE.md updated |
| **Triggers** | `DIFF_SECURITY_REVIEW_REQUESTED` |

---

## Purpose

Review code *changes* (not the full codebase) through a security lens. Every diff is a potential new attack surface. This skill identifies security implications of recent modifications — things a standard code review misses because it focuses on correctness, not security.

Inspired by [Trail of Bits' differential-review skill](https://github.com/trailofbits/skills).

> **See also:** For full codebase security audit, see SKL-0015 (Security Audit).

---

## Procedure

### Step 1 — Collect the Diff

Determine the diff scope:
1. If a branch is specified: `git diff main...HEAD`
2. If staged changes exist: `git diff --cached`
3. Otherwise: `git diff` (unstaged changes)
4. If no changes found: report "No changes to review" and stop

List all modified files and categorize by risk:

| File Category | Risk Level | Examples |
|---------------|-----------|---------|
| Auth/session handling | HIGH | `auth/`, `middleware/`, `session/`, `*auth*`, `*login*` |
| API endpoints | HIGH | `routes/`, `api/`, `controllers/` |
| Database queries | HIGH | `*model*`, `*query*`, `*migration*` |
| Configuration | MEDIUM | `config/`, `.env*`, `docker-compose*` |
| Input handling | MEDIUM | `*form*`, `*input*`, `*validation*` |
| UI rendering | MEDIUM | `*template*`, `*component*` (XSS risk) |
| Tests | LOW | `test/`, `spec/`, `__tests__/` |
| Documentation | LOW | `docs/`, `*.md` |

### Step 2 — Analyze Security-Sensitive Changes

For each HIGH and MEDIUM risk file, examine the diff for:

**Added code:**
- New API endpoints without authentication checks
- New database queries (SQL injection surface)
- New user input handling without validation
- New file upload or download functionality
- New external service calls without error handling
- New environment variable reads without defaults

**Removed code:**
- Removed authentication or authorization checks
- Removed input validation or sanitization
- Removed rate limiting
- Removed encryption or hashing
- Removed CSRF/XSS protections
- Removed error handling around security-sensitive operations

**Changed code:**
- Modified auth logic (any change to who-can-access-what)
- Changed encryption algorithms or key handling
- Weakened validation rules
- Changed session management
- Modified CORS or CSP policies

### Step 3 — Cross-Reference Decisions

Read DECISIONS.md to check if any security-relevant changes were intentional and documented. If a change looks risky but has a documented decision, note it as "Acknowledged risk" rather than a finding.

### Step 4 — Generate Report

For each finding:
- **File and diff context** (the specific lines changed)
- **Risk category** (new surface / removed protection / weakened control)
- **Severity** (CRITICAL / HIGH / MEDIUM / LOW)
- **Before vs. After** (what changed and why it matters)
- **Recommendation** (keep, revert, or mitigate)

### Step 5 — Update STATE.md

Record review completion, files analyzed, and severity summary.

---

## Constraints

- Read-only analysis — does not modify source files
- Reviews diffs only, not the entire codebase (use SKL-0015 for full audits)
- Does not fix issues — provides actionable recommendations
- If no security-relevant changes are found, say so explicitly (a clean diff review is a valid result)

---

## Primary Agent

reviewer

---

## Definition of Done

- [ ] Diff scope determined and all changed files categorized by risk
- [ ] All HIGH and MEDIUM risk files analyzed for security implications
- [ ] Added, removed, and changed code examined separately
- [ ] Cross-referenced with DECISIONS.md for intentional changes
- [ ] Each finding has file, diff context, severity, and recommendation
- [ ] STATE.md updated

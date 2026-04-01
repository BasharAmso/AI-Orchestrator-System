---
id: SKL-0037
name: Friction Audit
description: |
  Audit user-facing flows for unnecessary friction. Produces a friction report
  with scored findings and actionable fixes. Use this skill before launch
  readiness checks, after major UX changes, or when user drop-off is suspected.
version: 1.0.0
owner: reviewer
triggers:
  - FRICTION_AUDIT_REQUESTED
inputs:
  - Target flows (user-specified or auto-detected from recent tasks)
  - Friction Audit Checklist (.claude/skills/friction-audit/CHECKLIST.md)
  - Project source files (src/, docs/, UI components)
outputs:
  - Friction Audit Report (in Execution Summary or standalone file)
  - .claude/project/STATE.md (updated)
tags:
  - review
  - ux
  - friction
  - quality
---

# Friction Audit

> Audit user-facing flows for unnecessary friction. Produces a friction report with scored findings and actionable fixes.

## When to Use

- Explicitly via `/trigger FRICTION_AUDIT_REQUESTED`
- Automatically referenced by other skills (Frontend Dev, Code Review, UAT, Growth, Mobile Dev) when working on user-facing tasks
- Before launch readiness checks
- After major UX changes

## Inputs

| Input | Source | Required |
|-------|--------|----------|
| Target flows | User specifies, or auto-detect from recent tasks | Yes |
| Friction Audit Checklist | `.claude/skills/friction-audit/CHECKLIST.md` | Yes |
| Project source files | `src/`, `docs/`, UI components | Yes |

## Procedure

### Step 1: Identify User-Facing Flows

1. If the user specified flows: use those.
2. If not: scan recent completed tasks and files modified for UI components, pages, forms, and onboarding flows.
3. List all flows to audit (e.g., "signup flow", "checkout", "settings page").

### Step 2: Run Checklist Against Each Flow

For each identified flow, evaluate every item in the Friction Audit Checklist (`CHECKLIST.md`):

- **Core Questions** (5 items) — always evaluate
- **Interaction Friction** (6 items) — evaluate if flow has UI
- **Onboarding Friction** (4 items) — evaluate if flow involves new users
- **Cognitive Friction** (4 items) — always evaluate

Score each item: Pass / Fail / N/A

### Step 3: Calculate Friction Score

```
Friction Score = (items passed / items evaluated) * 100
```

| Score | Rating |
|-------|--------|
| 90-100% | Low friction — ready to ship |
| 70-89% | Moderate friction — fix before launch |
| Below 70% | High friction — needs redesign |

### Step 4: Generate Report

Write findings to the Execution Summary (not a separate file unless the user requests it):

```
## Friction Audit Report

- **Flows audited:** [count]
- **Overall score:** [X]% ([rating])
- **Items passed:** [N] of [M]

### Findings

| Flow | Score | Top Issues |
|------|-------|------------|
| [flow name] | [X]% | [top 2-3 friction points] |

### Recommended Fixes (Priority Order)

1. [Most impactful fix — what to change and why]
2. [Second fix]
3. [Third fix]
```

### Step 5: Log Friction Findings

If any flow scores below 70%, log to the Execution Summary:
```
Friction check: [N] flows audited, [M] flagged (scores below 70%)
```

## Definition of Done

- [ ] All user-facing flows identified and audited
- [ ] Each flow scored against the full checklist
- [ ] Findings reported with actionable fixes
- [ ] No flow scores below 70% without a documented fix plan

## Output Contract

| Field | Value |
|-------|-------|
| **Artifacts** | Friction Audit Report (in Execution Summary or standalone file if requested) |
| **State Update** | `.claude/project/STATE.md` — mark task complete, log friction scores |
| **Handoff Event** | `TASK_COMPLETED` (friction audit complete) |

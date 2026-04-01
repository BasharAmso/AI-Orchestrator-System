---
id: SKL-0002
name: Quality Review
description: |
  Review code, content, or deliverables for quality, clarity, and correctness.
  Adapts review criteria based on artifact type (code, documentation, PRD,
  design, configuration). Use this skill when a quality review has been
  requested on completed work.
version: 2.0
owner: reviewer
triggers:
  - QUALITY_REVIEW_REQUESTED
inputs:
  - Files or content to review (from event description or active task)
  - .claude/project/STATE.md
  - .claude/project/knowledge/DECISIONS.md (for consistency checks)
outputs:
  - Review summary with findings and suggestions
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
| **Version** | 2.0 |
| **Owner** | reviewer |
| **Inputs** | Files or content to review, STATE.md, DECISIONS.md |
| **Outputs** | Review summary with findings and suggestions, STATE.md updated |
| **Triggers** | `QUALITY_REVIEW_REQUESTED` |

---

## Purpose

Run a structured review for quality, clarity, and correctness on any project artifact. Unlike Code Review (SKL-0016) which focuses on code correctness and security, this skill reviews *any* deliverable — documentation, PRDs, architecture docs, config files, or content. Adapts its checklist based on the artifact type.

> For code-specific review, use SKL-0016 (Code Review). For security-specific review, use SKL-0015 (Security Audit). This skill handles everything else.

---

## Procedure

### Step 1 — Identify Target and Artifact Type

Read the event description or active task to determine what needs review. Classify the artifact:

| Artifact Type | Examples | Primary Checklist |
|---------------|----------|-------------------|
| **Code** | Source files, scripts, configs | Redirect to SKL-0016 (Code Review) |
| **Documentation** | README, API docs, guides, changelogs | Documentation checklist |
| **PRD / GDD** | docs/PRD.md, docs/GDD.md | Product document checklist |
| **Architecture** | docs/ARCHITECTURE.md, ADRs | Architecture checklist |
| **Design** | docs/ux/*.md, wireframes, flow docs | Design document checklist |
| **Configuration** | .env.example, CI/CD configs, MCP configs | Configuration checklist |
| **Content** | Landing page copy, email templates, blog posts | Content checklist |

If the artifact is code, suggest using SKL-0016 instead and stop. This skill is for non-code artifacts.

### Step 2 — Apply Artifact-Specific Checklist

#### Documentation Checklist

| Check | Pass Criteria |
|-------|--------------|
| Structure | Logical heading hierarchy (H1 → H2 → H3, no skipped levels) |
| Completeness | No empty sections, no TODO placeholders, no "TBD" |
| Accuracy | Claims match actual code/config (spot-check 2-3 references) |
| Audience fit | Language matches target audience (technical for API docs, plain for README) |
| Links | Internal links work, external links are relevant |
| Freshness | No outdated version numbers, file paths, or feature descriptions |

#### Product Document Checklist (PRD / GDD)

| Check | Pass Criteria |
|-------|--------------|
| Problem statement | Clearly articulated with evidence |
| Target user | Specifically defined (not "everyone") |
| Scope boundaries | In-scope and out-of-scope are explicit |
| Success metrics | Measurable with baseline, target, and timeframe |
| Kill rule | Defined (what signal means "stop building this") |
| Consistency | Doesn't contradict DECISIONS.md |
| Completeness | All required sections present per SKL-0004/SKL-0028 template |

#### Architecture Checklist

| Check | Pass Criteria |
|-------|--------------|
| Tech stack | Justified (not just "because it's popular") |
| Component boundaries | Clear ownership and interfaces between components |
| Data model | Entities, relationships, and storage decisions documented |
| Trade-offs | Each decision notes what was traded for what |
| Scalability | At least one note on what happens under 10x load |
| Dependencies | External service dependencies identified with fallback strategy |

#### Design Document Checklist

| Check | Pass Criteria |
|-------|--------------|
| User flow | Happy path + at least 2 error/edge paths documented |
| All states | Empty, loading, error, success, and partial states covered |
| Accessibility | WCAG 2.1 AA considerations noted |
| Responsiveness | Mobile and desktop layouts addressed |
| Consistency | Matches existing project patterns and conventions |

#### Configuration Checklist

| Check | Pass Criteria |
|-------|--------------|
| No secrets | No hardcoded credentials, tokens, or keys |
| Documentation | Each setting has a comment or is documented elsewhere |
| Defaults | Sensible defaults that work out of the box |
| Environment parity | Dev/staging/prod differences are explicit, not implicit |

#### Content Checklist

| Check | Pass Criteria |
|-------|--------------|
| Clarity | Plain language, target 8th-grade reading level for public content |
| Accuracy | No unsupported claims or fabricated data |
| Voice consistency | Matches brand/project tone |
| CTA quality | Clear, actionable, no "click here" |
| SEO basics | Heading hierarchy, meta-ready structure |

### Step 3 — Produce Review Summary

Structure findings in three tiers:

| Tier | Meaning | Action |
|------|---------|--------|
| **Must Fix** | Incorrect, incomplete, or contradictory | Block until resolved |
| **Should Fix** | Unclear, inconsistent, or below quality bar | Fix before next milestone |
| **Nice to Have** | Polish, style, or minor improvements | Fix when convenient |

For each finding, provide:
- **Location** (file + section/line)
- **Issue** (what's wrong)
- **Fix** (specific recommendation)

### Step 4 — Issue Verdict

| Verdict | Criteria |
|---------|----------|
| **APPROVED** | Zero Must Fix items. Should Fix items are minor. |
| **NEEDS WORK** | 1+ Must Fix items, OR 3+ Should Fix items. |

Default verdict is **NEEDS WORK** — the artifact must earn approval.

### Step 5 — Update STATE.md

Record review completion, verdict, and finding counts.

---

## Constraints

- Does not review code — redirect to SKL-0016 (Code Review) for source files
- Does not review security — redirect to SKL-0015 (Security Audit) for security concerns
- Read-only analysis — does not modify the reviewed artifact unless the user explicitly asks
- Every criticism must include a specific fix recommendation
- Beginner-friendly: review summary should be understandable by a non-technical reader

---

## Primary Agent

reviewer

---

## Definition of Done

- [ ] Artifact type identified and correct checklist applied
- [ ] All checklist items evaluated
- [ ] Findings categorized (Must Fix / Should Fix / Nice to Have)
- [ ] Each finding has location, issue, and fix recommendation
- [ ] Verdict issued (APPROVED / NEEDS WORK)
- [ ] Must Fix items added as tasks to Next Task Queue (if NEEDS WORK)
- [ ] STATE.md updated with verdict and finding counts

## Output Contract

| Field | Value |
|-------|-------|
| **Artifacts** | Review summary with categorized findings (Must Fix / Should Fix / Nice to Have) |
| **State Update** | `.claude/project/STATE.md` — mark task complete, log verdict and finding counts |
| **Handoff Event** | `TASK_COMPLETED` (if APPROVED) or `REWORK_REQUESTED` (if NEEDS WORK) |

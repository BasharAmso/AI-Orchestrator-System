---
id: SKL-0027
name: Problem Stress Test
description: |
  Stress-test a startup or product idea against Uri Levine's problem-validation
  frameworks from "Fall in Love with the Problem, Not the Solution." Produces a
  ten-lens challenge report with scores and an advisory verdict (Strong / Needs
  Work / Weak). Use this skill when validating whether a problem is worth solving
  before committing resources. The user always decides — this skill advises, never blocks.
version: 1.0
owner: product-manager
triggers:
  - PROBLEM_VALIDATION_REQUESTED
inputs:
  - Idea description (from event or docs/PRD.md)
  - .claude/project/knowledge/RESEARCH.md (raw intake)
  - docs/PRD.md (if exists)
outputs:
  - docs/PROBLEM_STRESS_TEST.md
  - .claude/project/STATE.md (updated)
  - .claude/project/knowledge/DECISIONS.md (verdict logged)
tags:
  - validation
  - planning
  - product
---

# Skill: Problem Stress Test

## Metadata

| Field | Value |
|-------|-------|
| **Skill ID** | SKL-0027 |
| **Version** | 1.0 |
| **Owner** | product-manager |
| **Inputs** | Idea description, PRD stub (if any), RESEARCH.md |
| **Outputs** | `docs/PROBLEM_STRESS_TEST.md`, STATE.md updated, DECISIONS.md updated |
| **Triggers** | `PROBLEM_VALIDATION_REQUESTED` |

---

## Purpose

Challenge a product or startup idea through ten structured lenses derived from Uri Levine's "Fall in Love with the Problem, Not the Solution." The goal is to strengthen ideas before resources are committed — not to reject them. Every lens produces a score, a one-paragraph assessment, and (if not passing) a strengthening question the founder should answer.

---

## Cognitive Mode

**The Seasoned Mentor.** You are a veteran startup advisor who has watched hundreds of founders succeed and fail. You are deeply constructive — you want this idea to succeed — but you refuse to let enthusiasm substitute for evidence. You challenge with warmth, not hostility. You ask the hard questions now so the market doesn't ask them later at a much higher cost.

When an idea is weak, say so plainly and explain exactly what would make it stronger. When an idea is strong, say so with genuine excitement and point out what makes it compelling.

This is not a gatekeeping exercise. It is a pressure test designed to strengthen the idea before resources are committed.

---

## Procedure

### Phase A — Input Collection

#### Step 1: Read Idea Context

Gather all available context about the idea:

1. Read the triggering event description from `.claude/project/EVENTS.md`
2. Read `docs/PRD.md` (if exists) — extract problem statement, target user, proposed solution
3. Read `.claude/project/knowledge/RESEARCH.md` — check for raw intake notes about this idea
4. If context is insufficient, read any idea-related entries in `.claude/project/knowledge/DECISIONS.md`

Extract and note:
- **Problem statement** (if articulated)
- **Target user** (if identified)
- **Proposed solution** (if described)
- **Evidence of validation** (conversations, data, observations)
- **Constraints mentioned**

#### Step 2: Determine Input Richness

Categorize the available input to calibrate the stress test fairly:

| Category | Criteria | Lens Behavior |
|----------|----------|---------------|
| **Rich** | Problem statement + target user + evidence of real-world validation | All 10 lenses scored normally |
| **Moderate** | Problem statement + target user present, but no external validation evidence | All 10 lenses run; lenses 2, 6, 7 flagged as "Needs More Data" instead of scored as failures |
| **Lean** | Just a one-liner or minimal description | Only lenses 1, 3, 4, 5, 9, 10 scored; rest marked "Skipped — insufficient input." Score normalized to 20-point scale |

> This prevents punishing early-stage ideas that simply haven't been fleshed out yet.

---

### Phase B — Ten-Lens Stress Test

Run each applicable lens. For each, assign a score and write a one-paragraph assessment. If the score is not Pass, provide a **strengthening question** — a specific question the founder should answer to improve on that dimension.

Read `LENSES.md` in this skill folder before proceeding with the evaluation. Apply each of the 10 lenses to the idea.

**The 10 lenses (each worth max 2 pts):**

1. **Problem Love Test** — Does the description lead with user pain or product features?
2. **The 100 Conversations Rule** — Is there evidence of real-world validation?
3. **Problem Scale & Frequency** — How many people have this problem, how often?
4. **Value Creation Test** — Does solving this create clear, measurable value?
5. **Disruption Framework** — How are people solving this today? What changes?
6. **Founder-Problem Fit** — Does the problem extend beyond the founder?
7. **Retention Signal Test** — Would users return repeatedly?
8. **Entrepreneurial Zone Check** — Does commitment match the timeline?
9. **Narrative Test** — Is the problem narrative more compelling than the solution narrative?
10. **Phase Discipline** — Is the idea focused on one core problem?

---

### Phase C — Scoring & Verdict

#### Step 1: Calculate Total Score

- **Full scoring** (Rich or Moderate input): Sum all 10 lens scores. Total possible = 20.
- **Normalized scoring** (Lean input): Sum scored lenses only, then normalize: `(earned points / possible points) × 20`. Round to nearest integer.
- For **Moderate** input: Lenses marked "Needs More Data" score as Partial (1 pt) — benefit of the doubt, not penalized as failures.

#### Step 2: Determine Verdict

| Score Range | Verdict | Meaning |
|-------------|---------|---------|
| **16–20** | **Strong** | Problem is well-defined, validated, and worth pursuing. Proceed to PRD with confidence. |
| **10–15** | **Needs Work** | Promising foundation but gaps exist. Address the strengthening questions before committing resources. |
| **0–9** | **Weak** | Fundamental questions unanswered. Strongly recommend more problem discovery before building anything. |

#### Step 3: Write Challenge Report

Write the full report to `docs/PROBLEM_STRESS_TEST.md` using this template:

```markdown
# Problem Stress Test Report

> Generated by SKL-0027 v1.0 | Date: YYYY-MM-DD
> Based on Uri Levine's "Fall in Love with the Problem, Not the Solution"

## Idea Under Test

**Name:** [from intake]
**Problem Statement:** [extracted, or "Not articulated"]
**Target User:** [extracted, or "Not identified"]
**Input Richness:** Rich / Moderate / Lean

---

## Lens Results

| # | Lens | Score | Assessment |
|---|------|-------|------------|
| 1 | Problem Love Test | Pass / Partial / Fail | [one-line summary] |
| 2 | 100 Conversations Rule | Pass / Partial / Fail / Skipped | [one-line summary] |
| 3 | Problem Scale & Frequency | Pass / Partial / Fail | [one-line summary] |
| 4 | Value Creation Test | Pass / Partial / Fail | [one-line summary] |
| 5 | Disruption Framework | Pass / Partial / Fail | [one-line summary] |
| 6 | Founder-Problem Fit | Pass / Partial / Fail / Skipped | [one-line summary] |
| 7 | Retention Signal Test | Pass / Partial / Fail / Skipped | [one-line summary] |
| 8 | Entrepreneurial Zone | Pass / Partial / Fail / Skipped | [one-line summary] |
| 9 | Narrative Test | Pass / Partial / Fail | [one-line summary] |
| 10 | Phase Discipline | Pass / Partial / Fail | [one-line summary] |

**Total Score:** X / 20
**Verdict:** Strong / Needs Work / Weak

---

## Detailed Assessments

### Lens 1: Problem Love Test — [Score]

[One paragraph assessment]

[If not Pass] **Strengthening question:** [question]

[Repeat for each lens]

---

## Top Strengths

1. [strongest aspect]
2. [second strongest]

## Critical Gaps

1. [most important gap + what to do about it]
2. [second gap + what to do about it]

---

## Recommended Next Steps

[Tailored based on verdict:]

- **Strong:** Proceed to PRD creation. Your problem foundation is solid.
- **Needs Work:** Address these N strengthening questions, then re-run this stress test or proceed with awareness of gaps: [list specific questions]
- **Weak:** Invest in problem discovery before building. Suggested actions: [specific actions like "talk to 10 people who might have this problem" or "observe how people currently work around this"].

---

> **Advisory Notice:** This is an advisory assessment, not a gate. The user has final authority on whether to proceed. Strong ideas can have weak early articulation; weak scores may reflect insufficient input rather than a bad idea.
```

#### Step 4: Update System State

1. Log the verdict as a decision in `.claude/project/knowledge/DECISIONS.md`:
   ```
   ### DEC-XXXX — Problem Stress Test Verdict: [Idea Name]
   - **Date:** YYYY-MM-DD
   - **Decision:** Verdict is [Strong/Needs Work/Weak] (score: X/20)
   - **Rationale:** [one-sentence summary of strongest and weakest lenses]
   - **Status:** Active
   ```

2. Update `.claude/project/STATE.md` — note the stress test completion and verdict in the current task status.

#### Step 5: Present Summary to User

Print a concise summary (under 200 words per context policy):

- Verdict and score
- Top 2 strengths
- Top 2 gaps (with strengthening questions)
- File path to full report
- Reminder: "This is advisory — you decide whether to proceed."

---

## Constraints

- Never blocks idea progression — advisory only, user has final authority
- Never overwrites an existing `docs/PROBLEM_STRESS_TEST.md` without confirmation
- Never fabricates evidence of validation — assess only what's actually present in the input
- Never penalizes lean input as if it were rich input — use the input richness adaptation
- Never dumps the full report in chat — write to file, summarize in chat
- Cognitive mode (The Seasoned Mentor) must be maintained throughout — constructive, warm, direct
- Each lens assessment must be grounded in specific observations from the input, not generic advice

---

## Primary Agent

product-manager

---

## Definition of Done

- [ ] Idea context read from all available sources (events, PRD, research)
- [ ] Input richness determined (Rich / Moderate / Lean)
- [ ] All applicable lenses scored with one-paragraph assessments
- [ ] Strengthening questions provided for every non-Pass lens
- [ ] Total score calculated (normalized if Lean input)
- [ ] Verdict determined (Strong / Needs Work / Weak)
- [ ] Full report written to `docs/PROBLEM_STRESS_TEST.md`
- [ ] Verdict logged in DECISIONS.md
- [ ] STATE.md updated
- [ ] Concise summary presented in chat (under 200 words)

## Output Contract

| Field | Value |
|-------|-------|
| **Artifacts** | `docs/PROBLEM_STRESS_TEST.md` |
| **State Update** | `.claude/project/STATE.md` — mark task complete, log verdict |
| **Decision Log** | `.claude/project/knowledge/DECISIONS.md` — stress test verdict and score |
| **Handoff Event** | `TASK_COMPLETED` (advisory only, user decides next steps) |

---
id: SKL-0027
name: Problem Stress Test
description: |
  Stress-test a startup or product idea against Uri Levine's problem-validation
  frameworks from "Fall in Love with the Problem, Not the Solution." Produces a
  ten-lens challenge report with an advisory verdict (Strong / Needs Work / Weak).
  The user always decides whether to proceed — this skill advises, never blocks.
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

---

#### Lens 1: Problem Love Test (max 2 pts)

> *"If their pitch starts with 'our system' or 'our company is,' they're solution-focused. If it begins with 'the problem we are solving is,' they're problem-focused."* — Uri Levine

**Evaluate:** Does the idea description lead with user pain or product features?

| Score | Criteria |
|-------|----------|
| **Pass (2)** | The description centers on a specific, named problem experienced by identifiable people. The solution is secondary. |
| **Partial (1)** | A problem is mentioned but the description gravitates quickly toward the solution or product features. |
| **Fail (0)** | The description is entirely solution-first ("We built X" / "An app that does Y") with no articulated problem. |

**Strengthening question:** "Can you describe the problem in one sentence without mentioning your product or solution?"

---

#### Lens 2: The 100 Conversations Rule (max 2 pts)

> *"Go and speak with 100 people and understand their perception of the problem."* — Uri Levine

**Evaluate:** Is there evidence of real-world validation — conversations, surveys, observed behavior?

| Score | Criteria |
|-------|----------|
| **Pass (2)** | Specific conversations, user quotes, behavioral data, or survey results referenced. |
| **Partial (1)** | Anecdotal evidence — "people I know have this problem" or "I've seen others struggle with this." |
| **Fail (0)** | No evidence of talking to anyone outside the founder's own experience. |

**Strengthening question:** "Describe one conversation with someone who has this problem. What did they say unprompted?"

---

#### Lens 3: Problem Scale & Frequency (max 2 pts)

> *"If you're the only person on the planet with the problem, see a therapist — it's faster and cheaper than building a startup."* — Uri Levine

**Evaluate:** How many people have this problem, how often does it occur, and how painful is it? Apply the **Toothbrush Model**: is this something people would use twice daily?

| Score | Criteria |
|-------|----------|
| **Pass (2)** | Large addressable population AND high frequency or high severity. Clear evidence the problem is widespread. |
| **Partial (1)** | Niche but high-pain, OR broad but low-frequency. The scale/frequency combination is uncertain. |
| **Fail (0)** | Unclear who has the problem, how often it occurs, or evidence suggests very few people are affected. |

**Strengthening question:** "How many people experience this problem, and how often? Is this a daily annoyance or an annual inconvenience?"

---

#### Lens 4: Value Creation Test (max 2 pts)

> *"The most straightforward way to create value is to solve a problem. When you provide a solution to someone's problem, you're generating value for that person."* — Uri Levine

**Evaluate:** Does solving this problem create clear, measurable value?

| Score | Criteria |
|-------|----------|
| **Pass (2)** | Value proposition is concrete and expressible in one sentence. Clear willingness-to-pay or behavior-change signal. |
| **Partial (1)** | Value is implied but not quantified or articulated crisply. |
| **Fail (0)** | No clear value proposition, or the value seems trivial ("nice to have" not "need to have"). |

**Strengthening question:** "What specific thing improves in your user's life, and would they pay for that improvement (or change their behavior to get it for free)?"

---

#### Lens 5: Disruption Framework (max 2 pts)

> *"The most important thing about disruption is that it is not about technology — it is about changing behavior and, as a result, changing the market equilibrium."* — Uri Levine

**Evaluate:** How are people solving this problem today? What changes if this solution exists?

| Score | Criteria |
|-------|----------|
| **Pass (2)** | Current workarounds are identified, are clearly painful, and the proposed approach represents a meaningful behavior change. Bonus: incumbents are ignoring this space. |
| **Partial (1)** | Workarounds mentioned but the improvement over status quo is incremental, not disruptive. |
| **Fail (0)** | No awareness of current solutions, or the market is already well-served by existing options. |

**Strengthening question:** "How are people solving this problem right now, and why is that approach unacceptable?"

---

#### Lens 6: Founder-Problem Fit (max 2 pts)

> *"You are only a sample of one."* — Uri Levine, Ch. 7

**Evaluate:** Is the founder projecting personal frustration onto a market, or is there evidence this problem extends beyond them?

| Score | Criteria |
|-------|----------|
| **Pass (2)** | Founder has personal experience AND has validated that the problem extends beyond themselves. |
| **Partial (1)** | Founder has personal experience but hasn't validated breadth. Or: building for a market they understand deeply through professional exposure. |
| **Fail (0)** | No personal connection to the problem (building for a market they don't understand) OR extreme projection with no external validation. |

**Strengthening question:** "Beyond your own experience, who else has this problem? How do you know they're not just being polite when they agree?"

---

#### Lens 7: Retention Signal Test (max 2 pts)

> *"Customer retention is the solitary metric indicating product-market fit. If you offer value, your customers will return; if you don't, they'll disappear."* — Uri Levine

**The Bump Cautionary Tale:** Bump (backed by Sequoia) had explosive growth but zero retention — frequency of use was "essentially once in a lifetime." It failed despite viral adoption.

**Evaluate:** Would users return repeatedly, or is this a one-time use?

| Score | Criteria |
|-------|----------|
| **Pass (2)** | Clear retention mechanic — the problem recurs and the solution provides ongoing value. High-frequency use case. |
| **Partial (1)** | Retention is plausible but depends on features not yet described, or the use case is moderate-frequency. |
| **Fail (0)** | Looks like a one-and-done solution with no repeat engagement model. |

**Strengthening question:** "After someone uses this once, why would they come back tomorrow? Next week? Next month?"

---

#### Lens 8: Entrepreneurial Zone Check (max 2 pts)

> *"Your passion for making a change must be greater than your fear of failure and the alternative cost."* — Uri Levine

**Reality check:** Product-market fit took Microsoft 5 years, Netflix 10 years, Waze 4 years. The "desert of no traction" is real and prolonged.

**Evaluate:** Does the founder's commitment match the likely timeline to traction?

| Score | Criteria |
|-------|----------|
| **Pass (2)** | Founder acknowledges multi-year timeline and shows evidence of deep commitment (dedicated time, assembled team, invested resources). |
| **Partial (1)** | Enthusiasm is high but timeline expectations are unrealistic ("we'll have PMF in 3 months") or commitment level is unclear. |
| **Fail (0)** | This reads like a casual side-project with no evidence of commitment proportional to the challenge. |

**Strengthening question:** "Would you still work on this if it took 3 years to gain traction?"

---

#### Lens 9: Narrative Test (max 2 pts)

> Compare: *"I'm building an AI crowd-sourced navigation system"* vs. *"I'm devising a way to bypass traffic jams."* The second makes people lean in. — Uri Levine

**Evaluate:** Is the problem narrative more compelling than the solution narrative?

| Score | Criteria |
|-------|----------|
| **Pass (2)** | Reframing the idea as "I'm devising a way to [solve problem]" is clearly more engaging than "I'm building [product]." The problem framing makes people want to share their own experiences. |
| **Partial (1)** | Both framings are roughly equal in appeal. |
| **Fail (0)** | The solution framing is more compelling — suggesting the product is interesting but the problem isn't real enough to carry the story. |

**Strengthening question:** "Try describing your idea starting with 'I'm devising a way to...' — does that version make people lean in more?"

---

#### Lens 10: Phase Discipline (max 2 pts)

> *"The main thing is to keep the main thing the main thing."* — Uri Levine, Ch. 4

**Evaluate:** Is the idea focused on one core problem, or is it trying to solve everything at once?

| Score | Criteria |
|-------|----------|
| **Pass (2)** | Single clear problem with a defined Most Important Thing (MIT). Scope is focused. |
| **Partial (1)** | Core problem identifiable but scope creep is visible — 3+ distinct problems being addressed simultaneously. |
| **Fail (0)** | The idea is a platform/suite/ecosystem with no clear entry point or priority. Everything is equally important (which means nothing is). |

**Strengthening question:** "If you could only solve ONE aspect of this problem, which would it be and why?"

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

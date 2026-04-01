---
id: SKL-0036
name: Pitch Deck
description: |
  Create a structured pitch deck outline for investors, stakeholders, or
  partners. Covers problem, solution, market, traction, team, and ask.
  Natural output after PRD + Problem Stress Test validation.
version: 1.0
owner: product-manager
triggers:
  - PITCH_DECK_REQUESTED
inputs:
  - docs/PRD.md or docs/GDD.md
  - docs/PROBLEM_STRESS_TEST.md (if exists)
  - docs/COMPETITOR_ANALYSIS.md (if exists)
  - .claude/project/knowledge/DECISIONS.md
  - .claude/project/STATE.md
outputs:
  - docs/PITCH_DECK.md
  - .claude/project/STATE.md (updated)
tags:
  - product
  - fundraising
  - pitch
  - custom
---

# Skill: Pitch Deck

## Metadata

| Field | Value |
|-------|-------|
| **Skill ID** | SKL-0036 |
| **Version** | 1.0 |
| **Owner** | product-manager |
| **Inputs** | PRD/GDD, stress test, competitor analysis, DECISIONS.md |
| **Outputs** | `docs/PITCH_DECK.md`, STATE.md updated |
| **Triggers** | `PITCH_DECK_REQUESTED` |

---

## Purpose

After the idea has been validated (Problem Stress Test) and designed (PRD/GDD), the user may need to pitch it — to investors, stakeholders, co-founders, or potential users. This skill produces a structured pitch deck outline following the format VCs and angel investors expect to see.

---

## Procedure

### Step 1 — Gather Context

Read available documents:
1. `docs/PRD.md` or `docs/GDD.md` — problem, solution, users, scope
2. `docs/PROBLEM_STRESS_TEST.md` — validation verdict and strengths
3. `docs/COMPETITOR_ANALYSIS.md` — market landscape and differentiation
4. `DECISIONS.md` — key product decisions

If minimal context exists, interview the user for missing pieces.

### Step 2 — Build the Deck (12-Slide Structure)

Write each slide as a section in `docs/PITCH_DECK.md`:

**Slide 1: Title**
- Company/product name
- One-line tagline (from PRD elevator pitch or GDD core fantasy)
- Your name and role

**Slide 2: Problem**
- The problem in the user's language (not technical jargon)
- How many people have this problem (scale)
- How they're solving it today (painful workarounds)
- Source: PRD Problem Statement or Problem Stress Test Lens 3

**Slide 3: Solution**
- Your solution in one sentence
- 3 key features that address the problem
- Demo screenshot or mockup description (placeholder)
- Source: PRD MVP Scope or GDD Core Mechanics

**Slide 4: Market Size**
- TAM (Total Addressable Market)
- SAM (Serviceable Addressable Market)
- SOM (Serviceable Obtainable Market)
- Source: web research + PRD target users

**Slide 5: Business Model**
- How you make money
- Pricing model
- Unit economics (if known): LTV, CAC, margins
- Source: PRD or user interview

**Slide 6: Traction**
- What you've built or shipped so far
- Users, revenue, or engagement metrics (if any)
- Key milestones achieved
- If pre-launch: validation signals (conversations, waitlist, LOIs)

**Slide 7: Competition**
- Competitive landscape (2x2 matrix or comparison table)
- Your differentiation (primary differentiator)
- Source: COMPETITOR_ANALYSIS.md

**Slide 8: Go-to-Market**
- How you'll acquire your first 100 users
- Growth strategy (organic, paid, partnerships, community)
- Distribution advantage (if any)

**Slide 9: Team**
- Founder(s) background — why are you the right people?
- Key hires needed
- Advisors (if any)

**Slide 10: Financials**
- Revenue projections (if applicable)
- Key assumptions
- Burn rate and runway (if applicable)

**Slide 11: The Ask**
- How much are you raising?
- What will the money be used for? (hire, build, market)
- What milestones will it fund?

**Slide 12: Closing**
- Contact information
- One powerful closing statement (not "thank you" — use Uri Levine's advice: put your strongest argument on the last slide)

### Step 3 — Apply Uri Levine's Pitch Principles

Review the deck against these rules:
- **First and last slides get the most screen time** — make them count
- **Lead with the problem narrative** — the problem story is more compelling than the solution description
- **Emotional engagement** — investors should envision using the product themselves
- **Expect 100 rejections** — the deck should be tight enough to survive brutal Q&A

### Step 4 — Write to docs/PITCH_DECK.md

Include a note at the top:
```markdown
> This is a pitch deck **outline**, not a slide file. Use it as the content
> source for your actual presentation tool (Google Slides, Keynote, Figma, etc.).
> Each section = one slide.
```

### Step 5 — Update STATE.md

---

## Constraints

- Produces an outline document, not actual slides (no PowerPoint/Keynote generation)
- Financial projections are frameworks, not predictions — clearly label assumptions
- Market size estimates use available data — flag if numbers are rough
- Does not fabricate traction or metrics — if pre-launch, say so honestly
- Never makes promises the product can't keep

---

## Primary Agent

product-manager

---

## Definition of Done

- [ ] All 12 slides have content
- [ ] Problem slide uses user language, not jargon
- [ ] Solution slide is one sentence + 3 features
- [ ] Market size includes TAM/SAM/SOM
- [ ] Competition slide has comparison (matrix or table)
- [ ] Ask slide is specific (amount + use of funds)
- [ ] Closing slide has a strong statement (not "thank you")
- [ ] Uri Levine pitch principles applied
- [ ] Written to docs/PITCH_DECK.md
- [ ] STATE.md updated

## Output Contract

| Field | Value |
|-------|-------|
| **Artifacts** | `docs/PITCH_DECK.md` (12-slide outline) |
| **State Update** | `.claude/project/STATE.md` — mark task complete, log files modified |
| **Handoff Event** | `TASK_COMPLETED` (pitch deck outline complete) |

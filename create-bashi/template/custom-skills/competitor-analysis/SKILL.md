---
id: SKL-0035
name: Competitor Analysis
description: |
  Structured competitor research: features, pricing, positioning, gaps, and
  differentiation strategy. Feeds into PRD Writing (SKL-0004) and Problem
  Stress Test (SKL-0027) with better market context.
version: 1.0
owner: product-manager
triggers:
  - COMPETITOR_ANALYSIS_REQUESTED
inputs:
  - Competitor names or URLs (from user)
  - docs/PRD.md (if exists — value prop, target users)
  - .claude/project/knowledge/RESEARCH.md
  - .claude/project/STATE.md
outputs:
  - docs/COMPETITOR_ANALYSIS.md
  - .claude/project/knowledge/RESEARCH.md (updated)
  - .claude/project/STATE.md (updated)
tags:
  - product
  - marketing
  - research
  - custom
---

# Skill: Competitor Analysis

## Metadata

| Field | Value |
|-------|-------|
| **Skill ID** | SKL-0035 |
| **Version** | 1.0 |
| **Owner** | product-manager |
| **Inputs** | Competitor names/URLs, PRD.md, RESEARCH.md |
| **Outputs** | `docs/COMPETITOR_ANALYSIS.md`, RESEARCH.md updated, STATE.md updated |
| **Triggers** | `COMPETITOR_ANALYSIS_REQUESTED` |

---

## Purpose

Understand the competitive landscape before committing to a product direction. This skill produces a structured analysis that feeds into PRD Writing and Problem Stress Test — helping answer "how are people solving this today?" and "what makes us different?" with real data instead of guesses.

---

## Procedure

### Step 1 — Identify Competitors

Ask the user (or extract from PRD/research):
- **Direct competitors:** Same problem, same audience, same approach
- **Indirect competitors:** Same problem, different approach (workarounds, manual processes)
- **Aspirational references:** Not competitors but products whose quality/UX you want to match

Aim for 3-5 direct + 2-3 indirect.

### Step 2 — Research Each Competitor

For each competitor, gather (via web search):

| Dimension | What to Find |
|-----------|-------------|
| **Product** | Core features, unique capabilities, platform (web/mobile/desktop) |
| **Pricing** | Free tier? Price points? Per-seat vs flat? Trial period? |
| **Positioning** | How do they describe themselves? What problem do they claim to solve? |
| **Audience** | Who are their customers? (Check testimonials, case studies, social proof) |
| **Strengths** | What do users praise? (Reviews, social media, Product Hunt) |
| **Weaknesses** | What do users complain about? (1-star reviews, forum posts, churn reasons) |
| **Traction** | Any visible signals? (App store ratings, social followers, Alexa rank, funding) |

### Step 3 — Build Comparison Matrix

```markdown
| Dimension | Our Product | Competitor A | Competitor B | Competitor C |
|-----------|------------|-------------|-------------|-------------|
| Core value prop | ... | ... | ... | ... |
| Key differentiator | ... | ... | ... | ... |
| Price point | ... | ... | ... | ... |
| Target audience | ... | ... | ... | ... |
| Biggest strength | ... | ... | ... | ... |
| Biggest weakness | ... | ... | ... | ... |
```

### Step 4 — Identify Gaps and Opportunities

From the research, identify:

1. **Underserved segments** — Who are competitors ignoring?
2. **Feature gaps** — What do users want that nobody provides?
3. **Price gaps** — Is there room for a cheaper/premium alternative?
4. **UX gaps** — Where is the existing experience frustrating?
5. **Positioning gaps** — Is there an unclaimed narrative?

### Step 5 — Define Differentiation Strategy

Based on gaps, articulate:
- **Primary differentiator** — The one thing that makes this product worth choosing over alternatives (must be defensible)
- **Supporting differentiators** — 2-3 secondary advantages
- **Parity features** — What must we match just to be considered (table stakes)
- **Deliberate omissions** — What competitors do that we intentionally won't

### Step 6 — Write Report

Write to `docs/COMPETITOR_ANALYSIS.md` with sections:
1. Competitive Landscape Overview
2. Competitor Profiles (one per competitor)
3. Comparison Matrix
4. Gaps & Opportunities
5. Differentiation Strategy
6. Parity Features (table stakes)

Also append key findings to RESEARCH.md as a new entry.

### Step 7 — Update STATE.md

---

## Constraints

- Research uses web search — findings are as current as available data
- Does not make up competitor data — clearly mark anything that couldn't be verified
- Does not decide product direction — presents analysis for the user to decide
- Differentiation must be based on real gaps, not wishful thinking
- Never disparages competitors — focus on factual observations

---

## Primary Agent

product-manager

---

## Definition of Done

- [ ] 3-5 competitors identified and researched
- [ ] Comparison matrix completed
- [ ] Gaps and opportunities identified (minimum 3)
- [ ] Differentiation strategy articulated (primary + supporting)
- [ ] Parity features identified
- [ ] Report written to docs/COMPETITOR_ANALYSIS.md
- [ ] Key findings logged in RESEARCH.md
- [ ] STATE.md updated

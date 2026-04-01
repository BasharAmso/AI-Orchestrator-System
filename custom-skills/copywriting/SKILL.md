---
id: SKL-0033
name: Copywriting
description: |
  Write conversion-focused copy using proven frameworks (AIDA, PAS, BAB).
  Produces headlines, CTAs, landing page copy, email sequences, and
  micro-copy. Ensures copy matches brand voice and target audience.
version: 1.0
owner: builder
triggers:
  - COPYWRITING_REQUESTED
inputs:
  - Target page or component
  - docs/PRD.md (value proposition, target users)
  - Brand voice guidelines (if any in docs/)
  - .claude/project/STATE.md
outputs:
  - Copy written to target files or docs/COPY.md
  - .claude/project/STATE.md (updated)
tags:
  - marketing
  - copywriting
  - content
  - custom
---

# Skill: Copywriting

## Metadata

| Field | Value |
|-------|-------|
| **Skill ID** | SKL-0033 |
| **Version** | 1.0 |
| **Owner** | builder |
| **Inputs** | Target page, PRD.md, brand guidelines |
| **Outputs** | Copy in target files or docs/COPY.md, STATE.md updated |
| **Triggers** | `COPYWRITING_REQUESTED` |

---

## Purpose

Write copy that converts — not just fills space. Generic placeholder text ("Welcome to our app") kills conversion rates. This skill applies proven copywriting frameworks to produce headlines, CTAs, landing page sections, email sequences, and micro-copy that matches the product's value proposition and target audience.

---

## Procedure

### Step 1 — Understand the Context

Read:
1. `docs/PRD.md` — extract value proposition, target users, problem statement
2. Target page/component — understand what copy is needed and where
3. Any existing brand guidelines in `docs/`
4. `docs/PROBLEM_STRESS_TEST.md` (if exists) — the validated problem language

Identify the copy type needed:
- **Hero section** (headline + subhead + CTA)
- **Feature descriptions** (benefit-focused, not feature-focused)
- **Social proof** (testimonial framing, trust signals)
- **Email sequence** (welcome, onboarding, re-engagement)
- **Micro-copy** (button text, error messages, empty states, tooltips)
- **About page** (story, mission, team)

### Step 2 — Select Framework

| Framework | Best For | Structure |
|-----------|----------|-----------|
| **AIDA** | Landing pages, ads | Attention → Interest → Desire → Action |
| **PAS** | Problem-aware audiences | Problem → Agitate → Solution |
| **BAB** | Aspirational products | Before → After → Bridge |
| **4Ps** | Feature sections | Promise → Picture → Proof → Push |
| **StoryBrand** | Brand narrative | Character → Problem → Guide → Plan → Action → Success → Failure |

### Step 3 — Write Copy

**Headlines:**
- Lead with the benefit, not the feature
- Use the user's language (from PRD target users section)
- Test: "Would I click this?" If not, rewrite.
- Provide 3 headline options: safe, bold, and provocative

**CTAs:**
- Action verb + value ("Start saving time" not "Submit")
- One primary CTA per section — never compete with yourself
- Micro-copy under buttons reduces friction ("No credit card required", "Cancel anytime")

**Body copy:**
- Short paragraphs (2-3 sentences max)
- One idea per paragraph
- Conversational tone unless brand guidelines specify otherwise
- Features → Benefits: "AI-powered search" → "Find what you need in seconds"

**Micro-copy:**
- Error messages: Say what went wrong + how to fix it
- Empty states: Guide the user to their first action
- Loading states: Reassure ("Setting up your workspace...")
- Success states: Celebrate + suggest next step

### Step 4 — Voice Consistency Check

If brand guidelines exist, verify all copy matches:
- Tone (formal/casual/playful/authoritative)
- Vocabulary level (target 8th-grade reading level for public content per accessibility rules)
- Prohibited words or phrases
- Pronoun style (we/you/our)

### Step 5 — Write Output

- If copy is for specific pages/components: write directly to those files
- If copy is general (email sequences, ad variations): write to `docs/COPY.md`
- Always provide the framework used and rationale for key choices

### Step 6 — Update STATE.md

---

## Constraints

- Never writes generic placeholder text — every string should be intentional
- Always leads with benefits, not features
- Copy must be factual — no unsupported claims or fake testimonials
- Respects accessibility: plain language, clear CTAs, no "click here"
- Does not make promises the product can't keep
- Multiple options provided for headlines and CTAs — user chooses

---

## Primary Agent

builder

---

## Definition of Done

- [ ] Copy context understood (PRD, target users, problem statement)
- [ ] Framework selected and applied
- [ ] Headlines provided (3 options)
- [ ] CTAs are action-verb + value (not "Submit" or "Click here")
- [ ] Body copy follows short-paragraph, benefit-first pattern
- [ ] Micro-copy covers error, empty, loading, and success states
- [ ] Voice consistency verified against brand guidelines (if any)
- [ ] Copy written to target files or docs/COPY.md
- [ ] STATE.md updated

## Output Contract

| Field | Value |
|-------|-------|
| **Artifacts** | Copy in target files or `docs/COPY.md` |
| **State Update** | `.claude/project/STATE.md` — mark task complete, log files modified |
| **Handoff Event** | `TASK_COMPLETED` (copy written) |

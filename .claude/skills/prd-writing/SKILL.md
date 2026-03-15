---
id: SKL-0004
name: PRD Writing
description: |
  Write a Product Requirements Document through user interview, including user
  stories, requirements, and acceptance criteria. Includes a Vision Challenge
  mode (CEO review) to ensure the right problem is being solved at the right
  scope before writing begins. Use this skill when a new PRD needs to be
  created for a project.
version: 2.0
owner: product-manager
triggers:
  - PRD_CREATION_REQUESTED
inputs:
  - User's product idea or description
  - docs/PRD.md (if exists)
  - .claude/project/knowledge/DECISIONS.md
  - TODOS.md (if exists)
outputs:
  - docs/PRD.md (created or updated)
  - .claude/project/STATE.md (updated)
  - .claude/project/knowledge/DECISIONS.md (updated with scope decisions)
tags:
  - planning
  - prd
  - vision
---

# Skill: PRD Writing

## Metadata

| Field | Value |
|-------|-------|
| **Skill ID** | SKL-0004 |
| **Version** | 2.0 |
| **Owner** | product-manager |
| **Inputs** | User's product idea, existing PRD (if any), DECISIONS.md, TODOS.md |
| **Outputs** | `docs/PRD.md`, STATE.md updated, DECISIONS.md updated |
| **Triggers** | `PRD_CREATION_REQUESTED` |

---

## Purpose

Interview the user conversationally and produce a structured PRD at `docs/PRD.md` that downstream skills can parse. Before writing, run a Vision Challenge to ensure the right problem is being solved at the right ambition level.

---

## Cognitive Mode

**Founder Thinking.** You are not a note-taker. You are a co-founder helping shape the product vision. Challenge assumptions, expand thinking where warranted, and ensure the product is worth building before defining how to build it.

---

## Procedure

### Step 0 — Vision Challenge (CEO Review Mode)

Before any interview questions, establish the right scope and ambition level.

#### 0A. Premise Challenge

Ask the user these three questions (one at a time, wait for each response):

1. **"What problem are you solving, and how do you know it's real?"** — Is this a genuine pain point or a hypothetical one? What evidence exists?
2. **"What happens if you build nothing?"** — If the answer is "not much changes," the problem may not be worth solving yet.
3. **"Who specifically has this problem, and how are they solving it today?"** — The current workaround reveals what the product must beat.

#### 0B. Scope Posture Selection

Present three postures and ask the user to choose:

1. **SCOPE EXPANSION** — Dream big. What would make this product so good users tell their friends? What's the 10x version that only costs 2x the effort? You have permission to push scope UP.
2. **HOLD SCOPE** — The idea is right-sized. Focus on making it bulletproof — cover every edge case, define clear boundaries, ensure nothing important is missed.
3. **SCOPE REDUCTION** — Cut to the bone. What is the absolute minimum that delivers value? Everything else is deferred. Be ruthless.

**Default guidance:**
- Brand new idea with no constraints → suggest EXPANSION
- Clear idea with defined boundaries → suggest HOLD SCOPE
- Overwhelmed user or tight timeline → suggest REDUCTION

Once selected, commit fully. Do not drift toward a different posture during the interview.

#### 0C. Dream State Mapping (EXPANSION and HOLD only)

Ask: **"Imagine this product is wildly successful 12 months from now. What does it look like? What can users do that they can't do today?"**

Map the response:
```
CURRENT STATE              THIS PRD               12-MONTH IDEAL
[how things work now] ---> [what we're building] ---> [the vision]
```

This anchors every subsequent decision. If a feature doesn't move toward the 12-month ideal, it may not belong in v1.

#### 0D. Existing Solutions Check

Before proceeding, check:
- Read `DECISIONS.md` — has related work already been decided?
- Read `TODOS.md` (if exists) — are there deferred items that relate to this idea?
- Ask: **"Is there anything already built (by you or others) that partially solves this?"**

Log findings. Avoid rebuilding what already exists.

**Once Step 0 is complete, proceed to the interview. Reference the chosen posture throughout.**

---

### Step 1 — Check for Existing PRD

Read `docs/PRD.md` if it exists. If found, summarize and ask whether to update or start fresh.

---

### Step 2 — Run the Interview

Wait for the user's response after each round. Adapt depth based on the chosen scope posture.

**Round 1 — Problem and Users:**
- What problem? Who has it? How do you know?
- (EXPANSION) What adjacent problems could this also solve?
- (REDUCTION) What is the single most painful aspect?

**Round 2 — Goals and Scope:**
- Success metric? What does "working" look like?
- 3-5 MVP features — what must v1 do?
- What's NOT in v1? (minimum 3 exclusions)
- (EXPANSION) What would make this a "10-star" experience? What's the version users would pay double for?
- (REDUCTION) Can any of the 3-5 features be cut further?

**Round 3 — AI Features (conditional):**
Only if AI/LLM features are involved.
- What does AI do in this product? What's the user's mental model?
- Fallback when AI fails or returns poor results?
- Trust signals — how does the user know the AI output is good?
- (EXPANSION) What AI capabilities would feel magical?

**Round 4 — Constraints and Kill Rule:**
- Real constraints (budget, timeline, platform, skills)?
- Biggest risk — what could make this fail?
- Kill rule — what signal means "stop building this"?
- (EXPANSION) Which constraints are real vs. assumed? Challenge one.

---

### Step 3 — Confirm Before Writing

Summarize the PRD in 5-8 bullets. Include:
- Problem + evidence
- Target user
- Scope posture chosen
- Key features (in/out)
- Success metric
- Kill rule

Ask: **"Anything wrong or missing?"**

---

### Step 4 — Write docs/PRD.md

Use exact section headings (prd-to-tasks skill depends on them):

1. **Overview** — One-paragraph product summary
2. **Problem Statement** — The problem, evidence, who has it, current workarounds
3. **Vision** — The 12-month dream state (from Step 0C)
4. **Goals** — Success metrics with baseline, target, timeframe
5. **Target Users** — Who they are, what they need
6. **MVP Scope** — Features in v1, with brief descriptions
7. **NOT in Scope** — Features explicitly excluded from v1, with one-line rationale each
8. **User Stories** — As a [user], I want [action], so that [outcome]
9. **Risks and Assumptions** — Including Kill Rule
10. **Constraints** — Budget, timeline, platform, skills
11. **Open Questions** — Unresolved items that need answers before building
12. **AI/ML Requirements** (if applicable) — AI capabilities, fallbacks, trust signals

**Scope posture adjustments:**
- EXPANSION: Add a "Delight Opportunities" subsection under MVP Scope — 3-5 small wins (<30 min each) that would make users think "they thought of everything"
- REDUCTION: MVP Scope should be ruthlessly minimal. Move anything questionable to NOT in Scope.

---

### Step 5 — Log Decisions and Emit Event

1. Write scope posture and key product decisions to `DECISIONS.md`
2. Print: `"Suggest emitting: PRD_UPDATED — use /trigger to create it."`
3. Update `STATE.md`

---

## Constraints

- Never overwrites existing PRD without confirmation
- Interview is conversational — never dump all questions at once
- Never skip the problem statement
- Never write solutions before the problem is established
- Scale to context: solo = lean PRD, AI product = add AI sections
- Once a scope posture is chosen, commit to it — do not silently drift
- Step 0 (Vision Challenge) is mandatory — never skip it

---

## Primary Agent

product-manager

---

## Definition of Done

- [ ] Vision Challenge completed (Step 0) — posture selected, premise challenged
- [ ] docs/PRD.md exists with all required sections
- [ ] Problem statement includes evidence
- [ ] Success metric has baseline, target, timeframe
- [ ] NOT in Scope has at least 3 exclusions with rationale
- [ ] Kill rule defined
- [ ] Key decisions logged in DECISIONS.md
- [ ] STATE.md updated

---
id: SKL-0028
name: GDD Writing
description: |
  Write a Game Design Document through user interview, incorporating established
  game design theory (MDA Framework, Bartle Player Types, 4-timescale gameplay
  loops, design pillars). Produces a structured GDD at docs/GDD.md. Parallels
  PRD Writing (SKL-0004) but is purpose-built for game projects.
version: 1.0
owner: product-manager
triggers:
  - GDD_CREATION_REQUESTED
inputs:
  - User's game idea or description
  - docs/GDD.md (if exists)
  - .claude/project/knowledge/DECISIONS.md
  - TODOS.md (if exists)
outputs:
  - docs/GDD.md (created or updated)
  - .claude/project/STATE.md (updated)
  - .claude/project/knowledge/DECISIONS.md (updated with design decisions)
tags:
  - planning
  - game-design
  - gdd
  - vision
---

# Skill: GDD Writing

## Metadata

| Field | Value |
|-------|-------|
| **Skill ID** | SKL-0028 |
| **Version** | 1.0 |
| **Owner** | product-manager |
| **Inputs** | User's game idea, existing GDD (if any), DECISIONS.md, TODOS.md |
| **Outputs** | `docs/GDD.md`, STATE.md updated, DECISIONS.md updated |
| **Triggers** | `GDD_CREATION_REQUESTED` |

---

## Purpose

Interview the user conversationally and produce a structured Game Design Document at `docs/GDD.md` that downstream skills can parse. Before writing, run a Game Vision Challenge to ensure the core fantasy is compelling and the 30-second gameplay loop is fun. Incorporates MDA Framework, Bartle Player Types, Self-Determination Theory, and 4-timescale gameplay loop analysis.

This skill is the game-development parallel to PRD Writing (SKL-0004). Where PRD Writing asks "what problem are we solving?", GDD Writing asks "what fantasy are we delivering?"

---

## Cognitive Mode

**Game Designer's Mind.** You think in loops, systems, and player emotions — not features and requirements. You evaluate every mechanic by asking "is this fun?" before asking "is this feasible?" You understand that a game is a series of interesting decisions (Sid Meier), that the 30-second loop must be fun in isolation (Uri Levine's problem-first thinking applied to games), and that great games make players feel something specific.

You are equal parts creative visionary and systems thinker. You push for clarity on the core fantasy ("what does the player *feel*?") while grounding design in concrete mechanics ("what does the player *do* every 30 seconds?").

Challenge scope — both upward ("what if the combat had more depth?") and downward ("do we really need multiplayer in v1?"). Speak in terms of player experience, not implementation details.

---

## Procedure

### Step 0 — Game Vision Challenge

Before any interview questions, establish the core fantasy and validate the game concept.

#### 0A. Core Fantasy Challenge

Ask the user these three questions (one at a time, wait for each response):

1. **"What is the core fantasy?"** — The emotional promise. Not a feature list. What does the player *feel* while playing? (Power? Discovery? Mastery? Fear? Connection?)
2. **"What does 30 seconds of gameplay feel like?"** — Describe the moment-to-moment experience. If this isn't fun in isolation, no amount of progression or narrative will save the game.
3. **"What existing game is closest, and how is yours different?"** — The differentiation test. If the answer is "it's exactly like X," ask what makes it worth building.

#### 0B. Scope Posture Selection

Present three postures and ask the user to choose:

1. **SCOPE EXPANSION** — Dream big. What's the version of this game that players can't stop talking about? What systems emerge when mechanics interact? What's the 10-star version?
2. **HOLD SCOPE** — The design is right-sized. Focus on making the core loop bulletproof — every interaction polished, every edge case handled.
3. **SCOPE REDUCTION** — Cut to the vertical slice. What is the absolute minimum that demonstrates the core fantasy? Everything else is post-launch.

**Default guidance:**
- Brand new game concept with no constraints → suggest EXPANSION
- Clear game idea with defined mechanics → suggest HOLD SCOPE
- Game jam, prototype, or tight timeline → suggest REDUCTION

Once selected, commit fully. Do not drift toward a different posture during the interview.

#### 0C. Player Fantasy Mapping (EXPANSION and HOLD only)

Ask: **"Imagine someone has played your game for 10 hours and loves it. What story do they tell their friend about why it's great?"**

Map the response:
```
CURRENT STATE              THIS GDD                10-HOUR PLAYER STORY
[games they play now] ---> [what we're building] ---> [the experience]
```

This anchors every subsequent decision. If a mechanic doesn't serve the 10-hour player story, it may not belong in v1.

#### 0D. Existing Design Check

Before proceeding, check:
- Read `DECISIONS.md` — has related game design work already been decided?
- Read `TODOS.md` (if exists) — are there deferred mechanics or features?
- Ask: **"Have you prototyped anything yet? Is there any existing code or design work?"**

Log findings. Build on what exists rather than starting from scratch.

**Once Step 0 is complete, proceed to the interview. Reference the chosen posture throughout.**

---

### Step 1 — Check for Existing GDD

Read `docs/GDD.md` if it exists. If found, summarize and ask whether to update or start fresh.

---

### Step 2 — Run the Interview

Wait for the user's response after each round. Adapt depth based on the chosen scope posture.

**Round 1 — Identity & Fantasy:**
- What genre? (platformer, RPG, roguelike, puzzle, strategy, etc.)
- What platform? (PC, mobile, console, web, cross-platform?)
- Target audience? (casual, core, hardcore? age range?)
- Player count? (single-player, co-op, competitive, MMO?)
- Session length? (5 min mobile sessions? 2-hour PC sessions?)
- Core fantasy — the emotional promise (from Step 0, refined)
- Elevator pitch: "It's a [genre] where you [verb] in [setting] to [goal]"
- Unique hook — what passes the "and also" test? (What makes this different from every other [genre] game?)
- (EXPANSION) What's the version of this that creates a new genre or subgenre?
- (REDUCTION) What one feeling must the prototype nail?

**Round 2 — Gameplay Loops:**
- **30-second loop:** What is the core verb? What does the player do every 30 seconds? What feedback do they get? (This is the most important design question.)
- **5-15 minute loop:** What's the objective cycle? (Complete quest, win match, clear level, solve puzzle?)
- **30-120 minute loop:** What's the session arc? (Narrative beat, meaningful choice, progress milestone?)
- **Long-term loop:** What keeps players coming back over days/weeks? (Unlocks, rankings, story chapters, community?)
- Win/lose/draw conditions — how does the player succeed and fail?
- Difficulty and mastery curve — how does challenge scale?
- (EXPANSION) What emergent behaviors could arise from these systems interacting?
- (REDUCTION) Which loops are v1 and which are post-launch?

**Round 3 — Design Pillars & Aesthetics:**
- Define 3-5 design pillars (non-negotiable principles). Each must be:
  - Falsifiable (you can test if a design choice violates it)
  - Constraining (it forces real decisions, not just "be fun")
  - Memorable (the team can recite them)
- Define anti-pillars — what the game is explicitly NOT (e.g., "NOT a grind," "NOT competitive," "NOT realistic")
- MDA aesthetics ranking — rank these 8 by importance for your game:
  1. Sensation (sensory pleasure)
  2. Fantasy (make-believe)
  3. Narrative (drama, story)
  4. Challenge (mastery, difficulty)
  5. Fellowship (social, cooperation)
  6. Discovery (exploration, secrets)
  7. Expression (self-expression, creativity)
  8. Submission (relaxation, routine)
- Bartle type appeal — which player types does this game primarily serve?
  - Achievers (goals, points, completion)
  - Explorers (discovery, secrets, knowledge)
  - Socializers (interaction, community)
  - Killers/Competitors (domination, PvP, leaderboards)
- Player motivation mapping (Self-Determination Theory):
  - Autonomy — where does the player have meaningful choice?
  - Competence — where does the player feel skilled growth?
  - Relatedness — where does the player feel connection?

**Round 4 — Art, Audio & Feel:**
- Art style direction — reference games, artists, or mood boards
- Visual tone — bright/dark, realistic/stylized, detailed/minimal?
- Audio style — music genre, ambient vs. dynamic, iconic sounds?
- Game feel goals — weighty, snappy, floaty, precise, crunchy?
- Juiciness — what gets screen shake, particles, sound effects?
- UI/UX philosophy — minimalist HUD? diegetic UI? information density?
- (EXPANSION) What visual or audio moment would go viral on social media?

**Round 5 — Scope & Constraints:**
- MVP features — the vertical slice that proves the core fantasy
- NOT in scope — explicit exclusions with one-line rationale each (minimum 3)
- Technical constraints — engine preference? platform limitations? performance targets?
- Monetization model — premium, F2P, ads, subscription, none?
- Team size and timeline reality
- Kill rule — what signal means "this game isn't working"? (e.g., "if playtesters don't replay the core loop voluntarily within 5 minutes, rethink the mechanic")
- (EXPANSION) What's the DLC/expansion/sequel potential?
- (REDUCTION) Can any MVP features be cut further?

---

### Step 3 — Confirm Before Writing

Summarize the GDD in 8-10 bullets. Include:
- Core fantasy + elevator pitch
- Core 30-second loop
- Top 3 design pillars
- Target platform + audience
- Scope posture chosen
- Key features (in/out)
- Art/audio direction (one line)
- Kill rule

Ask: **"Anything wrong or missing?"**

---

### Step 4 — Write docs/GDD.md

Use exact section headings (downstream skills depend on them):

```markdown
# Game Design Document

## 1. Game Identity

- **Title:** [name]
- **Genre:** [genre(s)]
- **Platform:** [platform(s)]
- **Target Audience:** [who, age range, casual/core/hardcore]
- **Player Count:** [single/co-op/competitive/MMO]
- **Session Length:** [typical play session duration]
- **Elevator Pitch:** It's a [genre] where you [verb] in [setting] to [goal].

## 2. Core Fantasy

[The emotional promise — what the player feels. 2-3 sentences.]

**Unique Hook:** [one-sentence differentiator that passes the "and also" test]

**10-Hour Player Story:** [what a fan tells their friend after 10 hours]

## 3. Design Pillars

### Pillar 1: [Name]
[One-sentence definition — falsifiable and constraining]
- **Decision test:** [a concrete design question this pillar resolves]

### Pillar 2: [Name]
[repeat]

### Pillar 3: [Name]
[repeat]

### Anti-Pillars
- This game is NOT [x]
- This game is NOT [y]
- This game is NOT [z]

## 4. Gameplay Loops

### 30-Second Loop (Moment-to-Moment)
- **Core verb:** [what the player does]
- **Feedback:** [what happens in response]
- **Feel:** [weighty/snappy/precise/etc.]

### 5-15 Minute Loop (Objective Cycle)
[description]

### 30-120 Minute Loop (Session Arc)
[description]

### Long-Term Loop (Meta Progression)
[description]

### Win/Lose Conditions
[how the player succeeds and fails]

## 5. Core Mechanics

[Detailed breakdown of the primary gameplay systems — rules, interactions,
 state changes. Expanded from the 30-second loop.]

## 6. Progression & Economy

- **Difficulty curve:** [how challenge scales]
- **Unlock paths:** [what the player earns and how]
- **Currencies/resources:** [if applicable]
- **Rewards:** [what motivates continued play]

## 7. Player Experience

### MDA Aesthetics (ranked by priority)
1. [highest priority aesthetic] — [how the game delivers it]
2. [second] — [how]
3. [third] — [how]

### Bartle Type Appeal
- **Primary:** [type] — [how the game serves them]
- **Secondary:** [type] — [how]

### Player Motivation (SDT)
- **Autonomy:** [where the player has meaningful choice]
- **Competence:** [where the player feels growth]
- **Relatedness:** [where the player feels connection]

## 8. Art Direction

- **Visual style:** [description + references]
- **Tone:** [bright/dark, realistic/stylized]
- **Key visual targets:** [2-3 scenes or moments that define the look]

## 9. Audio Direction

- **Music style:** [genre, mood, dynamic vs. static]
- **Sound design:** [key sounds, juiciness level]
- **Key audio moments:** [2-3 moments where audio is critical]

## 10. MVP Scope

[Vertical slice features, prioritized. This is what gets built first.]

| Priority | Feature | Description |
|----------|---------|-------------|
| Must | [feature] | [one-line description] |
| Must | [feature] | [description] |
| Should | [feature] | [description] |
| Could | [feature] | [description] |

## 11. NOT in Scope

| Feature | Rationale |
|---------|-----------|
| [feature] | [why it's excluded from v1] |
| [feature] | [rationale] |
| [feature] | [rationale] |

## 12. Risks & Assumptions

### Design Risks
- [risk + mitigation]

### Technical Risks
- [risk + mitigation]

### Market Risks
- [risk + mitigation]

### Kill Rule
[specific signal that means "this game isn't working" — e.g., "if playtesters
don't voluntarily replay the core loop within 5 minutes"]

## 13. Open Questions

| Question | Owner | Needs |
|----------|-------|-------|
| [question] | [who decides] | [prototype / playtest / research] |

## 14. References

| Game | What We Adopt | What We Differentiate | Why It Matters |
|------|---------------|----------------------|----------------|
| [game] | [element] | [how ours differs] | [design insight] |
```

**Scope posture adjustments:**
- EXPANSION: Add a "Delight Opportunities" subsection under MVP Scope — 3-5 juice moments that would make players think "they thought of everything." Add a "Sequel/DLC Potential" note under section 14.
- REDUCTION: MVP Scope should be ruthlessly minimal — vertical slice only. Move anything questionable to NOT in Scope.

---

### Step 5 — Log Decisions and Emit Event

1. Write design pillars, scope posture, and key game design decisions to `DECISIONS.md`
2. Print: `"Suggest emitting: GDD_UPDATED — use /trigger to create it."`
3. Update `STATE.md`

---

## Constraints

- Never overwrites existing GDD without confirmation
- Interview is conversational — never dump all questions at once
- Never skip the core fantasy — mechanics come after the fantasy is established
- Never write mechanics before the 30-second loop is defined
- Scale to context: solo dev = lean GDD, team = detailed GDD
- Once a scope posture is chosen, commit to it — do not silently drift
- Step 0 (Game Vision Challenge) is mandatory — never skip it
- Design pillars must be falsifiable — reject vague pillars like "be fun" or "high quality"

---

## Primary Agent

product-manager

---

## Definition of Done

- [ ] Game Vision Challenge completed (Step 0) — core fantasy defined, 30-second loop described, posture selected
- [ ] docs/GDD.md exists with all 14 required sections
- [ ] Core fantasy articulated in 2-3 sentences (not a feature list)
- [ ] 30-second gameplay loop described with core verb, feedback, and feel
- [ ] 3-5 design pillars defined, each falsifiable and constraining
- [ ] Anti-pillars defined (minimum 3)
- [ ] MDA aesthetics ranked
- [ ] MVP Scope uses MoSCoW prioritization
- [ ] NOT in Scope has at least 3 exclusions with rationale
- [ ] Kill rule defined
- [ ] Key decisions logged in DECISIONS.md
- [ ] STATE.md updated

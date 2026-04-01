# GDD Template

> Use exact section headings below when writing `docs/GDD.md`. Downstream skills depend on them.

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

## Scope Posture Adjustments

- **EXPANSION:** Add a "Delight Opportunities" subsection under MVP Scope — 3-5 juice moments that would make players think "they thought of everything." Add a "Sequel/DLC Potential" note under section 14.
- **REDUCTION:** MVP Scope should be ruthlessly minimal — vertical slice only. Move anything questionable to NOT in Scope.

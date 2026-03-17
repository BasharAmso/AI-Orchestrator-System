# Command: /capture-idea

> Capture a project idea and seed the system with a PRD stub, architecture stub, tasks, and an event — all in one step.

---

## Procedure

### Step 1: Collect the Idea

Ask the user to fill in this template (5-15 lines). Accept freeform answers — do not enforce strict formatting:

```
NAME:
WHAT ARE YOU MAKING? (a book, a website, a phone app):
ONE-LINER:
WHO IT'S FOR:
THE PROBLEM:
WHAT SUCCESS LOOKS LIKE:
KEY FEATURES (bullets):
WHAT IT SHOULD NOT DO (bullets):
LIMITS (time, budget, what you know):
```

If the user provides a freeform description instead of the template, extract as many fields as possible and note any gaps.

### Step 2: Archive Raw Intake to Research

Append the user's raw input (verbatim) to `.claude/project/knowledge/RESEARCH.md` as a new entry.

**Format** (append-only — never overwrite existing entries):

```
---

### RES-XXXX: Idea Intake — <project name>

- **Date:** YYYY-MM-DD
- **Source:** User idea intake via /capture-idea
- **Summary:** <ONE-LINER from intake>
- **Relevance:** Foundational project concept. All planning derives from this intake.
- **Status:** Active

**Raw Intake:**

> <paste the user's full input verbatim, blockquoted>
```

Auto-increment the `RES-XXXX` ID from the highest existing ID in RESEARCH.md.

### Step 3: Create or Update Doc Stubs

For each file below, create it **only if it does not exist**. If the file already exists, **append** any missing sections (do not overwrite or duplicate existing sections).

#### docs/PRD.md

Populate these sections using the intake fields:

```
# Product Requirements Document

## Overview

<ONE-LINER expanded into 2-3 sentences using NAME, THE PROBLEM, and WHAT SUCCESS LOOKS LIKE>

## Target Users

<WHO IT'S FOR>

## Problem Statement

<THE PROBLEM>

## Goals

<WHAT SUCCESS LOOKS LIKE, rephrased as bullet points>

## Non-Goals

<WHAT IT SHOULD NOT DO bullets from intake>

## MVP Scope

<FEATURES bullets from intake>

## Risks and Assumptions

- Constraints: <LIMITS from intake>
- Assumptions: <any assumptions inferred from the intake>
- Risks: <any risks inferred from the intake>
```

#### docs/ARCHITECTURE.md

Populate these sections:

```
# Architecture

## Overview

Architecture details will be defined after the PRD is reviewed and approved.

## Initial Assumptions

- **Project Type:** <WHAT ARE YOU MAKING from intake>
- <any technical assumptions that can be inferred from the intake>

## Open Questions

See [.claude/project/knowledge/OPEN_QUESTIONS.md](./.claude/project/knowledge/OPEN_QUESTIONS.md) for unresolved technical questions.
```

### Step 3b: Create or Update Project Charter

If `docs/PROJECT_CHARTER.md` does not exist, create it. If it exists, skip.

Populate from intake fields:

```
# Project Charter

## Project Name

<NAME from intake>

## Vision

<ONE-LINER from intake>

## Goals

<WHAT SUCCESS LOOKS LIKE from intake, as numbered list>

## Target Users

<WHO IT'S FOR from intake>

## Constraints

<LIMITS from intake, structured as Time/Budget/Technical/Knowledge>

## Success Criteria

<WHAT SUCCESS LOOKS LIKE from intake, rephrased as measurable outcomes>

## Non-Goals

<WHAT IT SHOULD NOT DO from intake>

## Risks

<Inferred from LIMITS and THE PROBLEM>
```

### Step 4: Seed Next Task Queue

Read `.claude/project/STATE.md` and locate the `## Next Task Queue` section.

**If the queue already contains real tasks**, do NOT modify it.
Print: `"Next Task Queue already populated; skipping seeding."`

A queue is considered **empty/placeholder-only** if it matches ANY of these patterns:
- Contains only `(none)` or `*(none)*`
- Contains only `- (none)`
- Contains only the table headers with no data rows beneath them
- The section is completely empty

**If the queue is empty or placeholder-only**, replace it with these 5 starter tasks:

| # | Task | Priority | Skill |
|---|------|----------|-------|
| 1 | Draft PRD v1 (docs/PRD.md) | High | SKL-0004 |
| 2 | Review PRD for beginner clarity | High | SKL-0016 |
| 3 | Draft Architecture v1 (docs/ARCHITECTURE.md) | High | — |
| 4 | Break PRD into tasks | Medium | SKL-0003 |
| 5 | Run first build scaffold | Medium | — |

### Step 5: Emit IDEA_CAPTURED Event

Check `.claude/project/EVENTS.md` under `## Unprocessed Events`.

**Canonical event format** (must match the format defined in `.claude/project/EVENTS.md`):

```
EVT-XXXX | IDEA_CAPTURED | <project name> idea captured | user | YYYY-MM-DD HH:MM
```

- **If the most recent unprocessed event already matches** `IDEA_CAPTURED` with the same project name (compare the `IDEA_CAPTURED` type and that the description contains `<project name> idea captured`): skip emitting. Print: `"IDEA_CAPTURED event already pending; skipping."`
- **Otherwise:** append the canonical event line under `## Unprocessed Events`.
- Auto-increment the EVT ID from the highest existing ID across **both** Unprocessed and Processed sections.
- If the section currently shows `*(none)*`, replace the placeholder with the new event.

### Step 6: Print Summary

Print a concise confirmation:

```
## Idea Captured

- **Project:** <NAME>
- **Files Created:** [list of new files]
- **Files Updated:** [list of files that were appended to]
- **Research Entry:** RES-XXXX
- **Tasks Queued:** [seeded (5) | skipped (already populated)]
- **Event Emitted:** [yes | skipped (already pending)]

### Next Task Queue

| # | Task | Priority | Skill |
|---|------|----------|-------|
| ... | ... | ... |
```

Then print the last 5 lines of `.claude/project/EVENTS.md`.

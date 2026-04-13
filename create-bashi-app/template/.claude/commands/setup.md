# Command: /setup

> One-command project setup. Combines `/bootstrap` (structure verification + runtime files) and `/init-project` (project type + starter files). Safe to run multiple times (fully idempotent).

---

## Procedure

### Step 1: Verify Directory Structure

Ensure these directories exist (create if missing):

```
.claude/
  agents/
  commands/
  rules/
  skills/
  project/
    knowledge/
docs/
```

### Step 2: Verify Framework Files

Check that each framework file exists. These are part of the template and cannot be auto-created — report any missing ones.

| File | Required |
|------|----------|
| `.claude/CLAUDE.md` | Yes |
| `.claude/agents/orchestrator.md` | Yes |
| `.claude/commands/run-project.md` | Yes |
| `.claude/commands/trigger.md` | Yes |
| `.claude/commands/fix-registry.md` | Yes |
| `.claude/commands/setup.md` | Yes |
| `.claude/rules/orchestration-routing.md` | Yes |
| `.claude/rules/event-hooks.md` | Yes |
| `.claude/rules/knowledge-policy.md` | Yes |
| `.claude/rules/context-policy.md` | Yes |
| `.claude/skills/REGISTRY.md` | Yes |
| `.claudeignore` | Yes |

If any are missing, report them as `MISSING` in the summary. Do not attempt to create framework files.

### Step 2.5: Global User Profile

Check if `~/.bashi/user-profile.md` exists.

**If it exists:**
1. Read it.
2. Print: `"Welcome back, [Name]. Using your saved preferences."`
3. Store the profile values (Framework Mode, Execution Mode, Output Style, Experience, Role) in memory for use in Step 3 below.

**If it does NOT exist:**
1. Print: `"First time using Bashi? Let me learn about you so I can adapt to how you work."`
2. Ask the user 4 questions:
   - **a.** "What's your name?"
   - **b.** "What's your role?" — Options: developer, designer, product manager, non-technical builder, other
   - **c.** "How experienced are you with building software?" — Options: beginner, intermediate, senior
   - **d.** "How much detail do you want in responses?" — Options: detailed (explain everything), concise (just what I need), just-the-code
3. Create the `~/.bashi/` directory.
4. Write `~/.bashi/user-profile.md`:

```markdown
# User Profile

> Created by /setup on first project. Loaded automatically on every session.
> Edit manually or run /setup in any project to update.

- **Name:** [answer a]
- **Role:** [answer b]
- **Experience:** [answer c]
- **Preferred Framework Mode:** [beginner → Full Planning | intermediate → Full Planning | senior → Quick Start]
- **Preferred Execution Mode:** [beginner → Safe | intermediate → Semi-Autonomous | senior → Autonomous]
- **Output Style:** [answer d]
- **Projects Completed:** 0
```

5. Print: `"Profile saved to ~/.bashi/user-profile.md. This carries over to all future projects."`

**Applying profile defaults to Step 3:**

When creating STATE.md in Step 3 (below), use the profile's Preferred Framework Mode and Preferred Execution Mode instead of the hardcoded defaults (Full Planning + Semi-Autonomous). If STATE.md already exists, do NOT override — `/setup` is idempotent.

**Updating an existing profile:**

If the profile already exists and the user says "I want to update my profile" (or runs `/setup` with `--update-profile`):
1. Show current profile values.
2. Ask which fields to change.
3. Update `~/.bashi/user-profile.md` with new values.

### Step 2.7: Global AI-Memory (Cross-Project Knowledge Store)

The AI-Memory directory stores cross-project learning (lessons, patterns, failures, decisions). It lives outside any single project so all projects can share knowledge.

1. Resolve the path: `${AI_MEMORY_PATH:-~/Projects/AI-Memory}`
2. If the directory already exists → print `"AI-Memory found at <path> — skipped."` and continue to Step 3.
3. If it does not exist → create the full structure:

**Directories to create (7):**

- `<path>/decisions/`
- `<path>/patterns/`
- `<path>/failures/`
- `<path>/lessons/`
- `<path>/ideas/`
- `<path>/feedback/`
- `<path>/improvements/`

**Seed files to create (3):**

**`<path>/GLOBAL_INDEX.md`:**

```markdown
# Global Memory Index

> Tracks all stored knowledge across projects. Update this file when adding a new entry.

---

## Decisions

| Date | Project | Description | File |
|------|---------|-------------|------|

---

## Patterns

| Date | Project | Description | File |
|------|---------|-------------|------|

---

## Feedback

| Date | Project | Description | File |
|------|---------|-------------|------|

---

## Ideas

| Date | Project | Description | File |
|------|---------|-------------|------|

---

## Failures

| Date | Project | Description | File |
|------|---------|-------------|------|

---

## Lessons

| Date | Project | Description | File |
|------|---------|-------------|------|
```

**`<path>/README.md`:**

```markdown
# AI Memory — Cross-Project Knowledge Store

> This directory stores cross-project learning for Bashi.
> It lives outside any single project so all projects can share knowledge.

---

## Purpose

Every project built with Bashi generates insights — what worked, what failed, which patterns proved useful. This directory captures those insights so future projects start smarter.

---

## Memory Types

| Folder | What Goes Here |
|--------|---------------|
| `decisions/` | Architectural decisions that proved useful across projects. |
| `patterns/` | Reusable workflows, prompts, or system patterns worth repeating. |
| `failures/` | Mistakes or failed approaches that future projects should avoid. |
| `lessons/` | Short insights discovered during development. |
| `ideas/` | Project ideas and cross-project roadmap items. |
| `feedback/` | Agent feedback log (self-review and cross-agent reviews). |
| `improvements/` | Proposed skill improvements tracked by IMP-XXXX entries. |

---

## Entry Format

Each entry is a short `.md` file in the appropriate folder. Use this template:

# <Short Title>

- **Date:** YYYY-MM-DD
- **Project:** <project name>
- **Summary:** <1-2 sentences>
- **Detail:** <optional longer explanation>

---

## Usage Rules

1. **Keep entries concise.** One file per insight. If it takes more than a paragraph, split it.
2. **Name files descriptively.** Use kebab-case: `avoid-global-state.md`, `prd-before-code.md`.
3. **Update GLOBAL_INDEX.md** when adding a new entry.
4. **Don't duplicate.** Check if a similar entry exists before creating a new one.
5. **Any project can write here**, but entries must be general enough to benefit other projects.
```

**`<path>/SKILL_IMPROVEMENTS.md`:**

```markdown
# Skill Improvements Index

> Track proposed improvements to reusable skills across all projects. Append-only — do not remove entries.

---

## Entry Format

### IMP-XXXX: <Short title>

- **Date:** YYYY-MM-DD
- **Project:** <project name>
- **Skill ID:** <SKL-XXXX>
- **Problem Observed:** <what went wrong or caused friction>
- **Proposed Improvement:** <what should change>
- **Status:** Proposed | Approved | Applied | Rejected
- **Reference File:** <path to the skill file>

---

## Proposed Improvements

*(None yet — improvements will be logged here as agents detect recurring friction patterns.)*
```

4. Print: `"AI-Memory created at <path>. This is your cross-project knowledge store — all projects share it."`

### Step 3: Create Runtime Files (If Missing)

Check each runtime file. If missing, create it from the corresponding template in the **Runtime File Templates** section below. Report each created file as `CREATED`.

| File | Required |
|------|----------|
| `.claude/project/STATE.md` | Yes |
| `.claude/project/EVENTS.md` | Yes |
| `.claude/project/RUN_POLICY.md` | Yes |
| `.claude/project/knowledge/DECISIONS.md` | Yes |
| `.claude/project/knowledge/RESEARCH.md` | Yes |
| `.claude/project/knowledge/GLOSSARY.md` | Yes |
| `.claude/project/knowledge/OPEN_QUESTIONS.md` | Yes |
| `.claude/project/knowledge/TASK-FORMAT.md` | Yes |
| `.claude/project/knowledge/TODOS-FORMAT.md` | Yes |
| `.claude/project/IDENTITY.md` | Yes — **auto-populate from project context** (see note below) |

**IDENTITY.md Auto-Population Note:**

When creating `.claude/project/IDENTITY.md`, do NOT use the static template — auto-detect values:

1. **Project name** (use first match):
   - Read `README.md` → extract the first `# Heading` line (strip the `# `)
   - Run `git remote get-url origin 2>/dev/null` → extract repo name (`basename <url> .git`)
   - Fallback: `basename $(pwd)` (directory name)

2. **Purpose** (use first match):
   - Read `README.md` → extract the first non-heading paragraph (first 150 characters, end at sentence boundary)
   - Fallback: `[Describe what this project does — one sentence]`

3. **Status:** Always write `Not Started` (accurate for a fresh setup)

4. **Stack:** Always write `[Fill in after architecture decisions]` — cannot be reliably inferred

Write the file using the detected values. If IDENTITY.md already exists, skip — never overwrite.

### Step 4: Determine Project Type

**Precedence order:**

1. If `PROJECT_TYPE.md` exists in the repo root, read the `Project Type: <value>` line. Use that value.
2. If the `create-bashi-app/` directory exists in the repo root, this is the framework source repo — set type to `Template` and skip Steps 5–6.
3. **Ask what they're building.** Start with a natural question:

   > "What brings you here today? Describe what you're trying to build in a sentence or two."

   Wait for their answer. Use their description to recommend a project type in the next step.

4. **Recommend and confirm project type.** Based on their description, suggest the best-fit type and ask them to confirm:

   > "Based on what you described, I'd recommend **[type]**. Does that sound right, or would you prefer one of these?"

   **If Cortex MCP is available:** Call `list_categories` to get the `pillars` object. Present the available pillars as project type options (e.g., "web-dev", "game-dev", "ecommerce", "mobile", "iot", etc.). This ensures new domains added to Cortex appear automatically without updating setup.

   **If Cortex MCP is NOT available:** Present the default options:
   - **Web App** — React, Next.js, SPA, browser-based games, static sites
   - **Mobile App** — React Native/Expo (cross-platform), Swift/SwiftUI (iOS), Kotlin/Compose (Android)
   - **API / Backend** — REST, GraphQL, server-side services
   - **SaaS (Full-Stack)** — Frontend + backend + database + auth

   **MCP enhancement:** Also call `detect_project` with the project's root files to refine the recommendation.

   Wait for the user's confirmation before proceeding. Never skip this step.

Once determined, create `PROJECT_TYPE.md` **only if it does not already exist** (never overwrite):

```
# Project Type

- **Project Type:** [selected type]
- **Pillar:** [selected pillar from Cortex, or "general" if no MCP]
- **Initialized:** YYYY-MM-DD
```

### Step 4b: Update Project Identity

After Step 4 confirms the project type, update IDENTITY.md and CLAUDE.md with the user's actual project description. This ensures the auto-loaded context describes *this* project, not the generic Bashi template.

1. **Update IDENTITY.md** — overwrite the `## Fields` section with:
   - **Project:** The project name from Step 3 auto-detection (or the user's description if clearer)
   - **Purpose:** The user's answer from Step 4.3 ("What brings you here today?") — condensed to one sentence
   - **Stack:** Infer from the confirmed project type and any tech mentioned by the user (e.g., "Next.js app" → "Next.js"). If uncertain, keep `[Fill in after architecture decisions]`.
   - **Status:** `Not Started`

2. **Update CLAUDE.md Project Identity section** — replace the `## Project Identity` block in `.claude/CLAUDE.md` with:
   ```markdown
   ## Project Identity

   - **Project:** [project name]
   - **Purpose:** [one-sentence purpose from user's description]
   - **Stack:** [inferred or placeholder]
   - **Framework:** Bashi v[read from FRAMEWORK_VERSION]
   ```

3. If IDENTITY.md or CLAUDE.md already have non-placeholder values (i.e., not `(set by /setup)` and not the generic Bashi template text), skip — don't overwrite user-customized identity.

### Step 5: Create Project-Type Folders (Idempotent)

Create each directory only if it does not already exist. Never delete or modify existing directories.

**Web App / SaaS (Full-Stack):**

- `src/`
- `public/`
- `tests/`

**Mobile App:**

- `lib/`
- `test/`
- `android/`
- `ios/`

**API / Backend:**

- `src/`
- `tests/`

### Step 6: Create Starter Files (Only If Missing)

Create each file **only if it does not already exist**. Never overwrite an existing file.

**Shared (all project types):**

- `docs/PRD.md`
  ```
  # Product Requirements Document

  ## Overview

  *(Describe what you are building, who it is for, and why it matters.)*
  ```

- `docs/PROJECT_CHARTER.md`
  ```
  # Project Charter

  ## Project Name

  *(Your project name)*

  ## Vision

  *(One sentence: what does this project exist to do?)*

  ## Goals

  1. *(Primary goal)*
  2. *(Secondary goal)*
  3. *(Tertiary goal)*

  ## Target Users

  *(Who is this for? Be specific.)*

  ## Constraints

  - **Time:** *(deadline or pace)*
  - **Budget:** *(cost limits)*
  - **Technical:** *(platform, language, or tool constraints)*
  - **Knowledge:** *(what you don't know yet)*

  ## Success Criteria

  *(How will you know this project succeeded? Be measurable.)*

  ## Non-Goals

  - *(What this project will NOT do)*

  ## Risks

  - *(What could go wrong?)*
  ```

- `docs/ARCHITECTURE.md`
  ```
  # Architecture

  ## Overview

  *(Describe the high-level structure, tech stack, and key design decisions.)*
  ```

- `docs/RELEASE_NOTES.md`
  ```
  # Release Notes

  ## v0.1.0 — Project Initialized

  - Project initialized with Bashi template.
  - Initial directory structure created.
  ```

### Step 7: Log Decision (Append-Only)

In `.claude/project/knowledge/DECISIONS.md`, check whether a decision entry already exists containing the text `"Project type set to <type>"`.

- **If it already exists:** skip. Print: `"Decision already logged; skipping."`
- **If it does not exist:** append a new entry using the next available `DEC-XXXX` ID:

```
---

### DEC-XXXX: Project Type Selection

- **Status:** Accepted
- **Date:** YYYY-MM-DD
- **Context:** The project needed a type designation to determine directory structure and starter files.
- **Decision:** Project type set to [Web App | Mobile App | API / Backend | SaaS (Full-Stack)].
- **Consequences:** Type-specific folders and starter files have been created. Future skills and agents can use PROJECT_TYPE.md to adapt behavior.
```

### Step 8: Seed Next Task Queue (Strict Idempotency)

Read `.claude/project/STATE.md` and locate the `## Next Task Queue` section.

**If the queue already contains real tasks**, do NOT modify the queue.
Print: `"Next Task Queue already populated; skipping seeding."`

A queue is considered **empty/placeholder-only** (and therefore eligible for seeding) if it matches ANY of these patterns:
- Contains only `(none)` or `*(none)*`
- Contains only `- (none)`
- Contains only the table headers with no data rows beneath them
- The section is completely empty

**If the queue is empty or placeholder-only**, replace it with starter tasks based on project type:

**All project types (Web App / Mobile App / API / Backend / SaaS):**

| # | Task | Priority | Skill |
|---|------|----------|-------|
| 1 | Draft PRD v1 | High | SKL-0004 |
| 2 | Draft Architecture v1 | High | — |
| 3 | Create initial app scaffold | Medium | — |

### Step 9: Skills Registry Self-Heal

Check `.claude/skills/REGISTRY.md`:

**Rebuild REGISTRY.md if ANY of these conditions are true:**

1. `REGISTRY.md` does not exist.
2. `REGISTRY.md` is empty (zero bytes).
3. `REGISTRY.md` contains `(none)` placeholders in the Skills Index or Trigger Lookup tables.
4. Any subfolder in `.claude/skills/` containing a `SKILL.md` file is **not listed** in the Skills Index table of `REGISTRY.md`.

**Rebuild procedure:**
1. Scan all subfolders in `.claude/skills/` for `SKILL.md` files (excluding `REGISTRY.md`).
2. Extract metadata from each skill file: Skill ID, Name, Version, Owner, Triggers.
3. Regenerate `REGISTRY.md` with the Skills Index table, Trigger Lookup table, and Stats section.
4. If no skill files are found, write `(none)` placeholders.
5. Registry status = `refreshed`

**If none of those conditions are true:** the registry is current. Registry status = `already current`

### Step 10: Emit PROJECT_INITIALIZED Event (Idempotent)

Check `.claude/project/EVENTS.md` under `## Unprocessed Events`.

**Canonical event format:**

```
EVT-XXXX | PROJECT_INITIALIZED | Project initialized as <type> | system | YYYY-MM-DD HH:MM
```

- **If the most recent unprocessed event already matches** `PROJECT_INITIALIZED` with the same project type: skip emitting.
- **Otherwise:** append the canonical event line under `## Unprocessed Events`.
- Auto-increment the EVT ID from the highest existing ID across both sections.
- If the section currently shows `*(none)*`, replace the placeholder with the new event.

### Step 11: Print "Setup Complete" Summary

```
## Setup Complete

- **Project Type:** [Web App | Mobile App | API / Backend | SaaS (Full-Stack) | Template]
- **User Profile:** [Loaded (Name) | Created (Name) | Skipped]
- **AI-Memory:** [Created at <path> | Found at <path> — skipped]
- **Current Mode:** [from STATE.md, e.g., Semi-Autonomous]
- **Unprocessed Events:** [count from EVENTS.md]
- **Skills Available:** [If Cortex MCP connected: call `list_categories`, sum all pillar counts, print "[total] via Cortex MCP ([count from REGISTRY.md] local triggers)". If no Cortex: print "[count from REGISTRY.md] local skills"]
- **Framework Files:** [pass count] / [total count]
- **Runtime Files:** [pass count] / [total count] ([list of CREATED files, or "all present"])
- **Folders Ensured:** [list of folders created or already present]
- **Starter Files Created:** [list of new files, or "none"]
- **Decision Logged:** [yes | already exists]
- **Tasks Queued:** [seeded (3) | skipped (already populated)]
- **Skills Registry:** [refreshed | already current]
- **Event Emitted:** [yes | skipped (already pending)]
- **Missing Framework Files:** [list, or "None"]

### Recommended Next Steps

1. [First recommended action based on project state]
2. [Second recommended action]
3. [Third recommended action]
```

Default recommended actions for a fresh project:
1. Run `/capture-idea` to describe your project concept.
2. Run `/run-project` to process the event and generate a plan.
3. Review the generated PRD and task queue, then run `/run-project` again.

---

## Runtime File Templates

### STATE.md Template

```markdown
# Project State

> Single source of truth for the current project status. Updated by every action.

---

## Framework Mode

`Full Planning`

> **Full Planning** — Full planning pipeline: charter → PRD → architecture → design → tasks → build. Best for complex projects.
> **Quick Start** — Scaffold first, plan as you go: idea → immediate app scaffold → build features one at a time. Best for learning and simple projects.
> Set during `/start`. Change with `/set-mode quick-start` or `/set-mode full-planning`.

---

## Current Mode

| Mode | Description | Active |
|------|-------------|--------|
| Safe | Propose only, no file changes | |
| Semi-Autonomous | Execute one unit of work, then stop for review | **YES** |
| Autonomous | Execute up to N units (see RUN_POLICY.md), then stop | |

---

## Current Phase

`Not Started`

---

## Active Task

| Field | Value |
|-------|-------|
| ID | — |
| Description | — |
| Owner Agent | — |
| Started | — |
| Status | — |

### Status Lifecycle

| Status | Meaning |
|--------|---------|
| In Progress | Work is actively being done |
| Review | Work is done, awaiting review |
| Completed | Reviewed and accepted |
| Blocked | Cannot proceed; see Blockers/Risks |

> **Lifecycle Rule:** When promoting a task into Active Task, set Status = `In Progress` and Started = current timestamp.

### Definition of Done

- [ ] *(populated per task)*

### Inputs / Context Used

*(none)*

### Outputs Produced

*(none)*

---

## Files Modified (Last Task)

*(none)*

---

## Blockers / Risks

*(none)*

---

## Failed Approaches

| Approach | Why It Failed | Date |
|----------|---------------|------|
| *(none yet)* | — | — |

---

## Next Task Queue

| # | Task | Priority | Skill |
|---|------|----------|-------|
| — | *(none — will be seeded by /setup)* | — | — |

---

## Completed Tasks Log

| ID | Description | Completed | Skill Used |
|----|-------------|-----------|------------|
| — | *(none yet)* | — | — |

---

## Run Cycle

| Field | Value |
|-------|-------|
| Current Cycle | 0 |
| Max Cycles This Run | 1 |
| Last Run Status | Idle |
| Consecutive Failures | 0 |
| Phantom Completions | 0 |
| Run Type | Standard |

> **Mode mapping:** Safe = 0 cycles, Semi-Autonomous = 1 cycle, Autonomous = cycle limit from RUN_POLICY.md (default 10).

---

## Session Lock

| Field | Value |
|-------|-------|
| Session Started | — |
| Last Activity | — |
| Checkpointed | No |

> **How it works:** When a session starts, the orchestrator writes the current timestamp to `Session Started` and sets `Checkpointed = No`. When `/save` runs, it sets `Checkpointed = Yes`. On the next session start, if `Checkpointed = No` and `Session Started` has a value, the system warns that the previous session may not have saved all progress.

---

## Goal Alignment

| Field | Value |
|-------|-------|
| Current Goal | — |
| Current Milestone | — |
| Last Step Advanced | — |
```

### EVENTS.md Template

```markdown
# Events Log

> Events represent things that happened or need to happen. They are processed FIFO (oldest first).

---

## Event Format

EVT-XXXX | <TYPE> | <Description> | <Source> | <Timestamp> | <Priority>

- **EVT-XXXX** — Auto-incremented event ID (e.g., EVT-0001)
- **TYPE** — Event type matching a skill trigger or routing rule
- **Description** — Brief summary of what happened or what needs to happen
- **Source** — Who/what created the event (user, agent, system)
- **Timestamp** — When the event was created
- **Priority** — Optional: `high`, `normal`, or `low` (default: `normal` if omitted)

---

## Unprocessed Events

*(none)*

---

## Processed Events

*(none)*
```

### RUN_POLICY.md Template

```markdown
# Run Policy

> Defines execution boundaries for the orchestrator. Read by the orchestrator at the start of every `/run-project` invocation.

---

## Default Mode

Semi-Autonomous

---

## Cycle Limits

| Mode | Cycles per /run-project |
|------|------------------------|
| Safe | 0 (proposal only) |
| Semi-Autonomous | 1 |
| Autonomous | 10 |

> **Configurable:** To change the Autonomous cycle limit, edit the value above. The orchestrator reads this table at the start of each `/run-project` invocation. Default: 10.

---

## Stop Conditions

The orchestrator must stop immediately if any of the following occur:

1. The user says stop.
2. The current task becomes Blocked.
3. A single file modification exceeds 500 lines.
4. The Next Task Queue becomes empty and no next tasks can be proposed.
5. A required artifact is missing and cannot be created safely.
6. The project goal exit condition is satisfied (if `GOAL.md` exists).

---

## Review Gates

| Task Type | Review Agents |
|-----------|--------------|
| Writing / content tasks | Orchestrator (self-review for clarity and beginner-friendliness) |
| Conceptual / framework tasks | Orchestrator (self-review for consistency and coherence) |
| Implementation / build tasks | Defined by routing rules or skills |

---

## Claude Code Permissions

> The framework's Autonomous mode and Claude Code's tool permissions are **two independent layers**. Even in Autonomous mode, CC may prompt for every file write or bash command.

**Why this matters:** If CC prompts on each tool call, Autonomous mode's multi-cycle runs are interrupted constantly, defeating the purpose.

**Recommended approach before entering Autonomous mode:**
1. When CC prompts for a tool permission, select **"Allow for this session"** for common operations (file writes, reads, bash commands in the project directory).
2. For persistent permissions, configure your `.claude/settings.json` allow list with patterns matching your project's file types.
3. The `/set-mode auto` command will remind you about this.

**Note:** This only affects CC-level permissions. The framework's own stop conditions, review gates, and circuit breakers still apply regardless of CC permission settings.

---

## Mode Escalation

At the start of each `/run-project` invocation, check if the current phase suggests a mode change. **Suggest, never force.**

| Current Phase | Current Mode | Suggestion |
|---------------|-------------|------------|
| `Building` | Semi-Autonomous | "Planning is complete and you're in Building phase. Consider `/set-mode auto` for faster progress through the task queue." |
| `Ready for Deploy` | Autonomous | "Build tasks are done. Consider `/set-mode semi` for more careful oversight during deployment." |
| `Deploying` | Autonomous | "Deployment in progress. Consider `/set-mode semi` to review each deploy step." |

If a suggestion applies: print it once at the top of the run output, then proceed normally. Do not re-suggest on consecutive runs if the user has not changed mode.

---

## Execution Rule

After every cycle the orchestrator must:

1. Update `.claude/project/STATE.md` (Active Task, Outputs, Files Modified, Completed Tasks Log, Run Cycle).
2. Print an Execution Summary.
3. Evaluate stop conditions before starting the next cycle.
```

### IDENTITY.md Template

> Note: `/setup` auto-populates Project and Purpose from README/git/directory — use this
> template only as a fallback when no context can be detected.

```markdown
# Project Identity

> Persists project-specific identity across `/clone-framework --upgrade` runs.
> Managed by `/setup` (creates) and `/clone-framework` (reads). Do not delete.

---

## Fields

- **Project:** [auto-detected from README heading or git repo name]
- **Status:** Not Started
- **Stack:** [Fill in after architecture decisions]
- **Purpose:** [auto-detected from README first paragraph, or describe in one sentence]
```

### DECISIONS.md Template

```markdown
# Decisions Log

> Record architectural and design decisions here.

---

## Decision Template

### DEC-XXXX: [Title]

- **Status:** Proposed | Accepted | Superseded
- **Date:** YYYY-MM-DD
- **Context:** Why this decision was needed
- **Decision:** What was decided
- **Consequences:** What follows from this decision

---

*(No decisions recorded yet.)*
```

### RESEARCH.md Template

```markdown
# Research Notes

> Store research findings, references, and external knowledge here.

---

## Research Entry Template

### RES-XXXX: [Title]

- **Date:** YYYY-MM-DD
- **Source:** URL, book, or reference
- **Summary:** Key findings in 2-3 sentences
- **Relevance:** How this applies to the current project
- **Status:** Active | Outdated | Unverified

---

*(No research entries yet.)*
```

### GLOSSARY.md Template

```markdown
# Glossary

> Definitions of key terms. Keep entries beginner-friendly.

---

| Term | Definition |
|------|------------|
| **Orchestrator** | The central agent that runs the system. It reads STATE, processes events, routes tasks to skills, and updates everything. |
| **Agent** | A specialized role that performs a specific type of work (e.g., planning, building, reviewing). Defined in .claude/agents/. |
| **Skill** | A reusable procedure for a specific task. Skills have triggers, inputs, outputs, and a definition of done. They live in .claude/skills/. |
| **Event** | Something that happened or needs to happen, logged in EVENTS.md. Events trigger skills. |
| **State** | The current status of the project, tracked in STATE.md. Includes the active task, mode, blockers, and history. |
| **SDLC** | Software Development Life Cycle. The phases a project goes through: planning, building, testing, deploying, maintaining. |
| **PRD** | Product Requirements Document. Describes what you're building, who it's for, and what it should do. |
```

### OPEN_QUESTIONS.md Template

```markdown
# Open Questions

> Unresolved questions and uncertainties. Review these when making decisions. Close them when answered.

---

## Question Template

### OQ-XXXX: [Question]

- **Status:** Open | Resolved | Deferred
- **Date Raised:** YYYY-MM-DD
- **Context:** Why this question matters
- **Resolution:** (filled in when resolved)

---

*(No open questions yet.)*
```

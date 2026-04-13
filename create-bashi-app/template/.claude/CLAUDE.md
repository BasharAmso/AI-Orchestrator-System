# CLAUDE.md - Bashi Context Index

> This file is loaded automatically on every session. Keep it concise.

## Project Identity

- **Template:** Bashi
- **Problem:** The Syntax Wall (you can architect and direct - but writing code line-by-line blocks shipping)
- **Method:** AI Orchestration Framework (agents, skills, hooks, and state machine for structured AI development)
- **Tool:** Bashi (this template - software development variant)

## Key Files

| File | Purpose |
|------|---------|
| `FRAMEWORK_VERSION` | Semver version stamp for upgrade tracking |
| `README.md` | Human-readable overview, quick start, and command reference |
| `.claude/project/STATE.md` | Current task, mode, blockers, history |
| `.claude/project/EVENTS.md` | Event queue (unprocessed + processed) |
| `.claude/skills/REGISTRY.md` | Skill index with triggers |
| `.claude/agents/orchestrator.md` | Core agent: event/task processing loop |

## Rules (auto-loaded by Claude Code)

| Rule File | Governs |
|-----------|---------|
| `.claude/rules/orchestration-routing.md` | Task type to agent routing |
| `.claude/rules/event-hooks.md` | Event type to agent routing |
| `.claude/rules/knowledge-policy.md` | When to read/write knowledge files |
| `.claude/rules/context-policy.md` | Chat context conservation and artifact persistence |
| `.claude/rules/user-consent.md` | Never auto-select when a procedure says to ask the user |
| `.claude/rules/methodology-policies.md` | Dispatch policy per methodology (Waterfall, Kanban, Scrum, FDD) |

## Knowledge Base (`.claude/project/knowledge/`)

| File | Contains |
|------|----------|
| `DECISIONS.md` | Architectural and design decisions |
| `RESEARCH.md` | Research notes and references |
| `GLOSSARY.md` | Term definitions |
| `OPEN_QUESTIONS.md` | Unresolved questions and uncertainties |
| `TODOS-FORMAT.md` | Standard format for TODOS.md (cross-skill convention) |
| `TASK-FORMAT.md` | Canonical task table format for STATE.md Next Task Queue |

## Commands

| Command | Entry Point |
|---------|-------------|
| `/run-project` | `.claude/commands/run-project.md` |
| `/trigger` | `.claude/commands/trigger.md` |
| `/fix-registry` | `.claude/commands/fix-registry.md` |
| `/capture-idea` | `.claude/commands/capture-idea.md` |
| `/capture-lesson` | `.claude/commands/capture-lesson.md` |
| `/doctor` | `.claude/commands/doctor.md` |
| `/save` | `.claude/commands/save.md` |
| `/start` | `.claude/commands/start.md` |
| `/setup` | `.claude/commands/setup.md` |
| `/set-mode` | `.claude/commands/set-mode.md` |
| `/methodology` | `.claude/commands/methodology.md` |
| `/status` | `.claude/commands/status.md` |
| `/clone-framework` | `.claude/commands/clone-framework.md` |
| `/cleanup` | `.claude/commands/cleanup.md` |
| `/retro` | `.claude/commands/retro.md` |
| `/test-framework` | `.claude/commands/test-framework.md` |
| `/test-hooks` | `.claude/commands/test-hooks.md` |
| `/test-skill` | `.claude/commands/test-skill.md` |
| `/log-session` | `.claude/commands/log-session.md` |
| `/learn` | `.claude/commands/learn.md` |
| `/framework-review` | `.claude/commands/framework-review.md` |
| `/overnight` | `.claude/commands/overnight.md` |

## Context Loading Policy

To stay token-efficient, load context incrementally:

| Situation | Load |
|-----------|------|
| **Default (any task)** | This file + relevant rules for the task type |
| **Conceptual / design work** | + `DECISIONS.md` + `GLOSSARY.md` |
| **Research-backed claims** | + `RESEARCH.md` |
| **Uncertainty or ambiguity** | + `OPEN_QUESTIONS.md` |
| **Running the system** | + `STATE.md` + `EVENTS.md` + `REGISTRY.md` |
| **Non-Waterfall dispatch** | + `SPRINT.md` (Scrum) or `FEATURES.md` (FDD) — methodology-policies.md is already auto-loaded as a rule |
| **Session start** | Scan `AI-Memory/lessons/` for entries relevant to the current task |
| **Session start** | Load `~/.bashi/user-profile.md` if it exists (adapts output style, experience level, role) |
| **MCP available** | Query Cortex MCP instead of reading `.claude/agents/` and `.claude/skills/` (see orchestrator.md Section Knowledge Source Detection) |

> Do NOT load all files at once. Read only what the current task requires.

## Conventions

- STATE.md is the single source of truth for current work.
- Every action must update STATE before completing.
- Events are processed oldest-first (FIFO).
- Default mode is Semi-Autonomous: one unit of work, then stop.
- Default methodology is Waterfall. Run `/methodology` to switch.
- When the user asks a framework question, requests guidance, or describes a goal without specifying a command, follow the coach agent procedure at `.claude/agents/coach.md`.
- For first-time orientation, run `/start` first; the coach handles follow-up conversation.
- When a queued task has a Skill assigned, remind the user to run `/run-project` — conversational execution bypasses skill procedures and quality gates. Proceed only if the user explicitly accepts the tradeoff.

## Methodology (optional)

Default is **Waterfall** (sequential task execution — no extra config needed). Run `/methodology <name>` to switch:

| Methodology | Best For | Setup |
|-------------|----------|-------|
| **Waterfall** | Sequential execution, solo work | Default — no setup |
| **Kanban** | Continuous flow, async work, parallel worktrees | Sets WIP limit |
| **Scrum** | Time-bounded delivery with planned reviews | Creates SPRINT.md, sets sprint duration |
| **FDD** | User-facing capabilities delivered as feature slices | Creates FEATURES.md, groups tasks by feature |

- Dispatch policy details: `.claude/rules/methodology-policies.md`
- Orchestrator filter: `orchestrator.md` step 1.5
- FDD and Scrum cannot switch directly — route through Waterfall first.

> Architecture primitives, dispatch chain, and full command reference: `.claude/REFERENCE.md`

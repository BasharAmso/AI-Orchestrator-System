# CLAUDE.md — Bashi Context Index

> This file is loaded automatically on every session. Keep it concise.

## Project Identity

- **Template:** Bashi
- **Problem:** The Syntax Wall (you can architect and direct — but writing code line-by-line blocks shipping)
- **Method:** AI Orchestration Framework (agents, skills, hooks, and state machine for structured AI development)
- **Tool:** Bashi (this template — software development variant)

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
| `/status` | `.claude/commands/status.md` |
| `/clone-framework` | `.claude/commands/clone-framework.md` |
| `/cleanup` | `.claude/commands/cleanup.md` |
| `/retro` | `.claude/commands/retro.md` |
| `/test-framework` | `.claude/commands/test-framework.md` |
| `/test-hooks` | `.claude/commands/test-hooks.md` |
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
| **Session start** | Scan `AI-Memory/lessons/` for entries relevant to the current task |
| **Session start** | Load `~/.bashi/user-profile.md` if it exists (adapts output style, experience level, role) |
| **MCP available** | Query Cortex MCP instead of reading `.claude/agents/` and `.claude/skills/` (see orchestrator.md § Knowledge Source Detection) |

> Do NOT load all files at once. Read only what the current task requires.

## Conventions

- STATE.md is the single source of truth for current work.
- Every action must update STATE before completing.
- Events are processed oldest-first (FIFO).
- Default mode is Semi-Autonomous: one unit of work, then stop.
- When the user asks a framework question, requests guidance, or describes a goal without specifying a command, follow the coach agent procedure at `.claude/agents/coach.md`.
- For first-time orientation, run `/start` first; the coach handles follow-up conversation.

> Architecture primitives, dispatch chain, and full command reference: `.claude/REFERENCE.md`

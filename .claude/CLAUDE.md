# CLAUDE.md — AI Builder System Context Index

> This file is loaded automatically on every session. Keep it concise.

## Project Identity

- **Template:** AI Builder System
- **Problem:** The Syntax Wall (non-programmers blocked by syntax)
- **Method:** AI Orchestration Framework (structured AI agent workflows)
- **Tool:** AI Builder System (this template)

## Key Files

| File | Purpose |
|------|---------|
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

## Knowledge Base (`.claude/project/knowledge/`)

| File | Contains |
|------|----------|
| `DECISIONS.md` | Architectural and design decisions |
| `RESEARCH.md` | Research notes and references |
| `GLOSSARY.md` | Term definitions |
| `OPEN_QUESTIONS.md` | Unresolved questions and uncertainties |

## Commands

| Command | Entry Point |
|---------|-------------|
| `/run-project` | `.claude/commands/run-project.md` |
| `/emit-event` | `.claude/commands/emit-event.md` |
| `/refresh-skills` | `.claude/commands/refresh-skills.md` |
| `/bootstrap` | `.claude/commands/bootstrap.md` |
| `/init-project` | `.claude/commands/init-project.md` |
| `/capture-idea` | `.claude/commands/capture-idea.md` |
| `/capture-lesson` | `.claude/commands/capture-lesson.md` |
| `/system-check` | `.claude/commands/system-check.md` |
| `/checkpoint` | `.claude/commands/checkpoint.md` |
| `/start` | `.claude/commands/start.md` |

## Architecture Primitives

| Primitive | Location | Role |
|-----------|----------|------|
| Commands | `.claude/commands/` | Entry points: `/run-project`, `/emit-event`, `/bootstrap`, etc. |
| State | `.claude/project/STATE.md` | Single source of truth: current task, mode, blockers, history |
| Events | `.claude/project/EVENTS.md` | Queue of things that happened or need to happen (FIFO) |
| Skills | `.claude/skills/` | Reusable procedures with triggers, registered in REGISTRY.md |
| Registry | `.claude/skills/REGISTRY.md` | Skill index mapping triggers to skill files |
| Rules | `.claude/rules/` | Governance: routing, security, policy |
| Agents | `.claude/agents/` | Specialized roles that execute skills (core: Orchestrator) |
| Knowledge | `.claude/project/knowledge/` | Persistent memory: decisions, research, glossary, open questions |

## Dispatch Chain

`Events → Skills (via REGISTRY) → Agents (via routing rules)`
Fallback: REGISTRY trigger → event-hooks.md → orchestration-routing.md.
Full algorithm: `.claude/agents/orchestrator.md` § "Dispatch Chain (Canonical)".

## Context Loading Policy

To stay token-efficient, load context incrementally:

| Situation | Load |
|-----------|------|
| **Default (any task)** | This file + relevant rules for the task type |
| **Conceptual / design work** | + `DECISIONS.md` + `GLOSSARY.md` |
| **Research-backed claims** | + `RESEARCH.md` |
| **Uncertainty or ambiguity** | + `OPEN_QUESTIONS.md` |
| **Running the system** | + `STATE.md` + `EVENTS.md` + `REGISTRY.md` |

> Do NOT load all files at once. Read only what the current task requires.

## Conventions

- STATE.md is the single source of truth for current work.
- Every action must update STATE before completing.
- Events are processed oldest-first (FIFO).
- Default mode is Semi-Autonomous: one unit of work, then stop.
- When the user asks a framework question, requests guidance, or describes a goal without specifying a command, follow the coach agent procedure at `.claude/agents/coach.md`.
- For first-time orientation, run `/start` first; the coach handles follow-up conversation.

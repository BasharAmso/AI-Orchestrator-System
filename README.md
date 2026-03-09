# AI Builder System

The AI Builder System is a reusable project template that lets you build software projects using AI — without needing to write code yourself. Copy this folder into any new project (a web app, mobile app, book, or anything else), open it in VS Code with Claude Code, and start building by describing what you want in plain language.

The system gives your AI assistant a structured set of agents, skills, and rules so it can plan, build, test, and ship your project step by step. You stay in control: every action is reviewed before the next one starts.

## The Naming Stack

| Layer | Name | What It Means |
|-------|------|---------------|
| **Problem** | The Syntax Wall | The barrier that stops non-programmers from building software — you have the idea but not the syntax. |
| **Method** | AI Orchestration Framework | A structured method for coordinating AI agents, skills, and events to do the building for you. |
| **Tool** | AI Builder System | This template — the ready-to-use implementation of the framework. |

## Quick Start

1. **Copy** this entire folder into a new directory (or use `/clone-framework`).
2. **Rename** it to match your project (e.g., `my-cool-app`).
3. **Open** the folder in VS Code with Claude Code installed.
4. **Run these commands** in order:

```
/start             — See where you are and what to do next
/setup             — Create project structure and runtime files
/capture-idea      — Describe what you want to build
/run-project       — Start processing (generates PRD, seeds tasks)
```

That's it. The system will guide you from there.

## What's Inside

```
.claude/
  CLAUDE.md            — Context index + architecture guide (loaded by Claude on startup)
  agents/              — AI agent definitions (orchestrator)
  commands/            — Entry-point commands you run
  rules/               — Routing and governance policies
  skills/              — Reusable task procedures + registry
  project/
    STATE.md           — Current project status (single source of truth)
    EVENTS.md          — Event queue (things to process)
    knowledge/         — Decisions, research, glossary, open questions
```

## System Commands

| Command | What It Does |
|---------|-------------|
| `/start` | Detect project state and recommend what to do next. |
| `/setup` | Create project structure, runtime files, and starter docs. Replaces the old `/bootstrap` and `/init-project`. |
| `/capture-idea` | Turn a rough idea into a structured starting point (research, PRD stub, tasks, event). |
| `/run-project` | Execute orchestration cycles — process events and tasks based on current mode. |
| `/status` | Show a project dashboard: phase, mode, progress, active task, queue. |
| `/set-mode` | Switch between Safe, Semi-Autonomous, and Autonomous execution modes. |
| `/checkpoint` | Save session progress so the next session can pick up where you left off. |
| `/emit-event` | Manually trigger a workflow by emitting an event. |
| `/refresh-skills` | Rebuild the Skills Registry so the orchestrator can discover available workflows. |
| `/system-check` | Run diagnostics to verify the environment is healthy, with optional auto-repair. |
| `/clone-framework` | Copy or upgrade the AI Builder System into another project directory. |
| `/capture-lesson` | Save a reusable insight to global memory for cross-project learning. |
| `/prune-knowledge` | Review knowledge files for staleness and recommend cleanup. |

### Recommended First-Time Flow

```
1. /start            — See where you are and what to do next
2. /setup            — Create project structure and runtime files
3. /capture-idea     — Describe what you want to build
4. /run-project      — Process the idea (generates PRD, seeds tasks)
5. /run-project      — Execute the first task from the queue
```

## Run Modes

| Mode | What Happens |
|------|-------------|
| **Safe** | Propose actions only. No files are modified. |
| **Semi-Autonomous** | Execute one safe cycle and pause for review. *(Default)* |
| **Autonomous** | Execute up to 10 cycles before stopping (configurable in RUN_POLICY.md). |

Switch modes with `/set-mode safe`, `/set-mode semi`, or `/set-mode auto`. Cycle limits and stop conditions are defined in [.claude/project/RUN_POLICY.md](.claude/project/RUN_POLICY.md). The current mode is shown in [.claude/project/STATE.md](.claude/project/STATE.md).

## Global Memory

The AI Builder System supports cross-project learning. All reusable knowledge — decisions, patterns, failures, and lessons — is stored in a separate **AI-Memory** directory that lives outside any single project.

> **Setup:** Create an `AI-Memory` folder on your machine (e.g., alongside your projects) and set the `AI_MEMORY_PATH` environment variable to point to it. See the `/capture-lesson` command for details.

This allows future projects to benefit from past discoveries. The orchestrator checks global memory before major architectural work and writes new insights back when they emerge.

## Self-Improving Skills

The AI Builder System can capture proposed improvements to reusable skills. When the orchestrator notices a skill causing repeated friction or rework, it logs a proposal in `SKILL_IMPROVEMENTS.md` inside your AI-Memory folder.

Skills do not rewrite themselves automatically. Instead, the system logs proposed improvements for later review and approval. This keeps the improvement loop safe and human-controlled.

## Learn More

- **[User Guide](docs/USER_GUIDE.md)** — Step-by-step walkthrough for first-time users.
- **[Custom Skills Guide](docs/CUSTOM_SKILLS_GUIDE.md)** — How to create your own skills.
- **[Framework Scope](docs/FRAMEWORK_SCOPE.md)** — The conceptual "why" behind the framework.
- **[CLAUDE.md](.claude/CLAUDE.md)** — Architecture index and context loading rules (loaded by Claude Code automatically).

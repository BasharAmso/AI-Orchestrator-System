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

1. **Copy** this entire folder into a new directory.
2. **Rename** it to match your project (e.g., `my-cool-app`).
3. **Open** the folder in VS Code with Claude Code installed.
4. **Run these commands** in order:

```
/bootstrap         — Verify all files are in place
/refresh-skills    — Build the skill registry
/run-project       — Start processing (describe your idea when prompted)
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
| `/bootstrap` | Prepare the project environment and ensure core system files exist. |
| `/init-project` | Create the correct folder structure and starter files for Book, Web App, or Mobile App projects. |
| `/capture-idea` | Turn a rough idea into a structured starting point (research entry, PRD stub, tasks, event). |
| `/refresh-skills` | Rebuild the Skills Registry so the orchestrator can discover available workflows. |
| `/run-project` | Execute one safe orchestration cycle (process one event or one task by default). |
| `/system-check` | Run a read-only diagnostic to verify the environment is healthy. |

### Recommended First-Time Flow

```
1. /bootstrap        — Prepare the project environment and ensure core system files exist
2. /init-project     — Set up folders and files for your project type
3. /capture-idea     — Describe what you want to build
4. /refresh-skills   — Update the skill registry
5. /run-project      — Start the first orchestration cycle
```

## Run Modes

| Mode | What Happens |
|------|-------------|
| **Safe** | Propose actions only. No files are modified. |
| **Semi-Autonomous** | Execute one safe cycle and pause for review. *(Default)* |
| **Autonomous** | Execute up to five cycles before stopping. |

The orchestrator runs bounded autonomous cycles rather than a single step. Cycle limits and stop conditions are defined in [.claude/project/RUN_POLICY.md](.claude/project/RUN_POLICY.md). The current mode is set in [.claude/project/STATE.md](.claude/project/STATE.md).

## Global Memory

The AI Builder System supports cross-project learning. All reusable knowledge — decisions, patterns, failures, and lessons — is stored in a separate **AI-Memory** directory that lives outside any single project.

> **Setup:** Create an `AI-Memory` folder on your machine (e.g., alongside your projects) and set the `AI_MEMORY_PATH` environment variable to point to it. See the `/capture-lesson` command for details.

This allows future projects to benefit from past discoveries. The orchestrator checks global memory before major architectural work and writes new insights back when they emerge.

## Self-Improving Skills

The AI Builder System can capture proposed improvements to reusable skills. When the orchestrator notices a skill causing repeated friction or rework, it logs a proposal in `SKILL_IMPROVEMENTS.md` inside your AI-Memory folder.

Skills do not rewrite themselves automatically. Instead, the system logs proposed improvements for later review and approval. This keeps the improvement loop safe and human-controlled.

## Learn More

Open [.claude/CLAUDE.md](.claude/CLAUDE.md) for the full architecture explanation, including how events, skills, agents, and the dispatch chain work together. This is also the file Claude Code reads automatically on every session.

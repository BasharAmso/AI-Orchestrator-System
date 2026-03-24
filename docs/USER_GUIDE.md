# The AI Orchestrator System — User Guide

This guide walks you through using The AI Orchestrator System from start to finish. No programming experience required — you'll describe what you want in plain language and the system handles the rest.

If you're looking for the conceptual explanation of *why* this system exists, see [FRAMEWORK_SCOPE.md](FRAMEWORK_SCOPE.md). This guide focuses on the *how*.

---

## 1. What You Need Before Starting

Before using The AI Orchestrator System, make sure you have:

- **VS Code** — A free code editor from Microsoft. Download it from the official VS Code website.
- **Claude Code** — The AI assistant that powers the system. Install the Claude Code extension inside VS Code.
- **A copy of The AI Orchestrator System** — Either cloned from the template repository or copied using the `/clone-framework` command from an existing project.

That's everything. You won't write code — you'll type short commands and describe what you want to build. The system coordinates the AI to do the technical work.

---

## 2. Your First Project

This walkthrough takes you from an empty project to a running task queue. We'll use a simple example: building a recipe sharing website.

### Step 1: Open Your Project

Open your project folder in VS Code. If you copied The AI Orchestrator System template into a folder called `my-recipe-app`, open that folder.

### Step 2: Run /start

Type `/start` in the Claude Code chat. This is a read-only command that detects your project's current state and tells you what to do next.

```
## Project State: Not Bootstrapped

The project directory exists but hasn't been set up yet.

Recommended next step: /setup
```

The system classified your situation and recommended a command. Follow its advice.

### Step 3: Run /setup

Type `/setup`. This command creates the directory structure, verifies framework files, generates runtime files (like STATE.md and EVENTS.md), and asks you to choose a project type.

```
## Setup Complete

- Directories: 6 verified
- Framework files: 12 verified
- Runtime files: 3 created (STATE.md, EVENTS.md, RUN_POLICY.md)
- Project type: Web App
- Tasks seeded: 3 starter tasks

Next step: /capture-idea to describe what you want to build.
```

The system is now initialized and ready to receive your idea.

### Step 4: Run /capture-idea

Type `/capture-idea`. The system will ask you to describe your project. Write in plain language — no technical jargon needed.

You might say something like:

> "I want to build a recipe sharing website where people can post their favorite recipes, browse by category, and save recipes to a personal collection. It should have a clean, modern design and work on mobile."

The system takes your idea and creates:

- A **PRD** (Product Requirements Document) in `docs/PRD.md`
- An **architecture stub** in `docs/ARCHITECTURE.md`
- **Tasks** seeded into the task queue in STATE.md
- An **event** (`IDEA_CAPTURED`) in EVENTS.md that triggers the planning workflow

```
## Idea Captured

- PRD stub: docs/PRD.md
- Architecture stub: docs/ARCHITECTURE.md
- Research entry: RES-0001 logged
- Event emitted: IDEA_CAPTURED
- Tasks seeded: 3 planning tasks

Next step: /run-project to process the idea.
```

### Step 5: Run /run-project (First Time)

Type `/run-project`. The system picks up the `IDEA_CAPTURED` event and processes it. On this first run, it typically:

1. Reads your idea description
2. Expands the PRD with user stories, features, and success criteria
3. Proposes an architecture and tech stack
4. Breaks the work into a detailed task queue

```
## Run Summary — Cycle 1/1

- Event processed: EVT-0001 (IDEA_CAPTURED)
- Skill executed: SKL-0001 (Plan From Idea)
- Output: docs/PRD.md updated (5 user stories, 3 NFRs)
- Tasks queued: 12 development tasks
- Phase: Planning
- Progress: 0/12 tasks (0%)

Next: /run-project to start executing tasks.
```

### Step 6: Run /run-project Again

Each time you run `/run-project`, the system executes the next task in the queue. In Semi-Autonomous mode (the default), it completes one task and stops for your review.

```
## Run Summary — Cycle 1/1

- Task completed: TSK-0001 (Define database schema)
- Skill: SKL-0008 (Database Design)
- Output: Database schema written to docs/ARCHITECTURE.md
- Files modified: docs/ARCHITECTURE.md
- Phase: Building
- Progress: 1/12 tasks (8%)

Next: /run-project to continue.
```

### Step 7: Check Your Progress

At any point, type `/status` to see where things stand.

```
## Project Dashboard

Phase:    Building
Mode:     Semi-Autonomous (1 cycle/run)
Progress: 4/12 tasks (33%)

Active:   TSK-0005 — Build recipe listing page
Queue:    8 tasks remaining
Blockers: None
```

### Step 8: Keep Going

Continue running `/run-project` to execute tasks one by one. When you're comfortable with how things are going, you can switch to Autonomous mode for faster progress (see Section 4).

### Step 9: Save Before Closing

Before you close VS Code or end your session, run `/save`. This ensures all progress is saved to files so the next session picks up exactly where you left off.

```
## Save Complete

- STATE.md: updated (active task, completed log)
- Knowledge: 2 decisions persisted
- Session safe to end.
```

**Tip:** If you're ever unsure what to do next, just ask in the chat. The system has a built-in Coach that reads your project state and recommends the right command. Try saying "What should I do next?" and it will guide you.

---

## 3. Understanding the Dashboard

The `/status` command gives you a one-screen snapshot of your project. Here's what each field means.

### Phase

Your project moves through these phases automatically:

| Phase | What It Means |
|-------|--------------|
| **Not Started** | Project exists but no idea has been captured yet |
| **Planning** | Idea captured, PRD being written, tasks being created |
| **Building** | Development tasks are being executed |
| **Ready for Deploy** | All build tasks are done, deployment tasks are queued |
| **Deploying** | Deployment is in progress |
| **Live** | Project is deployed and running |

You don't set the phase manually — the system evaluates conditions after each task and advances automatically. When a phase transition happens, you'll see a notification suggesting you capture any lessons learned.

### Mode

Shows how fast the system runs (see Section 4 for details).

### Progress

A percentage showing completed tasks vs. total tasks. For example, "4/12 tasks (33%)" means 4 of 12 tasks are done.

### Active Task

The task currently being worked on (or the last one completed).

### Queue

How many tasks are waiting to be executed.

### Blockers

If a task gets stuck — maybe it needs input from you, or depends on something that isn't ready — the blocker appears here. The system stops automatically when it hits a blocker.

### Reading STATE.md Directly

For more detail than the dashboard provides, open `.claude/project/STATE.md`. It contains the full task queue, completed task log, cycle counters, and everything the system tracks. The dashboard is a summary — STATE.md is the source of truth.

---

## 4. Run Modes — Controlling Speed

The AI Orchestrator System has three speed settings. You control which one is active.

### Safe Mode

```
/set-mode safe
```

- **Cycles per run:** 0
- **What happens:** The system proposes what it would do, but changes nothing. No files are created or modified.
- **When to use:** When you want to preview the next action before committing to it. Good for learning how the system works.

### Semi-Autonomous Mode (Default)

```
/set-mode semi
```

- **Cycles per run:** 1
- **What happens:** The system executes one task, then stops for your review. You see what it did and decide whether to continue.
- **When to use:** Normal operation. Review each step as it happens. This is the default and the safest way to work.

### Autonomous Mode

```
/set-mode auto
```

- **Cycles per run:** Up to 10 (configurable in RUN_POLICY.md)
- **What happens:** The system executes multiple tasks in a row, stopping only when it hits a circuit breaker (queue empty, task blocked, cycle limit reached).
- **When to use:** When you're confident in the plan and want faster progress. Best for the Building phase when tasks are well-defined.

### When to Use Each Mode

| Phase | Recommended Mode | Why |
|-------|-----------------|-----|
| Planning | Semi-Autonomous | Review each planning decision carefully |
| Building | Autonomous | Tasks are well-defined; let the system run |
| Ready for Deploy | Semi-Autonomous | Review deployment preparation carefully |
| Deploying | Semi-Autonomous | Deployment steps need careful oversight |

The system suggests mode changes automatically. When you enter the Building phase in Semi-Autonomous mode, you'll see:

> "Planning is complete and you're in Building phase. Consider `/set-mode auto` for faster progress through the task queue."

### A Note About Permissions

The system's mode and Claude Code's tool permissions are two separate things. Even in Autonomous mode, Claude Code may still ask for permission before writing files or running commands. If you're entering Autonomous mode, consider selecting "Allow for this session" when prompted for common operations so the system can run without interruption.

---

## 5. Command Reference

### Core Commands

These 5 commands cover the entire workflow. You'll use them in almost every session.

| Command | What It Does |
|---------|-------------|
| `/start` | See where you are and what to do next. Read-only — never changes files. Run this at the start of any session. |
| `/setup` | Set up the project structure, verify framework files, and create runtime files. Safe to run multiple times. |
| `/capture-idea` | Describe what you want to build in plain language. Creates a PRD stub, architecture stub, seeds tasks, and kicks off the planning workflow. |
| `/run-project` | Do the next piece of work. Processes events and executes tasks based on your current mode. Run this repeatedly to advance through your task queue. |
| `/save` | Save your progress so the next session picks up where you left off. Run this before closing VS Code. |

### Power User Commands

The system will suggest these when the situation calls for them. You don't need to memorize them.

| Command | What It Does |
|---------|-------------|
| `/status` | Show a compact project dashboard with phase, mode, progress, and blockers. Read-only. |
| `/set-mode <mode>` | Switch execution speed. Options: `safe` (preview only), `semi` (one task at a time), `auto` (up to 10 tasks per run). |
| `/trigger` | Manually trigger a workflow by creating an event. For things like requesting a code review or reporting a bug. |
| `/doctor` | Diagnose the health of your project. Checks directories, files, registry, and state consistency. Offers repairs for common issues. |
| `/fix-registry` | Rebuild the skills registry by scanning all skill files. Run this after adding new skills or if skills aren't being found. |
| `/cleanup` | Review the knowledge base for stale or superseded entries. Read-only — suggests cleanup but never deletes. |
| `/clone-framework <path>` | Copy The AI Orchestrator System to a new project directory. Add `--upgrade` to update an existing project's framework files. |
| `/capture-lesson` | Save an insight, failure, decision, or pattern to global memory so future projects can benefit from it. |

### Deprecated Commands

These commands still work but have been replaced by `/setup`:

- `/bootstrap` — Use `/setup` instead.
- `/init-project` — Use `/setup` instead.

---

## 6. Working Across Sessions

AI chat context doesn't persist between sessions. When you close VS Code and reopen it, the AI starts fresh — it doesn't remember your previous conversation.

But your project state does persist. Everything important is written to files:

- **STATE.md** — Your current task, completed tasks, phase, mode, and task queue
- **EVENTS.md** — All events that have been processed and any still waiting
- **Knowledge files** — Decisions, research, glossary terms, and open questions
- **PRD and architecture** — Your project's requirements and design

### Starting a New Session

1. Open your project in VS Code.
2. Type `/start`. The system reads STATE.md and tells you exactly where you left off.
3. Continue with whatever command it recommends (usually `/run-project`).

That's it. The system reconstructs your context from the files.

### Why /save Matters

The `/save` command ensures that any progress made during the chat — decisions discussed, artifacts created, tasks completed — is fully written to the project files. Without it, some in-progress work might only exist in the chat window and would be lost when the session ends.

**Rule of thumb:** Run `/save` before closing VS Code. It only takes a moment and prevents lost work.

### The Knowledge Base

As your project evolves, the system builds a knowledge base in `.claude/project/knowledge/`:

| File | What It Stores |
|------|---------------|
| `DECISIONS.md` | Architectural and design choices (tech stack, patterns, trade-offs) |
| `RESEARCH.md` | Information gathered about tools, services, and best practices |
| `GLOSSARY.md` | Definitions for terms used in the project |
| `OPEN_QUESTIONS.md` | Unresolved questions that still need answers |

These files help the AI maintain consistency across sessions. When it needs to make a decision, it checks whether that decision was already made. When it encounters an unfamiliar term, it checks the glossary.

You can read and edit these files yourself at any time. They're plain Markdown.

---

## 7. How the System Works

This section is optional. If you just want to use the system, the previous sections are all you need. This section is for anyone curious about what's happening behind the scenes.

### The Eight Primitives

The AI Orchestrator System is built from eight building blocks:

| Primitive | Location | Role |
|-----------|----------|------|
| **Commands** | `.claude/commands/` | Entry points you type (like `/run-project`) |
| **State** | `.claude/project/STATE.md` | Single source of truth: current task, mode, phase, history |
| **Events** | `.claude/project/EVENTS.md` | Queue of things that happened or need to happen |
| **Skills** | `.claude/skills/` | Reusable procedures for specific tasks (writing a PRD, designing a database, etc.) |
| **Registry** | `.claude/skills/REGISTRY.md` | Index that maps event types to skills |
| **Rules** | `.claude/rules/` | Governance: how tasks are routed, when security checks run, how context is managed |
| **Agents** | `.claude/agents/` | Specialized roles that execute skills (Builder, Reviewer, Deployer, etc.) |
| **Knowledge** | `.claude/project/knowledge/` | Persistent memory: decisions, research, glossary, open questions |

### The Dispatch Chain

When you run `/run-project`, the system needs to decide *who does the work*. It follows a three-step lookup:

```
1. Check the Skills Registry
   └─ Does REGISTRY.md have a skill triggered by this event type?
   └─ If yes → execute that skill (fastest path)

2. Check the Event Hooks
   └─ Does event-hooks.md have a routing rule for this event type?
   └─ If yes → route to the specified agent

3. Check the Task Routing Table
   └─ Does orchestration-routing.md have a rule for this task type?
   └─ If yes → route to the specified agent
   └─ If no → the Orchestrator handles it directly
```

For example, when an `IDEA_CAPTURED` event arrives:
1. Registry lookup finds SKL-0001 (Plan From Idea) → execute it
2. The skill is owned by the Project Manager agent
3. The agent reads your idea, writes a PRD, and seeds the task queue

You don't need to understand the dispatch chain to use the system. But knowing it exists helps explain why the system reliably picks the right workflow for each situation.

### Events and Priority

Events in EVENTS.md can have an optional priority: `high`, `normal`, or `low`. The system processes events in priority order (high first), and within each priority level, oldest first (FIFO). Most events are `normal` by default.

### For More Detail

Read [FRAMEWORK_SCOPE.md](FRAMEWORK_SCOPE.md) for the full conceptual explanation of the Orchestration Stack, the two project classes (Product Projects and Idea Projects), and the vision behind the system.

The technical architecture is documented in [.claude/CLAUDE.md](../.claude/CLAUDE.md), which the AI reads automatically at the start of every session.

---

## 8. Sharing Your Framework

The AI Orchestrator System is designed to be reused across projects. You can copy it to new projects or upgrade existing ones.

### Setting Up a New Project

From any project that already has The AI Orchestrator System:

```
/clone-framework /path/to/new-project
```

This copies all framework files (commands, agents, skills, rules, hooks) to the target directory without overwriting anything that already exists. It also creates the directory structure needed for `/setup`.

After cloning, open the new project and run `/setup` to initialize it.

### Upgrading an Existing Project

If the source framework has been updated with new features:

```
/clone-framework /path/to/existing-project --upgrade
```

The `--upgrade` flag overwrites structural files (commands, agents, rules) with the latest versions while preserving your project's runtime state:

| Preserved (not touched) | Updated (overwritten) | Patched (format updates only) |
|------------------------|----------------------|------------------------------|
| STATE.md | Commands | EVENTS.md |
| Knowledge files | Agents | RUN_POLICY.md |
| Task history | Rules | |
| Project type | Hooks | |
| Settings | Skills | |

Your event history, completed tasks, decisions, and research are never lost during an upgrade.

---

## 9. Troubleshooting

### "Nothing is happening when I run /run-project"

Check `/status`. The system needs either unprocessed events or tasks in the queue to do work. If both are empty:
- Run `/capture-idea` to seed a new project idea
- Run `/trigger` to manually create an event

### "The system seems broken"

Run `/doctor`. It verifies directories, files, the skill registry, dispatch chain, and state consistency. If it finds issues, it suggests specific fixes.

### "Skills aren't being found"

Run `/fix-registry`. This rebuilds the registry by scanning all skill files. The registry can become stale if skills were added or modified since the last refresh.

### "I lost my progress"

Your progress lives in STATE.md. Open it and check the Completed Tasks Log — your work is likely still there. For future sessions, run `/save` before closing VS Code to ensure everything is saved.

### "I want to start over"

Re-run `/setup`. It's idempotent, meaning it fills in missing files without destroying existing ones. If you want a completely fresh start, delete the contents of STATE.md's task queue and completed log, then run `/capture-idea` with a new description.

### "I don't know what command to use"

Just ask. Type something like "What should I do next?" in the chat. The built-in Coach reads your project state and recommends the right command with an explanation of what it will do.

---

## Quick Reference

### Typical Session Flow

```
/start              → See where you left off
/run-project        → Execute the next task
/run-project        → Keep going
/status             → Check progress
/save         → Save before closing
```

### First-Time Flow

```
/start              → System detects "not set up"
/setup              → Initialize project
/capture-idea       → Describe what you want to build
/run-project        → Process the idea (creates PRD, seeds tasks)
/run-project        → Start executing tasks
```

### Mode Quick Switch

```
/set-mode safe      → Preview only (0 cycles)
/set-mode semi      → One task at a time (default)
/set-mode auto      → Multiple tasks per run (up to 10)
```

# Frequently Asked Questions

> Quick answers to common questions about Bashi.

---

## Getting Started

### What do I need to use this?

You need VS Code with the Claude Code extension installed. That's it. You don't need to know how to code — the system handles that for you.

### How do I start a new project?

1. Copy Bashi folder into a new directory (or use `/clone-framework`).
2. Open it in VS Code.
3. Run `/start` — it will tell you exactly what to do next.

### What's the difference between `/setup` and `/start`?

`/start` is read-only — it looks at your project and recommends what to do next. `/setup` actually creates files and folders. Run `/start` first to see where you are, then `/setup` if the system says you need it.

### What happened to `/bootstrap` and `/init-project`?

They've been removed. `/setup` replaces both commands, combining their functionality into a single entry point. If you see references to `/bootstrap` or `/init-project` in older documentation, use `/setup` instead.

---

## Daily Usage

### What does `/run-project` actually do?

It processes one unit of work — either an event (like "idea captured") or a task (like "draft PRD"). In Semi-Autonomous mode (the default), it does one thing and stops so you can review. In Autonomous mode, it does up to 10 things before stopping.

### How do I see my progress?

Run `/status`. It shows your current phase, mode, progress percentage, active task, and what's next in the queue.

### How do I speed things up?

Switch to Autonomous mode with `/set-mode auto`. This lets the system execute up to 10 tasks per `/run-project` instead of just one. Best used during the Building phase when you've already approved the plan.

### How do I slow things down?

Switch to Safe mode with `/set-mode safe`. The system will only *propose* what it would do without actually doing it. Good for reviewing before a deployment.

### When should I run `/save`?

Before you close VS Code or end your session. `/save` saves your progress to files so the next session can pick up where you left off. The AI's chat memory doesn't persist between sessions, but your files do.

---

## Troubleshooting

### Nothing happens when I run `/run-project`

Check `/status`. If there are no events and no tasks, the system has nothing to process. Run `/capture-idea` to describe what you want to build, or `/trigger` to trigger a specific workflow.

### The system seems broken

Run `/doctor`. It diagnoses issues and suggests exactly which command to run to fix each problem.

### Skills aren't being found

Run `/fix-registry`. This rebuilds the skill registry so the system can discover all available workflows.

### I lost my progress

Your progress is stored in `.claude/project/STATE.md`. Check if that file still has your task history. If it's corrupted, `/doctor` can detect and repair common issues. For best results, run `/save` regularly.

### I want to start over

Run `/setup` again — it's safe to run multiple times (idempotent). It won't delete your existing work, but it will recreate any missing files.

### An error message mentions a file I don't recognize

The system uses several internal files (STATE.md, EVENTS.md, REGISTRY.md). You don't need to edit these manually — commands like `/setup`, `/fix-registry`, and `/doctor` manage them for you. If one is missing or corrupted, `/setup` will recreate it.

---

## How It Works

### What are "events" and "skills"?

**Events** are things that happened or need to happen (like "idea captured" or "deployment requested"). **Skills** are reusable workflows that know how to handle events (like "generate a PRD" or "run a security audit"). The system matches events to skills automatically.

### What are the project phases?

Your project moves through these phases: **Not Started** → **Planning** → **Building** → **Ready for Deploy** → **Deploying** → **Live**. The system tracks which phase you're in and adjusts its suggestions accordingly.

### What project types does this support?

The framework supports four software project types: **Web App**, **Mobile App**, **API / Backend**, and **SaaS (Full-Stack)**. Each gets appropriate starter folders and tasks during `/setup`. Non-software domains (books, courses) are planned as separate framework variants.

### What is Global Memory?

A separate folder (AI-Memory) that stores lessons, patterns, and decisions across all your projects. When you start a new project, the system can check past experience to avoid repeating mistakes. Set it up with the `AI_MEMORY_PATH` environment variable.

---

## Advanced

### Can I add my own skills?

Yes. Create a folder in `custom-skills/` (not `.claude/skills/`) with a `SKILL.md` file following the skill template, then run `/fix-registry` to register it. Custom skills survive framework upgrades. See the [Custom Skills Guide](CUSTOM_SKILLS_GUIDE.md) for a full walkthrough with examples.

### Can I change the Autonomous cycle limit?

Yes. Edit the cycle limit table in `.claude/project/RUN_POLICY.md`. The default is 10 cycles per `/run-project` in Autonomous mode.

### How do I share the framework with another project?

Run `/clone-framework <target-path>` to copy the framework into another directory. Use `--upgrade` to update an existing project without overwriting its runtime files.

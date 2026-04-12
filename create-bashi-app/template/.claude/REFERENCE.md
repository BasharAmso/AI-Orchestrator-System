# REFERENCE.md — Architecture & Internals

> Reference detail for Bashi. Not loaded automatically — read on demand.
> For session-critical context, see `.claude/CLAUDE.md`.

---

## Architecture Primitives

| Primitive | Location | Role |
|-----------|----------|------|
| Commands | `.claude/commands/` | Entry points: `/run-project`, `/trigger`, `/setup`, etc. |
| State | `.claude/project/STATE.md` | Single source of truth: current task, mode, blockers, history |
| Events | `.claude/project/EVENTS.md` | Queue of things that happened or need to happen (FIFO) |
| Skills | `.claude/skills/` | Reusable procedures with triggers, registered in REGISTRY.md |
| Registry | `.claude/skills/REGISTRY.md` | Skill index mapping triggers to skill files |
| Rules | `.claude/rules/` | Governance: routing, security, policy |
| Agents | `.claude/agents/` | Specialized roles that execute skills (core: Orchestrator) |
| Knowledge | `.claude/project/knowledge/` | Persistent memory: decisions, research, glossary, open questions |

---

## Dispatch Chain

`Events → Skills (via REGISTRY) → Agents (via routing rules)`

Fallback: REGISTRY trigger → event-hooks.md → orchestration-routing.md.
Full algorithm: `.claude/agents/orchestrator.md` § "Dispatch Chain (Canonical)".

---

## Full Command Reference

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
| `/log-session` | `.claude/commands/log-session.md` |
| `/test-hooks` | `.claude/commands/test-hooks.md` |
| `/learn` | `.claude/commands/learn.md` |
| `/framework-review` | `.claude/commands/framework-review.md` |
| `/overnight` | `.claude/commands/overnight.md` |

# Knowledge Policy

> When and how to use the knowledge base files in `.claude/project/knowledge/`.

---

## When to READ Each File

| File | Read When... |
|------|-------------|
| `GLOSSARY.md` | You encounter an unfamiliar term, or before writing user-facing content |
| `DECISIONS.md` | Before making an architectural or design choice (check if it's already decided) |
| `RESEARCH.md` | Before making claims about external tools, patterns, or best practices |
| `OPEN_QUESTIONS.md` | When you hit uncertainty or need to understand what's unresolved |

---

## When to WRITE to Each File

| File | Write When... |
|------|--------------|
| `GLOSSARY.md` | A new term is introduced that future sessions need to understand |
| `DECISIONS.md` | A meaningful choice is made about architecture, tools, process, or design |
| `RESEARCH.md` | You discover useful information from external sources or experimentation |
| `OPEN_QUESTIONS.md` | You encounter an unresolved question that affects future work |

---

## Rules

1. **Keep entries brief.** One paragraph per entry is ideal. Link to external sources if detail is needed.
2. **Use the templates.** Each knowledge file has an entry template at the top. Follow it for consistency.
3. **Update, don't duplicate.** Before adding a new entry, check if a related one already exists. Update it instead.
4. **Close what's resolved.** When an open question is answered, update its status to `Resolved` and fill in the resolution.
5. **Supersede, don't delete.** When a decision is reversed, mark it `Superseded` and reference the new decision. Don't remove it.

---

## Global Memory Integration

The AI Orchestrator System maintains a shared knowledge store in a separate **AI-Memory** directory. To locate it:

1. Check the `AI_MEMORY_PATH` environment variable (if set).
2. Fall back to: `~/Projects/AI-Memory`

> **Setup:** Set the `AI_MEMORY_PATH` environment variable to your local AI-Memory folder path. Default assumes `~/Projects/AI-Memory` — update if your path differs.

This directory is **outside** any single project so all projects can benefit from past learning.

### When to READ Global Memory

Before making major architectural decisions, check the global memory directory for relevant entries in `decisions/`, `patterns/`, `failures/`, `lessons/`, `ideas/`, and `feedback/`. If relevant knowledge exists, incorporate it into planning.

### When to WRITE to Global Memory

If a new reusable insight is discovered during the current project:

1. Create a short `.md` file in the appropriate folder (`decisions/`, `patterns/`, `failures/`, or `lessons/`).
2. Add a reference entry to `GLOBAL_INDEX.md` in the matching section.
3. Keep entries concise and general enough to benefit other projects.

### Global Memory Folders

| Folder | Contents |
|--------|----------|
| `decisions/` | Architectural and design decisions |
| `patterns/` | Reusable patterns that worked |
| `failures/` | Approaches that failed and why |
| `lessons/` | General learnings from project work |
| `ideas/` | Project ideas and cross-project roadmap items |
| `feedback/` | Agent feedback log (self-review + cross-agent). Written automatically by orchestrator steps 5.6-5.8. |

---

## Skill Improvement Capture

If a skill repeatedly causes friction, confusion, or rework, capture a proposed improvement.

### When to Log an Improvement

- A skill produces output that consistently needs manual correction.
- A skill is missing a review gate that would catch recurring issues.
- A skill lacks required inputs or outputs.
- A skill produces unclear or overly technical results for the target audience.
- A skill causes repeated task drift across projects.

### How to Log

Write proposed improvements to `SKILL_IMPROVEMENTS.md` inside the AI-Memory directory (resolved via `AI_MEMORY_PATH` or the fallback path).

Use the entry format defined in that file (IMP-XXXX entries, append-only).

### Safety Rule

**Do not modify skill files automatically.** Only propose improvements and log them. A human must review and approve before any skill file is changed.

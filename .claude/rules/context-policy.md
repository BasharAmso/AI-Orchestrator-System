# Context Conservation Policy

> **Scope:** All agents, all commands, all sessions.
> **Purpose:** Prevent context window waste by keeping large artifacts in files, not chat.

---

## Rules

### 1. Summarize, Don't Reproduce

Chat responses must summarize work completed rather than reproduce full documents. Reference file paths instead of echoing content.

**Do:** "PRD written to `docs/PRD.md` with 5 user stories and 3 non-functional requirements."
**Don't:** Print the entire PRD in chat.

### 2. Write Artifacts to Files

All substantial output (documents, plans, code, analysis, task breakdowns) must be written to the appropriate canonical file:

| Artifact Type | Canonical Location |
|---------------|-------------------|
| Documentation | `docs/` |
| Task definitions & breakdowns | `tasks/` |
| Decisions | `.claude/project/knowledge/DECISIONS.md` |
| Research notes | `.claude/project/knowledge/RESEARCH.md` |
| Glossary terms | `.claude/project/knowledge/GLOSSARY.md` |
| Open questions | `.claude/project/knowledge/OPEN_QUESTIONS.md` |
| Task status & progress | `.claude/project/STATE.md` |
| Event records | `.claude/project/EVENTS.md` |

### 3. Persist Decisions

Every architectural, product, or design decision must be written to `.claude/project/knowledge/DECISIONS.md` using its entry template. Decisions stated only in chat are considered unpersisted and at risk of loss.

### 4. Update System State

After every unit of work:
- `.claude/project/STATE.md` — update active task status, outputs, files modified
- `.claude/project/EVENTS.md` — update event processing status

### 5. No Redundant Repetition

Do not repeat content that is already stored in a repository file unless the user explicitly asks to see it. Instead, reference the file path and describe what changed.

### 6. Chat Budget

Chat output per task cycle should stay under 200 words. Include only:
- Task completed (ID + one-line description)
- Files changed (list of paths)
- Decisions made (one-line each)
- Next task (ID + one-line description)

Exceed 200 words only when the user explicitly requests more detail.

### 7. Lazy Context Loading

Do not preemptively read all knowledge files, all agent files, or all skill files. Load framework files on-demand per the Context Loading Policy in CLAUDE.md. Only expand beyond the directly-targeted files when a dependency or ambiguity requires it.

---

## Enforcement

This policy applies to:
- `/run-project` cycles (reinforces the Output Policy in that command)
- `/save` (artifact persistence verification)
- All agent execution regardless of entry point
- Manual task work outside of formal commands

If an agent produces a large artifact in chat instead of writing it to a file, the next agent in the chain should flag it and persist it before continuing.

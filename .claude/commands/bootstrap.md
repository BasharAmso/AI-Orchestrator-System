# Command: /bootstrap

> Initialize or verify the AI Builder System project structure. Safe to run multiple times (idempotent).

---

## Procedure

### Step 1: Verify Directory Structure

Ensure these directories exist (create if missing):

```
.claude/
  agents/
  commands/
  rules/
  skills/
  project/
    knowledge/
```

### Step 2: Verify Required Files

Check that each required file exists. Report status for each:

| File | Required |
|------|----------|
| `.claude/CLAUDE.md` | Yes |
| `.claude/agents/orchestrator.md` | Yes |
| `.claude/commands/run-project.md` | Yes |
| `.claude/commands/emit-event.md` | Yes |
| `.claude/commands/refresh-skills.md` | Yes |
| `.claude/commands/bootstrap.md` | Yes |
| `.claude/rules/orchestration-routing.md` | Yes |
| `.claude/rules/event-hooks.md` | Yes |
| `.claude/rules/knowledge-policy.md` | Yes |
| `.claude/rules/context-policy.md` | Yes |
| `.claude/skills/REGISTRY.md` | Yes |
| `.claude/project/STATE.md` | Yes |
| `.claude/project/EVENTS.md` | Yes |
| `.claude/project/RUN_POLICY.md` | Yes |
| `.claude/project/knowledge/DECISIONS.md` | Yes |
| `.claude/project/knowledge/RESEARCH.md` | Yes |
| `.claude/project/knowledge/GLOSSARY.md` | Yes |
| `.claude/project/knowledge/OPEN_QUESTIONS.md` | Yes |
| `.claudeignore` | Yes |

If any file is missing, report it as `MISSING` and note it in the summary. Do not create files — only verify.

### Step 3: Initialize REGISTRY

If `.claude/skills/REGISTRY.md` is missing or contains only `(none)` placeholders:
- Run the `/refresh-skills` procedure to scan skill files and populate the registry.

### Step 4: Print "Project Ready" Summary

```
## Project Ready

- **Current Mode:** [from STATE.md, e.g., Semi-Autonomous]
- **Unprocessed Events:** [count from EVENTS.md]
- **Skills Registered:** [count from REGISTRY.md]
- **Files Verified:** [pass count] / [total count]
- **Missing Files:** [list, or "None"]

### Recommended Next Actions

1. [First recommended action based on project state]
2. [Second recommended action]
3. [Third recommended action]
```

Default recommended actions for a fresh project:
1. Run `/emit-event` with type `IDEA_CAPTURED` to describe your project idea.
2. Run `/run-project` to process the event and generate a plan.
3. Review the generated PRD and task queue, then run `/run-project` again.

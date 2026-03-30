# Task Table Format Reference

> Defines the canonical format for task tables in STATE.md Next Task Queue. All skills, commands, and project-specific rules that generate tasks must follow this format.

---

## Purpose

The task table is a cross-cutting concern. Multiple components generate or consume it:
- **PRD to Tasks** (SKL-0003) — generates 8-15 tasks from a PRD
- **Plan From Idea** (SKL-0001) — generates 3-5 initial tasks
- **Project Planning** (SKL-0025) — manages sprint task queues
- **Orchestrator** — reads task rows to dispatch skills via the Skill column
- **`/capture-idea`** — generates initial task stubs
- **`/setup`** — creates the STATE.md template with empty task table
- **`/clone-framework --upgrade`** — patches existing task tables to add new columns
- **Project-specific rules** — any rule that generates task breakdowns (e.g., implementation planners)

---

## Canonical Format

```markdown
| # | Task | Priority | Skill |
|---|------|----------|-------|
| 1 | Build login screen (src/app/login/) | High | SKL-0005 |
| 2 | Set up Supabase auth (src/lib/auth.ts) | High | SKL-0010 |
| 3 | Write API tests (tests/api/) | Medium | SKL-0017 |
```

---

## Column Definitions

| Column | Required | Description |
|--------|----------|-------------|
| **#** | Yes | Sequential number (1-based). Defines execution order. |
| **Task** | Yes | Short, plain-language title. Include target file/folder in parentheses when known. Write "Build login screen", not "Implement authentication UI component with OAuth flow". |
| **Priority** | Yes | One of: `High`, `Medium`, `Low`. |
| **Skill** | Yes | Skill ID from REGISTRY.md (e.g., `SKL-0006`) or `—` if no skill applies. |

---

## Skill Assignment Rules

The **Skill** column tells the orchestrator which skill procedure to invoke for this task. It is assigned at task generation time by the planner (who has full PRD/architecture context).

1. **Read REGISTRY.md** and match the task's domain to the closest skill.
2. **Assign the primary skill** — the one that covers the most work for this task.
3. **If a task spans multiple skills**, assign the primary one. The orchestrator will invoke only this skill's procedure.
4. **If no skill clearly applies**, use `—` (em dash). The orchestrator will fall back to agent routing via `orchestration-routing.md`.

### Common Mappings

| Task Domain | Skill |
|-------------|-------|
| Frontend UI, pages, components | SKL-0005 |
| API endpoints, server logic | SKL-0006 |
| Mobile screens, navigation | SKL-0007 |
| Database schema, migrations | SKL-0008 |
| LLM integrations, RAG, prompts | SKL-0009 |
| Third-party API connections | SKL-0010 |
| Billing, subscriptions, Stripe | SKL-0011 |
| Analytics, event tracking | SKL-0012 |
| Landing pages, SEO, growth | SKL-0013 |
| Onboarding, help content | SKL-0014 |
| Security audit, secrets scan | SKL-0015 |
| Code review | SKL-0016 |
| Writing tests | SKL-0017 |
| UAT, acceptance testing | SKL-0018 |
| Refactoring, cleanup | SKL-0019 |
| Bug investigation | SKL-0020 |
| Deployment, shipping | SKL-0021 |
| Documentation | SKL-0024 |

---

## Rules

1. **All 4 columns are mandatory** — even if Skill is `—`, the column must be present.
2. **Task titles must be beginner-friendly** — plain language, no jargon.
3. **Include target location** — reference the expected output file/folder in parentheses.
4. **Skill IDs must exist in REGISTRY.md** — don't invent IDs. Use `—` if unsure.
5. **Never generate tasks for non-goals** — cross-check against the PRD Non-Goals section.

---

## Enforcement

- **`/doctor`** validates STATE.md task tables against this format (step 7g).
- If the Skill column is missing, `/doctor` flags it and suggests running `/clone-framework --upgrade` to patch.

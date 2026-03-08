# Orchestration Routing Rules

> Fallback routing table. Used when no skill trigger matches in REGISTRY.md.
> Maps task types to primary and review agents.

---

## Task Routing Table

| Task Type | Primary Agent | Review Agent(s) | Notes |
|-----------|--------------|-----------------|-------|
| Planning / Sprint Management | `project-manager` | Orchestrator | PRD creation, task breakdown, roadmap, status updates |
| PRD Creation | `project-manager` | Orchestrator | Interview user and write docs/PRD.md (SKL-0004) |
| UI / Frontend | `builder` | Reviewer | Web UI components, pages, styling (SKL-0005) |
| API / Database | `builder` | Reviewer | API endpoints, database, server logic (SKL-0006) |
| Mobile (iOS / Android) | `builder` | Reviewer | React Native, Expo, platform-specific (SKL-0007) |
| Database Design | `builder` | Reviewer | Schema design, migrations, indexing (SKL-0008) |
| AI Feature Implementation | `builder` | Reviewer | LLM integrations, RAG, prompt engineering (SKL-0009) |
| Third-Party API Integration | `builder` | Reviewer | Stripe, Supabase, SendGrid, external services (SKL-0010) |
| Billing & Payments | `builder` | Reviewer | Stripe billing, subscriptions, webhooks (SKL-0011) |
| Analytics & Tracking | `builder` | Orchestrator | Event instrumentation, funnels, dashboards (SKL-0012) |
| Growth & Distribution | `builder` | Orchestrator | Landing pages, SEO, waitlists, referral (SKL-0013) |
| Customer Success | `builder` | Designer | Onboarding flows, help content, error messages (SKL-0014) |
| Security / Privacy Check | `reviewer` | Orchestrator | Secrets scan, dependency audit, OWASP (SKL-0015) |
| Review / Quality | `reviewer` | Orchestrator | Code review, content review, clarity (SKL-0016) |
| Test Creation | `reviewer` | Orchestrator | Writing tests, validating outputs (SKL-0017) |
| Acceptance Testing | `reviewer` | Orchestrator | UAT, go/no-go verdicts (SKL-0018) |
| Refactoring | `fixer` | Reviewer | Code cleanup, restructuring (SKL-0019) |
| Bug Reports | `fixer` | Reviewer | Bug investigation and fix (SKL-0020) |
| Deployment | `deployer` | Orchestrator | Ship to production, CI/CD, release (SKL-0021) |
| MCP Tool Connections | `deployer` | Orchestrator | Connect to external tools via MCP (SKL-0022) |
| UX / Design | `designer` | Orchestrator | Wireframes, flows, onboarding (SKL-0023) |
| Documentation | `documenter` | Project Manager | README, API docs, changelogs, guides (SKL-0024) |
| Research | `explorer` | Orchestrator | Gathering information, evaluating options |
| Checkpoint | `orchestrator` | — | Session compression via `/checkpoint` |
| Multi-Domain (2+ specialists) | `orchestrator` | — | Tasks spanning multiple agent domains |
| User Guidance & Coaching | `coach` | Orchestrator | Command navigation, framework Q&A |

---

## Recommended Workflow

The standard project lifecycle follows this sequence:

```
/capture-idea → /run-project (planning) → /run-project (execution cycles) → /checkpoint → /system-check
```

| Phase | Command | Purpose |
|-------|---------|---------|
| Idea capture | `/capture-idea` | Record the idea and emit IDEA_CAPTURED event |
| Planning | `/run-project` | Process event, generate PRD, create task queue |
| Execution | `/run-project` | Execute tasks from the queue (repeat as needed) |
| Session compression | `/checkpoint` | Persist all progress to files for session continuity |
| Verification | `/system-check` | Validate system integrity and file consistency |

> Run `/checkpoint` before ending any session with in-progress work.
> Run `/system-check` after major milestones or before sharing the project.

---

## Fallback Rule

If a task type is not listed above:
1. Assign to **Orchestrator** as primary.
2. Log a warning in the execution summary: `"No routing rule for task type: <type>"`.
3. Proceed with best-effort execution.

---

## How to Add a New Route

1. Define the new agent in `.claude/agents/<agent-name>.md`.
2. Add a row to the table above with the task type, primary agent, and review agent(s).
3. Run `/refresh-skills` to ensure the REGISTRY is up to date.

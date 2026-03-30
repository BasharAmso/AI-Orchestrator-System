# Orchestration Routing Rules

> Fallback routing table. Used when no skill trigger matches in REGISTRY.md.
> Maps task types to primary and review agents.

---

## Task Routing Table

| Task Type | Primary Agent | Review Agent(s) | Notes |
|-----------|--------------|-----------------|-------|
| Problem Validation | `product-manager` | Orchestrator | Problem stress test, advisory gate (SKL-0027) |
| Game Design | `product-manager` | Orchestrator | GDD creation, game vision, design pillars (SKL-0028) |
| Product Vision / Scope | `product-manager` | Orchestrator | Vision challenge, PRD creation, scope decisions (SKL-0001, SKL-0004) |
| Planning / Sprint Management | `project-manager` | Orchestrator | Task breakdown, roadmap, status updates, estimation (SKL-0025) |
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
| Deployment / Ship | `deployer` | Orchestrator | Ship workflow, CI/CD, release (SKL-0021) |
| MCP Tool Connections | `deployer` | Orchestrator | Connect to external tools via MCP (SKL-0022) |
| Architecture / System Design | `architecture-designer` | Orchestrator | Tech stack, components, data model, ADRs |
| UX / Design | `designer` | Orchestrator | Wireframes, flows, onboarding (SKL-0023) |
| Documentation | `documenter` | Orchestrator | README, API docs, changelogs, guides (SKL-0024) |
| Game Development | `builder` | Reviewer | Web games: adventure, sandbox, action, educational (SKL-0038) |
| Research | `explorer` | Orchestrator | Gathering information, evaluating options (no formal skill — explorer works free-form) |
| Checkpoint | `orchestrator` | — | Session compression via `/save` |
| Multi-Domain (2+ specialists) | `orchestrator` | — | Tasks spanning multiple agent domains |
| Retrospective | `orchestrator` | — | Engineering retro, velocity metrics (SKL-0026) |
| User Guidance & Coaching | `coach` | Orchestrator | Command navigation, framework Q&A |
| Insecure Defaults Check | `reviewer` | Orchestrator | Config-level security scan (SKL-0029) |
| Differential Security Review | `reviewer` | Orchestrator | Security review of code diffs (SKL-0030) |
| Supply Chain Audit | `reviewer` | Orchestrator | Dependency health and trust audit (SKL-0031) |
| SEO Audit | `builder` | Orchestrator | Search engine optimization validation (SKL-0032) |
| Copywriting | `builder` | Orchestrator | Conversion-focused copy (SKL-0033) |
| Launch Readiness | `builder` | Orchestrator | Pre-launch checklist validation (SKL-0034) |
| Competitor Analysis | `product-manager` | Orchestrator | Market research and differentiation (SKL-0035) |
| Pitch Deck | `product-manager` | Orchestrator | Investor/stakeholder pitch outline (SKL-0036) |

---

## Builder Spec Gate

For tasks expected to modify 3+ files, the builder agent should write a brief implementation spec to STATE.md (`## Current Task Spec`) before writing code:
- Target files and expected changes
- Approach in 2-3 sentences
- Edge cases to handle

This prevents wasted context on false starts and helps reviewers understand intent.

---

## Recommended Workflow

The standard project lifecycle follows this sequence:

```
/capture-idea → /run-project (planning) → /run-project (execution cycles) → /save → /doctor
```

| Phase | Command | Purpose |
|-------|---------|---------|
| Idea capture | `/capture-idea` | Record the idea and emit IDEA_CAPTURED event |
| Planning | `/run-project` | Process event, generate PRD, create task queue |
| Execution | `/run-project` | Execute tasks from the queue (repeat as needed) |
| Session compression | `/save` | Persist all progress to files for session continuity |
| Verification | `/doctor` | Validate system integrity and file consistency |

> Run `/save` before ending any session with in-progress work.
> Run `/doctor` after major milestones or before sharing the project.

---

## Fallback Rule

If a task type is not listed above:
1. Assign to **Orchestrator** as primary.
2. Log a warning in the execution summary: `"No routing rule for task type: <type>"`.
3. Proceed with best-effort execution.

---

## Friction Awareness Rule

**Before executing any task** that produces user-facing output, the executing agent must:

1. Reference the Friction Audit Checklist at `.claude/skills/friction-audit/CHECKLIST.md`
2. Apply the relevant checks to their output
3. Log friction findings in the Execution Summary: `Friction check: [passed | N items flagged]`

A task is considered **user-facing** if its description contains any of these keywords: `UI`, `page`, `screen`, `form`, `onboarding`, `landing`, `signup`, `login`, `checkout`, `dashboard`, `settings`, `profile`, `navigation`, `menu`.

This keyword-based approach works regardless of whether the skill has been assigned yet.

---

## How to Add a New Route

1. Define the new agent in `.claude/agents/<agent-name>.md`.
2. Add a row to the table above with the task type, primary agent, and review agent(s).
3. Run `/fix-registry` to ensure the REGISTRY is up to date.

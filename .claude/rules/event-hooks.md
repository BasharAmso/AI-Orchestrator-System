# Event Hooks

> Routes event types to agents. Used as fallback when REGISTRY.md has no matching skill trigger.

---

## Event Routing Table

| Event Type | Primary Agent | Review Agent(s) | Action |
|------------|--------------|-----------------|--------|
| IDEA_CAPTURED | Orchestrator | Orchestrator | Via REGISTRY: SKL-0001 — Orchestrator runs Plan From Idea, which suggests PRD_CREATION_REQUESTED for product-manager (SKL-0004) |
| PRD_UPDATED | Orchestrator | Orchestrator | Via REGISTRY: SKL-0003 — Orchestrator breaks PRD into tasks. Subsequent cycles may route to project-manager (SKL-0025) for sprint planning |
| TASK_COMPLETED | Orchestrator | — | Update STATE, promote next task |
| QUALITY_REVIEW_REQUESTED | Reviewer | Orchestrator | Run quality/clarity review (SKL-0016). User-triggered via `/trigger QUALITY_REVIEW_REQUESTED` |
| BUG_REPORTED | Fixer | Reviewer | Investigate, create fix task (SKL-0020) |
| DEPLOY_REQUESTED | Deployer | Orchestrator | Validate readiness, execute deploy (SKL-0021) |
| ARCHITECTURE_REQUESTED | architecture-designer | Orchestrator | Design system architecture (docs/ARCHITECTURE.md) |
| SECURITY_REVIEW_REQUESTED | Reviewer | Orchestrator | Run security checks (SKL-0015) |
| PROBLEM_VALIDATION_REQUESTED | product-manager | Orchestrator | Run problem stress test (SKL-0027). Advisory — user decides outcome. |
| GDD_CREATION_REQUESTED | product-manager | Orchestrator | Write Game Design Document (SKL-0028). Game-project parallel to PRD Writing. |
| GDD_UPDATED | Orchestrator | Orchestrator | Via REGISTRY: SKL-0003 — Break GDD into tasks (reads docs/GDD.md if docs/PRD.md absent) |
| INSECURE_DEFAULTS_CHECK_REQUESTED | reviewer | Orchestrator | Scan for insecure defaults and hardcoded credentials (SKL-0029) |
| DIFF_SECURITY_REVIEW_REQUESTED | reviewer | Orchestrator | Security-focused review of code changes (SKL-0030) |
| SUPPLY_CHAIN_AUDIT_REQUESTED | reviewer | Orchestrator | Dependency supply chain health audit (SKL-0031) |
| SEO_AUDIT_REQUESTED | builder | Orchestrator | SEO validation of web pages (SKL-0032) |
| LAUNCH_CHECK_REQUESTED | builder | Orchestrator | Pre-launch readiness checklist (SKL-0034) |
| COMPETITOR_ANALYSIS_REQUESTED | product-manager | Orchestrator | Market research and competitive landscape (SKL-0035) |
| PITCH_DECK_REQUESTED | product-manager | Orchestrator | Investor/stakeholder pitch outline (SKL-0036) |

---

## Security Keyword Rule

**Before routing any event**, scan the event's `Description` and any associated file paths for these keywords:

- `security`
- `privacy`
- `secrets`
- `credential`
- `auth`

**If a match is found:**
1. Route a security review step to **Reviewer** (security audit skill) before or after the primary action.
2. Log in the execution summary: `"Security-sensitive event detected. Security Auditor review required."`

---

## Fallback Rule

If an event type is not listed above:
1. Log the event as received.
2. Route to **Orchestrator** with best-effort handling.
3. Include a note in the execution summary: `"No event hook for type: <type>"`.

---

## How to Add a New Event Hook

1. Add a row to the routing table above.
2. Optionally, create a matching skill in `.claude/skills/` with the event type as its trigger.
3. Run `/fix-registry` to update the REGISTRY.

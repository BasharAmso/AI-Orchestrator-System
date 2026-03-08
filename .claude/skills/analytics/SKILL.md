---
id: SKL-0012
name: Analytics & Tracking
version: 1.0
owner: builder
triggers:
  - ANALYTICS_REQUESTED
inputs:
  - Task description (from STATE.md)
  - docs/PRD.md (success metrics)
  - .claude/project/knowledge/DECISIONS.md
  - Existing source code
outputs:
  - Analytics service layer, event taxonomy, dashboard spec
  - docs/ANALYTICS.md
  - .claude/project/STATE.md (updated)
tags:
  - building
  - analytics
  - tracking
  - metrics
---

# Skill: Analytics & Tracking

## Metadata

| Field | Value |
|-------|-------|
| **Skill ID** | SKL-0012 |
| **Version** | 1.0 |
| **Owner** | builder |
| **Inputs** | Task description, PRD success metrics, DECISIONS.md, source code |
| **Outputs** | Analytics service, event taxonomy, ANALYTICS.md, STATE.md updated |
| **Triggers** | `ANALYTICS_REQUESTED` |

---

## Purpose

Instrument the product so every important user action is measurable. Track events tied to PRD success metrics — not everything, just what drives decisions.

---

## Provider Defaults

| Use Case | Provider |
|----------|---------|
| Solo/MVP (free) | PostHog (open source) |
| Product analytics + funnels | Mixpanel or Amplitude |
| Multi-destination routing | Segment |
| Simple pageviews only | Plausible or Fathom |

---

## Procedure

1. **Read PRD success metrics** — extract primary metric, guardrail metrics, key user flows. Every tracked event must map to a metric.
2. **Choose analytics provider** from DECISIONS.md or defaults above. Default: PostHog. Log to DECISIONS.md.
3. **Define event taxonomy** in `src/services/analytics/events.js`:
   - Naming: `[object]_[action]` in snake_case (e.g., `user_signed_up`, `subscription_started`)
   - Single source of truth for all event names — never use raw strings inline
4. **Build analytics service layer** — provider-agnostic wrapper with `track()`, `identify()`, `alias()` methods.
   - **Critical:** All analytics calls wrapped in try/catch. Analytics must NEVER break the product.
   - Fail silently in dev if provider not configured.
5. **Instrument the critical path** in priority order:
   1. Signup + `identify()` with key traits
   2. Core feature usage (the action defining product value)
   3. Conversion to paid
   4. Retention signal (return visit, day-7 usage)
   5. Failure states (payment failed, feature failed)
6. **Document dashboard metrics** in `docs/ANALYTICS.md` — top 5 metrics with events, targets, and funnels to monitor.
7. **Update STATE.md.**

---

## Constraints

- Never breaks the product on analytics failure — all calls are try/catch
- Never tracks PII in event properties (PII goes in identify(), not track())
- Never hardcodes API keys
- Never instruments events not connected to a PRD metric
- Always uses centralized event constants — never raw string event names

---

## Primary Agent

builder

---

## Definition of Done

- [ ] PRD success metrics mapped to tracking events
- [ ] Event taxonomy defined in events.js
- [ ] Analytics service layer built (provider-agnostic)
- [ ] All calls wrapped in try/catch
- [ ] Signup, core feature, and billing events instrumented
- [ ] User identity called at signup
- [ ] Dashboard metrics documented in ANALYTICS.md
- [ ] Provider credentials in env vars
- [ ] STATE.md updated

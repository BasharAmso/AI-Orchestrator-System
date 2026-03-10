---
id: SKL-0010
name: API Integration
description: |
  Connect to third-party APIs and external services. Use this skill when
  integration with services like Stripe, Supabase, SendGrid, or other
  external APIs is requested.
version: 1.0
owner: builder
triggers:
  - INTEGRATION_REQUESTED
inputs:
  - Task description (from STATE.md)
  - .claude/project/knowledge/DECISIONS.md
  - .env.example (if present)
  - Existing integration code
outputs:
  - Integration service files, webhook handlers
  - .env.example (updated)
  - .claude/project/STATE.md (updated)
tags:
  - building
  - integration
  - api
  - webhook
---

# Skill: API Integration

## Metadata

| Field | Value |
|-------|-------|
| **Skill ID** | SKL-0010 |
| **Version** | 1.0 |
| **Owner** | builder |
| **Inputs** | Task description, DECISIONS.md, .env.example, existing integrations |
| **Outputs** | Integration files, .env.example updated, STATE.md updated |
| **Triggers** | `INTEGRATION_REQUESTED` |

---

## Purpose

Connect the app to third-party services (payments, auth, notifications, external APIs, webhooks) safely and reliably. Every integration is documented, every key is in an env var, every webhook is verified.

---

## Integration Defaults

| Type | Default | Why |
|------|---------|-----|
| Payments | Stripe | Best docs, widest adoption, excellent test mode |
| Auth | Supabase Auth | Free tier, open source |
| Email | SendGrid | Reliable delivery, simple API |
| SMS | Twilio | Industry standard |
| Push (mobile) | Expo Notifications | Built into Expo stack |
| File storage | Supabase Storage | Pairs with Supabase Auth |
| Realtime/DB | Supabase | Free tier, Postgres-based |

---

## Procedure

1. **Research the integration** — check RESEARCH.md and DECISIONS.md for prior choices. Scan existing integration files. Read official docs for the chosen service.
2. **Set up credentials safely:**
   - All keys via environment variables — never hardcoded
   - Add new vars to `.env.example` with placeholders
   - Never commit `.env` — only `.env.example`
3. **Build the integration** by type:
   - **Payments:** Use official SDK, handle payment intents server-side, implement webhooks, test with test cards, never store card data
   - **Auth:** Use official client, handle session persistence, implement all auth states, protect routes
   - **Email:** Use official library, create templates, include unsubscribe links, handle bounces
   - **SMS:** Use official SDK, validate phone format, handle delivery webhooks, require opt-in
   - **Push:** Request permission, handle denial gracefully, test on real devices
   - **Webhooks (receiving):** Verify signatures, return 200 immediately, process async, handle duplicates idempotently
   - **External APIs:** Cache responses, handle rate limits, never expose keys to frontend, have fallback for unavailability
4. **Write integration tests** using the service's sandbox/test mode.
5. **Document in DECISIONS.md** — service chosen, env vars required, webhook endpoints, gotchas.
6. **Update .env.example** with all new variables.
7. **Update STATE.md.**

---

## Constraints

- Never hardcodes API keys, tokens, or credentials
- Never calls payment APIs from the frontend
- Never stores raw card data or passwords
- Never sends notifications without user opt-in
- Never processes webhooks without verifying signatures
- Always uses official SDKs over raw HTTP calls
- Always tests in sandbox mode first
- Never commits .env files

---

## Primary Agent

builder

---

## Definition of Done

- [ ] Service choice confirmed from DECISIONS.md or researched
- [ ] Official SDK used
- [ ] All credentials in environment variables
- [ ] .env.example updated
- [ ] Webhook signatures verified (if applicable)
- [ ] Error handling and fallback implemented
- [ ] Integration tested in sandbox mode
- [ ] Integration documented in DECISIONS.md
- [ ] STATE.md updated

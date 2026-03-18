---
id: SKL-0011
name: Monetization
description: |
  Implement billing, payments, and subscription features. Use this skill when
  monetization functionality is requested, including Stripe integration,
  pricing pages, and webhook handling.
version: 1.0
owner: builder
triggers:
  - MONETIZATION_REQUESTED
inputs:
  - Task description (from STATE.md)
  - docs/PRD.md (pricing model, revenue goals)
  - .claude/project/knowledge/DECISIONS.md
  - Existing user/auth models
outputs:
  - Billing service files, webhook handlers, paywall middleware
  - docs/BILLING.md
  - .claude/project/STATE.md (updated)
tags:
  - building
  - billing
  - stripe
  - subscriptions
---

# Skill: Monetization

## Metadata

| Field | Value |
|-------|-------|
| **Skill ID** | SKL-0011 |
| **Version** | 1.0 |
| **Owner** | builder |
| **Inputs** | Task description, PRD, DECISIONS.md, user/auth models |
| **Outputs** | Billing service files, BILLING.md, STATE.md updated |
| **Triggers** | `MONETIZATION_REQUESTED` |

---

## Purpose

Implement payment processing, subscriptions, paywalls, and billing. Start with the simplest billing model that works; make it easy to change pricing later.

---

## Step 0: Provider Detection

Before proceeding, determine the billing provider. Read `docs/ARCHITECTURE.md` and `docs/PRD.md` for platform context.

| Platform / Context | Provider | Notes |
|-------------------|----------|-------|
| Web app (default) | **Stripe** | Use the Stripe procedure below |
| Shopify app | **Shopify AppSubscription** | Use Shopify Billing API, not Stripe. Route to SKL-0010 (API Integration) instead. |
| iOS app | **Apple In-App Purchase** | Use StoreKit 2. Apple requires IAP for digital goods. Route to SKL-0007 (Mobile Dev) instead. |
| Android app | **Google Play Billing** | Use Google Play Billing Library. Required for digital goods on Play Store. Route to SKL-0007 instead. |
| Physical goods / services | **Stripe** | Platform billing rules don't apply to physical goods |

**If the provider is not Stripe:** Log a decision in DECISIONS.md noting the provider choice, then route to the appropriate skill (SKL-0010 or SKL-0007). Do not proceed with the Stripe procedure below.

**If the provider is Stripe:** Continue with the procedure below.

---

## Billing Model to Stripe Mapping

| Model | Stripe Primitives |
|-------|------------------|
| Flat subscription | Product + Price (recurring) + Subscription |
| Usage-based | Product + Price (metered) + UsageRecord |
| One-time | Product + Price (one-time) + PaymentIntent |
| Freemium | Free tier in app logic + Subscription for paid |
| Per-seat | Subscription with quantity parameter |

---

## Procedure

1. **Confirm billing model** from PRD. If unspecified, ask user. Log to DECISIONS.md.
2. **Set up Stripe:**
   - Env vars: `STRIPE_SECRET_KEY`, `STRIPE_PUBLISHABLE_KEY`, `STRIPE_WEBHOOK_SECRET`
   - Always pin Stripe API version
3. **Database schema** — add billing fields via migration: `stripe_customer_id`, `subscription_status`, `subscription_id`, `current_period_end`, `plan_id`.
4. **Checkout flow** — create Stripe checkout session server-side. Get-or-create Stripe customer. Support trial periods and promo codes.
5. **Webhook handler (most critical):**
   - Always verify signatures — never skip
   - Handle idempotently (same event may arrive twice)
   - Minimum events: `checkout.session.completed`, `customer.subscription.updated`, `customer.subscription.deleted`, `invoice.payment_failed`, `invoice.payment_succeeded`
   - Return 200 even on handler errors (prevent retry loops)
6. **Access control** — paywall middleware checks subscription status from DB (not JWT). Plan hierarchy enforcement.
   - **Critical rule:** Stripe is source of truth. DB is a cache synced via webhooks.
7. **Customer portal** — use Stripe's hosted billing portal for self-serve management.
8. **Document in `docs/BILLING.md`** — provider, model, plans, webhook endpoint, test cards.
9. **Update STATE.md.**

---

## Constraints

- Never hardcodes Stripe keys or price IDs
- Never trusts client-side subscription state — always verify from DB
- Never skips webhook signature verification
- Never modifies subscription status directly — only via webhook handlers
- Always pins Stripe API version
- Always returns 200 from webhook handler

---

## Primary Agent

builder

---

## Definition of Done

- [ ] Billing model confirmed and logged to DECISIONS.md
- [ ] Stripe API version pinned
- [ ] Database migration created for billing fields
- [ ] Checkout session flow implemented
- [ ] Webhook handler with signature verification
- [ ] All 5 critical webhook events handled idempotently
- [ ] Access control middleware implemented
- [ ] Customer portal endpoint created
- [ ] No hardcoded Stripe keys
- [ ] BILLING.md created
- [ ] STATE.md updated

---
id: SKL-0013
name: Growth & Distribution
description: |
  Build growth features like landing pages, SEO, waitlists, and referral
  systems. Use this skill when growth or distribution features are requested.
version: 1.0
owner: builder
triggers:
  - GROWTH_FEATURE_REQUESTED
inputs:
  - Task description (from STATE.md)
  - docs/PRD.md (target users, value prop, success metrics)
  - .claude/project/knowledge/DECISIONS.md
outputs:
  - Landing pages, SEO components, referral/waitlist logic, share flows
  - .claude/project/STATE.md (updated)
tags:
  - building
  - growth
  - marketing
  - seo
---

# Skill: Growth & Distribution

## Metadata

| Field | Value |
|-------|-------|
| **Skill ID** | SKL-0013 |
| **Version** | 1.0 |
| **Owner** | builder |
| **Inputs** | Task description, PRD, DECISIONS.md |
| **Outputs** | Landing pages, SEO, referral/waitlist, STATE.md updated |
| **Triggers** | `GROWTH_FEATURE_REQUESTED` |

---

## Purpose

Build growth infrastructure — landing pages, SEO, referral mechanics, waitlists, social sharing. Growth is infrastructure that compounds, not a campaign.

---

## Procedure

1. **Extract value proposition from PRD:**
   - Who (target user), what problem, what product does, why now
   - Formula: "[Product] helps [user] [do X] so they can [outcome], without [pain]."
2. **Landing page structure** (high-converting order):
   1. Hero — who + what + primary CTA (above fold)
   2. Problem — amplify pain, make reader feel understood
   3. Solution — how product solves it (show, don't tell)
   4. Social proof — quotes, logos, numbers
   5. Features — 3 key capabilities with user benefits
   6. FAQ — top 5 objections answered
   7. Final CTA — same as hero
3. **SEO foundations:**
   - SEO component on all public pages (title, description, OG tags, Twitter card, structured data)
   - `robots.txt` (allow public, disallow /api/ and /dashboard/)
   - `sitemap.xml` auto-generated from pages
4. **Waitlist / email capture:**
   - Validate email, check duplicates, generate referral code
   - Send confirmation email with position and referral link
   - Track `waitlist_joined` event
5. **Referral mechanics (if PRD calls for it):**
   - Reward both referrer and referee
   - Reward referrer on activation (not signup) to prevent gaming
6. **Social sharing** — native share sheet on mobile, clipboard fallback, direct platform links.
7. **Update STATE.md.**

---

## Constraints

- Never writes dishonest or misleading marketing copy
- Never uses dark patterns (fake urgency, hidden costs)
- Never blocks signup with excessive fields — email first
- Never ships landing page without SEO metadata
- Always ties growth features to a PRD metric

---

## Primary Agent

builder

---

## Definition of Done

- [ ] Value proposition extracted from PRD
- [ ] Landing page with hero, problem, solution, features, proof, FAQ, CTA
- [ ] SEO component on all public pages
- [ ] robots.txt and sitemap.xml created
- [ ] Email capture / waitlist implemented
- [ ] Referral mechanics (if PRD requires)
- [ ] Share flow on key content/milestones
- [ ] Growth events tracked
- [ ] STATE.md updated

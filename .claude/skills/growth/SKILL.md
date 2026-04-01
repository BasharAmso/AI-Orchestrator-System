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
1.5. **Select Visual Tier:**

   Ask the user or infer from the PRD. This decision affects the page structure, not just styling.

   | Tier | When to Use | What It Produces |
   |------|-------------|-----------------|
   | **Clean** | MVP, internal tool, speed matters | Functional, readable, good defaults. Standard layout. |
   | **Premium** | Product launch, public-facing, brand impression matters | Everything in Clean + glassmorphism, gradients, animations, parallax, animated stats. |

   **Auto-detect:** If the PRD or task mentions "launch", "public", "marketing", or "brand", default to Premium. Otherwise default to Clean.

2. **Landing page structure** (high-converting order):
   1. Hero — who + what + primary CTA (above fold)
   2. Problem — amplify pain, make reader feel understood
   3. Solution — how product solves it (show, don't tell)
   4. Social proof — quotes, logos, numbers
   5. Features — 3 key capabilities with user benefits
   6. FAQ — top 5 objections answered
   7. Final CTA — same as hero
2.5. **Premium Tier Techniques** (skip if Visual Tier = Clean):

   Apply these techniques during and after the page build. Premium tier defaults to dark theme (dark background, light text) unless the project has an established light brand.

   **Hero:**
   - Full-viewport hero with layered background (gradient + image at 10-20% opacity + optional particle/grid overlay)
   - Animated headline (word-by-word reveal or typewriter effect)
   - Floating accent elements (blurred gradient orbs) for depth
   - CTA button with glow effect on hover

   **Sections:**
   - Glassmorphism cards (backdrop-blur, semi-transparent background, subtle border)
   - Multi-stop gradient backgrounds flowing between sections (no hard color breaks)
   - Alternating dark/light sections with gradient transitions
   - Generous whitespace (py-24 to py-32 between sections)

   **Typography:**
   - Custom Google Fonts pairing (display font for headlines, clean sans for body)
   - Oversized hero headline (text-6xl to text-8xl)
   - Gradient text on key headlines (background-clip: text)
   - Animated counter/stats section (numbers count up on scroll)

   **Animations:**
   - Scroll-triggered section reveals (Framer Motion or AOS)
   - Staggered card entrance (50-100ms delays)
   - Parallax on hero background (subtle, one layer)
   - Floating elements with subtle CSS animation (translate + rotate keyframes)
   - All animations must respect `prefers-reduced-motion`

   **Visual Depth:**
   - Layered z-index composition (background, mid-ground, foreground)
   - Soft shadows on cards (shadow-xl with low opacity)
   - Noise/grain texture overlay on dark sections (2-5% opacity)
   - SVG decorative shapes (blurred blobs, curves) as section dividers

   **Social Proof (Premium):**
   - Logo carousel with grayscale-to-color hover effect
   - Testimonial cards with avatar, name, role, quote
   - Animated stat counters (e.g., "500+ users" counting up on scroll)

   **Cross-reference:** Premium tier must also pass the frontend-dev Visual Polish checklist (Steps 4A-4F in `.claude/skills/frontend-dev/SKILL.md`).

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
- **Friction check before shipping:** Is CTA above fold? Can a visitor understand the product in under 10 seconds? Are form fields minimized? Reference: `.claude/skills/friction-audit/CHECKLIST.md`
- **Premium performance:** Premium animations must maintain 60fps. Use `will-change` sparingly. Test on mobile viewport. Prefer CSS animations over JS where possible.

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
- [ ] Visual Tier applied ([Clean | Premium])
- [ ] STATE.md updated

## Output Contract

| Field | Value |
|-------|-------|
| **Artifacts** | Landing pages, SEO components (`robots.txt`, `sitemap.xml`), referral/waitlist logic, share flows |
| **State Update** | `.claude/project/STATE.md` — mark task complete, log files modified |
| **Handoff Event** | `TASK_COMPLETED` (growth infrastructure built) |

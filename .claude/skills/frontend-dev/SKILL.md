---
id: SKL-0005
name: Frontend Development
description: |
  Build web UI components, pages, and styling. Includes a mandatory Visual
  Polish pass that adds scroll animations, micro-interactions, typography
  rhythm, and design depth. Use this skill when a frontend task is ready for
  implementation, including React components, CSS, layouts, and responsive design.
version: 2.0
owner: builder
triggers:
  - FRONTEND_TASK_READY
inputs:
  - Task description (from STATE.md)
  - .claude/project/knowledge/DECISIONS.md
  - Existing frontend files
  - docs/PRD.md or docs/GDD.md (for brand/tone context)
outputs:
  - Frontend component/page files
  - .claude/project/STATE.md (updated)
tags:
  - building
  - frontend
  - ui
---

# Skill: Frontend Development

## Metadata

| Field | Value |
|-------|-------|
| **Skill ID** | SKL-0005 |
| **Version** | 2.0 |
| **Owner** | builder |
| **Inputs** | Task description, DECISIONS.md, existing frontend files, PRD/GDD |
| **Outputs** | Frontend files, STATE.md updated |
| **Triggers** | `FRONTEND_TASK_READY` |

---

## Purpose

Build user interfaces that work correctly AND look exceptional. Correctness (responsive, accessible, all states handled) is the floor, not the ceiling. Every page and component must pass a Visual Polish check before it's considered done.

---

## Procedure

### Step 1 — Read Context

1. **Read DECISIONS.md** — identify framework (React/Next.js, Vue, Astro, vanilla), styling approach (Tailwind, CSS modules), component library (shadcn/ui, Radix, etc.).
2. **Read PRD or GDD** — extract brand tone, target audience, and visual expectations.
3. **Scan existing code** — identify conventions, color tokens, font choices, animation patterns already in use.

### Step 2 — Understand the Task

- What does this UI do? Who uses it? What data does it display or collect?
- What is the emotional tone? (professional, playful, luxurious, minimal, bold)
- Is this a hero page (high visual impact) or a utility screen (functional first)?

### Step 3 — Build the Component/Page

Core implementation:
- Match existing file structure and naming conventions
- Mobile-first responsive design
- Accessible markup (semantic HTML, ARIA labels, keyboard navigation)
- No hardcoded data — use props, state, or labeled placeholders
- Handle all states: loading, error, empty, populated

### Step 4 — Visual Polish Pass (Mandatory)

After the component works correctly, apply these checks. **This step is not optional.**

#### 4A. Typography Rhythm

| Check | What to Do |
|-------|-----------|
| Font pairing | Use a deliberate serif + sans-serif pairing OR a single family with weight contrast. Never rely on system defaults alone. |
| Size scale | Headings should have clear hierarchy — at least 3 distinct sizes with noticeable jumps (not 16px → 18px → 20px). |
| Line height | Body text: 1.5-1.7. Headings: 1.1-1.3. Tight headings + relaxed body creates rhythm. |
| Letter spacing | Uppercase labels need positive tracking (0.05-0.15em). Large headings can use slight negative tracking. |
| One "wow" text moment | At least one headline, quote, or stat should be oversized, italic, or styled distinctly to break the grid. |

#### 4B. Scroll Animations

| Check | What to Do |
|-------|-----------|
| Section reveals | Content sections should animate in on scroll — fade-up, slide-in, or scale. Use Framer Motion, AOS, or CSS `@keyframes` with Intersection Observer. |
| Staggered children | Lists, grids, and card groups should stagger their entrance (50-100ms delay between items). |
| Parallax (optional) | Hero images or background elements can scroll at a different rate for depth. Use sparingly — one parallax element max. |
| Respect `prefers-reduced-motion` | Wrap all animations in a motion-preference check. Users who disable motion see instant renders. |

#### 4C. Micro-Interactions

| Check | What to Do |
|-------|-----------|
| Button hover | Buttons should have a visible hover state beyond color change — slight scale (1.02-1.05), shadow lift, or fill animation. |
| Image hover | Gallery/portfolio images should respond to hover — zoom, overlay fade, or caption reveal. |
| Focus indicators | Interactive elements need visible focus rings that match the design language (not default browser blue). |
| Transitions | All state changes (hover, active, focus, open/close) should use `transition-all duration-200` minimum. No instant snaps. |
| Cursor | Consider `cursor-pointer` on all clickable non-link elements. |

#### 4D. Visual Depth

| Check | What to Do |
|-------|-----------|
| Layering | At least one section should have overlapping elements — a card that bleeds over a section boundary, text over an image, or a floating accent. |
| Shadows | Cards and elevated elements need subtle shadows (`shadow-sm` to `shadow-lg`). Avoid flat designs where everything is on the same plane. |
| Gradients | Use subtle background gradients to separate sections instead of hard color blocks. Gradient overlays on hero images add depth. |
| Texture (optional) | Subtle noise/grain overlay, dot patterns, or background shapes can add personality. Don't overdo it — one texture element per page. |
| Whitespace | Generous padding between sections (py-16 to py-24). Tight spacing looks cheap; breathing room looks premium. |

#### 4E. Color & Contrast

| Check | What to Do |
|-------|-----------|
| Limited palette | 1 primary, 1 accent, 2-3 neutrals. More than 5 colors looks chaotic. |
| Contrast ratio | Text on backgrounds must meet WCAG 2.1 AA (4.5:1 normal, 3:1 large). |
| Dark sections | At least one section should use an inverted color scheme (dark background, light text) for visual variety. |
| Accent usage | The accent color should appear sparingly — CTAs, highlights, decorative elements. Not on large surfaces. |

#### 4F. Component Library

When a project uses shadcn/ui, Radix, or a similar component library:
- **Use it.** Don't rebuild what exists.
- Customize through the theme/token layer, not by overriding styles.
- When no library is specified, **suggest shadcn/ui for React/Next.js projects** — it provides beautiful defaults with Tailwind customization. Log this to DECISIONS.md.

### Step 5 — Final Quality Check

Before marking done, verify:
- Does the page look good at 320px, 768px, and 1440px?
- Does it look polished in both light and dark modes (if applicable)?
- Is there at least one visual "moment" that makes someone pause? (a hero animation, a beautiful card grid, an unexpected typographic treatment)
- Would you screenshot this and put it in a portfolio?

### Step 6 — Update STATE.md

Record files created and note the visual approach taken (for consistency across future pages).

---

## Constraints

- Never modifies backend, API, or database files
- Never hardcodes data that should come from an API or prop
- Always logs new framework/library decisions to DECISIONS.md
- Visual Polish (Step 4) is mandatory — never skip it, even for "simple" pages
- Respect existing design language — polish should enhance the current direction, not introduce a conflicting aesthetic
- Animations must respect `prefers-reduced-motion`

---

## Deployment Reference

| Target | Tool | Notes |
|--------|------|-------|
| Static/SPA | Vercel | Zero config for React/Next.js |
| Static/SPA | Netlify | Drag and drop or Git deploy |
| Next.js/SSR | Vercel | Native support |

---

## Primary Agent

builder

---

## Definition of Done

- [ ] Framework and styling confirmed from DECISIONS.md
- [ ] Component handles loading, error, empty, populated states
- [ ] Mobile-first responsive layout (tested at 320px, 768px, 1440px)
- [ ] Accessible markup (semantic HTML, ARIA, keyboard nav, focus indicators)
- [ ] Matches existing project conventions
- [ ] **Typography rhythm applied** (hierarchy, pairing, one "wow" moment)
- [ ] **Scroll animations added** (section reveals, staggered children, reduced-motion respected)
- [ ] **Micro-interactions present** (button hover, image hover, transitions on all state changes)
- [ ] **Visual depth achieved** (shadows, layering, gradients, generous whitespace)
- [ ] **Color palette limited and contrast-checked**
- [ ] At least one visual moment that would make someone pause
- [ ] STATE.md updated

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

After the component works correctly, run the Design Quality Checklist. **This step is not optional.**

Run every section of `.claude/skills/frontend-dev/CHECKLIST.md`:
- Typography Rhythm
- Color & Contrast
- Scroll Animations
- Micro-Interactions
- Visual Depth
- Component Library
- Anti-Patterns (flag and fix any matches)

### Step 5 — Final Quality Check

Before marking done, verify:
- Does the page look good at 320px, 768px, and 1440px?
- Does it look polished in both light and dark modes (if applicable)?
- Is there at least one visual "moment" that makes someone pause? (a hero animation, a beautiful card grid, an unexpected typographic treatment)
- Would you screenshot this and put it in a portfolio?

### Step 5.1 — Friction Check

Run the Friction Audit Checklist (`.claude/skills/friction-audit/CHECKLIST.md`). Focus on:
- Unnecessary steps in user flows
- Form field count (every field earns its place)
- Smart defaults pre-filled where possible
- Loading states clear and visible
- Empty states guide the user

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

## Knowledge Enhancement (MCP mode)

If Cortex MCP is available:
1. Call `search_knowledge` with query derived from task (e.g., "color palette for fintech", "typography for dashboard", "animation patterns React"), category="ux-design"
2. If relevant results found, call `get_fragment` on the top result
3. Apply as supplementary context (does not override this skill's procedure)

## Output Contract

| Field | Value |
|-------|-------|
| **Artifacts** | Frontend component/page files (components, pages, styles, assets) |
| **State Update** | `.claude/project/STATE.md` — mark task complete, log files modified |
| **Handoff Event** | `TASK_COMPLETED` (ready for code review) |

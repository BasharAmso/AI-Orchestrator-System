---
id: SKL-0005
name: Frontend Development
version: 1.0
owner: builder
triggers:
  - FRONTEND_TASK_READY
inputs:
  - Task description (from STATE.md)
  - .claude/project/knowledge/DECISIONS.md
  - Existing frontend files
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
| **Version** | 1.0 |
| **Owner** | builder |
| **Inputs** | Task description, DECISIONS.md, existing frontend files |
| **Outputs** | Frontend files, STATE.md updated |
| **Triggers** | `FRONTEND_TASK_READY` |

---

## Purpose

Build user interfaces — web pages, components, layouts, and client-side interactions.

---

## Procedure

1. **Read DECISIONS.md** — identify framework (React, Vue, vanilla), styling approach (Tailwind, CSS modules), component library.
2. **Understand the task** — what does this UI do? Who uses it? What data does it display or collect?
3. **Build the component/page:**
   - Match existing file structure and naming conventions
   - Mobile-first responsive design
   - Accessible markup (semantic HTML, ARIA labels)
   - No hardcoded data — use props, state, or labeled placeholders
4. **Handle all states:** loading, error, empty, populated — every data-dependent component.
5. **Update STATE.md** with files created.

---

## Constraints

- Never modifies backend, API, or database files
- Never hardcodes data that should come from an API or prop
- Always logs new framework/library decisions to DECISIONS.md

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
- [ ] Mobile-first responsive layout
- [ ] Accessible markup used
- [ ] Matches existing project conventions
- [ ] STATE.md updated
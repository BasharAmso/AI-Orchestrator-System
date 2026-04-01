---
id: SKL-0032
name: SEO Audit
description: |
  Audit web pages for search engine optimization: meta tags, heading hierarchy,
  structured data, image optimization, mobile-friendliness, and content quality.
  Complements SKL-0013 (Growth & Distribution) by validating what was built.
version: 1.0
owner: builder
triggers:
  - SEO_AUDIT_REQUESTED
inputs:
  - Target HTML/JSX/TSX files or URLs
  - docs/PRD.md (target keywords and audience)
  - .claude/project/STATE.md
outputs:
  - SEO audit report
  - .claude/project/STATE.md (updated)
tags:
  - marketing
  - seo
  - growth
  - custom
---

# Skill: SEO Audit

## Metadata

| Field | Value |
|-------|-------|
| **Skill ID** | SKL-0032 |
| **Version** | 1.0 |
| **Owner** | builder |
| **Inputs** | HTML/JSX/TSX files, PRD.md, STATE.md |
| **Outputs** | SEO audit report, STATE.md updated |
| **Triggers** | `SEO_AUDIT_REQUESTED` |

---

## Purpose

Audit web pages for SEO readiness after they're built. SKL-0013 (Growth & Distribution) creates landing pages and SEO components; this skill validates that the output is actually optimized for search engines. Catches the gap between "we built a landing page" and "the landing page ranks."

---

## Procedure

### Step 1 — Identify Pages to Audit

Read the project's page/route structure. Prioritize:
1. Landing page / homepage
2. Any page with marketing intent (pricing, features, about)
3. Blog/content pages (if applicable)

### Step 2 — Technical SEO Check

For each page, verify:

| Check | Pass Criteria | Severity |
|-------|--------------|----------|
| `<title>` tag | Present, 50-60 chars, includes target keyword | HIGH |
| `<meta name="description">` | Present, 150-160 chars, compelling CTA | HIGH |
| `<h1>` tag | Exactly one per page, contains primary keyword | HIGH |
| Heading hierarchy | H1 → H2 → H3 (no skipped levels) | MEDIUM |
| `<html lang="">` | Present and correct | MEDIUM |
| Canonical URL | `<link rel="canonical">` present | MEDIUM |
| Open Graph tags | `og:title`, `og:description`, `og:image` present | MEDIUM |
| Twitter Card tags | `twitter:card`, `twitter:title`, `twitter:description` | LOW |
| Viewport meta | `<meta name="viewport">` for mobile | HIGH |
| Robots meta | Not accidentally blocking indexing | CRITICAL |

### Step 3 — Content Quality Check

| Check | Pass Criteria | Severity |
|-------|--------------|----------|
| Word count | Landing pages: 300+ words; blog: 800+ words | MEDIUM |
| Keyword presence | Target keyword in title, H1, first 100 words, and meta description | HIGH |
| Image alt text | All `<img>` have meaningful alt text (not empty, not "image") | MEDIUM |
| Internal links | At least 2 internal links per content page | LOW |
| External links | Outbound links use `rel="noopener"` | LOW |
| Structured data | JSON-LD schema markup where appropriate (Organization, Product, FAQ) | MEDIUM |

### Step 4 — Performance Signals

| Check | Pass Criteria | Severity |
|-------|--------------|----------|
| Image optimization | Images use modern formats (WebP, AVIF) or are reasonably sized (<200KB) | MEDIUM |
| Lazy loading | Below-fold images use `loading="lazy"` | LOW |
| Render-blocking resources | Critical CSS inlined or minimal blocking JS | MEDIUM |
| Mobile responsiveness | No horizontal scroll, tap targets ≥44px | HIGH |

### Step 5 — Generate Report

Organize findings by severity. For each issue:
- Page and element affected
- Current state vs. recommended state
- Specific fix (code snippet when possible)

### Step 6 — Update STATE.md

---

## Constraints

- Audits HTML/JSX/TSX output, not runtime behavior (no Lighthouse-style testing)
- Recommendations follow current Google Search guidelines
- Does not write or modify code — provides actionable recommendations
- SEO is a moving target — findings are best-practice guidance, not guarantees

---

## Primary Agent

builder

---

## Definition of Done

- [ ] All target pages identified and audited
- [ ] Technical SEO checks completed (title, meta, headings, OG tags)
- [ ] Content quality checks completed (keywords, alt text, links)
- [ ] Performance signals checked (images, mobile)
- [ ] Each finding has specific fix recommendation
- [ ] STATE.md updated

## Output Contract

| Field | Value |
|-------|-------|
| **Artifacts** | SEO audit report (findings by severity with fix recommendations) |
| **State Update** | `.claude/project/STATE.md` — mark task complete, log pages audited and findings |
| **Handoff Event** | `TASK_COMPLETED` (SEO audit complete) |

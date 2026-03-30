---
id: SKL-0018
name: User Acceptance Testing
description: |
  Structured QA testing with four modes: diff-aware (auto-scoped to branch
  changes), full (systematic exploration), quick (30-second smoke test), and
  regression (compare against baseline). Produces health score, structured
  reports, and actionable bug lists. Use this skill when UAT is requested
  or a feature is ready for acceptance testing.
version: 3.0
owner: reviewer
triggers:
  - UAT_REQUESTED
  - READY_FOR_ACCEPTANCE_TESTING
inputs:
  - docs/PRD.md (features and acceptance criteria)
  - .claude/project/STATE.md (what was built)
  - TODOS.md (if exists — known bugs and planned work)
  - Built application (test/staging environment)
  - Previous QA baseline (if exists, for regression mode)
outputs:
  - .claude/project/knowledge/UAT_REPORT.md
  - .claude/project/qa-reports/baseline.json (for regression tracking)
  - .claude/project/STATE.md (updated with verdict)
  - Bug list for fixer agent (if issues found)
tags:
  - review
  - testing
  - uat
  - acceptance
  - qa
  - mobile-qa
---

# Skill: User Acceptance Testing & QA

## Metadata

| Field | Value |
|-------|-------|
| **Skill ID** | SKL-0018 |
| **Version** | 3.0 |
| **Owner** | reviewer |
| **Inputs** | PRD, STATE.md, TODOS.md, built application, previous baseline |
| **Outputs** | UAT_REPORT.md, baseline.json, STATE.md updated, bug list |
| **Triggers** | `UAT_REQUESTED`, `READY_FOR_ACCEPTANCE_TESTING` |

---

## Purpose

Walk through the product as a real user would — using a real browser when Playwright MCP is available. Verify features match the PRD, edge cases don't crash the app, and error messages make sense. Produce a structured report with a health score and actionable findings. Issue a GO / GO WITH CONDITIONS / NO-GO verdict.

---

## Cognitive Mode

**Hostile QA Engineer.** You are trying to break the product. Click everything. Submit empty forms. Navigate backwards. Resize the window. You are the user's advocate — if something confuses you, it will confuse them.

---

## QA Modes

Detect the appropriate mode automatically, or let the user specify:

| Mode | When | What |
|------|------|------|
| **Diff-aware** (default on feature branch) | On a feature branch with changes against main | Analyze git diff, identify affected pages/routes, test those specifically |
| **Full** | User specifies, or first QA run on a project | Systematic exploration of every reachable page. 5-15 minutes. |
| **Quick** | User says "quick check" or "smoke test" | 30-second smoke test: homepage + top 5 pages. Console errors? Broken links? |
| **Regression** | User provides a baseline, or previous baseline exists | Run full mode, then compare against baseline. What's fixed? What's new? |

---

## Procedure

### Step 0 — Setup

1. **Read PRD and STATE.md** — identify all features, acceptance criteria, and what's marked complete. Build a checklist of testable features.
2. **Read TODOS.md** (if exists) — note known bugs and planned work. If a TODO describes a bug this branch should fix, add it to the test plan.
3. **Determine QA mode** based on branch state and user request.
4. **For diff-aware mode:** Analyze the branch diff to scope testing:
   ```bash
   git diff main...HEAD --name-only
   git log main..HEAD --oneline
   ```
   Map changed files to affected pages/routes:
   - Route/controller files → which URL paths they serve
   - View/template/component files → which pages render them
   - Model/service files → which pages use those models
   - API endpoint files → test endpoints directly
   - Style files → check pages that include them

---

### Step 0.5 — Browser Testing Setup (Playwright MCP)

**If Playwright MCP is connected**, use it for all browser-based testing in this skill. This enables real browser interaction instead of code-only inspection.

**Check availability:** Look for Playwright MCP tools (`browser_navigate`, `browser_click`, `browser_screenshot`, `browser_snapshot`, `browser_type`). If available, use them. If not, fall back to code inspection and manual verification notes.

**When Playwright MCP is available:**

1. **Get the app URL** — from deployment config, STATE.md, or ask the user (e.g., `http://localhost:3000` or a staging URL like `https://my-app.vercel.app`).
2. **Navigate to the app** using `browser_navigate` with the URL.
3. **For each test in Steps 1-4**, use real browser interaction:
   - `browser_navigate` — open pages and follow links
   - `browser_click` — click buttons, links, form elements
   - `browser_type` — fill in forms, search fields
   - `browser_screenshot` — capture visual state for evidence
   - `browser_snapshot` — read the DOM/accessibility tree to verify content and structure
4. **Screenshot evidence:** Take a screenshot for each critical flow tested and each issue found. Reference screenshots in the UAT report.

**When Playwright MCP is NOT available:**

Fall back to the previous approach:
- Inspect source code for potential issues
- Check route definitions, component logic, and error handling
- Note items that require manual browser verification
- Add a section to the UAT report: "Manual verification needed for: [list]"

> **Tip:** Always say "use Playwright MCP" in your prompt when invoking this skill. Claude may default to Bash-based testing otherwise.

---

### Step 1 — Identify Critical User Flows

Flows where failure means NO-GO:
- Account creation / sign-in (if applicable)
- Core value action (the one thing the app exists for)
- Payment / checkout (if applicable)
- Data save and retrieval
- Navigation between main sections

**Diff-aware adjustment:** Prioritize flows that touch changed files. But always smoke-test adjacent flows for regressions.

---

### Step 2 — Test Each Flow

Start from real entry points (not deep links). For each flow:

#### Happy Path
- Does it work as described in the PRD?
- Is the result correct?

#### Edge Cases
| Category | Test |
|----------|------|
| Empty inputs | Submit forms blank, navigate to empty states |
| Invalid inputs | Wrong types, too long, special characters, SQL/script injection strings |
| Error states | Disconnect network, provide wrong credentials, exceed rate limits |
| Navigation | Back button, page refresh, deep link directly to a page |
| Boundary values | Zero items, one item, maximum items, very long text |
| Concurrent | Double-click submit, rapid navigation |

#### For Each Issue Found
Document immediately:
1. **What happened** — one-line description
2. **Expected behavior** — what should have happened
3. **Reproduction steps** — exact steps to reproduce
4. **Severity** — Critical / High / Medium / Low (see rubric below)
5. **Category** — Functional / Visual / UX / Content / Performance / Accessibility / Console

---

### Step 3 — Accessibility & Usability Check

Test without inspecting source code:

| Check | How to Test |
|-------|------------|
| Keyboard navigation | Tab through all interactive elements. Can you reach everything? Visible focus? |
| Text readability | Squint test — can you read everything at normal zoom? |
| Color contrast | Any text hard to read against its background? |
| Image purpose | Do images have descriptions? (inspect via browser) |
| Error messages | Are they helpful and specific? Or just "Something went wrong"? |
| Mobile responsiveness | Resize to mobile width — does layout break? |
| Loading indicators | Are there spinners/skeletons for async operations? Or does content just pop in? |
| Empty states | What do lists/tables look like with zero items? Helpful message or blank void? |
| VoiceOver / TalkBack (mobile) | Enable screen reader, navigate core flow. Every interactive element reachable and labeled? |
| Dynamic Type / Font Scaling (mobile) | Set to largest text size. Does layout accommodate without truncation or overlap? |

---

### Step 4 — Framework-Specific Checks

Detect the framework and apply relevant checks:

**Next.js / React:**
- Console hydration errors (`Hydration failed`, `Text content did not match`)
- Client-side navigation — do page transitions work without full reload?
- Loading states during data fetching
- CLS (Cumulative Layout Shift) — does content jump around?

**Rails:**
- Flash messages appearing and dismissing
- Turbo/Stimulus integration — smooth transitions?
- CSRF token presence in forms

**General SPA (React, Vue, Angular):**
- Stale state — navigate away and back, does data refresh?
- Browser back/forward — does the app handle history?
- Direct URL navigation (deep links) — do they work?

**Static/WordPress:**
- Broken links
- Mixed content warnings (HTTP resources on HTTPS page)
- Plugin conflicts (console errors from different sources)

**API-only:**
- Test endpoints with `curl` or the app's API client
- Check response codes, error formats, empty responses
- Verify authentication/authorization on protected endpoints

**Swift/SwiftUI (iOS):**
- App launch: does it start without crash on simulator/device?
- Orientation: rotate device — does layout adapt correctly?
- App lifecycle: background the app and return — does state persist?
- Gestures: swipe-back navigation, pull-to-refresh, long press — all working?
- Permissions: deny camera/location/notifications — graceful handling with guidance to Settings?
- Push notifications: do they arrive and navigate correctly when tapped?
- Dynamic Type: increase text size to largest — does layout still work without truncation?
- Dark mode: switch appearance — are all elements visible and readable?
- VoiceOver: enable VoiceOver, navigate the core flow — every element labeled and reachable?
- Memory: monitor for leaks during repeated navigation (Instruments if available)

**Kotlin/Jetpack Compose (Android):**
- App launch: does it start without crash on emulator/device?
- Orientation: rotate device — does layout adapt? Is state preserved across configuration change?
- Process death: background app, kill process, restore — does SavedStateHandle preserve user input?
- Back button: does system back navigate correctly at every screen?
- Gestures: swipe, long press, pull-to-refresh — all working?
- Permissions: deny runtime permissions — graceful handling with rationale and Settings guidance?
- Push notifications: do they arrive and deep-link correctly?
- Font scaling: increase to largest font size — layout still usable?
- Dark theme: switch theme — all elements visible and readable?
- TalkBack: enable TalkBack, navigate core flow — every element labeled and reachable?
- Memory: watch for Activity leaks on configuration changes (LeakCanary if available)

**React Native / Expo:**
- Test on both iOS simulator and Android emulator — rendering differences?
- Hot reload: does the app survive a hot reload without state corruption?
- Native module errors: check for red screen / yellow warnings in development
- Platform-specific behavior: do `Platform.select()` branches work correctly on each OS?

---

### Step 5 — Compute Health Score

Rate each category 0-100, then compute weighted average:

| Category | Weight | Scoring |
|----------|--------|---------|
| Console | 15% | 0 errors = 100, 1-3 = 70, 4-10 = 40, 10+ = 10 |
| Functional | 20% | Start at 100, deduct: Critical -25, High -15, Medium -8, Low -3 |
| UX | 15% | Start at 100, deduct per finding by severity |
| Visual | 10% | Start at 100, deduct per finding by severity |
| Accessibility | 15% | Start at 100, deduct per finding by severity |
| Performance | 10% | Start at 100, deduct per finding by severity |
| Content | 5% | Start at 100, deduct per finding by severity |
| Friction | 10% | Happy path ≤5 steps = 100, 6-8 = 70, 9+ = 40. First action <60s = +0, >60s = -30. Error messages actionable = +0, generic = -20. Reference: `.claude/skills/friction-audit/CHECKLIST.md` |
| Links | 5% | 0 broken = 100, each broken link = -15 (minimum 0) |

**Mobile apps:** Replace "Console" (15%) with "Crash/ANR" (15%): 0 crashes = 100, 1 crash = 40, 2+ crashes = 10.

**Final Score:** `score = Σ (category_score × weight)`

| Score Range | Rating |
|-------------|--------|
| 90-100 | Excellent |
| 75-89 | Good |
| 60-74 | Needs Work |
| 40-59 | Poor |
| 0-39 | Critical |

---

### Step 6 — Write UAT Report

Write to `.claude/project/knowledge/UAT_REPORT.md`:

```markdown
# UAT Report — [Project Name]
**Date:** YYYY-MM-DD
**Mode:** [diff-aware / full / quick / regression]
**Health Score:** [N]/100 ([rating])
**Verdict:** [GO / GO WITH CONDITIONS / NO-GO]

## Summary
- Pages tested: N
- Issues found: N (X critical, Y high, Z medium, W low)
- Top 3 issues to fix: [list]

## Health Score Breakdown
| Category | Score | Issues |
|----------|-------|--------|
| Console | N | ... |
| Functional | N | ... |
| ... | ... | ... |

## Issues
### ISSUE-001: [title]
- **Severity:** Critical / High / Medium / Low
- **Category:** Functional / Visual / UX / ...
- **Steps to reproduce:** [exact steps]
- **Expected:** [what should happen]
- **Actual:** [what happened]
...

## PRD Compliance Matrix
| Feature | Status | Notes |
|---------|--------|-------|
| [feature from PRD] | Pass / Fail / Partial | ... |

## TODOS Cross-Reference
- Known bugs tested: [list]
- New bugs found not in TODOS: [list]
```

---

### Step 7 — Save Baseline (for Regression)

Write a JSON baseline for future comparison:

```json
{
  "date": "YYYY-MM-DD",
  "mode": "full",
  "healthScore": 85,
  "issues": [
    { "id": "ISSUE-001", "title": "...", "severity": "high", "category": "functional" }
  ],
  "categoryScores": { "console": 100, "functional": 70, "ux": 85 }
}
```

Save to `.claude/project/qa-reports/baseline.json` (create directory if needed).

**Regression mode:** After writing the report, load the previous baseline. Compare:
- Health score delta (↑ or ↓)
- Issues fixed (in baseline but not current)
- New issues (in current but not baseline)
- Append a regression section to the report

---

### Step 8 — Route Bugs

Log Critical and High issues to STATE.md task queue for the fixer agent. Include reproduction steps.

---

### Step 9 — Issue Verdict

The default verdict is **NO-GO**. The product must earn a passing verdict with evidence.

| Verdict | Requirements (all must be met) |
|---------|-------------------------------|
| **GO** | Every critical flow tested and passing. Zero critical issues. Zero high issues. Health score ≥ 75. Full PRD compliance. |
| **GO WITH CONDITIONS** | Every critical flow passing (workarounds acceptable). Zero critical issues. All high issues have documented fixes with owners. Health score ≥ 60. |
| **NO-GO** (default) | Any requirement above not met, OR insufficient evidence. |

---

### Step 10 — Update STATE.md

Record: verdict, health score, issues found, mode used.

---

## Constraints

- Never modifies application code — found bugs are logged for fixer
- Never tests in production — always test/staging
- Never issues GO if any critical user flow is broken
- Always tests as a user (no code inspection, except for console/network checks)
- Always includes exact reproduction steps for every issue
- Always reads PRD before testing (if available)
- Always documents immediately when an issue is found — do not batch

---

## Primary Agent

reviewer

---

## Definition of Done

- [ ] QA mode determined and applied
- [ ] Playwright MCP used for browser testing (if available; fallback documented if not)
- [ ] PRD features mapped to test checklist (if PRD exists)
- [ ] TODOS.md cross-referenced for known bugs
- [ ] All critical flows tested via real browser interaction (or manually verified)
- [ ] Edge cases tested (empty, invalid, error, navigation)
- [ ] Accessibility basics checked
- [ ] Framework-specific checks applied
- [ ] Screenshots captured for critical flows and issues (if Playwright available)
- [ ] Health score computed
- [ ] UAT_REPORT.md written with verdict and all findings
- [ ] Baseline saved for regression
- [ ] Bugs routed to fixer with reproduction steps
- [ ] STATE.md updated with verdict and health score

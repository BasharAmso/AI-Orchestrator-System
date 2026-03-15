---
id: SKL-0026
name: Team Retro
description: |
  Engineering retrospective analyzing commit history, work patterns, and code
  quality metrics. Supports configurable time windows (24h, 7d, 14d, 30d) and
  comparison mode. Per-contributor analysis with praise and growth suggestions.
  Streak tracking, focus scores, and trend comparison. Use this skill when a
  retrospective is requested or at the end of a sprint/week.
version: 1.0
owner: orchestrator
triggers:
  - RETRO_REQUESTED
inputs:
  - Git commit history (origin/main)
  - TODOS.md (if exists)
  - .context/retros/*.json (previous retro snapshots)
  - .claude/project/knowledge/DECISIONS.md
outputs:
  - Retro narrative (output to conversation)
  - .context/retros/<date>.json (snapshot for trend tracking)
  - .claude/project/STATE.md (updated)
tags:
  - retrospective
  - metrics
  - team
  - velocity
---

# Skill: Team Retro

## Metadata

| Field | Value |
|-------|-------|
| **Skill ID** | SKL-0026 |
| **Version** | 1.0 |
| **Owner** | orchestrator |
| **Inputs** | Git history, TODOS.md, previous retros, DECISIONS.md |
| **Outputs** | Retro narrative, JSON snapshot, STATE.md updated |
| **Triggers** | `RETRO_REQUESTED` |

---

## Purpose

Generate a comprehensive engineering retrospective analyzing commit history, work patterns, and code quality. Designed for builders using Claude Code as a force multiplier — track velocity, celebrate wins, identify growth areas.

---

## Cognitive Mode

**Encouraging Coach.** Be candid but kind. Anchor every observation in actual commits — no vague praise, no generic criticism. Frame improvements as investments, not failures.

---

## Arguments

- `/retro` — default: last 7 days
- `/retro 24h` — last 24 hours
- `/retro 14d` — last 14 days
- `/retro 30d` — last 30 days
- `/retro compare` — compare current window vs prior same-length window

---

## Procedure

### Step 1 — Gather Raw Data

Fetch origin and identify the current user:

```bash
git fetch origin main --quiet
git config user.name
git config user.email
```

The name returned is **"you"** — the person reading this retro. All other authors are teammates.

Run these git commands (all independent, run in parallel where possible):

```bash
# Commits with stats
git log origin/main --since="<window>" --format="%H|%aN|%ae|%ai|%s" --shortstat

# Per-commit test vs production LOC
git log origin/main --since="<window>" --format="COMMIT:%H|%aN" --numstat

# Timestamps for session detection
git log origin/main --since="<window>" --format="%at|%aN|%ai|%s" | sort -n

# File hotspots
git log origin/main --since="<window>" --format="" --name-only | sort | uniq -c | sort -rn

# Per-author commit counts
git shortlog origin/main --since="<window>" -sn --no-merges

# TODOS.md
cat TODOS.md 2>/dev/null || true
```

---

### Step 2 — Compute Metrics

Calculate and present in a summary table:

| Metric | Value |
|--------|-------|
| Commits to main | N |
| Contributors | N |
| Total insertions | N |
| Total deletions | N |
| Net LOC added | N |
| Test LOC (insertions) | N |
| Test LOC ratio | N% |
| Active days | N |
| Detected sessions | N |
| Avg LOC/session-hour | N |

**Test LOC:** Files matching `test/`, `spec/`, `__tests__/`, `*.test.*`, `*.spec.*` patterns.

**Per-author leaderboard** (immediately below):
```
Contributor         Commits   +/-          Top area
You (name)               N   +N/-N        src/
alice                    N   +N/-N        app/services/
```

Sort by commits descending. Current user always first, labeled "You (name)".

**Backlog Health** (if TODOS.md exists):
- Total open TODOs
- P0/P1 count (critical/urgent)
- Items completed this period

---

### Step 3 — Commit Time Distribution

Show hourly histogram:
```
Hour  Commits  ████████████████
 09:    5      █████
 14:    8      ████████
 22:    3      ███
```

Call out: peak hours, dead zones, late-night coding clusters.

---

### Step 4 — Work Session Detection

Detect sessions using **45-minute gap** between consecutive commits.

Classify:
- **Deep sessions** (50+ min)
- **Medium sessions** (20-50 min)
- **Micro sessions** (<20 min, single-commit)

Calculate: total active coding time, average session length, LOC per hour of active time.

---

### Step 5 — Commit Type Breakdown

Categorize by conventional commit prefix (feat/fix/refactor/test/chore/docs):
```
feat:     20  (40%)  ████████████████████
fix:      27  (54%)  ███████████████████████████
refactor:  2  ( 4%)  ██
```

Flag if fix ratio exceeds 50% — signals "ship fast, fix fast" pattern.

---

### Step 6 — Hotspot Analysis

Top 10 most-changed files. Flag:
- Files changed 5+ times (churn hotspots)
- Test files vs production files in the hotspot list

---

### Step 7 — Focus Score

Calculate the percentage of commits touching the single most-changed top-level directory. Higher = deeper focused work, lower = scattered context-switching.

Report: `Focus score: 62% (src/components/)`

---

### Step 8 — Ship of the Week

Auto-identify the single highest-LOC PR or commit set in the window. Highlight it:
- What it was
- LOC changed
- Why it matters (infer from commit messages)

---

### Step 9 — Per-Contributor Analysis

For each contributor (including current user):

1. **Commits and LOC** — total commits, insertions, deletions
2. **Areas of focus** — top 3 directories/files touched
3. **Commit type mix** — their personal feat/fix/refactor breakdown
4. **Session patterns** — when they code, session count
5. **Test discipline** — their personal test LOC ratio

**For the current user ("You"):** Deepest treatment. Include session analysis, time patterns, focus score. Frame in first person.

**For each teammate:**
- **Praise** (1-2 specific things): Anchor in actual commits. Not "great work" — say exactly what was good.
- **Growth opportunity** (1 specific thing): Frame as investment, not criticism. Anchor in data.

**AI collaboration note:** If commits have `Co-Authored-By` AI trailers, note AI-assisted commit percentage as a metric.

**Solo repo:** Skip team breakdown — retro is personal.

---

### Step 10 — Streak Tracking

Count consecutive days with at least 1 commit:

```bash
git log origin/main --format="%ad" --date=format:"%Y-%m-%d" | sort -u
```

Count backward from today. Report:
- Team shipping streak: N consecutive days
- Your shipping streak: N consecutive days

---

### Step 11 — Week-over-Week Trends (if window >= 14d)

Split into weekly buckets and show trends:
- Commits per week
- LOC per week
- Test ratio per week
- Fix ratio per week

---

### Step 12 — Load History & Compare

Check for prior retros:
```bash
ls -t .context/retros/*.json 2>/dev/null
```

**If prior retros exist:** Load the most recent. Calculate deltas:
```
                    Last        Now         Delta
Test ratio:         22%    →    41%         ↑19pp
Sessions:           10     →    14          ↑4
Commits:            32     →    47          ↑47%
```

**If no prior retros:** Skip comparison. Note: "First retro — run again next week to see trends."

---

### Step 13 — Save Snapshot

```bash
mkdir -p .context/retros
```

Write JSON snapshot with metrics, per-author data, and streak info. Filename: `.context/retros/<YYYY-MM-DD>-<N>.json` (N = sequence number for today).

---

### Step 14 — Write the Narrative

Structure the output:

**Tweetable summary** (first line):
```
Week of Mar 8: 47 commits, 3.2k LOC, 38% tests, peak: 10pm | Streak: 47d
```

Then sections:
1. **Summary Table** (Step 2)
2. **Trends vs Last Retro** (Step 12, if available)
3. **Time & Session Patterns** (Steps 3-4)
4. **Shipping Velocity** (Steps 5-7)
5. **Code Quality Signals** (test ratio, hotspots)
6. **Focus & Highlights** (Steps 7-8)
7. **Your Week** (personal deep-dive, Step 9)
8. **Team Breakdown** (Step 9, if not solo)
9. **Top 3 Wins** (highest-impact things shipped)
10. **3 Things to Improve** (specific, actionable)
11. **3 Habits for Next Week** (small, practical, <5 min to adopt)

---

### Step 15 — Update STATE.md

Record: retro completed, window, health metrics summary.

---

## Compare Mode

When the user runs `/retro compare`:
1. Compute metrics for current window using `--since`
2. Compute metrics for prior same-length window using `--since` and `--until`
3. Show side-by-side comparison with deltas
4. Save only the current-window snapshot

---

## Tone

- Encouraging but candid — no coddling
- Specific and concrete — always anchor in actual commits
- Skip generic praise ("great job!") — say exactly what was good and why
- Frame improvements as leveling up, not criticism
- Never compare teammates negatively
- Keep total output around 2000-3500 words
- Use markdown tables for data, prose for narrative
- Output directly to conversation — only file written is the JSON snapshot

---

## Constraints

- Use `origin/main` for all git queries (not local main)
- If the window has zero commits, say so and suggest a different window
- Round LOC/hour to nearest 50
- Do not read CLAUDE.md or other framework docs — this skill is self-contained
- All narrative output goes to the conversation, NOT to files (except the JSON snapshot)
- Never modify source code or project files (except `.context/retros/`)

---

## Primary Agent

orchestrator

---

## Definition of Done

- [ ] Raw data gathered from git history
- [ ] Metrics computed and summary table produced
- [ ] Time distribution and session analysis completed
- [ ] Commit type breakdown completed
- [ ] Hotspot analysis completed
- [ ] Focus score and Ship of the Week identified
- [ ] Per-contributor analysis completed (if team)
- [ ] Streak tracked
- [ ] Prior retro loaded and compared (if exists)
- [ ] JSON snapshot saved to `.context/retros/`
- [ ] Narrative written to conversation
- [ ] STATE.md updated

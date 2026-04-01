---
id: SKL-0026
name: Team Retro
description: |
  Engineering retrospective analyzing commit history, work patterns, and code
  quality metrics. Supports configurable time windows (24h, 7d, 14d, 30d) and
  comparison mode. Per-contributor analysis with praise and growth suggestions.
  Streak tracking, focus scores, and trend comparison. Use this skill when a
  retrospective is requested or at the end of a sprint/week.
version: 2.0
owner: orchestrator
triggers:
  - RETRO_REQUESTED
inputs:
  - Git commit history (origin/main)
  - TODOS.md (if exists)
  - .claude/project/retros/*.json (previous retro snapshots)
  - .claude/project/knowledge/DECISIONS.md
outputs:
  - Retro narrative (output to conversation)
  - .claude/project/retros/<date>.json (snapshot for trend tracking)
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
| **Version** | 2.0 |
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

Calculate metrics and present using the summary table, per-author leaderboard, and backlog health formats. Read `SCHEMA.md` in this skill folder for the metrics schema and report format.

---

### Step 3 — Commit Time Distribution

Show hourly commit histogram. Call out: peak hours, dead zones, late-night coding clusters. See `SCHEMA.md` for histogram format.

---

### Step 4 — Work Session Detection

Detect sessions using **45-minute gap** between consecutive commits. Classify into deep/medium/micro sessions and calculate active coding time. See `SCHEMA.md` for session classification thresholds.

---

### Step 5 — Commit Type Breakdown

Categorize by conventional commit prefix (feat/fix/refactor/test/chore/docs). Flag if fix ratio exceeds 50%. See `SCHEMA.md` for histogram format.

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

Analyze each contributor's commits, focus areas, commit type mix, session patterns, and test discipline. Give the current user the deepest treatment. For teammates, provide specific praise and one growth opportunity anchored in data. See `SCHEMA.md` for per-contributor analysis fields and formatting rules.

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
ls -t .claude/project/retros/*.json 2>/dev/null
```

**If prior retros exist:** Load the most recent and calculate deltas. See `SCHEMA.md` for trend comparison format.

**If no prior retros:** Skip comparison. Note: "First retro — run again next week to see trends."

---

### Step 13 — Save Snapshot

```bash
mkdir -p .context/retros
```

Write JSON snapshot with metrics, per-author data, and streak info. Filename: `.claude/project/retros/<YYYY-MM-DD>-<N>.json` (N = sequence number for today).

---

### Step 14 — Write the Narrative

Structure the output using the narrative report structure in `SCHEMA.md`: tweetable summary first, then 11 sections from summary table through habits for next week.

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
- Never modify source code or project files (except `.claude/project/retros/`)

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
- [ ] JSON snapshot saved to `.claude/project/retros/`
- [ ] Narrative written to conversation
- [ ] STATE.md updated

## Output Contract

| Field | Value |
|-------|-------|
| **Artifacts** | Retro narrative (output to conversation), `.claude/project/retros/<date>.json` (snapshot) |
| **State Update** | `.claude/project/STATE.md` — mark task complete, log retro window and health metrics |
| **Handoff Event** | `TASK_COMPLETED` (retrospective complete) |

# Retro Metrics Schema & Report Format

> Reference material for the Team Retro skill (SKL-0026). The procedure in SKILL.md references this file for detailed metric definitions, output formats, and report structure.

---

## Summary Table Format

Present metrics in this table structure:

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

---

## Per-Author Leaderboard Format

```
Contributor         Commits   +/-          Top area
You (name)               N   +N/-N        src/
alice                    N   +N/-N        app/services/
```

Sort by commits descending. Current user always first, labeled "You (name)".

---

## Backlog Health (if TODOS.md exists)

- Total open TODOs
- P0/P1 count (critical/urgent)
- Items completed this period

---

## Commit Time Histogram Format

```
Hour  Commits  ████████████████
 09:    5      █████
 14:    8      ████████
 22:    3      ███
```

Call out: peak hours, dead zones, late-night coding clusters.

---

## Session Classification

Detect sessions using **45-minute gap** between consecutive commits.

| Session Type | Duration |
|-------------|----------|
| **Deep sessions** | 50+ min |
| **Medium sessions** | 20-50 min |
| **Micro sessions** | <20 min, single-commit |

Calculate: total active coding time, average session length, LOC per hour of active time.

---

## Commit Type Histogram Format

Categorize by conventional commit prefix (feat/fix/refactor/test/chore/docs):

```
feat:     20  (40%)  ████████████████████
fix:      27  (54%)  ███████████████████████████
refactor:  2  ( 4%)  ██
```

Flag if fix ratio exceeds 50% — signals "ship fast, fix fast" pattern.

---

## Trend Comparison Format

When prior retros exist, show deltas in this format:

```
                    Last        Now         Delta
Test ratio:         22%    →    41%         ↑19pp
Sessions:           10     →    14          ↑4
Commits:            32     →    47          ↑47%
```

If no prior retros exist: "First retro — run again next week to see trends."

---

## Narrative Report Structure

### Tweetable Summary (first line)

```
Week of Mar 8: 47 commits, 3.2k LOC, 38% tests, peak: 10pm | Streak: 47d
```

### Sections (in order)

1. **Summary Table** (metrics table above)
2. **Trends vs Last Retro** (trend comparison, if available)
3. **Time & Session Patterns** (histogram + session analysis)
4. **Shipping Velocity** (commit types, hotspots, focus score)
5. **Code Quality Signals** (test ratio, hotspots)
6. **Focus & Highlights** (focus score + Ship of the Week)
7. **Your Week** (personal deep-dive for current user)
8. **Team Breakdown** (per-contributor analysis, if not solo)
9. **Top 3 Wins** (highest-impact things shipped)
10. **3 Things to Improve** (specific, actionable)
11. **3 Habits for Next Week** (small, practical, <5 min to adopt)

---

## Per-Contributor Analysis Fields

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

## JSON Snapshot Schema

The snapshot saved to `.claude/project/retros/<YYYY-MM-DD>-<N>.json` must include:

- All computed metrics from the summary table
- Per-author breakdown data
- Streak information
- Window parameters (start date, end date, duration)
- Commit type counts

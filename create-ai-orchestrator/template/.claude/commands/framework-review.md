# Command: /framework-review

> Analyze framework progress metrics and surface trends, improvements, and regressions.
> Reads from the global log at `~/.claude/logs/framework-progress.csv`.

---

## Arguments

- `/framework-review` — full report (all time + last 7 days)
- `/framework-review weekly` — last 7 days only, with week-over-week comparison
- `/framework-review project [name]` — filter to a single project

## Procedure

### Step 1: Read the Log

1. Check if `~/.claude/logs/framework-progress.csv` exists.
   - If not: print `No progress log found. Run /log-session after your next session to start tracking.` — then **stop**.

2. Parse all rows from the CSV. Expected columns: `date,project,duration_min,quality,iterations,bugs_rework,notes`

3. **Row validation:** Skip any row that doesn't have at least 6 comma-separated fields. Track the count of skipped rows.

4. If fewer than 2 valid entries, print:
   ```
   Not enough data yet (X entry). Log at least 2 sessions with /log-session to see trends.
   ```
   Then **stop**.

5. If any rows were skipped, note: `(X malformed rows skipped)`

### Step 2: Calculate Metrics

For the requested scope (all time, last 7 days, or single project), compute:

| Metric | Calculation |
|--------|------------|
| **Avg Quality** | Mean of quality column (1-5 scale), 1 decimal |
| **Avg Iterations** | Mean of iterations column, 1 decimal |
| **Avg Duration** | Mean of duration_min column (minutes), rounded |
| **Total Bugs** | Sum of bugs_rework column |
| **Avg Bugs/Session** | Mean of bugs_rework column, 1 decimal |
| **Sessions Logged** | Valid row count |
| **Projects Covered** | Distinct project names |

Output as:

```
## Overview ([scope])

| Metric | Value |
|--------|-------|
| Sessions | X |
| Projects | X (list) |
| Avg Quality | X.X/5 |
| Avg Iterations | X.X |
| Avg Duration | Xmin |
| Avg Bugs/Session | X.X |
| Total Bugs | X |
```

### Step 3: Trend Analysis

Compare the **last 7 days** vs the **prior 7 days**.

**Zero-division guard:** If the prior period has 0 entries, print:
```
Not enough historical data for week-over-week comparison. Keep logging!
```
Then skip to Step 4.

For each metric, calculate the delta and label it:
- **Improved** — quality up, OR iterations/bugs/duration down
- **Regressed** — quality down, OR iterations/bugs/duration up
- **Stable** — less than 10% change

```
## Trends (Last 7 Days vs Prior 7 Days)

| Metric | Current | Prior | Delta | Status |
|--------|---------|-------|-------|--------|
| Quality | 4.2 | 3.8 | +0.4 | Improved |
| Iterations | 2.1 | 3.5 | -1.4 | Improved |
| Duration | 25min | 35min | -10min | Improved |
| Bugs/Session | 0.5 | 1.2 | -0.7 | Improved |
```

### Step 4: Per-Project Breakdown

If more than one project has entries, show:

```
## By Project

| Project | Sessions | Avg Quality | Avg Iterations | Avg Bugs |
|---------|----------|-------------|----------------|----------|
| CarrierPulse | 5 | 4.0 | 2.4 | 0.6 |
| FUT-BRAIN | 3 | 3.7 | 3.0 | 1.0 |
```

If only one project, skip this section.

### Step 5: Highlights

```
## Highlights

**Biggest improvement:** [metric] — [description]
**Biggest gap:** [metric] — [description and suggestion]
**Streak:** [X] consecutive sessions with quality >= 4 (or "No active streak")
```

Determine biggest improvement and gap by comparing the latest 3 sessions against the 3 before them. The metric with the largest positive change is the improvement; the metric with the largest negative change (or smallest improvement) is the gap.

### Step 6: Weekly Summary (if `weekly` argument)

When invoked with `/framework-review weekly`, also show:

```
## Weekly Summary ([start date] to [end date])

- Sessions: [count]
- Total time: [sum duration]min
- Average quality: [avg]/5
- Total bugs: [sum]
- Week-over-week: [improved/regressed/stable] overall

**Best session:** [date] — [project] — [quality]/5, [iterations] iterations
**Worst session:** [date] — [project] — [quality]/5, [iterations] iterations
```

Best = highest quality, then fewest iterations as tiebreaker.
Worst = lowest quality, then most iterations as tiebreaker.

### Step 7: Output

Print the full report directly to the conversation. This is a **read-only** command — do not modify any files.

Keep the report scannable. Use the table formats above. Bold key numbers.

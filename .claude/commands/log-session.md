# Command: /log-session

> Log session metrics to track framework effectiveness over time.
> Lightweight - 4 quick questions, then a single row appended to the global log.

---

## Procedure

### Step 1: Pre-fill What You Can

1. **Project name:** Use the basename of the current working directory (e.g., `bashi`, `CarrierPulse`). Show the pre-filled value so the user can override.

2. **Duration:** Read `.claude/project/session-log.csv` and extract the **last row** where the date matches today. Use its `duration_min` value. If no match or file missing, leave blank and ask the user.

3. **Date:** Today's date in `YYYY-MM-DD` format.

### Step 2: Ask 4 Metrics

Ask the user in a single compact prompt. Pre-fill any values from Step 1.

```
Quick session log:

1. Output quality (1-5): ___
2. Iterations to get desired result: ___
3. Bugs or rework cycles (0 if none): ___
4. Optional notes: ___

Pre-filled: Project = [auto] | Duration = [auto]min
(Override any pre-filled value by stating it)
```

**Defaults:**
- If the user says "none" for bugs, record `0`
- If notes are empty, record empty string
- Duration: use the session tracker value unless the user overrides

### Step 3: Write the Entry

1. **Ensure the global log exists:**
   - Path: `~/.claude/logs/framework-progress.csv`
   - If the directory `~/.claude/logs/` doesn't exist, create it
   - If the CSV file doesn't exist, create it with header: `date,project,duration_min,quality,iterations,bugs_rework,notes`

2. **Sanitize notes:** If the notes field contains commas, wrap it in double quotes.

3. **Append one row** to the CSV:
   ```
   YYYY-MM-DD,[project],[duration],[quality],[iterations],[bugs],[notes]
   ```

### Step 4: Confirm

Print a one-line confirmation:

```
Logged: [Quality]/5 quality, [Iterations] iterations, [Bugs] bugs - [Project] ([Duration]min)
```

Do not print the full CSV. Do not suggest next steps unless asked.

# Command: /capture-lesson

> Capture a lesson, failure, decision, or pattern from the current session and write it to AI-Memory.

---

## When to Use

Run this command at the end of a significant session — or whenever a notable insight, mistake, or reusable pattern emerges. This feeds the cross-project learning system so future projects start smarter.

---

## Procedure

### Step 1: Identify the Lesson Type

Ask the user (or infer from context) which type of knowledge to capture:

| Type | Target Folder | Description |
|------|---------------|-------------|
| `lesson` | `lessons/` | A short insight discovered during development |
| `failure` | `failures/` | A mistake or failed approach to avoid |
| `decision` | `decisions/` | An architectural decision that proved useful |
| `pattern` | `patterns/` | A reusable workflow or system pattern worth repeating |
| `skill-improvement` | *(append to SKILL_IMPROVEMENTS.md)* | A proposed improvement to a reusable skill |

### Step 2: Gather Details

Collect the following from the user or from the current session context:

- **Title** — Short, descriptive (used as filename in kebab-case)
- **Project** — Name of the current project
- **Summary** — 1–2 sentences capturing the insight
- **Detail** — (Optional) Longer explanation if needed

### Step 3: Determine the AI-Memory Path

The default AI-Memory location is defined by the user's local setup. Look for the path in:

1. The `AI_MEMORY_PATH` environment variable (if set)
2. Fall back to: `~/Projects/AI-Memory`

> **Setup:** Set the `AI_MEMORY_PATH` environment variable to your local AI-Memory folder path. Default assumes `~/Projects/AI-Memory` — update if your path differs.

### Step 4: Write the Entry

**For lessons, failures, decisions, and patterns:**

Create a new `.md` file in the appropriate subfolder using this template:

```markdown
# <Title>

- **Date:** <YYYY-MM-DD>
- **Project:** <project name>
- **Summary:** <1-2 sentences>
- **Detail:** <optional longer explanation>
```

Filename should be kebab-case: `<title-as-kebab>.md`

**For skill improvements:**

Append a new entry to `SKILL_IMPROVEMENTS.md` using its existing IMP-XXXX format.

### Step 5: Update the Global Index

Add a row to the matching section in `GLOBAL_INDEX.md`:

```
| <Date> | <Project> | <Summary> | <subfolder/filename.md> |
```

### Step 6: Confirm

Print a summary:

```
## Lesson Captured

- **Type:** <type>
- **Title:** <title>
- **File:** <path to created file>
- **Index Updated:** GLOBAL_INDEX.md
```

---

## Error Handling

- If the AI-Memory directory does not exist at the expected path, warn the user and offer to create it.
- If `GLOBAL_INDEX.md` is missing, create it using the template from the AI-Memory README.
- Never overwrite an existing entry — append or create a new file with a unique name.

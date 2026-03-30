# Command: /learn

> Analyze the current session and extract reusable lessons, patterns, or failure records for AI-Memory.
> Unlike `/capture-lesson` (which requires you to articulate the lesson), `/learn` does the analysis for you.

---

## When to Use

Run at the end of a productive session — especially after:
- Debugging a tricky issue
- Making an architectural decision
- Discovering a useful pattern or workaround
- Encountering an unexpected failure

---

## Procedure

### Step 1: Analyze the Current Session

Review the full conversation history of this session. Look for extractable patterns:

| Pattern Type | What to Look For |
|-------------|-----------------|
| **Error resolutions** | A bug or error that was diagnosed and fixed — capture root cause and fix |
| **Debugging techniques** | A non-obvious debugging approach that worked |
| **Failed approaches** | Something tried, didn't work, and was abandoned — capture what and why |
| **Architecture decisions** | A meaningful choice about structure, tools, or design — capture rationale |
| **Integration patterns** | A way of connecting two systems/tools that worked well |
| **Workflow insights** | A process improvement or way of working that proved effective |
| **Workarounds** | A creative solution to a tool limitation or environment constraint |

**Skip these — they are not worth saving:**
- Trivial fixes (typos, simple syntax errors)
- One-time issues (specific API outages, transient failures)
- Things already documented in the codebase or CLAUDE.md

### Step 2: Draft Candidate Lessons

For each extractable pattern, draft an entry:
- **Title** — Short, descriptive (will become the filename)
- **Type** — One of: `lesson`, `failure`, `pattern`, `decision`
- **Summary** — 1–2 sentences capturing the insight
- **Detail** — Why this matters for future sessions

### Step 3: Present Findings

Print candidates in this format:

```
## Session Analysis: [N] potential lessons found

### 1. [Title]
- **Type:** [type]
- **Summary:** [summary]

### 2. [Title]
- **Type:** [type]
- **Summary:** [summary]

...

**Options:** Save all / Pick specific numbers / Skip all
```

If no extractable patterns are found:
```
No notable patterns found in this session. Use /capture-lesson to manually record something specific.
```

**Cap at 7 lessons maximum per invocation.** If more are found, present the top 7 by significance.

### Step 4: Save Confirmed Lessons

For each confirmed lesson:

1. **Determine AI-Memory path:**
   - Check `AI_MEMORY_PATH` environment variable
   - Fall back to `~/Projects/AI-Memory`
   - If the directory doesn't exist, warn and offer to create it

2. **Write the entry** to the appropriate subfolder:

| Type | Folder |
|------|--------|
| `lesson` | `lessons/` |
| `failure` | `failures/` |
| `pattern` | `patterns/` |
| `decision` | `decisions/` |

Use this template:

```markdown
# <Title>

- **Date:** <YYYY-MM-DD>
- **Project:** <current project name from IDENTITY.md or directory name>
- **Summary:** <1-2 sentences>
- **Detail:** <longer explanation>
- **Extracted by:** /learn (session analysis)
```

3. **Filename:** kebab-case of the title, e.g., `tilde-expansion-breaks-env-vars-in-settings-json.md`

4. **Update GLOBAL_INDEX.md** with a new row in the matching section

### Step 5: Confirm

Print summary:

```
## Lessons Saved

- [count] lessons written to AI-Memory
- Files created:
  - [path/to/file1.md]
  - [path/to/file2.md]
- GLOBAL_INDEX.md updated

Tip: Run /capture-lesson to manually add anything /learn missed.
```

---

## Guardrails

- Never overwrite existing AI-Memory entries — always create new files with unique names
- Never fabricate lessons that didn't actually occur in the session
- Each lesson must be traceable to a specific moment or exchange in the session
- If AI-Memory directory doesn't exist, warn and offer to create it — don't fail silently

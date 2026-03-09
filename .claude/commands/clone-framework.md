# Command: /clone-framework

> Copy the AI Builder System framework files to a target directory. Does not copy runtime files — those are created by `/setup`.

---

## Procedure

### Step 1: Determine Target Directory

The user must provide a target directory path as an argument. If not provided, ask for it.

Validate:
- The target directory exists (or its parent exists and can be created).
- If the target directory doesn't exist, create it.

### Step 2: Identify Framework Files to Copy

Copy these framework directories and their contents:

| Source | Purpose |
|--------|---------|
| `.claude/agents/` | Agent definitions |
| `.claude/commands/` | Command definitions |
| `.claude/skills/` | Skill definitions (including REGISTRY.md) |
| `.claude/rules/` | Governance rules |
| `.claude/hooks/` | Hook scripts |
| `.claude/CLAUDE.md` | Context index |
| `.claudeignore` | Ignore patterns |

### Step 3: Identify Files to SKIP

Do **not** copy these — they are runtime/project-specific and get created by `/setup`:

| Skipped | Reason |
|---------|--------|
| `.claude/project/STATE.md` | Project-specific state |
| `.claude/project/EVENTS.md` | Project-specific events |
| `.claude/project/RUN_POLICY.md` | Project-specific policy |
| `.claude/project/knowledge/` | Project-specific knowledge |
| `docs/` | Project-specific documentation |
| `PROJECT_TYPE.md` | Project-specific type |
| `.claude/settings.json` | User-specific settings |

### Step 4: Copy with No-Overwrite

For each file to copy:

1. Check if the file already exists at the target path.
2. If it **does not exist**: copy the file. Log: `Copied: <path>`
3. If it **already exists**: skip it. Log: `Skipped (exists): <path>`

This makes the command safe to run multiple times — it fills in missing files without overwriting customizations.

### Step 5: Create Target Directory Structure

Ensure these directories exist at the target (create if missing):

- `<target>/.claude/project/`
- `<target>/.claude/project/knowledge/`
- `<target>/docs/`
- `<target>/tasks/`

These empty directories prepare the target for `/setup`.

### Step 6: Print Summary

```
## Clone Summary

- **Source:** [framework root path]
- **Target:** [target directory path]
- **Copied:** [count] files
- **Skipped:** [count] files (already existed)
- **Next step:** `cd <target>` then run `/setup` to initialize the project.
```

---

## Constraints

- Never overwrite existing files at the target.
- Never copy runtime state files.
- Never copy user-specific settings.
- If the source framework root cannot be determined, stop and report the error.

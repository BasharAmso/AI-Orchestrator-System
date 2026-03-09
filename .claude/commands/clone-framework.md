# Command: /clone-framework

> Copy the AI Builder System framework files to a target directory. Supports `--upgrade` mode to update existing projects. Does not copy runtime files — those are created by `/setup`.

---

## Procedure

### Step 1: Determine Target Directory and Mode

The user must provide a target directory path as an argument. If not provided, ask for it.

**Parse flags:**
- If `--upgrade` is provided: enable upgrade mode (overwrites structural files, patches runtime files).
- If no flag: use default mode (no-overwrite — fills in missing files only).

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
| `.claude/project/EVENTS.md` | Project-specific events (patched in upgrade mode, never replaced) |
| `.claude/project/RUN_POLICY.md` | Project-specific policy (patched in upgrade mode, never replaced) |
| `.claude/project/knowledge/` | Project-specific knowledge |
| `docs/` | Project-specific documentation |
| `PROJECT_TYPE.md` | Project-specific type |
| `.claude/settings.json` | User-specific settings |

### Step 4: Copy Files

For each file from Step 2:

1. Check if the file already exists at the target path.
2. If it **does not exist**: copy the file. Log: `Copied: <path>`
3. If it **already exists AND upgrade mode**: overwrite it. Log: `Updated: <path>`
4. If it **already exists AND default mode**: skip it. Log: `Skipped (exists): <path>`

Default mode is safe to run multiple times — fills in missing files without overwriting customizations.
Upgrade mode brings all structural files up to date with the source framework.

### Step 5: Patch Runtime Files (Upgrade Mode Only)

Skip this step entirely in default mode.

In upgrade mode, apply **format updates** to runtime files without replacing their content:

#### 5a. Patch EVENTS.md

If `<target>/.claude/project/EVENTS.md` exists:

1. Read the file.
2. Check if the Event Format block already includes `<Priority>`. If not:
   - Update the format line to include `| <Priority>` at the end.
   - Add the Priority field description: `- **Priority** — Optional: \`high\`, \`normal\`, or \`low\` (default: \`normal\` if omitted)`
   - Add a `### Priority Processing Order` subsection after the field descriptions.
3. Do **NOT** clear or modify the Unprocessed Events or Processed Events sections.
4. Log: `Patched: EVENTS.md (added Priority field)`

#### 5b. Patch RUN_POLICY.md

If `<target>/.claude/project/RUN_POLICY.md` exists:

1. Read the file.
2. Check if a `## Claude Code Permissions` section exists. If not, add it before the `## Execution Rule` section (or at the end if that section doesn't exist). Content should explain the two-layer permission model and recommend "Allow for this session" for Autonomous mode.
3. Check if a `## Mode Escalation` section exists. If not, add it after the `## Cycle Limits` section. Content should suggest mode changes based on Current Phase.
4. Do **NOT** modify existing cycle limits, stop conditions, or other sections.
5. Log: `Patched: RUN_POLICY.md (added [section names])`

### Step 6: Create Target Directory Structure

Ensure these directories exist at the target (create if missing):

- `<target>/.claude/project/`
- `<target>/.claude/project/knowledge/`
- `<target>/docs/`
- `<target>/tasks/`

These empty directories prepare the target for `/setup`.

### Step 7: Print Summary

**Default mode:**
```
## Clone Summary

- **Source:** [framework root path]
- **Target:** [target directory path]
- **Copied:** [count] files
- **Skipped:** [count] files (already existed)
- **Next step:** `cd <target>` then run `/setup` to initialize the project.
```

**Upgrade mode:**
```
## Upgrade Summary

- **Source:** [framework root path]
- **Target:** [target directory path]
- **Copied:** [count] new files
- **Updated:** [count] files (overwritten with latest)
- **Patched:** [count] runtime files (format updates only)
- **Skipped:** [count] files (runtime state preserved)
```

---

## Constraints

- Never copy or replace runtime state files (STATE.md, knowledge/).
- Never copy user-specific settings.
- In default mode, never overwrite existing files at the target.
- In upgrade mode, structural files are overwritten but runtime state (event history, task history, knowledge) is preserved.
- If the source framework root cannot be determined, stop and report the error.

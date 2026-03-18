# Command: /clone-framework

> Copy the The AI Orchestrator System framework files to a target directory. Supports `--upgrade` mode to update existing projects and `--format portable` mode to export tool-agnostic files for use with non-CC tools (Cursor, Copilot, Windsurf, Aider). Does not copy runtime files — those are created by `/setup`.

---

## Procedure

### Step 1: Determine Target Directory and Mode

The user must provide a target directory path as an argument. If not provided, ask for it.

**Parse flags:**
- If `--upgrade` is provided: enable upgrade mode (overwrites structural files, patches runtime files).
- If `--format portable` is provided: enable portable export mode (exports tool-agnostic files only + generates adaptation guide). **Mutually exclusive with `--upgrade`.**
- If no flag: use default mode (no-overwrite — fills in missing files only).

Validate:
- The target directory exists (or its parent exists and can be created).
- If the target directory doesn't exist, create it.

### Step 1b: Version Check (Upgrade Mode Only)

Skip this step in default mode and portable mode.

In upgrade mode:

1. Read `FRAMEWORK_VERSION` from the **source** framework root. If missing, treat as `0.0.0`.
2. Read `FRAMEWORK_VERSION` from the **target** directory root. If missing, treat as `0.0.0`.
3. Compare versions (semver: major.minor.patch):
   - **Source > Target:** Normal upgrade. Log: `Upgrading: v[target] → v[source]`
   - **Source = Target:** Already current. Log: `Already at v[source]. Re-running upgrade to ensure file consistency.` Continue with upgrade.
   - **Source < Target:** Downgrade detected. Print warning: `"Warning: Source (v[source]) is older than target (v[target]). This would downgrade the framework. Proceed anyway?"` Wait for user confirmation before continuing.
4. After upgrade completes (Step 7), copy the source `FRAMEWORK_VERSION` file to the target root.

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
| `FRAMEWORK_VERSION` | Version stamp for upgrade tracking |

### Step 3: Identify Files to SKIP

Do **not** copy these — they are runtime/project-specific and get created by `/setup`:

| Skipped | Reason |
|---------|--------|
| `custom-skills/` | User-created skills — never overwrite, even in upgrade mode |
| `.claude/project/STATE.md` | Project-specific state |
| `.claude/project/EVENTS.md` | Project-specific events (patched in upgrade mode, never replaced) |
| `.claude/project/RUN_POLICY.md` | Project-specific policy (patched in upgrade mode, never replaced) |
| `.claude/project/knowledge/` | Project-specific knowledge |
| `docs/` | Project-specific documentation |
| `PROJECT_TYPE.md` | Project-specific type |
| `.claude/settings.json` | User-specific settings |
| `CLAUDE.md` (root) | Legacy duplicate — `.claude/CLAUDE.md` is the canonical location |

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

#### 5b. Patch STATE.md Task Table Format

If `<target>/.claude/project/STATE.md` exists:

1. Read the file.
2. Locate the `## Next Task Queue` section.
3. Check if the task table header includes a `Skill` column. If not:
   - Update the header row from `| # | Task | Priority |` to `| # | Task | Priority | Skill |`.
   - Update the separator row to include the extra column.
   - For any existing task rows, append `| — |` (dash) to indicate no skill assigned.
4. Do **NOT** clear or modify task data, completed tasks, or other sections.
5. Log: `Patched: STATE.md (added Skill column to task table)`

#### 5c. Clean Up Duplicate Root CLAUDE.md

If `<target>/CLAUDE.md` (root) exists AND `<target>/.claude/CLAUDE.md` also exists:

1. Both are loaded by Claude Code, wasting ~1.2k tokens/session.
2. `.claude/CLAUDE.md` is the canonical location — it was just updated in Step 4.
3. Check if the root `CLAUDE.md` contains project-specific identity (project name, client name, charter reference) that differs from the `.claude/CLAUDE.md` template identity.
4. If the root file has project-specific fields: merge them into `.claude/CLAUDE.md`'s Project Identity section, replacing the template values.
5. Delete the root `CLAUDE.md`.
6. Log: `Cleaned: removed duplicate root CLAUDE.md (merged project identity into .claude/CLAUDE.md)`

If only one CLAUDE.md exists (at either location): no action needed.

#### 5d. Patch RUN_POLICY.md

If `<target>/.claude/project/RUN_POLICY.md` exists:

1. Read the file.
2. Check if a `## Claude Code Permissions` section exists. If not, add it before the `## Execution Rule` section (or at the end if that section doesn't exist). Content should explain the two-layer permission model and recommend "Allow for this session" for Autonomous mode.
3. Check if a `## Mode Escalation` section exists. If not, add it after the `## Cycle Limits` section. Content should suggest mode changes based on Current Phase.
4. Do **NOT** modify existing cycle limits, stop conditions, or other sections.
5. Log: `Patched: RUN_POLICY.md (added [section names])`

### Step 5e: Legacy Artifact Cleanup (Upgrade Mode Only)

Skip this step entirely in default mode.

After copying framework files and patching runtime files, check for known legacy artifacts that are superseded by framework equivalents:

| Legacy Pattern | Framework Replacement | Action |
|---------------|----------------------|--------|
| `tasks/` directory | STATE.md Next Task Queue | Warn user, suggest deletion |
| Root `ARCHITECTURE.md` | `docs/ARCHITECTURE.md` | Warn user, suggest deletion |
| `.claude/rules-archive/` | `.claude/rules/` | Warn user, suggest deletion |
| Root `CLAUDE.md` | `.claude/CLAUDE.md` | Already handled in Step 5b |

For each legacy artifact found:
1. Log: `Legacy artifact found: <path> — superseded by <replacement>`
2. Do **NOT** auto-delete. Print a warning and let the user decide.

Add the count to the upgrade summary as `**Legacy warnings:** [count] artifacts found (review recommended)`.

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
- **Cleaned:** [count] duplicate files removed (if any)
- **Skipped:** [count] files (runtime state preserved)
```

### Step 8: Portable Export Mode (if `--format portable`)

Skip Steps 2–7 entirely. This mode exports only the **tool-agnostic** parts of the framework — the markdown primitives that work with any AI coding tool (Cursor, Copilot, Windsurf, Aider, etc.).

#### 8a. Identify Portable Files

Copy these files to the target:

| Source | Purpose |
|--------|---------|
| `.claude/agents/*.md` | Agent role definitions (universal) |
| `.claude/skills/*/SKILL.md` | Skill procedures (universal) |
| `.claude/skills/REGISTRY.md` | Skill index and trigger map |
| `.claude/rules/orchestration-routing.md` | Task-to-agent routing table |
| `.claude/rules/event-hooks.md` | Event-to-agent routing table |
| `.claude/rules/knowledge-policy.md` | Knowledge base read/write rules |
| `.claude/rules/context-policy.md` | Context conservation rules |

#### 8b. Identify Files to EXCLUDE

Do **not** copy these — they are Claude Code-specific and would not work in other tools:

| Excluded | Reason |
|----------|--------|
| `.claude/hooks/` | CC-specific hook JSON format and shell execution model |
| `.claude/settings.json` | CC permission model (`permissions.allow`, `permissions.deny`) |
| `.claude/commands/` | CC `/command` system (markdown-as-commands) |
| `.claude/CLAUDE.md` | CC auto-loading convention |
| `.claudeignore` | CC-specific ignore format |
| `.claude/project/` | Runtime state — created per-project |

#### 8c. Create State Templates

Write blank templates (not actual project state) to the target:

1. **`templates/STATE.md`** — Copy the structure from the source STATE.md but clear all task data, set phase to "Not Started", clear completed/queued tables. Add a comment at top: `<!-- Copy this file to your project's state tracking location -->`
2. **`templates/EVENTS.md`** — Copy the structure from the source EVENTS.md but clear all events. Add a comment at top: `<!-- Copy this file to your project's event queue location -->`
3. **`templates/knowledge/`** — Create empty template files for DECISIONS.md, RESEARCH.md, GLOSSARY.md, OPEN_QUESTIONS.md with just the entry templates from each. Also copy TASK-FORMAT.md and TODOS-FORMAT.md as-is (these are convention files, not project data).

#### 8d. Generate ADAPTATION_GUIDE.md

Write an `ADAPTATION_GUIDE.md` file at the target root with this structure:

```markdown
# The AI Orchestrator System — Portable Export

## What This Is

This is a portable export of the The AI Orchestrator System framework. It contains the
tool-agnostic primitives (agents, skills, rules, state templates) without the
Claude Code-specific wiring (hooks, settings, commands).

## How the Framework Works

The framework has 5 core concepts:

1. **Agents** (`agents/`) — Specialized roles (builder, reviewer, coach, etc.)
   that define WHO does the work and HOW they approach it.
2. **Skills** (`skills/`) — Step-by-step procedures for specific tasks
   (code review, PRD writing, deployment, etc.) that define WHAT gets done.
3. **Rules** (`rules/`) — Routing tables and policies that define WHEN each
   agent or skill is activated.
4. **State** (`templates/STATE.md`) — Single source of truth for current task,
   progress, and blockers.
5. **Events** (`templates/EVENTS.md`) — Queue of things that happened or need
   to happen, processed oldest-first.

## Setting Up in Your Tool

### Cursor / Windsurf / Copilot
- Place agent files in your tool's system prompt or rules directory
- Reference skill procedures in your custom instructions
- Copy state templates to your project root
- Use your tool's file-watching or hook system for event processing

### Aider
- Add agent definitions to `.aider.conf.yml` or pass via `--system-prompt`
- Reference skill files with `--read` flag when running specific tasks
- State and events are plain markdown — edit directly or via scripts

### Generic (any AI tool)
- Paste relevant agent + skill content into your system prompt
- Keep STATE.md and EVENTS.md as plain files you update between sessions
- The rules files describe routing logic your tool can follow

## What's Missing (and Why)

| Missing | Why | What to Do Instead |
|---------|-----|-------------------|
| Hook scripts | CC-specific shell execution model | Use your tool's native hook/trigger system |
| settings.json | CC permission model | Configure permissions in your tool's settings |
| /commands | CC slash-command system | Create equivalent commands in your tool |
| CLAUDE.md | CC auto-loading | Add to your tool's auto-loaded context |
| .claudeignore | CC-specific | Use your tool's ignore/exclude mechanism |

## File Inventory

[Auto-generated list of all exported files with one-line descriptions]
```

Replace `[Auto-generated list...]` with an actual inventory of every file copied, with a one-line description of each.

#### 8e. Print Portable Export Summary

```
## Portable Export Summary

- **Source:** [framework root path]
- **Target:** [target directory path]
- **Agents:** [count] agent definitions
- **Skills:** [count] skill procedures
- **Rules:** [count] governance files
- **Templates:** STATE.md, EVENTS.md, knowledge files
- **Guide:** ADAPTATION_GUIDE.md generated
- **Note:** This export contains tool-agnostic files only.
  Hook scripts, settings, and commands are CC-specific and were excluded.
  See ADAPTATION_GUIDE.md for setup instructions for your AI tool.
```

---

## Constraints

- Never copy or replace runtime state files (STATE.md, knowledge/).
- Never copy user-specific settings.
- In default mode, never overwrite existing files at the target.
- In upgrade mode, structural files are overwritten but runtime state (event history, task history, knowledge) is preserved.
- In portable mode, never copy CC-specific files (hooks, settings, commands, CLAUDE.md, .claudeignore). Only export tool-agnostic markdown primitives.
- `--format portable` and `--upgrade` are mutually exclusive. If both are provided, report the error and stop.
- If the source framework root cannot be determined, stop and report the error.

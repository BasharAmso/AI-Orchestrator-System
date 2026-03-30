# Custom Skills Guide

> How to create your own skills for Bashi. Custom skills extend the framework with project-specific workflows that survive framework upgrades.

---

## Where Custom Skills Live

| Directory | Owner | Survives Upgrade? |
|-----------|-------|-------------------|
| `.claude/skills/` | Framework (built-in) | No — overwritten by `/clone-framework --upgrade` |
| `custom-skills/` | You | Yes — never touched by upgrades |

Always put your own skills in `custom-skills/`. The system scans both directories when you run `/fix-registry`. If a custom skill defines the same trigger as a built in skill, the custom skill takes priority (see [Overriding Built-in Skills](#overriding-built-in-skills) below).

---

## Creating a Custom Skill

### Step 1: Create the Folder

Create a subfolder in `custom-skills/` with a descriptive name:

```
custom-skills/
  my-skill-name/
    SKILL.md
```

The folder name should be lowercase, hyphenated, and describe what the skill does (e.g., `generate-changelog`, `email-digest`, `sync-to-notion`).

### Step 2: Write the SKILL.md File

Every skill needs a `SKILL.md` file with two parts: a **frontmatter header** and a **procedure body**.

Here is the complete template:

```markdown
---
id: CUSTOM-0001
name: My Custom Skill
version: 1.0
owner: Orchestrator
triggers:
  - MY_CUSTOM_EVENT
inputs:
  - Description of what this skill needs to run
outputs:
  - Description of what this skill produces
tags:
  - category-tag
---

# Skill: My Custom Skill

## Metadata

| Field | Value |
|-------|-------|
| **Skill ID** | CUSTOM-0001 |
| **Version** | 1.0 |
| **Owner** | Orchestrator |
| **Inputs** | Description of what this skill needs |
| **Outputs** | Description of what this skill produces |
| **Triggers** | `MY_CUSTOM_EVENT` |

## Definition of Done

- [ ] Condition 1 that must be true when this skill finishes
- [ ] Condition 2

## Procedure

### Step 1: [First Step Name]

Describe what the AI agent should do in this step. Be specific — the agent follows these instructions literally.

### Step 2: [Second Step Name]

Continue with the next step. Include:
- What files to read or create
- What decisions to make
- What output to produce

### Step 3: [Final Step Name]

Describe the final step, including any state updates or events to emit.
```

### Step 3: Register Your Skill

Run `/fix-registry`. The system will scan `custom-skills/` and add your skill to the registry.

```
/fix-registry
```

You should see your skill listed in the summary under "Custom Skills."

### Step 4: Trigger Your Skill

You can trigger your skill in two ways:

1. **Emit an event** that matches your skill's trigger:
   ```
   /trigger MY_CUSTOM_EVENT "Description of what needs to happen"
   ```

2. **Queue a task** whose description matches your skill's trigger keyword. The orchestrator will route it automatically.

---

## Skill ID Conventions

| Prefix | Range | Used For |
|--------|-------|----------|
| `SKL-` | 0001–9999 | Built-in framework skills |
| `CUSTOM-` | 0001–9999 | Your custom skills |

Use the `CUSTOM-` prefix to avoid ID collisions with built-in skills.

---

## Overriding Built-in Skills

If your custom skill defines the same trigger as a built-in skill, **your custom skill takes priority**. This lets you replace framework behavior without modifying built-in files.

For example, if you create a custom skill with trigger `IDEA_CAPTURED`, it will run instead of the built-in `Plan From Idea` skill (SKL-0001).

The `/fix-registry` command will log a note when it detects a trigger override.

---

## Versioning

Update the `version` field in your skill's frontmatter when you make changes:

| Change Type | Version Bump | Example |
|-------------|-------------|---------|
| Bug fix or wording tweak | Patch (1.0 → 1.1) | Fixed a typo in Step 2 |
| New step or changed behavior | Minor (1.0 → 2.0) | Added a review gate |
| Complete rewrite | Major (1.0 → 2.0) | Redesigned the entire procedure |

The registry shows the current version of each skill, making it easy to track changes.

---

## Tips

- **Keep skills focused.** One skill should do one thing well. If your skill has more than 5 steps, consider splitting it.
- **Define clear triggers.** Use uppercase event names like `WEEKLY_REPORT_GENERATED` or `DATA_IMPORT_COMPLETE`.
- **Include a Definition of Done.** This tells the system (and you) when the skill has finished successfully.
- **Test with Safe mode.** Run `/set-mode safe` before `/run-project` to preview what your skill would do without executing it.
- **Check the built-in skills** in `.claude/skills/` for examples of well-structured procedures.

---

## Example: A Simple Custom Skill

Here's a real-world example — a skill that generates a weekly status report:

```markdown
---
id: CUSTOM-0001
name: Weekly Status Report
version: 1.0
owner: Orchestrator
triggers:
  - WEEKLY_REPORT_REQUESTED
inputs:
  - .claude/project/STATE.md (completed tasks log)
  - .claude/project/EVENTS.md (processed events)
outputs:
  - docs/weekly-reports/YYYY-MM-DD.md
tags:
  - reporting
  - status
---

# Skill: Weekly Status Report

## Metadata

| Field | Value |
|-------|-------|
| **Skill ID** | CUSTOM-0001 |
| **Version** | 1.0 |
| **Owner** | Orchestrator |
| **Inputs** | STATE.md (completed tasks), EVENTS.md (processed events) |
| **Outputs** | Weekly report markdown file |
| **Triggers** | `WEEKLY_REPORT_REQUESTED` |

## Definition of Done

- [ ] Report file created in docs/weekly-reports/
- [ ] Report includes tasks completed this week
- [ ] Report includes events processed this week
- [ ] Report includes current phase and progress percentage

## Procedure

### Step 1: Gather Data

Read `.claude/project/STATE.md` and extract:
- All entries in Completed Tasks Log from the past 7 days
- Current Phase and progress percentage
- Any active blockers

Read `.claude/project/EVENTS.md` and extract:
- All entries in Processed Events from the past 7 days

### Step 2: Generate Report

Create `docs/weekly-reports/YYYY-MM-DD.md` with:
- Summary of completed tasks
- Events processed
- Current project status
- Blockers or risks (if any)

### Step 3: Update State

Log the report generation in the execution summary.
```

To use this skill:
1. Save it as `custom-skills/weekly-status-report/SKILL.md`
2. Run `/fix-registry`
3. Run `/trigger WEEKLY_REPORT_REQUESTED "Generate this week's status report"`
4. Run `/run-project`

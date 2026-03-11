# Command: /fix-registry

> Rebuild the internal skill index so the system can find all available workflows.
> *(Replaces `/refresh-skills`.)*

---

## Source Paths

Skills are loaded from two directories:

| Directory | Purpose | Managed By |
|-----------|---------|------------|
| `.claude/skills/` | Built-in framework skills | Framework (overwritten on upgrade) |
| `custom-skills/` | User-created project-specific skills | You (never overwritten) |

When deployed into a project, `.claude/skills/` contains the master skill definitions shipped with the framework. `custom-skills/` is where you add your own skills — they are safe from framework upgrades.

> **Framework source (default):** `${AI_BUILDER_SYSTEM_PATH:-~/Projects/AI-Builder-System}/.claude/skills/`
> **Setup:** Set the `AI_BUILDER_SYSTEM_PATH` environment variable to your local clone of the framework. Default assumes `~/Projects/AI-Builder-System` — update if your path differs.

---

## Procedure

### Step 1: Scan Skill Files

Find all `SKILL.md` files in both directories:
1. `.claude/skills/*/SKILL.md` — built-in skills (excluding `REGISTRY.md`)
2. `custom-skills/*/SKILL.md` — user-created skills (if the directory exists)

### Step 2: Extract Metadata

For each skill file, extract from the Metadata table:
- **Skill ID** (e.g., SKL-0001)
- **Name** (from the `# Skill: <Name>` heading)
- **Version**
- **Owner**
- **Triggers** (one or more event types)

If any required field is missing, log a warning:
```
Warning: [filename] is missing field: [field name]
```

### Step 3: Rebuild REGISTRY.md

Regenerate `.claude/skills/REGISTRY.md` with:

1. **Skills Index table** — One row per skill with ID, Name, Version, File, Owner, Source (built-in or custom).
2. **Trigger Lookup table** — One row per trigger mapping to its Skill ID and file.
3. **Stats section** — Total skill count (built-in + custom), current date.

If no skill files are found, use `(none)` placeholders in both tables.

### Step 4: Print Summary

```
## Registry Rebuilt

- **Built-in Skills:** [count]
- **Custom Skills:** [count]
- **Total Skills:** [count]
- **Triggers Mapped:** [count]
- **Warnings:** [count] (list any missing fields)
- **Conflicts:** [count] (list any trigger conflicts between built-in and custom skills)
- **Registry Updated:** .claude/skills/REGISTRY.md
```

### Trigger Conflict Resolution

If a custom skill defines the same trigger as a built-in skill, the **custom skill wins**. This lets you override framework behavior without modifying built-in files. Log a note: `"Custom skill [ID] overrides built-in trigger [TRIGGER] from [built-in ID]."`

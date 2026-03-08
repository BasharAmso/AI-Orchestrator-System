# Command: /refresh-skills

> Scan all skill files and rebuild the REGISTRY.md index.

---

## Source Path

The canonical skill source directory is:

```
<AI-Builder-System-root>/.claude/skills/
```

When deployed into a project, this is the directory that contains the master skill definitions. If you need to sync skills from the framework into a project, copy from this source path.

> **Framework source (default):** `${AI_BUILDER_SYSTEM_PATH:-~/Projects/AI-Builder-System}/.claude/skills/`
> **Setup:** Set the `AI_BUILDER_SYSTEM_PATH` environment variable to your local clone of the framework. Default assumes `~/Projects/AI-Builder-System` — update if your path differs.

---

## Procedure

### Step 1: Scan Skill Files

Find all `.md` files in `.claude/skills/` **excluding** `REGISTRY.md`.

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

1. **Skills Index table** — One row per skill with ID, Name, Version, File, Owner.
2. **Trigger Lookup table** — One row per trigger mapping to its Skill ID and file.
3. **Stats section** — Total skill count and current date.

If no skill files are found, use `(none)` placeholders in both tables.

### Step 4: Print Summary

```
## Skills Refresh Complete

- **Skills Found:** [count]
- **Triggers Mapped:** [count]
- **Warnings:** [count] (list any missing fields)
- **Registry Updated:** .claude/skills/REGISTRY.md
```

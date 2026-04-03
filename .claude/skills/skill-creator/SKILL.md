---
id: SKL-0040
name: Skill Creator
description: |
  Turn a repetitive workflow into a reusable custom skill. Interviews the user,
  then produces a complete SKILL.md with frontmatter, procedure, constraints,
  definition of done, and output contract in custom-skills/. Use this skill
  when you find yourself repeating the same process and want to automate it.
version: 1.0
owner: orchestrator
triggers:
  - SKILL_CREATION_REQUESTED
inputs:
  - User description of the workflow to capture
  - .claude/skills/REGISTRY.md (to avoid duplicate triggers)
  - Existing custom-skills/ (to avoid name collisions)
outputs:
  - custom-skills/[skill-name]/SKILL.md (new skill file)
  - .claude/project/STATE.md (updated)
tags:
  - meta
  - skills
  - automation
  - workflow
---

# Skill: Skill Creator

## Metadata

| Field | Value |
|-------|-------|
| **ID** | SKL-0040 |
| **Owner** | orchestrator |
| **Version** | 1.0 |
| **Triggers** | `SKILL_CREATION_REQUESTED` |

## Purpose

Most people have repetitive workflows they keep prompting manually. This skill turns those into reusable, agent-callable procedures. The user describes what they keep doing, and this skill generates a properly structured SKILL.md that follows all Bashi standards.

---

## Procedure

### Step 1 — Interview the User

Ask the user these 4 questions. **Do NOT proceed until all are answered.** This is a user interview, not inference.

1. **What do you keep doing?** Describe the repetitive workflow in plain language.
2. **What triggers it?** When do you typically need this? What phrase would you say to start it?
3. **What does good output look like?** What artifact does it produce? Where does it go? What format?
4. **What are the gotchas?** Edge cases, things that go wrong, things to always or never do.

### Step 2 — Check for Conflicts

Read `.claude/skills/REGISTRY.md` and scan `custom-skills/` directories.

Check for:
- Existing skills that already cover this workflow (by trigger name or description similarity)
- Name collisions in `custom-skills/`

If a conflict exists:
- Present the conflicting skill to the user (name, ID, description)
- Ask: "This looks similar to [existing skill]. Do you want to proceed anyway, merge with the existing skill, or cancel?"
- **Wait for the user's answer before proceeding.**

### Step 3 — Generate Skill Identity

- Find the highest `SKL-XXXX` ID in REGISTRY.md
- Assign the next sequential ID
- Generate a trigger name from the workflow: `UPPER_SNAKE_CASE_REQUESTED` (e.g., `WEEKLY_REPORT_GENERATION_REQUESTED`)
- Generate a folder name: `lower-kebab-case` (e.g., `weekly-report-generation`)
- Present to user: "I'd assign this skill ID **SKL-XXXX**, trigger **TRIGGER_NAME**, folder **folder-name**. Does that look right?"
- **Wait for confirmation.**

### Step 4 — Determine the Owner Agent

Based on the workflow type, suggest an owner agent:

| Workflow type | Suggested owner |
|--------------|----------------|
| Planning, scoping, product decisions | `product-manager` |
| Building, coding, creating | `builder` |
| Reviewing, auditing, testing | `reviewer` |
| Fixing, debugging, refactoring | `fixer` |
| Deploying, shipping, CI/CD | `deployer` |
| Documenting, writing | `documenter` |
| Designing, UX, wireframes | `designer` |
| Research, exploration | `explorer` |
| Everything else or multi-domain | `orchestrator` |

Present the suggestion. Let the user override.

### Step 5 — Write SKILL.md

Generate `custom-skills/[folder-name]/SKILL.md` with all required sections:

**YAML Frontmatter (9 required fields):**
- `id`: from Step 3
- `name`: human-readable name
- `description`: multiline YAML pipe (`|`), must include "Use this skill when" trigger phrase, must name the output artifact
- `version`: `1.0`
- `owner`: from Step 4
- `triggers`: from Step 3
- `inputs`: derived from the workflow (what does it need to start?)
- `outputs`: derived from "what does good output look like?"
- `tags`: 3-5 relevant tags

**Body sections (all required):**

1. `# Skill: [Name]`
2. `## Metadata` — table with Field/Value pairs
3. `## Purpose` — one paragraph from question 1
4. `## Procedure` — numbered steps derived from the workflow. Include reasoning, not just steps. Embed edge cases from question 4 explicitly. Do not assume Claude will handle edge cases with common sense.
5. `## Constraints` — boundaries, what the skill should never do
6. `## Primary Agent` — the owner agent name
7. `## Definition of Done` — at least 3 checkbox items derived from question 3
8. `## Output Contract` — table with Artifacts, State Update, Handoff Event (default `TASK_COMPLETED`)

**Quality rules:**
- Keep the skill under 150 lines
- Description must name the output artifact explicitly
- Procedure should have reasoning frameworks, not just linear steps
- Edge cases must be written out, not assumed

### Step 6 — Present for Review

Show the user the complete SKILL.md content **before writing the file**.

Ask:
- "Does this capture your workflow correctly?"
- "Anything to add or change?"

**Do NOT write the file until the user approves.** If they request changes, revise and present again.

### Step 7 — Write and Register

After user approval:
1. Write the file to `custom-skills/[folder-name]/SKILL.md`
2. Tell the user: "Skill created. Run `/fix-registry` to add it to the Skills Registry."

### Step 8 — Update STATE.md

---

## Constraints

- New skills are **always** created in `custom-skills/`, never in `.claude/skills/` (those are framework-managed and would be overwritten on upgrade)
- The user **must** approve the skill before it is written (user consent rule)
- Do not create skills that duplicate existing built-in skills — flag the conflict
- Generated skills must follow all Bashi standards (9 frontmatter fields, required body sections, output contract)
- Do not generate skills over 150 lines — if the workflow is complex, suggest splitting into multiple skills or using companion files
- Do not auto-assign the skill ID without presenting it to the user first

---

## Primary Agent

orchestrator

---

## Definition of Done

- [ ] User interview completed (all 4 questions answered)
- [ ] No unresolved conflicts with existing skills
- [ ] Skill ID, trigger, and folder name confirmed by user
- [ ] SKILL.md generated with all 8 required sections
- [ ] User reviewed and approved the generated skill
- [ ] File written to `custom-skills/[name]/SKILL.md`
- [ ] User reminded to run `/fix-registry`
- [ ] STATE.md updated

## Output Contract

| Field | Value |
|-------|-------|
| **Artifacts** | `custom-skills/[skill-name]/SKILL.md` (new skill file) |
| **State Update** | `.claude/project/STATE.md` — mark task complete, log new skill created |
| **Handoff Event** | `TASK_COMPLETED` (skill created, user should run /fix-registry) |

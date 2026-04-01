# Command: /test-skill

> Validate skill files for structural completeness, quality signals, and registry consistency.
> Run this after adding or modifying skills to catch issues before they affect dispatch.
> Read-only — never modifies files.

---

## Usage

- `/test-skill` — test all skills (built-in + custom)
- `/test-skill backend-dev` — test a single skill by folder name

---

## Procedure

### Step 1: Announce

Print:
```
## Skill Test Suite
Running skill validation...
```

### Step 2: Discover Skills

Scan both skill directories for `SKILL.md` files:
- `.claude/skills/*/SKILL.md` (built-in)
- `custom-skills/*/SKILL.md` (custom)

If a skill name argument was provided, filter to only that skill.

Read `REGISTRY.md` at `.claude/skills/REGISTRY.md` for cross-reference checks.

### Step 3: Run Tests (per skill)

For each discovered skill, run all 10 tests:

#### T1. YAML Frontmatter Complete

Read the YAML frontmatter block (between `---` delimiters). Check that all 9 required fields are present:
- `id`, `name`, `description`, `version`, `owner`, `triggers`, `inputs`, `outputs`, `tags`

Result: `PASS` if all 9 present. `FAIL (missing: X, Y)` listing absent fields.

#### T2. Description Not Empty

Verify the `description` field exists and contains non-whitespace content.

Result: `PASS` if non-empty description. `FAIL` if missing or empty.

#### T3. Required Body Sections

Check that the skill body (after frontmatter) contains these section headers:
- A metadata table (look for `| Field | Value |` or `## Metadata`)
- `## Procedure` or numbered steps (`### Step`)
- `## Constraints`
- `## Definition of Done`

Result: `PASS` if all found. `FAIL (missing: X)` listing absent sections.

#### T4. Output Contract Present

Check for `## Output Contract` section containing at minimum:
- An `**Artifacts**` row
- A `**Handoff Event**` row

Result: `WARN` if missing (25 skills are pending retrofit). `PASS` if present with required rows.

#### T5. Line Count Check

Count total lines in the SKILL.md file.

Result: `PASS` if ≤ 200 lines. `WARN ([N] lines)` if over 200.

#### T6. REGISTRY Match

Extract the `id` field from YAML frontmatter (e.g., `SKL-0006`). Search REGISTRY.md for that ID.

Result: `PASS` if ID found in REGISTRY. `FAIL (SKL-XXXX not in REGISTRY)` if missing.

#### T7. Description Has Trigger Phrase

Check that the description contains activation language: "Use this skill when", "Use this skill before", "Use this skill after", or similar.

Result: `PASS` if trigger phrase found. `WARN` if missing (skill may undertrigger).

#### T8. Description Names Artifact

Check that the description mentions at least one output artifact — look for words like "produces", "generates", "creates", "writes", or file paths/extensions.

Result: `PASS` if artifact named. `WARN` if no output artifact mentioned.

#### T9. Definition of Done Has Checkboxes

Count `- [ ]` items in the Definition of Done section.

Result: `PASS` if 2 or more checkboxes. `WARN` if fewer than 2.

#### T10. Agent File Exists

Extract the `owner` field from YAML frontmatter. Verify the agent file exists at `.claude/agents/{owner}.md`.

Result: `PASS` if agent file found. `FAIL ({owner}.md not found)` if missing.

### Step 4: Print Results

For each skill tested, print a results table:

```
### [Skill Name] (SKL-XXXX) — [folder-name]

| # | Test | Status | Notes |
|---|------|--------|-------|
| T1 | Frontmatter complete | [PASS/FAIL] | |
| T2 | Description not empty | [PASS/FAIL] | |
| T3 | Required body sections | [PASS/FAIL] | |
| T4 | Output Contract present | [PASS/WARN] | |
| T5 | Line count | [PASS/WARN] | [N lines] |
| T6 | REGISTRY match | [PASS/FAIL] | |
| T7 | Description has trigger phrase | [PASS/WARN] | |
| T8 | Description names artifact | [PASS/WARN] | |
| T9 | Definition of Done checkboxes | [PASS/WARN] | |
| T10 | Agent file exists | [PASS/FAIL] | |
```

### Step 5: Print Summary

```
## Skill Test Summary

- **Skills tested:** [N]
- **Pass:** [N] | **Warn:** [N] | **Fail:** [N]

**Result: [X/Y skills fully passing]** — [All clear / X issues need attention]
```

A skill "fully passes" if it has zero FAILs (WARNs are acceptable).

### Step 6: Issues (if any failures)

If any tests produced FAIL results, add:

```
### Issues

| Skill | Test | Fix |
|-------|------|-----|
| [skill] | T1: Frontmatter | Add missing fields to YAML frontmatter |
| [skill] | T6: REGISTRY | Run `/fix-registry` to rebuild |
| [skill] | T10: Agent | Create `.claude/agents/{owner}.md` |
```

---

## Constraints

- This command is **read-only** — it never modifies any files.
- All tests should complete in under 30 seconds.
- T4 (Output Contract) and T5 (Line Count) produce `WARN`, not `FAIL` — these are quality signals, not blockers.
- T7, T8, T9 also produce `WARN` — they flag quality gaps but don't indicate broken skills.
- When testing all skills, group results: built-in skills first, then custom skills.
- Run from the framework root directory (where `.claude/` lives).

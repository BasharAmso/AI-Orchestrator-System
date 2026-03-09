# Command: /init-project

> **Deprecated:** Use `/setup` instead, which combines `/bootstrap` and `/init-project` into a single command.

> Initialize a new project from the AI Builder System template. Safe to run multiple times (fully idempotent).

---

## Procedure

### Step 1: Determine Project Type

**Precedence order:**

1. If `PROJECT_TYPE.md` exists in the repo root, read the `Project Type: <value>` line. Use that value.
2. If `PROJECT_TYPE.md` does not exist, ask the user to choose:
   - **Book**
   - **Web App**
   - **Mobile App**

Once determined, create `PROJECT_TYPE.md` **only if it does not already exist** (never overwrite):

```
# Project Type

- **Project Type:** [Book | Web App | Mobile App]
- **Initialized:** YYYY-MM-DD
```

### Step 2: Create Folders (Idempotent)

Create each directory only if it does not already exist. Never delete or modify existing directories.

**Shared (all project types):**

- `docs/`
- `.claude/project/`
- `.claude/project/knowledge/`

**Book:**

- `manuscript/`
- `diagrams/`
- `export/`

**Web App:**

- `src/`
- `public/`
- `tests/`

**Mobile App:**

- `lib/`
- `test/`
- `android/`
- `ios/`

### Step 3: Create Starter Files (Only If Missing)

Create each file **only if it does not already exist**. Never overwrite an existing file.

**Shared (all project types):**

- `docs/PRD.md`
  ```
  # Product Requirements Document

  ## Overview

  *(Describe what you are building, who it is for, and why it matters.)*
  ```

- `docs/ARCHITECTURE.md`
  ```
  # Architecture

  ## Overview

  *(Describe the high-level structure, tech stack, and key design decisions.)*
  ```

- `docs/RELEASE_NOTES.md`
  ```
  # Release Notes

  ## v0.1.0 — Project Initialized

  - Project initialized with AI Builder System template.
  - Initial directory structure created.
  ```

**Book only:**

- `manuscript/preface.md`
  ```
  # Preface

  *(Write your preface here.)*
  ```

- `manuscript/WRITING_PLAYBOOK.md`
  ```
  # Writing Playbook

  This playbook guides the writing process for this book project.
  For product requirements and architecture details, see the docs/ directory.
  ```

- `diagrams/README.md`
  ```
  # Diagrams

  Store visual diagrams here (Mermaid source files, exported images, etc.).
  These support the manuscript and can be referenced from chapter files.
  ```

- `export/README.md`
  ```
  # Export

  Store exported artifacts here (PDF builds, EPUB files, print-ready output).
  These are generated from the manuscript/ source files.
  ```

### Step 4: Log Decision (Append-Only)

In `.claude/project/knowledge/DECISIONS.md`, check whether a decision entry already exists containing the text `"Project type set to <type>"`.

- **If it already exists:** skip. Print: `"Decision already logged; skipping."`
- **If it does not exist:** append a new entry using the next available `DEC-XXXX` ID:

```
---

### DEC-XXXX: Project Type Selection

- **Status:** Accepted
- **Date:** YYYY-MM-DD
- **Context:** The project needed a type designation to determine directory structure and starter files.
- **Decision:** Project type set to [Book | Web App | Mobile App].
- **Consequences:** Type-specific folders and starter files have been created. Future skills and agents can use PROJECT_TYPE.md to adapt behavior.
```

### Step 5: Seed Next Task Queue (Strict Idempotency)

Read `.claude/project/STATE.md` and locate the `## Next Task Queue` section.

**If the queue already contains real tasks**, do NOT modify the queue.
Print: `"Next Task Queue already populated; skipping seeding."`

A queue is considered **empty/placeholder-only** (and therefore eligible for seeding) if it matches ANY of these patterns:
- Contains only `(none)` or `*(none)*`
- Contains only `- (none)`
- Contains only the table headers (`| # | Task | Priority |` and `|---|------|----------|`) with no data rows beneath them
- The section is completely empty (no content between `## Next Task Queue` and the next `---` or `##`)

**If the queue is empty or placeholder-only**, replace it with 3 starter tasks based on project type:

**Book:**

| # | Task | Priority |
|---|------|----------|
| 1 | Draft Preface v1 | High |
| 2 | Outline Chapter 1 | High |
| 3 | Draft Chapter 1 | Medium |

**Web App:**

| # | Task | Priority |
|---|------|----------|
| 1 | Draft PRD v1 | High |
| 2 | Draft Architecture v1 | High |
| 3 | Create initial app scaffold | Medium |

**Mobile App:**

| # | Task | Priority |
|---|------|----------|
| 1 | Draft PRD v1 | High |
| 2 | Draft Architecture v1 | High |
| 3 | Create initial app scaffold | Medium |

### Step 6: Skills Registry Self-Heal

Check `.claude/skills/REGISTRY.md`:

**Rebuild REGISTRY.md if ANY of these conditions are true:**

1. `REGISTRY.md` does not exist.
2. `REGISTRY.md` is empty (zero bytes).
3. `REGISTRY.md` contains `(none)` placeholders in the Skills Index or Trigger Lookup tables.
4. Any subfolder in `.claude/skills/` containing a `SKILL.md` file is **not listed** in the Skills Index table of `REGISTRY.md` (folder-based staleness check — do not rely on timestamps).

**Rebuild procedure:**
1. Scan all subfolders in `.claude/skills/` for `SKILL.md` files (excluding `REGISTRY.md`).
2. Extract metadata from each skill file: Skill ID, Name, Version, Owner, Triggers.
3. Regenerate `REGISTRY.md` with the Skills Index table, Trigger Lookup table, and Stats section.
4. If no skill files are found, write `(none)` placeholders.
5. Registry status = `refreshed`

**If none of those conditions are true:** the registry is current. Registry status = `already current`

**Idempotency guarantee:** This step only writes to `REGISTRY.md`. It never modifies or deletes any skill `SKILL.md` file.

### Step 7: Emit PROJECT_INITIALIZED Event (Idempotent)

Check `.claude/project/EVENTS.md` under `## Unprocessed Events`.

**Canonical event format** (must match the format defined in `.claude/project/EVENTS.md`):

```
EVT-XXXX | PROJECT_INITIALIZED | Project initialized as <type> | system | YYYY-MM-DD HH:MM
```

- **If the most recent unprocessed event already matches** `PROJECT_INITIALIZED` with the same project type (compare the `PROJECT_INITIALIZED` type and the `initialized as <type>` description): skip emitting. Print: `"PROJECT_INITIALIZED event already pending; skipping."`
- **Otherwise:** append the canonical event line under `## Unprocessed Events`.
- Auto-increment the EVT ID from the highest existing ID across both Unprocessed and Processed sections.
- If the section currently shows `*(none)*`, replace the placeholder with the new event.

### Step 8: Print "Init Complete" Summary

```
## Init Complete

- **Project Type:** [Book | Web App | Mobile App]
- **Folders Ensured:** [list of folders created or already present]
- **Files Created:** [list of new files, or "none"]
- **Decision Logged:** [yes | already exists]
- **Tasks Queued:** [seeded (3) | skipped (already populated)]
- **Skills Registry:** [refreshed | already current]
- **Event Emitted:** [yes | skipped (already pending)]

### Next Task Queue

| # | Task | Priority |
|---|------|----------|
| 1 | ... | ... |
| 2 | ... | ... |
| 3 | ... | ... |
```

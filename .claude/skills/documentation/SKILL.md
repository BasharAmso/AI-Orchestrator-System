---
id: SKL-0024
name: Documentation
version: 1.0
owner: documenter
triggers:
  - DOCS_REQUESTED
  - FEATURE_SHIPPED
inputs:
  - Task description (from active task or event)
  - .claude/project/STATE.md
  - .claude/project/knowledge/DECISIONS.md
  - Existing source code
  - README.md (if exists)
  - docs/ (if exists)
outputs:
  - Documentation files (README.md, docs/*.md, CHANGELOG.md)
  - .claude/project/STATE.md (updated)
tags:
  - documentation
  - readme
  - api-docs
  - changelog
  - onboarding
---

# Skill: Documentation

## Metadata

| Field | Value |
|-------|-------|
| **Skill ID** | SKL-0024 |
| **Version** | 1.0 |
| **Owner** | documenter |
| **Inputs** | Task description, STATE.md, DECISIONS.md, source code, README.md, docs/ |
| **Outputs** | Documentation files, STATE.md updated |
| **Triggers** | `DOCS_REQUESTED`, `FEATURE_SHIPPED` |

---

## Purpose

Make the project understandable to any developer who picks it up cold. Documentation is a first-class deliverable. Every public API is documented. Every setup step is tested. Every decision that affects future developers is recorded.

---

## Procedure

1. **Identify what needs documenting:**
   - Read STATE.md for recently completed tasks
   - Read DECISIONS.md for architectural context
   - Determine type: new README, feature update, API reference, setup guide, code comments, or changelog

2. **Identify the audience:**
   - **Solo developer (self):** terse, focus on "why" not "what"
   - **External developer / open source:** zero context assumed, cover prerequisites, setup, examples, common errors
   - **Non-technical stakeholder:** plain language, no code blocks, focus on what it does
   - **AI coding assistant:** structured, precise, explicit file paths, exact commands

3. **README structure** (when creating from scratch):
   - Project name + one-sentence description
   - What it does (2-4 sentences, user-facing, no jargon)
   - Quick start (minimum steps, every command tested and exact)
   - Configuration table (variable, required, description, example)
   - Project structure (directory tree with descriptions)
   - API reference (link or inline)
   - Contributing guide
   - License

4. **API documentation format** (for every public endpoint/function):
   - Method + path
   - Description (one sentence)
   - Auth required (yes/no)
   - Request body with types
   - Success response with example
   - Error responses table
   - curl example

5. **CHANGELOG format** (Keep a Changelog):
   - Version + date
   - Sections: Added, Changed, Fixed, Removed
   - One-sentence descriptions

6. **Quality checks before finishing:**
   - Every setup command is exact and tested
   - No placeholder text left unfilled
   - All code examples are syntactically correct
   - File paths match actual project structure
   - Prerequisites listed with minimum versions
   - Quick start gets user to working state in under 5 minutes

7. **Update STATE.md.**

---

## Constraints

- Never modifies application logic (except adding inline comments)
- Never documents features that don't exist yet
- Never leaves placeholder text in delivered documentation
- Always writes setup instructions as if reader has never seen the project
- Always uses exact commands — never "run the install command" without specifying it

---

## Primary Agent

documenter

---

## Definition of Done

- [ ] Documentation matches actual project state
- [ ] Quick start instructions are complete and correct
- [ ] All public APIs documented with request/response examples
- [ ] No placeholder text remaining
- [ ] CHANGELOG updated if a feature was shipped
- [ ] STATE.md updated with files created/modified

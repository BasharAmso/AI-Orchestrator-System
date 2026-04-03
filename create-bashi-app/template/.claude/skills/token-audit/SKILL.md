---
id: SKL-0039
name: Token Audit
description: |
  Audit the current project for token waste patterns. Produces a Token Health
  Report with scored findings and actionable fixes. Use this skill when token
  usage feels high, sessions are hitting limits, or before optimizing costs.
version: 1.0
owner: reviewer
triggers:
  - TOKEN_AUDIT_REQUESTED
inputs:
  - .claude/settings.json (MCP servers and plugin count)
  - .claude/project/session-log.csv (session duration trends)
  - .claude/CLAUDE.md (context loading rules)
  - Project files (check for non-markdown formats)
outputs:
  - Token Health Report (in Execution Summary)
  - .claude/project/STATE.md (updated)
tags:
  - review
  - tokens
  - optimization
  - cost
---

# Skill: Token Audit

## Metadata

| Field | Value |
|-------|-------|
| **ID** | SKL-0039 |
| **Owner** | reviewer |
| **Version** | 1.0 |
| **Triggers** | `TOKEN_AUDIT_REQUESTED` |

## Purpose

Identify where token waste is happening in a project and provide specific, prioritized fixes. This is a heuristic audit based on observable patterns, not precise token measurement (Claude Code does not expose token counts to skills).

---

## Procedure

### Step 1 — Audit MCP & Plugin Load

Read `.claude/settings.json`. Count:
- MCP servers configured (under `mcpServers`)
- MCP tools in the allow list (patterns matching `mcp__*`)

Each MCP server adds token overhead on every conversation start (tool definitions load into context).

| Score | Criteria |
|-------|----------|
| GREEN | 0-3 MCP servers |
| YELLOW | 4-5 MCP servers |
| RED | 6+ MCP servers |

If RED: recommend the user audit which servers they actively use and remove the rest.

### Step 2 — Audit Session Patterns

Read `.claude/project/session-log.csv`. Analyze the most recent 10 sessions:
- Average session duration
- Any sessions over 60 minutes (likely conversation sprawl)
- Sessions with very high hook counts relative to duration (may indicate excessive tool calls)

| Score | Criteria |
|-------|----------|
| GREEN | Average under 30 minutes |
| YELLOW | Average 30-60 minutes |
| RED | Average over 60 minutes |

If YELLOW/RED: recommend starting fresh conversations every 10-15 turns. Run `/save` first.

### Step 3 — Audit File Formats

Scan the project root and common directories (`docs/`, `src/`, `assets/`, `data/`) for files likely being fed to Claude in non-markdown formats:

Flag: `.pdf`, `.docx`, `.xlsx`, `.pptx`, `.csv` (over 100KB), `.png`, `.jpg`, `.jpeg`, `.gif`, `.bmp` (screenshots)

Raw PDFs can use 10-20x more tokens than the same content in markdown. Screenshots are similarly expensive.

| Score | Criteria |
|-------|----------|
| GREEN | No raw document files found |
| YELLOW | 1-3 non-markdown files found |
| RED | 4+ non-markdown files found |

If YELLOW/RED: recommend converting documents to markdown before feeding to Claude.

### Step 4 — Audit Context Loading

Read `.claude/CLAUDE.md` context loading policy. Check:
- Is lazy loading configured? (look for "load on-demand" or "Context Loading Policy")
- Is MCP-connected mode active? (Cortex MCP configured in settings.json)
- Count total files in `.claude/skills/` and `.claude/agents/`

MCP-connected mode is more token-efficient: skills load on demand from Cortex instead of sitting on disk where Claude may read them unnecessarily.

| Score | Criteria |
|-------|----------|
| GREEN | MCP mode active, or fewer than 30 skill files |
| YELLOW | 30-40 skill files, no MCP |
| RED | 40+ skill files, no MCP |

If YELLOW/RED: recommend connecting Cortex MCP (`npx create-bashi-app --light`) or removing unused skills.

### Step 5 — Audit Skill File Sizes

Read line counts of all SKILL.md files in `.claude/skills/` and `custom-skills/`.

Flag any over 200 lines. Note skills with companion files (LENSES.md, TEMPLATE.md, SCHEMA.md) as good practice — they keep the SKILL.md lean while preserving content.

| Score | Criteria |
|-------|----------|
| GREEN | All skills under 200 lines |
| YELLOW | 1-3 skills over 200 lines |
| RED | 4+ skills over 200 lines |

If YELLOW/RED: recommend extracting inlined reference material into companion files.

### Step 6 — Generate Token Health Report

```markdown
## Token Health Report

**Date:** YYYY-MM-DD
**Overall Score:** [X/5 GREEN] — [Excellent (5) / Good (4) / Needs Work (3) / Poor (0-2)]

| Category | Score | Finding |
|----------|-------|---------|
| MCP & Plugin Load | [GREEN/YELLOW/RED] | [X MCP servers, Y mcp tools in allow list] |
| Session Patterns | [GREEN/YELLOW/RED] | [avg X min across Y sessions] |
| File Formats | [GREEN/YELLOW/RED] | [X non-markdown files found] |
| Context Loading | [GREEN/YELLOW/RED] | [MCP mode: yes/no, X skill files on disk] |
| Skill File Sizes | [GREEN/YELLOW/RED] | [X skills over 200 lines] |

### Recommendations (Priority Order)
1. [Most impactful fix — specific action and expected improvement]
2. [Second fix]
3. [Third fix]
```

### Step 7 — Update STATE.md

---

## Constraints

- This skill is **read-only** — it audits but does not modify any files (except STATE.md)
- Scores are heuristic, not precise token measurements
- Should complete in under 30 seconds
- Recommendations must be specific and actionable, not generic ("convert report.pdf to markdown" not "consider your file formats")
- Do not recommend removing MCP servers or plugins without naming which ones appear unused

---

## Primary Agent

reviewer

---

## Definition of Done

- [ ] All 5 audit categories evaluated
- [ ] Each category scored GREEN / YELLOW / RED
- [ ] Recommendations listed in priority order with specific actions
- [ ] Overall score calculated (count of GREEN scores out of 5)
- [ ] STATE.md updated

## Output Contract

| Field | Value |
|-------|-------|
| **Artifacts** | Token Health Report in Execution Summary |
| **State Update** | `.claude/project/STATE.md` — mark task complete, log findings |
| **Handoff Event** | `TASK_COMPLETED` (audit complete, recommendations provided) |

# TODOS.md Format Reference

> Defines the standard format for TODOS.md files used across projects built with Bashi.

---

## Purpose

TODOS.md is a cross-cutting concern. Multiple skills reference it:
- **Code Review** (SKL-0016) — cross-references PRs against open TODOs
- **Ship Workflow** (SKL-0021) — auto-marks completed items from the diff
- **UAT Testing** (SKL-0018) — checks known bugs during QA
- **Team Retro** (SKL-0026) — reports backlog health

---

## File Structure

```markdown
# TODOS

## <Component/Skill Name>

- [ ] **[Title]** — [One-line description]
  - **Priority:** P0 / P1 / P2 / P3 / P4
  - **Context:** [Enough detail for someone to pick this up in 3 months]
  - **Depends on:** [prerequisites, or "None"]

## <Another Component>

- [ ] ...

## Completed

- [x] **[Title]** — [description]
  - **Completed:** v1.2.0 (2026-03-15)
```

---

## Priority Levels

| Priority | Meaning | SLA |
|----------|---------|-----|
| **P0** | Critical — blocks users or causes data loss | Fix immediately |
| **P1** | Urgent — significant degradation of core functionality | Fix this sprint |
| **P2** | Important — noticeable issue, workaround exists | Fix next sprint |
| **P3** | Nice-to-have — improvement, not a fix | When capacity allows |
| **P4** | Wishlist — future enhancement, no urgency | Someday/maybe |

---

## Rules

1. **Group by component or skill** — not by priority. Priority is a field on each item.
2. **P0 items at the top** of each section, descending to P4.
3. **Completed items move to `## Completed`** — never delete them. Include version and date.
4. **Context is mandatory** — a TODO without context is worse than no TODO. Include enough detail that someone unfamiliar can understand the motivation and where to start.
5. **One TODO per item** — don't nest sub-TODOs. If something needs sub-items, it's a task, not a TODO.
6. **Never auto-create TODOS.md** — only create when the user confirms. Ask first.

---

## Cross-Skill Integration

### During Code Review (SKL-0016)
- Check if the PR addresses any open TODOs → note in review output
- Check if the PR creates work that should become a TODO → flag as informational

### During Ship (SKL-0021)
- Match diff against TODO descriptions → auto-mark completed with version
- Be conservative — only mark with clear evidence from the diff

### During QA (SKL-0018)
- Check for known bugs in TODOS → add them to the test plan
- New bugs found during QA that aren't in TODOS → note in report

### During Retro (SKL-0026)
- Report backlog health: total open, P0/P1 count, items completed this period

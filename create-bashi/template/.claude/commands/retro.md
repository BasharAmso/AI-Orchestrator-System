# Command: /retro

> Engineering retrospective. Analyzes commit history, work patterns, and code quality metrics.

---

## Arguments

- `/retro` — last 7 days (default)
- `/retro 24h` — last 24 hours
- `/retro 14d` — last 14 days
- `/retro 30d` — last 30 days
- `/retro compare` — compare current window vs prior same-length window

## Procedure

1. Parse the argument to determine the time window. Default to 7 days.
2. Read and execute the retro skill at `.claude/skills/retro/SKILL.md`.
3. Follow all steps in the skill procedure.
4. Output the narrative directly to the conversation.
5. Save the JSON snapshot to `.context/retros/`.
6. Update STATE.md.

> This command outputs to the conversation. The only file written is the `.context/retros/` JSON snapshot.

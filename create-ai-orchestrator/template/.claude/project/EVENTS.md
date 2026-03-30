# Events Log

> Events represent things that happened or need to happen. They are processed FIFO (oldest first).

---

## Event Format

```
EVT-XXXX | <TYPE> | <Description> | <Source> | <Timestamp> | <Priority>
```

- **EVT-XXXX** — Auto-incremented event ID (e.g., EVT-0001)
- **TYPE** — Event type matching a skill trigger or routing rule (e.g., IDEA_CAPTURED, QUALITY_REVIEW_REQUESTED)
- **Description** — Brief summary of what happened or what needs to happen
- **Source** — Who/what created the event (user, agent, system)
- **Timestamp** — When the event was created
- **Priority** — Optional: `high`, `normal`, or `low` (default: `normal` if omitted)

### Priority Processing Order

Events are processed **high -> normal -> low**, FIFO within each priority level. Events without a priority field are treated as `normal`.

---

## Unprocessed Events

*(none)*

---

## Processed Events

*(none)*

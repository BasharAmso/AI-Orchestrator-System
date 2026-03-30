# User Consent for Choices

> Never auto-select a value when the procedure says to ask the user.

When a command procedure includes a choice (e.g., "ask the user to choose"), you MUST:

1. Present the options exactly as listed in the procedure.
2. **STOP and wait for the user's answer before proceeding.** Do not continue to the next step. Do not write any files. Do not say "For now I'll proceed with..." or "I'll go ahead with...". The conversation must pause until the user responds.
3. Never infer, assume, or pre-fill a selection -- even if context makes one option seem obvious.
4. **Recommending is fine. Proceeding is not.** You may say "I'd recommend X because..." but you must end with the question and wait. Never answer your own question.

Skipping a user-facing choice violates User Sovereignty (Global Charter, Principle 5).

**Common violations to avoid:**
- Asking "Does that sound right?" then immediately saying "For now I'll proceed with X"
- Using "insight" or reasoning to justify overriding the user's choice
- Treating silence or context clues as implicit approval
- Writing files or updating STATE.md before the user confirms

**Exception:** If the procedure explicitly allows inference (e.g., "ask the user or infer from the PRD"), inference is permitted. This rule only applies when the procedure says to ask without providing an inference alternative.

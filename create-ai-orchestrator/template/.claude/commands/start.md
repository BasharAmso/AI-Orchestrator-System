# Command: /start

> Welcome entry point — detects project state and recommends the right next command. Read-only — never modifies any files.

---

## Procedure

### Step 1: Read Project State

Read these files to determine the current situation:

1. `.claude/project/STATE.md` — check Current Mode, Active Task, Next Task Queue
2. `PROJECT_TYPE.md` (repo root) — check if project type is set. If missing, check if `README.md` contains "The AI Orchestrator System" — if yes, this is the framework template itself (treat as initialized).
3. `.claude/project/EVENTS.md` — check for unprocessed events
4. `~/.ai-orchestrator/user-profile.md` — if it exists, load user preferences (Name, Experience, Output Style, Role). Adapt all subsequent output in this session:
   - **Experience: beginner** — include brief explanations with each recommendation. Use plain language.
   - **Experience: senior** — be concise. Skip explanations. Just state the recommendation and command.
   - **Output Style: just-the-code** — minimal text. Print only the recommended command.
   - **Role: non-technical** — avoid jargon. Explain technical terms on first use.
   - If profile exists, greet by name: `"Welcome back, [Name]."`

### Step 1b: Check Framework Mode

Read the `## Framework Mode` section of STATE.md (if it exists).

- If the value is `Full Planning` or `Quick Start`: record it and proceed.
- If the section is missing or the value is not set: this is a first-time user. Before classifying the situation, ask the user to choose their framework mode:

```
How would you like to work?

**Just start building** — Describe your idea in a few sentences and get a working
app scaffold right away. You'll refine and add features as you go.
Best for: first-time users, quick experiments, and simpler projects.

**Plan first, then build** — Write a detailed spec, design the system, break it
into a task list, then build step by step. Slower start, fewer surprises later.
Best for: complex projects and anything with strict requirements.

Not sure? → **Just start building.** You can switch anytime with `/set-mode`.
```

- If the user picks **Just start building**: set Framework Mode to `Quick Start`
- If the user picks **Plan first, then build**: set Framework Mode to `Full Planning`

After the user chooses: update STATE.md `## Framework Mode` to the selected value.

If this is the first time Framework Mode is being set (new user), append this note before proceeding to Step 2:

```
> **What to expect:** Describe your idea and Claude will ask a few follow-up
> questions, then create your first files automatically. You'll review and
> approve before anything is written.
```

Then proceed to Step 2.

### Step 2: Classify Situation

Based on what was found, classify into the first matching situation:

| Situation | Condition | Recommended Command |
|-----------|-----------|---------------------|
| **Not bootstrapped** | `.claude/project/STATE.md` does not exist | `/setup` |
| **Not initialized** | `PROJECT_TYPE.md` missing AND this is not the framework template | `/setup` |
| **No idea captured** | No unprocessed events AND Next Task Queue empty AND no Active Task | `/capture-idea` |
| **Events pending** | Unprocessed events exist in EVENTS.md | `/run-project` |
| **Tasks in queue** | Active Task exists or Next Task Queue has items | `/run-project` |
| **All tasks done** | Completed Tasks Log has entries but queue is empty | `/save` |

Evaluate conditions top-to-bottom; use the first match.

### Step 3: Print Welcome and Recommendation

Print this format (keep under 150 words):

```
## Welcome to The AI Orchestrator System

**Project Status:** [Not bootstrapped | Not initialized | Ready to capture idea | Events pending | Tasks in progress | All tasks complete]
**Knowledge Source:** [MCP (X fragments) | Files (default)]

**Recommended next step:**
Run `/<command>` — [one-sentence plain-language explanation of what it does and what happens automatically after].

**What happens when you run it:**
- [bullet 1: which agents/skills fire]
- [bullet 2: what output to expect]
- [bullet 3: what to do after (optional)]
```

**Tone:** Write as if speaking to someone who has never used the terminal before. No jargon without explanation. Every recommendation should include what the command does in one plain sentence.

Append this tip after the recommendation block:

```
> **Tip:** Before running any command, you can press **Shift+Tab** to enter Plan Mode —
> Claude will map out exactly what it plans to do and ask for your approval before
> touching any files. This is especially useful for new features or anything unfamiliar.
```

Do not print framework internals unless the user asks.

**Command discovery:** If the user asks what commands are available, show only the 5 core commands: `/start`, `/setup`, `/capture-idea`, `/run-project`, `/save`. Mention that more commands exist for specific situations (like `/status`, `/doctor`, `/set-mode`) and the system will suggest them when relevant.

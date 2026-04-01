# Decisions Log

> Record architectural and design decisions here. Each decision should explain the context, the choice made, and why.

---

## Decision Template

```
### DEC-XXXX: [Title]

- **Status:** Proposed | Accepted | Superseded
- **Date:** YYYY-MM-DD
- **Context:** Why this decision was needed
- **Decision:** What was decided
- **Consequences:** What follows from this decision
```

---

### DEC-0001: Use Semi-Autonomous as Default Mode

- **Status:** Accepted
- **Date:** 2026-03-05
- **Context:** The system needs a default execution mode that balances productivity with user control. Beginners need to see what happens after each step.
- **Decision:** Semi-Autonomous mode is the default. The orchestrator executes one unit of work (one event or one task), then stops for user review.
- **Consequences:** Users always get a chance to review before the next action. Slightly slower than Autonomous, but much safer for new users.

---

### DEC-0002: FIFO Event Processing Order

- **Status:** Accepted
- **Date:** 2026-03-05
- **Context:** Events could be processed by priority, recency, or arrival order. We need a simple, predictable rule.
- **Decision:** Events are processed in FIFO order (oldest first). No priority override mechanism in v1.
- **Consequences:** Predictable behavior. If priority routing is needed later, it can be added as a REGISTRY enhancement without changing the core loop.

---

### DEC-0003: Native Mobile as First-Class Platform Support

- **Status:** Accepted
- **Date:** 2026-03-25
- **Context:** The framework's mobile-dev skill only supported React Native + Expo. Users building native iOS or Android apps had no structured guidance for Swift/SwiftUI or Kotlin/Jetpack Compose.
- **Decision:** Add Swift/SwiftUI (iOS) and Kotlin/Jetpack Compose (Android) as first-class platforms alongside React Native. Includes platform-specific stack defaults, anti-patterns, testing guides, QA checklists, code review items, and app store deployment procedures. Architecture-designer and builder both prompt for platform and style choices.
- **Consequences:** Mobile-dev skill v2.0, test-writing v2.0, UAT v2.1, deployment v3.0. Framework now covers the full native mobile lifecycle. React Native remains the default. Nine files changed across skills, agents, and commands.

---

### DEC-0004: Project-Level Permission Allows for Unattended Operation

- **Status:** Accepted
- **Date:** 2026-03-25
- **Context:** `/overnight` was designed for hours-long unattended runs, but Claude Code's permission model paused for approval on every file write and bash command — defeating the purpose. The framework already has a 3-layer safety stack (deny list + 5 blocking hooks + circuit breakers) that fires regardless of permissions.
- **Decision:** Add broad `allow` rules (Edit, Write, Bash patterns) to the project-level settings.json. Also cleaned up global settings from 643 one-off entries to 36 broad patterns. Safety stack unchanged — hooks and deny lists still guard every tool call.
- **Consequences:** `/overnight` can now run without permission prompts in this project. `rm` commands, Python execution, and curl/wget still prompt. `git push` still prompts via the `ask` rule (overridden only by `BASHI_OVERNIGHT_MODE` during overnight runs).

---

### DEC-0005: Parallel Agent Execution as Next Major Feature

- **Status:** Accepted
- **Date:** 2026-03-26
- **Context:** Competitive analysis (RES-0002) identified parallel agent execution as the primary technical gap vs. competitors (Composio, Ruflo, Agent Farm). Claude Code natively supports `isolation: "worktree"` for running agents in separate git worktrees. The orchestrator currently processes tasks sequentially.
- **Decision:** Add parallel agent dispatch to the orchestrator. Independent tasks in the queue should be launchable simultaneously, each in its own worktree, with state tracking and conflict resolution on merge. This is the #1 priority for the next framework version.
- **Consequences:** Requires changes to orchestrator.md dispatch chain, STATE.md tracking (parallel task slots), and merge conflict resolution. Will be a major differentiator since most frameworks talk about parallelism but few orchestrate it with state management and circuit breakers.

---

### DEC-0006: One-Command Install for Public Distribution

- **Status:** Accepted
- **Date:** 2026-03-26
- **Context:** The framework is open source on GitHub but requires manual setup. Competitors like Ruflo have `npm install`, ECC has GitHub clone workflows. Bashar's goal is recognition and helping others, which requires frictionless adoption.
- **Decision:** After parallel agent support ships, create a one-command install experience (e.g., `npx create-bashi-app` or equivalent). This is the #2 priority after parallel execution.
- **Consequences:** Needs a package.json, install script, and possibly a selective install flow. README must be updated with the install command prominently.

---

### DEC-0007: Parallel Agent Dispatch Design

- **Status:** Accepted
- **Date:** 2026-03-27
- **Context:** DEC-0005 accepted parallel execution as the #1 priority. This decision records the specific design choices for implementation.
- **Decision:** Three key design choices:
  1. **Sequential merge by orchestrator.** Worktree agents commit to isolated branches. The orchestrator merges one branch at a time (Slot 1, then 2, then 3). On conflict: `git merge --abort`, re-queue the task. This eliminates all merge race conditions without file locking.
  2. **Framework files excluded from worktree merges.** Agents are instructed to NOT modify `.claude/` files. The orchestrator is the sole writer of STATE.md, EVENTS.md, and all framework state. This prevents parallel agents from corrupting shared state.
  3. **Auto-classify before independence check.** Tasks without Skill IDs get auto-classified using the existing dispatch chain before independence is assessed. This ensures the feature works even when tasks haven't been pre-assigned to skills.
  4. **Safety via prompt, not hooks.** Hooks may not inherit in worktree subagents. Critical safety rules (no destructive commands, no secrets, no >500-line changes) are replicated in the agent prompt template.
- **Consequences:** Parallel dispatch is backward compatible (falls back to sequential if only 1 task eligible or Parallel Enabled = No). Max 3 parallel slots (configurable). Merge conflict limit circuit breaker stops the run if 2+ tasks conflict in one cycle. Changes span orchestrator.md, STATE.md, RUN_POLICY.md, run-project.md, and overnight.md.

---

### DEC-0008: One-Command Install via npx

- **Status:** Accepted
- **Date:** 2026-03-27
- **Context:** DEC-0006 called for a one-command install experience. The framework requires ~100 files across agents, skills, commands, hooks, rules, and state templates. Manual setup is a barrier to adoption.
- **Decision:** Create an `npx create-bashi-app` package. The package contains a `template/` directory with clean copies of all framework files (empty state, no project-specific data). The install script copies the template into the target directory, initializes git if needed, and skips existing files by default (--force to overwrite). No runtime dependencies.
- **Consequences:** Users can set up the framework in any project with one command. The template directory must be kept in sync with framework changes (manual sync for now, could be automated later). Package ready for npm publish.

---

### DEC-0009: Agent Self-Improvement System

- **Status:** Accepted
- **Date:** 2026-03-28
- **Context:** The framework had building blocks for improvement (skill improvement check, handoff protocol, review gates, AI-Memory) but none were wired together. Feedback from reviewers was inert. Repeated friction was invisible. No agent evaluated its own work.
- **Decision:** Three-layer self-improvement system:
  1. **Agent Self-Review (step 5.6):** After each task, the agent answers 3 questions (followed procedure? assumptions? would change?). Friction logged as FB-XXXX to AI-Memory/feedback/.
  2. **Cross-Agent Feedback Capture (step 5.7):** NEEDS WORK verdicts logged with pattern tags. Auto-emits REWORK_REQUESTED event (max 2 rework attempts, then blocked).
  3. **Pattern Detection (step 5.8):** 3+ same pattern tag + agent → auto-propose improvement to SKILL_IMPROVEMENTS.md.
  All propose-only. No agent or skill files auto-modified. 9 standard pattern tags. Feedback stored in single append-only log.
- **Consequences:** Agents now self-evaluate and capture feedback automatically. Recurring issues surface as improvement proposals. Rework loops capped at 2 attempts. Works with parallel dispatch (orchestrator logs after merge). New event type: REWORK_REQUESTED. New AI-Memory folder: feedback/.

---

### DEC-0010: Friction Reduction as Cross-Cutting Concern

- **Status:** Accepted
- **Date:** 2026-03-28
- **Context:** Friction reduction only existed in 2 of 37 skills (UX Design, Customer Support). A PRD could skip friction targets, frontend could add unnecessary steps, code review wouldn't catch interaction complexity. Friction got designed in at requirements and never caught.
- **Decision:** Make friction awareness automatic across the framework, like security. Created SKL-0037 Friction Audit skill with a 19-item checklist across 4 categories (core, interaction, onboarding, cognitive). Added a Friction Awareness Rule to orchestration-routing.md that triggers on user-facing task keywords. Updated 6 skills (PRD Writing, Frontend Dev, Code Review, UAT, Growth, Mobile Dev) with friction references. Added friction scoring (10% weight) to UAT health score. Builder agent is now friction-aware.
- **Consequences:** Every user-facing task now gets a friction check. PRD interviews ask about friction upfront. Code review catches interaction complexity. UAT scores friction. Framework now has 37 skills. One shared checklist prevents duplication.

### DEC-0011: Two-Mode Knowledge Loading (Standalone vs Cortex MCP)

- **Status:** Accepted
- **Date:** 2026-03-30
- **Context:** Cortex MCP is complete (202 fragments: 10 agents, 123 skills, 53 patterns, 16 examples). The framework loads agents/skills from files. Two delivery methods for the same knowledge exist but aren't connected.
- **Decision:** Add two-mode loading to the orchestrator. Mode 1 (Standalone): loads from .claude/agents/ and .claude/skills/ files (current behavior, always available). Mode 2 (MCP-connected): queries Cortex MCP on-demand, falls back to files if unavailable. Detection at startup via `list_categories`. Smart context enhancement loads related patterns (up to 2) and examples (up to 1) alongside skills. Difficulty-based skill preference matches user experience level. `/setup` uses `detect_project` for stack auto-detection. REGISTRY.md stays as trigger lookup in both modes. Coach and orchestrator agents always load from files.
- **Consequences:** Framework version bumps to 2.0.0. Cortex MCP needs pre-requisite changes (ID alignment, owner field, content sync). All projects work without Cortex MCP (graceful fallback). npm package needs republishing.

### DEC-0012: Growth Skill Premium Visual Tier

- **Status:** Accepted
- **Date:** 2026-03-29
- **Context:** The growth skill produces functional landing pages but lacks the visual polish of sites like orchestr8.ai (gradients, glassmorphism, parallax, animated stats).
- **Decision:** Add Visual Tier selection (Clean vs Premium) as Step 1.5 in the growth skill. Premium tier adds: full-viewport hero with layered backgrounds, glassmorphism cards, gradient text, scroll animations, parallax, animated stat counters, dark theme default. Auto-detects from PRD keywords (launch, public, marketing, brand). Performance constraint: 60fps, prefer CSS over JS. Must also pass frontend-dev Visual Polish checklist (4A-4F).
- **Consequences:** Growth skill now produces two quality levels. Premium tier applied to all framework projects with Cortex MCP.

### DEC-0013: AI-Memory Created by /setup

- **Status:** Accepted
- **Date:** 2026-03-29
- **Context:** AI-Memory directory referenced by 13 framework files but nothing creates it. New adopters get instructions pointing to ~/Projects/AI-Memory which doesn't exist.
- **Decision:** Add Step 2.7 to /setup that creates AI-Memory with 7 subdirectories (decisions, patterns, failures, lessons, ideas, feedback, improvements) and 3 seed files (GLOBAL_INDEX.md, README.md, SKILL_IMPROVEMENTS.md). Idempotent -- skips if already exists. Session-start hook updated to mention /setup.
- **Consequences:** New adopters get AI-Memory automatically. Cross-project learning works from first project.

### DEC-0014: Cortex MCP as Delivery Engine, Frame Brain as Generator

- **Status:** Accepted
- **Date:** 2026-03-29
- **Context:** orchestr8 (GitHub, 64 stars) already serves developer-focused agent expertise via MCP. Frame Brain needs differentiation.
- **Decision:** Frame Brain targets non-developers (event planners, authors, analysts). Cortex MCP is the delivery engine. Frame Brain generates domain-specific knowledge, Cortex serves it. Frame Brain is the product, MCP is the delivery mechanism.
- **Consequences:** Frame Brain and Cortex MCP are separate projects with a clear relationship. Frame Brain generates content, Cortex delivers it.

### DEC-0015: Rename to Bashi

- **Status:** Accepted
- **Date:** 2026-03-30
- **Context:** "The AI Orchestrator System" is generic, hard to remember, and doesn't stand out in awesome-lists. Derived from Bashar's nickname (Bashariooo).
- **Decision:** Rename to Bashi. npm package: create-bashi-app. GitHub: BasharAmso/bashi. FRAMEWORK_VERSION bumped to 3.0.0. Old npm package deprecated. Old GitHub URL auto-redirects.
- **Consequences:** 157 files renamed. All env vars changed (BASHI_PATH, BASHI_OVERNIGHT_MODE). User profile directory moved to ~/.bashi/. cortex-mcp references updated.

### DEC-0016: Light Install Mode (--light)

- **Status:** Accepted
- **Date:** 2026-03-30
- **Context:** Users with Cortex MCP don't need local skill or agent files. Only orchestrator and coach load from files.
- **Decision:** `npx create-bashi-app --light` installs only orchestrator + coach agents, commands, hooks, rules, state. ~40% fewer files. Skills load from MCP on demand.
- **Consequences:** fix-registry guards against wiping REGISTRY in light mode. doctor skips agent file checks when Knowledge Source = MCP.

### DEC-0017: Cortex-Aware Orchestrator (Step B.5)

- **Status:** Accepted
- **Date:** 2026-03-30
- **Context:** REGISTRY has 37 skills, Cortex has 155. 118 skills invisible to auto-dispatch.
- **Decision:** Add step B.5 to dispatch chain: when REGISTRY lookup fails, search Cortex via search_knowledge before falling to event-hooks/routing-rules. Only fires in Files mode when MCP is available (avoids duplicate search in MCP mode).
- **Consequences:** All Cortex skills auto-discoverable. New skills added to Cortex are immediately routable.

### DEC-0018: Quick Start Builds Immediately

- **Status:** Accepted
- **Date:** 2026-03-30
- **Context:** Quick Start took 3-4 /run-project cycles before generating code. Events (IDEA_CAPTURED, PROBLEM_VALIDATION_REQUESTED) blocked building.
- **Decision:** Quick Start path in capture-idea no longer emits blocking events. Sets phase to Building directly. First /run-project produces code. Problem stress test and GDD available on-demand via /trigger.
- **Consequences:** Quick Start lives up to its name. Setup also dynamically discovers project types from Cortex MCP pillars when available.

### DEC-0019: Broad Bash Permissions Over Granular Patterns

- **Status:** Accepted
- **Date:** 2026-03-31
- **Context:** Project-level settings.json shipped with ~20 granular Bash patterns (Bash(git *), Bash(npm *), etc.). Agents use unpredictable commands (python, sed, test, wc), triggering permission prompts for anything not listed. VS Code extension also ignores settings.json entirely (known bug).
- **Decision:** Replace granular Bash patterns with broad "Bash" allow. Safety via deny list (rm -rf, force push, reset hard, checkout --, DROP TABLE/DATABASE) and ask list (git push, curl). Added Read, Glob, Grep to allow list. VS Code workaround: set initialPermissionMode in extension settings.
- **Consequences:** No more permission prompts for routine commands. Deny list + 11 hooks remain as safety net. Template updated so new projects inherit broad permissions.

### DEC-0020: Multiline YAML Descriptions Are Safe in Claude Code

- **Status:** Accepted
- **Date:** 2026-04-01
- **Context:** Community guidance (Nate's agent-readable skills video) warned that skill descriptions must stay on a single line or Claude won't read the second line. All 37 Bashi skills use YAML pipe (`|`) multiline syntax.
- **Decision:** Keep multiline format. The single-line constraint applies to Claude Desktop's native skill matching, not Claude Code. Evidence: this session's system-reminder lists every skill with full multiline descriptions and they all trigger correctly.
- **Consequences:** No refactoring needed. Framework-wide multiline format is the standard.

### DEC-0021: REGISTRY.md Stays Lightweight

- **Status:** Accepted
- **Date:** 2026-04-01
- **Context:** Output Contract sections were added to skills. Considered adding output/handoff columns to REGISTRY.md.
- **Decision:** Keep REGISTRY.md as a lightweight index (ID, Name, Version, Owner, Folder, Triggers). Output Contract in each SKILL.md is the source of truth for artifacts and handoff events.
- **Consequences:** REGISTRY stays scannable. Agents that need output/handoff info read the individual SKILL.md files.

### DEC-0022: Output Contract Section as Standard Skill Section

- **Status:** Accepted
- **Date:** 2026-04-01
- **Context:** Mid-pipeline skills (backend-dev, test-writing, documentation) ended with just "Update STATE.md" and no explicit handoff event. Agents had no contract for what a skill produces or what comes next.
- **Decision:** Add `## Output Contract` as a standard section after `## Definition of Done`. Table format with Artifacts, State Update, Decision Log (optional), and Handoff Event. 12 pipeline-critical skills retrofitted. Remaining 25 to follow.
- **Consequences:** Skills are now agent-discoverable and composable. Handoff events are explicit, not implicit. `/test-skill` command (T4) validates presence.

### DEC-0023: Long Skills Split Into Companion Files

- **Status:** Accepted
- **Date:** 2026-04-01
- **Context:** 10 skills exceeded 150 lines. Community guidance recommends 100-150 lines max for core SKILL.md. But some skills (deployment at 559, uat-testing at 406) have legitimate complexity.
- **Decision:** Extract inlined reference material (lenses, templates, schemas) into companion files (LENSES.md, TEMPLATE.md) within the skill folder. SKILL.md references them with "Read X.md in this skill folder." Keep skills with legitimate complexity intact.
- **Consequences:** problem-stress-test: 408 → 260 lines. gdd-writing: 406 → 275 lines. Content preserved in companion files. Pattern available for retro and prd-to-tasks in future.

### DEC-0024: Knowledge Enhancement Sections for Cortex MCP Integration

- **Status:** Accepted
- **Date:** 2026-04-01
- **Context:** The orchestrator silently handles Cortex integration, but individual skills are blind to it. Custom skill authors don't know they can request domain-specific knowledge. Skills that know about Cortex can be smarter about what patterns they pull.
- **Decision:** Add `## Knowledge Enhancement (MCP mode)` to 3 reference skills (backend-dev, security-audit, ai-feature). Pattern: search_knowledge with task-derived query, get_fragment on top result, apply as supplementary context. Complements Cortex README's "For Skill Authors" section.
- **Consequences:** Skill authors have a copyable pattern. Skills can request domain-specific knowledge instead of relying solely on the orchestrator's generic search.

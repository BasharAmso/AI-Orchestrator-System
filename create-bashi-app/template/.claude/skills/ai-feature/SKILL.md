---
id: SKL-0009
name: AI Feature Implementation
description: |
  Integrate AI capabilities like LLM calls, RAG pipelines, and prompt
  engineering. Use this skill when an AI-powered feature needs to be built
  or refined.
version: 1.0
owner: builder
triggers:
  - AI_FEATURE_REQUESTED
inputs:
  - Task description (from STATE.md)
  - docs/PRD.md (AI/ML Requirements section)
  - .claude/project/knowledge/DECISIONS.md
  - Existing AI service files
outputs:
  - AI service layer files (client, prompts, guardrails, evaluator)
  - .claude/project/STATE.md (updated)
tags:
  - building
  - ai
  - llm
  - rag
---

# Skill: AI Feature Implementation

## Metadata

| Field | Value |
|-------|-------|
| **Skill ID** | SKL-0009 |
| **Version** | 1.0 |
| **Owner** | builder |
| **Inputs** | Task description, PRD AI/ML section, DECISIONS.md, existing AI files |
| **Outputs** | AI service layer files, STATE.md updated |
| **Triggers** | `AI_FEATURE_REQUESTED` |

---

## Purpose

Build AI-powered features (LLM integrations, RAG pipelines, prompt engineering, agentic workflows) with production-grade reliability. Every AI integration handles failures, controls costs, and evaluates quality.

---

## Architecture Selection

| Use Case | Architecture |
|----------|-------------|
| Q&A over documents/data | RAG (Retrieval Augmented Generation) |
| Structured data extraction | Prompt engineering with JSON output mode |
| Multi-step automation | Agentic with tool use |
| Classification / routing | Classifier prompt or fine-tuned model |
| Chat / conversation | Stateful conversation with system prompt |
| Content generation | Prompt engineering with temperature control |

---

## Procedure

1. **Read PRD AI/ML Requirements** — extract what the AI does, model selection, performance thresholds, guardrails, cost model.
2. **Choose and confirm architecture** from the table above. Log to DECISIONS.md.
3. **Build AI service layer** in `src/services/ai/`:
   - `client.js` — model client setup, auth, retry config
   - `prompts/[feature].js` — all prompt templates (never inline)
   - `[feature]-service.js` — feature-specific AI logic
   - `guardrails.js` — input/output validation
4. **Non-negotiables:**
   - Pin model versions (e.g., `claude-sonnet-4-6`, not `claude-sonnet`)
   - Set explicit `temperature`, `max_tokens`, `top_p`
   - Handle all failure modes: rate limit (backoff), timeout, low confidence, model error
   - Log token usage per request; set `max_tokens` to minimum needed
   - Cache identical requests for cost reduction
5. **Implement guardrails:**
   - Input: validate length, check injection patterns, redact PII
   - Output: check confidence, validate schema, flag unsourced claims
   - Fallback hierarchy: retry simplified → rule-based → "I'm not sure" → never empty
6. **RAG (if applicable):** chunk docs (800-1200 tokens, 10-15% overlap), embed, retrieve top-K, instruct model to cite sources and say "I don't know" when context is insufficient.
7. **Write evaluation tests** — minimum 10-case golden set (expected outputs, must-not-contain).
8. **Document in `docs/AI.md`** — feature, model, architecture, cost estimate, fallback behavior.
9. **Update STATE.md.**

---

## Constraints

- Never uses floating model aliases — always pins versions
- Never puts prompts inline — always in dedicated prompt files
- Never ships without a fallback for model failure
- Never sends PII to external models without PRD authorization
- Always logs token usage — no AI feature without cost visibility
- Never sets max_tokens to unlimited

---

## Primary Agent

builder

---

## Definition of Done

- [ ] Model version pinned
- [ ] Temperature and max_tokens explicitly set
- [ ] Prompts in `/prompts/` directory
- [ ] Input and output guardrails implemented
- [ ] Fallback behavior defined and tested
- [ ] Token usage logged per request
- [ ] Cost controls in place
- [ ] Golden set evaluation test written (10+ cases)
- [ ] AI feature documented in docs/AI.md
- [ ] Architecture decision logged to DECISIONS.md
- [ ] STATE.md updated

## Output Contract

| Field | Value |
|-------|-------|
| **Artifacts** | AI service layer files (`src/services/ai/`), prompt templates (`prompts/`), guardrails, `docs/AI.md` |
| **State Update** | `.claude/project/STATE.md` — mark task complete, log files modified |
| **Decision Log** | `.claude/project/knowledge/DECISIONS.md` — AI architecture and model selection decisions |
| **Handoff Event** | `TASK_COMPLETED` (ready for code review) |

## Knowledge Enhancement (MCP mode)

If Cortex MCP is available:
1. Call `search_knowledge` with query derived from task (e.g., "RAG pipeline patterns", "prompt engineering best practices"), category="patterns"
2. If relevant results found, call `get_fragment` on the top result
3. Apply as supplementary context (does not override this skill's procedure)

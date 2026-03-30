# AI Orchestration Framework — Scope

## The Problem: The Syntax Wall

For decades, building software required learning programming syntax. If you couldn't write code, your ideas stayed ideas.

This barrier became known as the **Syntax Wall**.

AI-assisted development tools have begun lowering this barrier, but most tools still treat the user like a programmer. They assume you know how to structure a project, debug errors, and navigate a codebase.

As Uri Levine wrote in "Fall in Love with the Problem, Not the Solution," the key is obsessing over the problem before reaching for a solution. The problem here isn't "how do I use AI to write code?" It's "how do I ship software when writing code isn't my strength?"

The AI Orchestration Framework approaches that problem differently.

Instead of writing code directly, the user **orchestrates a structured system of agents, skills, and workflows**. The user's role becomes **Architect and Orchestrator**, not programmer.

---

## The AI Orchestration Framework

The **AI Orchestration Framework** is a general method for turning ideas into structured outcomes.

It defines how AI systems should be organized:

- **Orchestrator agents** coordinate work across tasks and priorities.
- **Skills** implement reusable workflows that can be triggered by events.
- **State** tracks progress so no work is lost between sessions.
- **Events** trigger actions and keep the system moving forward.
- **Knowledge layers** preserve decisions, research, and lessons learned.
- **Memory systems** accumulate experience across projects over time.

The framework focuses on **system design and orchestration**, not syntax.

---

## Bashi

The **Bashi** is a practical implementation of the AI Orchestration Framework.

It provides:

- A ready-to-use project structure
- An orchestrator agent that coordinates all work
- A skills registry for discovering and running reusable workflows
- Event routing that connects triggers to actions
- Run-cycle execution with bounded autonomy and safety controls
- Knowledge layers for decisions, research, glossary, and open questions
- Global memory for cross-project learning
- Self-improving skills that capture friction and propose refinements

Together these components create a repeatable pipeline for building structured digital outcomes — whether that outcome is a web app, a mobile app, an API, or a SaaS product.

---

## The Orchestration Stack

Bashi organizes work using a layered architecture. Each layer has a specific role.

### Idea Layer

The user supplies the idea, goal, or problem to solve.

### Command Layer

Commands such as `/capture-idea` or `/run-project` initiate actions and move the system forward.

### Orchestrator Layer

The orchestrator coordinates work, selects tasks, routes events, and manages execution cycles.

### Skill Layer

Skills implement reusable workflows such as generating a PRD, decomposing work into tasks, or running reviews.

### Knowledge Layer

Project knowledge tracks decisions, research, glossary terms, and open questions that arise during development.

### Memory Layer

Global memory stores lessons, patterns, failures, and improvement proposals across projects.

### Execution Layer

Autonomous run cycles allow the system to safely perform multiple steps of work while respecting review gates and stop conditions.

Together these layers form an **AI orchestration stack** that transforms ideas into structured outcomes.

The user does not interact with every layer directly. Instead, the orchestrator coordinates the system on the user's behalf.

---

## What You Can Build

The framework supports any software project that starts as an idea and ends as a shipped product.

**Project types:**

- Web applications
- Mobile applications (React Native, Swift/SwiftUI, Kotlin/Compose)
- SaaS products
- APIs and backend services
- Games (with dedicated Game Design Document support)
- Internal business tools

**Two planning modes** adapt to your project's maturity:

| Mode | Best For |
|------|----------|
| **Quick Start** | You have a clear idea and want a working scaffold immediately. Planning docs grow as you build. |
| **Full Planning** | You need to think through requirements, architecture, and scope before writing any code. |

The orchestrator coordinates the entire lifecycle: idea capture, problem validation, planning, architecture, development, testing, review, and deployment. Skills handle the specific work at each stage.

> **Note:** Non-software domains (books, courses, research) are planned as separate framework variants.

---

## Why the Distinction Matters

Many AI tools focus only on writing code. The AI Orchestration Framework recognizes that **building software requires more than code — it requires orchestration**.

The same orchestration principles — planning before building, tracking state, routing work to the right skill, preserving knowledge — apply across every phase of software development.

This makes the framework useful for:

- **Systems thinkers** who can architect and direct but hit a wall writing code
- **Builders** turning an app idea into a working product
- **Founders** prototyping and shipping an MVP
- **Parents** building educational tools with their kids
- **Solo developers** building a SaaS product end-to-end
- **Product managers** defining and tracking requirements
- **Small teams** coordinating across frontend, backend, and infrastructure
- **Anyone** who has ever had an idea for an app but didn't know how to start building it

---

## A Universal Idea Engine

At its highest level, Bashi becomes a **universal idea engine**.

The user supplies vision and direction. The orchestrated AI system supplies structure, execution, and iteration.

Instead of asking:

> "How do I write this code?"

The orchestrator asks:

> "What system do I need to produce this outcome?"

This shift — from syntax to orchestration — is what makes the framework accessible to people who have never written a line of code, and powerful for people who have.

---

## Summary

| Layer | Role |
|-------|------|
| **AI Orchestration Framework** | The method — how to organize AI agents, skills, and workflows for structured outcomes. |
| **Bashi** | The implementation — a ready-to-use template that puts the framework into practice. |

Together they allow users to move from **idea to structured outcome** without needing to cross the traditional Syntax Wall.

The barrier isn't gone — it's been replaced. Instead of learning syntax, you learn to orchestrate. And orchestration is something anyone can do.

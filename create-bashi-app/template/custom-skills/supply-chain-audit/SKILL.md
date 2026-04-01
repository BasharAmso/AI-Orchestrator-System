---
id: SKL-0031
name: Supply Chain Audit
description: |
  Audit the dependency supply chain for security risks beyond what `npm audit`
  or `pip audit` catches. Analyzes dependency health, maintainer trust signals,
  typosquatting risk, and transitive dependency exposure.
version: 1.0
owner: reviewer
triggers:
  - SUPPLY_CHAIN_AUDIT_REQUESTED
inputs:
  - Dependency manifests (package.json, requirements.txt, Gemfile, go.mod, etc.)
  - Lock files (package-lock.json, yarn.lock, poetry.lock, etc.)
  - .claude/project/STATE.md
outputs:
  - Supply chain risk report
  - .claude/project/STATE.md (updated)
tags:
  - security
  - dependencies
  - supply-chain
  - custom
---

# Skill: Supply Chain Audit

## Metadata

| Field | Value |
|-------|-------|
| **Skill ID** | SKL-0031 |
| **Version** | 1.0 |
| **Owner** | reviewer |
| **Inputs** | Dependency manifests, lock files, STATE.md |
| **Outputs** | Supply chain risk report, STATE.md updated |
| **Triggers** | `SUPPLY_CHAIN_AUDIT_REQUESTED` |

---

## Purpose

Go beyond `npm audit` and `pip audit` to assess the *health and trustworthiness* of your dependency supply chain. Known vulnerabilities are only part of the picture — abandoned packages, single-maintainer risks, typosquatting, and deep transitive dependencies are where real supply chain attacks happen.

Inspired by [Trail of Bits' supply-chain-risk-auditor skill](https://github.com/trailofbits/skills).

> **See also:** For code-level vulnerabilities and OWASP checks, see SKL-0015 (Security Audit).

---

## Procedure

### Step 1 — Inventory Dependencies

Read all dependency manifests and lock files. Build a dependency inventory:

| Field | Source |
|-------|--------|
| Direct dependencies | package.json, requirements.txt, etc. |
| Dev dependencies | Separate from production deps |
| Transitive dependencies | Lock files |
| Total dependency count | Lock file line count |
| Dependency depth | Max nesting level in lock file |

Flag if total dependency count exceeds thresholds:
- **Web app:** >200 total deps = HIGH concern
- **API/backend:** >100 total deps = HIGH concern
- **Library:** >50 total deps = MEDIUM concern

### Step 2 — Assess Dependency Health

For each **direct** dependency, evaluate:

| Signal | Healthy | Concerning | Risky |
|--------|---------|-----------|-------|
| Last publish | <6 months | 6-18 months | >18 months |
| Weekly downloads | >10,000 | 1,000-10,000 | <1,000 |
| Maintainers | 3+ | 2 | 1 (bus factor) |
| Open issues ratio | <20% | 20-50% | >50% |
| License | MIT, Apache, BSD | LGPL, MPL | GPL, AGPL, None, Unknown |
| Repository | Active, public | Archived | Missing, private |

> Note: This assessment uses publicly available metadata. For packages where metadata is unavailable, flag as "Unable to assess" rather than scoring.

### Step 3 — Check for Red Flags

| Red Flag | Severity | What to look for |
|----------|----------|-----------------|
| Typosquatting risk | HIGH | Package names similar to popular packages (e.g., `lodahs` vs `lodash`) |
| Install scripts | HIGH | `preinstall`, `postinstall` scripts in package.json that execute arbitrary code |
| Excessive permissions | MEDIUM | Packages requesting filesystem, network, or OS access beyond their stated purpose |
| Unpinned versions | MEDIUM | `"*"` or `"latest"` in dependency versions |
| No lock file | HIGH | Missing lock file means builds are non-reproducible |
| Deprecated packages | MEDIUM | Dependencies marked as deprecated by their maintainers |
| Name squatting | LOW | Packages with very few downloads that claim generic names |

### Step 4 — Evaluate Transitive Risk

Identify the highest-risk transitive dependencies — packages you didn't choose but are exposed to:

- Which transitive deps have the most dependents in your tree? (single points of failure)
- Are any transitive deps abandoned (>2 years, no maintainer)?
- Do any transitive deps have known vulnerabilities?

### Step 5 — Generate Report

Structure:
1. **Dependency Summary** — Total count, direct vs transitive, depth
2. **Health Assessment** — Table of direct deps with health signals
3. **Red Flags** — Specific findings with severity
4. **Transitive Risks** — Highest-risk transitive dependencies
5. **Recommendations** — Prioritized action items (replace, pin, remove, audit)

### Step 6 — Update STATE.md

Record audit completion and top-level findings.

---

## Constraints

- Assessment is based on publicly available metadata and heuristics
- Does not execute or install packages — read-only analysis
- Does not replace `npm audit` / `pip audit` — complements them with health/trust signals
- Health signals are indicators, not verdicts — a low-download package may be perfectly fine for a niche use case
- Never recommends removing a dependency without suggesting an alternative or explaining the trade-off

---

## Primary Agent

reviewer

---

## Definition of Done

- [ ] All dependency manifests identified and read
- [ ] Direct dependency count and transitive depth calculated
- [ ] Health assessment completed for all direct dependencies
- [ ] Red flag checks completed
- [ ] Transitive risk evaluation completed
- [ ] Report generated with prioritized recommendations
- [ ] STATE.md updated

## Output Contract

| Field | Value |
|-------|-------|
| **Artifacts** | Supply chain risk report (dependency health, red flags, transitive risks, recommendations) |
| **State Update** | `.claude/project/STATE.md` — mark task complete, log audit findings |
| **Handoff Event** | `TASK_COMPLETED` (supply chain audit complete) |

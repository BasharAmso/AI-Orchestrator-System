---
id: SKL-0015
name: Security Audit
description: |
  Audit code and dependencies for security vulnerabilities. Use this skill
  when a security review is requested, including OWASP checks, secrets
  scanning, and dependency audits.
version: 1.0
owner: reviewer
triggers:
  - SECURITY_REVIEW_REQUESTED
inputs:
  - Target files (from active task or event)
  - .claude/project/STATE.md
  - .claude/project/knowledge/DECISIONS.md
  - Dependency manifests (package.json, requirements.txt, etc.)
outputs:
  - Security report with severity ratings
  - .claude/project/STATE.md (updated)
tags:
  - review
  - security
  - audit
  - owasp
---

# Skill: Security Audit

## Metadata

| Field | Value |
|-------|-------|
| **Skill ID** | SKL-0015 |
| **Version** | 1.0 |
| **Owner** | reviewer |
| **Inputs** | Target files, STATE.md, DECISIONS.md, dependency manifests |
| **Outputs** | Security report, STATE.md updated |
| **Triggers** | `SECURITY_REVIEW_REQUESTED` |

---

## Purpose

Find security vulnerabilities before they reach production. OWASP Top 10 scan, secrets detection, dependency audit, and auth review. Read-only analysis — never modifies source files.

> **See also:** For config-level defaults and hardcoded credentials, see SKL-0029 (Insecure Defaults). For security review of code diffs, see SKL-0030 (Differential Security Review). For dependency health and trust signals, see SKL-0031 (Supply Chain Audit).

---

## Procedure

1. **OWASP Top 10 scan** of target files:
   - Injection (SQL, command, template)
   - Broken auth (weak passwords, session issues, missing MFA)
   - Sensitive data exposure (unencrypted PII, logged secrets, verbose errors)
   - XSS/XXE (unsanitized input in HTML/XML/templates)
   - Broken access control (missing authz checks, privilege escalation)
   - Security misconfiguration (debug mode in prod, default credentials)
   - CSRF (missing tokens on state-changing operations)
2. **Secrets scan** across codebase:
   - API keys, passwords, tokens, private keys, connection strings
   - `.env` files committed to version control
   - Pattern matching for common secret formats (AWS keys, JWT secrets)
3. **Dependency audit** (if manifests exist):
   - Check for known CVEs
   - Flag outdated packages with vulnerabilities
   - Recommend patched versions
4. **Auth and authorization review:**
   - Tokens validated on every protected route?
   - Passwords hashed with strong algorithm (bcrypt, argon2)?
   - Session management secure (httpOnly, secure flags, expiry)?
   - Principle of least privilege followed?
5. **Produce security report** with severity ratings:
   - **CRITICAL:** Exploitable now, blocks deployment
   - **HIGH:** Serious risk, fix before merge
   - **MEDIUM:** Should fix, track in task queue
   - **LOW:** Best practice improvement
6. **Update STATE.md** with findings.

---

## Constraints

- Never modifies source files — read-only analysis
- Never logs, echoes, or exposes secrets — even in reports
- Never suggests disabling security features without justification
- Always recommends well-maintained libraries over custom crypto/auth

---

## Primary Agent

reviewer

---

## Definition of Done

- [ ] OWASP Top 10 scan completed
- [ ] Secrets scan completed
- [ ] Dependency audit completed (if manifests exist)
- [ ] Auth and authorization reviewed (if applicable)
- [ ] All findings rated by severity
- [ ] Security report written to STATE.md

## Output Contract

| Field | Value |
|-------|-------|
| **Artifacts** | Security audit report with severity-rated findings (CRITICAL / HIGH / MEDIUM / LOW) in Execution Summary |
| **State Update** | `.claude/project/STATE.md` — mark task complete, log files modified |
| **Handoff Event** | `TASK_COMPLETED` (findings reported) |

## Knowledge Enhancement (MCP mode)

If Cortex MCP is available:
1. Call `search_knowledge` with query derived from task (e.g., "OWASP security patterns", "authentication best practices"), category="patterns"
2. If relevant results found, call `get_fragment` on the top result
3. Apply as supplementary context (does not override this skill's procedure)

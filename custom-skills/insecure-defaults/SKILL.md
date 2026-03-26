---
id: SKL-0029
name: Insecure Defaults Detection
description: |
  Detect insecure default configurations, hardcoded credentials, fail-open
  security patterns, and dangerous default values in application code and
  configuration files. Complements SKL-0015 (Security Audit) by focusing
  on configuration-level vulnerabilities that dependency scanners miss.
version: 1.0
owner: reviewer
triggers:
  - INSECURE_DEFAULTS_CHECK_REQUESTED
inputs:
  - Target source files and configuration files
  - .env.example (if exists)
  - .claude/project/STATE.md
  - .claude/project/knowledge/DECISIONS.md
outputs:
  - Insecure defaults report with severity ratings
  - .claude/project/STATE.md (updated)
tags:
  - security
  - configuration
  - audit
  - custom
---

# Skill: Insecure Defaults Detection

## Metadata

| Field | Value |
|-------|-------|
| **Skill ID** | SKL-0029 |
| **Version** | 1.0 |
| **Owner** | reviewer |
| **Inputs** | Source files, config files, .env.example |
| **Outputs** | Insecure defaults report, STATE.md updated |
| **Triggers** | `INSECURE_DEFAULTS_CHECK_REQUESTED` |

---

## Purpose

Scan application code and configuration files for insecure default values, hardcoded credentials, fail-open security patterns, and dangerous configurations that would survive into production. This catches the class of vulnerabilities that dependency scanners and OWASP checklists miss — the ones baked into *your* code, not your dependencies.

Inspired by [Trail of Bits' insecure-defaults skill](https://github.com/trailofbits/skills).

---

## Procedure

### Step 1 — Identify Configuration Surface

Scan the project for configuration files and patterns:

- `.env`, `.env.example`, `.env.local`, `.env.production`
- `config/`, `settings/`, any `*config*` files
- Docker Compose files, Dockerfiles
- CI/CD configs (`.github/workflows/`, `Jenkinsfile`, etc.)
- Database connection strings
- API endpoint configurations
- Authentication and session settings
- CORS and CSP headers

### Step 2 — Check for Hardcoded Secrets

Search for patterns that indicate hardcoded credentials:

| Pattern | Severity | Example |
|---------|----------|---------|
| Hardcoded API keys | CRITICAL | `apiKey = "sk-..."` |
| Hardcoded passwords | CRITICAL | `password = "admin123"` |
| Default JWT secrets | CRITICAL | `JWT_SECRET = "secret"` or `"changeme"` |
| Hardcoded database credentials | HIGH | `DB_PASSWORD = "postgres"` |
| Commented-out credentials | MEDIUM | `// password: "test123"` |
| Placeholder secrets in non-example files | HIGH | `TOKEN = "xxx"` in production configs |

### Step 3 — Check for Fail-Open Patterns

Identify code paths where security fails to the permissive state:

| Pattern | Severity | What to look for |
|---------|----------|-----------------|
| Auth bypass on error | CRITICAL | `catch { return true }` in auth middleware |
| CORS wildcard | HIGH | `Access-Control-Allow-Origin: *` in production |
| Debug mode defaults | HIGH | `DEBUG = true` without environment override |
| Disabled CSRF | HIGH | CSRF protection commented out or defaulting to off |
| Permissive CSP | MEDIUM | `Content-Security-Policy: default-src *` |
| Missing rate limiting | MEDIUM | Auth endpoints without rate limits |
| Insecure cookie defaults | MEDIUM | Missing `Secure`, `HttpOnly`, or `SameSite` flags |

### Step 4 — Check for Dangerous Defaults

| Pattern | Severity | What to look for |
|---------|----------|-----------------|
| Default admin accounts | CRITICAL | User seed data with admin/admin or similar |
| Open registration | HIGH | Registration enabled with no verification |
| Verbose error messages | MEDIUM | Stack traces or SQL errors exposed to client |
| Default ports on sensitive services | LOW | Database/cache on default ports without auth |
| Missing HTTPS redirect | MEDIUM | HTTP allowed without redirect in production config |
| Auto-approve patterns | HIGH | Code that auto-approves without validation |

### Step 5 — Generate Report

For each finding, document:
- **File and line number**
- **Severity** (CRITICAL / HIGH / MEDIUM / LOW)
- **What was found** (specific code or config)
- **Why it's dangerous** (attack scenario)
- **Recommended fix** (concrete code change)

### Step 6 — Update STATE.md

Record findings summary and severity counts.

---

## Constraints

- Read-only analysis — does not modify source files
- Findings are advisory unless severity is CRITICAL
- Does not replace SKL-0015 (Security Audit) — complements it with config-level focus
- Does not scan dependencies (that's SKL-0015's job)
- Never prints actual secret values in reports — redact to first/last 2 characters

---

## Primary Agent

reviewer

---

## Definition of Done

- [ ] All configuration files identified and scanned
- [ ] Hardcoded secrets check completed
- [ ] Fail-open patterns check completed
- [ ] Dangerous defaults check completed
- [ ] Each finding has file, line, severity, explanation, and fix
- [ ] No actual secrets exposed in the report
- [ ] STATE.md updated with findings summary

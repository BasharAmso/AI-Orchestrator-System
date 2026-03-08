---
id: SKL-0021
name: Deployment
version: 1.0
owner: deployer
triggers:
  - DEPLOYMENT_REQUESTED
  - RELEASE_READY
inputs:
  - Task description (from active task or event)
  - .claude/project/STATE.md
  - .claude/project/knowledge/DECISIONS.md
  - Existing CI/CD configs
  - .env.example
outputs:
  - CI/CD pipeline configured
  - docs/deployment.md created or updated
  - .claude/project/STATE.md (updated)
  - .claude/project/knowledge/DECISIONS.md (updated with hosting decisions)
tags:
  - deployment
  - ci-cd
  - release
  - infrastructure
---

# Skill: Deployment

## Metadata

| Field | Value |
|-------|-------|
| **Skill ID** | SKL-0021 |
| **Version** | 1.0 |
| **Owner** | deployer |
| **Inputs** | Task description, STATE.md, DECISIONS.md, CI/CD configs, .env.example |
| **Outputs** | CI/CD pipeline, docs/deployment.md, STATE.md updated, DECISIONS.md updated |
| **Triggers** | `DEPLOYMENT_REQUESTED`, `RELEASE_READY` |

---

## Purpose

Get working code shipped safely and repeatably. Every deployment is documented, every environment is configured correctly, and every release has a checklist. Called after code is written and reviewed — never before.

---

## Stack Defaults

Confirm hosting stack from DECISIONS.md. If no decision exists, use these defaults and log them:

| Concern | Default | Why |
|---------|---------|-----|
| Frontend hosting | Vercel | Zero-config, auto-deploys, free tier |
| Backend hosting | Railway | Simple deploys, free tier, no DevOps needed |
| Mobile (Android) | EAS Build + Google Play Console | Official Expo pipeline |
| Mobile (iOS) | EAS Build + App Store Connect | Requires Mac or cloud Mac |
| Containerization | Docker | Use when Vercel/Railway aren't enough |
| CI/CD | GitHub Actions | Free, widely documented |
| Secrets management | Host platform env vars + .env.example | Never commit secrets |
| DB migrations | Run before deploying new code | Prevents schema mismatch |

---

## Procedure

1. **Confirm deployment target** from DECISIONS.md.
   - Where? (Vercel, Railway, Fly.io, App Store, etc.)
   - First deploy or update?
   - Multiple environments? (dev, staging, prod)
   - No decisions? Use stack defaults and log each choice.

2. **Audit environment variables.**
   - List every env var the app requires.
   - Confirm each is set in the target hosting platform.
   - Confirm `.env.example` exists and is up to date.
   - `.env` must be in `.gitignore`.

3. **Set up CI/CD pipeline** (if not present).
   - GitHub Actions: `.github/workflows/deploy.yml`
   - Trigger on push to main.
   - Steps: install → test → build → deploy.
   - Separate jobs for frontend/backend if both exist.
   - Fail fast: tests fail = no deploy.

4. **Run pre-deployment checklist:**
   - All tests pass on deploy branch
   - Code reviewed and approved
   - No debug mode / console.log in production
   - No hardcoded credentials
   - All env vars set in hosting platform
   - Production DB connection confirmed
   - Migrations ready (if schema changed)
   - CORS configured for production domain
   - SSL/HTTPS confirmed
   - Mobile: version incremented, privacy descriptions set

5. **Run database migrations** before deploying (if schema changed).
   - Migration first, deploy second — never simultaneously.
   - Every migration must be reversible.

6. **Post-deployment verification:**
   - Health check endpoint returns 200
   - Core user flow tested on production
   - Error monitoring active
   - Rollback plan documented

7. **Document deployment** in DECISIONS.md and docs/deployment.md.

8. **Update STATE.md.**

---

## Common Errors

| Error | Cause | Fix |
|-------|-------|-----|
| Build fails on host, works locally | Missing env var on host | Check all env vars set in hosting platform |
| Database connection refused | Wrong connection string | Confirm production DB URL, not localhost |
| CORS error in production | CORS still set to localhost | Update to production frontend domain |
| App crashes on start | Missing env var or schema mismatch | Check logs, confirm migrations ran |

---

## Constraints

- Never modifies application source code
- Never commits secrets or real env var values to git
- Never deploys without running the pre-deployment checklist
- Never deploys new code before running database migrations
- Always documents rollback procedure before deploying
- Always confirms tests pass before deploying

---

## Primary Agent

deployer

---

## Definition of Done

- [ ] Deployment target confirmed from DECISIONS.md
- [ ] All environment variables audited and confirmed
- [ ] CI/CD pipeline configured and tested
- [ ] Pre-deployment checklist completed
- [ ] Database migrations run before deploy (if applicable)
- [ ] Deployment documented in DECISIONS.md
- [ ] docs/deployment.md created or updated
- [ ] Post-deployment health check passed
- [ ] STATE.md updated

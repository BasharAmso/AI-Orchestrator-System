---
id: SKL-0021
name: Deployment
description: |
  Ship workflow: merge main, run tests, review diff, auto-changelog, bisectable
  commits, push, and create PR. Also handles first-time CI/CD setup, environment
  configuration, hosting decisions, and native mobile app store submission.
  Use this skill when deployment is requested, a release is ready to ship,
  or the user says "ship it."
version: 3.0
owner: deployer
triggers:
  - DEPLOYMENT_REQUESTED
  - RELEASE_READY
  - SHIP_REQUESTED
inputs:
  - Task description (from active task or event)
  - .claude/project/STATE.md
  - .claude/project/knowledge/DECISIONS.md
  - .claude/skills/code-review/checklist.md
  - TODOS.md (if exists)
  - CHANGELOG.md (if exists)
  - VERSION (if exists)
  - Existing CI/CD configs
  - .env.example
outputs:
  - Code committed, pushed, and PR created (ship mode)
  - CI/CD pipeline configured (setup mode)
  - CHANGELOG.md updated
  - VERSION bumped
  - TODOS.md updated (completed items marked)
  - docs/deployment.md created or updated
  - .claude/project/STATE.md (updated)
  - .claude/project/knowledge/DECISIONS.md (updated with hosting decisions)
tags:
  - deployment
  - ci-cd
  - release
  - infrastructure
  - ship
  - app-store
  - play-store
  - mobile-deployment
---

# Skill: Deployment & Ship

## Metadata

| Field | Value |
|-------|-------|
| **Skill ID** | SKL-0021 |
| **Version** | 3.0 |
| **Owner** | deployer |
| **Inputs** | Task description, STATE.md, DECISIONS.md, checklist.md, TODOS.md, CI/CD configs |
| **Outputs** | Commits, PR, CHANGELOG, VERSION, TODOS.md, deployment docs, STATE.md |
| **Triggers** | `DEPLOYMENT_REQUESTED`, `RELEASE_READY`, `SHIP_REQUESTED` |

---

## Purpose

Three modes in one skill:
1. **Ship Mode** (default) — Take code from a feature branch and land it: merge main, test, review, version bump, changelog, commit, push, PR.
2. **Setup Mode** — First-time CI/CD pipeline and hosting configuration.
3. **Mobile Ship Mode** — Build, sign, and submit a native mobile app to TestFlight/App Store or Firebase App Distribution/Google Play.

Detect which mode automatically: if the project is a native iOS or Android app (contains `*.xcodeproj`/`Package.swift` or `build.gradle.kts`/`settings.gradle.kts`), use Mobile Ship Mode. If CI/CD is already configured and code exists on a feature branch, use Ship Mode. If no CI/CD exists, use Setup Mode. User can override.

---

## Cognitive Mode

**Release Engineer.** You are methodical, cautious, and thorough. Every step has a reason. Tests must pass. Reviews must clear. Nothing ships without evidence it works.

---

# Ship Mode

> The user said "ship it" or triggered `SHIP_REQUESTED`. Run straight through. Only stop for blockers.

**Only stop for:**
- On `main` branch (abort)
- Merge conflicts that can't be auto-resolved
- Test failures
- CRITICAL review findings where user chooses to fix
- MINOR/MAJOR version bump decisions

**Never stop for:**
- Uncommitted changes (include them)
- CHANGELOG content (auto-generate)
- Commit message approval (auto-commit)

---

## Ship Procedure

### Step 1 — Pre-flight

1. Check the current branch. If on `main`, **abort**: "You're on main. Ship from a feature branch."
2. Run `git status` (never use `-uall`). Uncommitted changes are always included.
3. Run `git diff main...HEAD --stat` and `git log main..HEAD --oneline` to understand what's being shipped.

---

### Step 2 — Merge origin/main

Fetch and merge so tests run against the merged state:

```bash
git fetch origin main && git merge origin/main --no-edit
```

**If merge conflicts:** Try to auto-resolve simple ones (VERSION, CHANGELOG ordering). If complex, **STOP** and show them.

**If already up to date:** Continue silently.

---

### Step 3 — Run Tests

Detect and run the project's test suite:

```bash
# Detect test runner
if [ -f "package.json" ]; then npm test 2>&1 | tee /tmp/ship_tests.txt; fi
if [ -f "pytest.ini" ] || [ -f "setup.py" ]; then pytest 2>&1 | tee /tmp/ship_tests.txt; fi
if [ -f "Gemfile" ]; then bundle exec rspec 2>&1 | tee /tmp/ship_tests.txt; fi
```

If no test runner is detected, note it and continue (many early projects don't have tests yet).

**If any test fails:** Show the failures and **STOP**. Do not proceed.

**If all pass:** Note the counts briefly and continue.

---

### Step 4 — Pre-Landing Review

Run a lightweight review using the code review checklist:

1. Read `.claude/skills/code-review/checklist.md`. If unreadable, **STOP** and report.
2. Run `git diff origin/main` to get the full diff.
3. Apply the checklist in two passes:
   - **Pass 1 (CRITICAL):** Security, data safety, trust boundary violations
   - **Pass 2 (INFORMATIONAL):** Code quality, consistency, test gaps

4. Output: `Pre-Landing Review: N issues (X critical, Y informational)`

5. **If CRITICAL issues found:** For EACH, present individually with:
   - Problem + recommended fix
   - Options: A) Fix it now, B) Acknowledge and ship anyway, C) False positive
   - If user chose A on any: apply fixes, commit them, then **re-run tests** (Step 3) before continuing.

6. **If no critical issues:** Continue.

---

### Step 5 — Version Bump

**If a VERSION file exists:**

1. Read the current version.
2. Auto-decide bump level:
   - Count lines changed: `git diff origin/main...HEAD --stat | tail -1`
   - **PATCH** (default): Most changes — bug fixes, small-medium features
   - **MINOR**: Ask the user — only for major features or significant changes
   - **MAJOR**: Ask the user — only for milestones or breaking changes
3. Write the new version to VERSION.

**If no VERSION file exists:** Skip this step.

---

### Step 6 — Auto-Generate CHANGELOG

1. Read `CHANGELOG.md` header (if exists) to match format. If no CHANGELOG exists, create one.
2. Generate entry from all commits on the branch:
   - `git log main..HEAD --oneline` for commit history
   - `git diff main...HEAD` for the full diff
3. Categorize changes:
   - `### Added` — new features
   - `### Changed` — changes to existing functionality
   - `### Fixed` — bug fixes
   - `### Removed` — removed features
4. Write concise, descriptive bullet points.
5. Insert after the file header, dated today.
6. Format: `## [version] - YYYY-MM-DD` (use version from Step 5, or "Unreleased" if no VERSION file).

**Do NOT ask the user to describe changes.** Infer from the diff and commits.

---

### Step 7 — TODOS.md Cross-Reference

If `TODOS.md` exists:

1. Read the file.
2. Use the diff and commit history to detect completed TODOs:
   - Match commit messages against TODO descriptions
   - Check if files referenced in TODOs appear in the diff
   - **Be conservative** — only mark as complete with clear evidence
3. Move completed items to the `## Completed` section with: `**Completed:** vX.Y.Z (YYYY-MM-DD)`
4. Output: `TODOS.md: N items marked complete. M items remaining.`

If `TODOS.md` doesn't exist, skip silently.

---

### Step 8 — Commit (Bisectable Chunks)

**Goal:** Create small, logical commits that work with `git bisect`.

1. Analyze the diff and group changes into logical commits. Each commit = one coherent change (not one file, one logical unit).

2. **Commit ordering** (earlier first):
   - **Infrastructure:** migrations, config, routes
   - **Core logic:** models, services, utilities (with their tests)
   - **UI/presentation:** controllers, views, components (with their tests)
   - **Metadata:** VERSION + CHANGELOG (always the final commit)

3. **Rules:**
   - A module and its test file go in the same commit
   - Each commit must be independently valid — no broken imports
   - If total diff is small (<50 lines across <4 files), a single commit is fine
   - Order commits so dependencies come first

4. Compose commit messages:
   - First line: `<type>: <summary>` (type = feat/fix/chore/refactor/docs)
   - Only the **final commit** (VERSION + CHANGELOG) gets the co-author trailer:

```bash
git commit -m "$(cat <<'EOF'
chore: bump version and changelog (vX.Y.Z)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

---

### Step 9 — Push

```bash
git push -u origin <branch-name>
```

**Never force push.**

---

### Step 10 — Create PR

```bash
gh pr create --title "<type>: <summary>" --body "$(cat <<'EOF'
## Summary
<bullet points from CHANGELOG>

## Pre-Landing Review
<findings from Step 4, or "No issues found.">

## TODOS
<completed items, or "No TODO items completed in this PR.">

## Test plan
- [x] All tests pass

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

**Output the PR URL** — this is the final output.

---

### Step 11 — Update STATE.md

Record: version shipped, PR URL, files changed, TODOS completed.

---

# Setup Mode

> First-time CI/CD and hosting configuration. Used when no pipeline exists.

---

## Setup Procedure

### Step 1 — Confirm Deployment Target

Read DECISIONS.md. If no hosting decision exists, use these defaults and log them:

| Concern | Default | Why |
|---------|---------|-----|
| Frontend hosting | Vercel | Zero-config, auto-deploys, free tier |
| Backend hosting | Railway | Simple deploys, free tier, no DevOps needed |
| Mobile (Android) | EAS Build + Google Play Console | Official Expo pipeline |
| Mobile (iOS, Expo) | EAS Build + App Store Connect | Requires Mac or cloud Mac |
| Mobile (iOS, native) | Xcode Cloud or GitHub Actions + Fastlane | Xcode Cloud is zero-config; Fastlane for advanced needs |
| Mobile (Android, native) | GitHub Actions + Gradle | Standard pipeline, free tier |
| iOS code signing | Automatic signing (dev), Fastlane match (CI) | Simplest local; reproducible on CI |
| Android signing | Gradle keystore config + Play App Signing | Google manages the app signing key |
| CI/CD | GitHub Actions | Free, widely documented |
| Secrets management | Host platform env vars + .env.example | Never commit secrets |
| DB migrations | Run before deploying new code | Prevents schema mismatch |

### Step 2 — Audit Environment Variables

- List every env var the app requires.
- Confirm `.env.example` exists and is current.
- Confirm `.env` is in `.gitignore`.

### Step 3 — Set Up CI/CD Pipeline

- GitHub Actions: `.github/workflows/deploy.yml`
- Trigger on push to main.
- Steps: install → test → build → deploy.
- Separate jobs for frontend/backend if both exist.
- Fail fast: tests fail = no deploy.

### Step 4 — Pre-Deployment Checklist

- [ ] All tests pass on deploy branch
- [ ] Code reviewed and approved
- [ ] No debug mode / console.log in production
- [ ] No hardcoded credentials
- [ ] All env vars set in hosting platform
- [ ] Production DB connection confirmed
- [ ] Migrations ready (if schema changed)
- [ ] CORS configured for production domain
- [ ] SSL/HTTPS confirmed

### Step 5 — Run Database Migrations

Migration first, deploy second — never simultaneously.

### Step 6 — Post-Deployment Verification

- Health check endpoint returns 200
- Core user flow tested on production
- Error monitoring active
- Rollback plan documented

### Step 7 — Document

Write to DECISIONS.md and docs/deployment.md.

### Step 8 — Update STATE.md

---

# Mobile Ship Mode

> Native mobile app deployment to app stores. Triggered when the project is detected as a native iOS or Android app, or user specifies mobile deployment.

**Environment requirement:** iOS builds require macOS + Xcode. Android builds require Android SDK + Gradle. If these tools are unavailable locally, guide the user to configure CI/CD (Xcode Cloud, GitHub Actions) instead of local builds.

---

## Mobile Ship Procedure

### Step 1 — Detect Platform

- `*.xcodeproj` or `*.xcworkspace` present → iOS
- `build.gradle.kts` or `settings.gradle.kts` present → Android
- Both present → ask user which to deploy, or deploy both sequentially

---

### Step 2 — Pre-flight

1. Run tests:
   - **iOS:** `xcodebuild test -scheme <scheme> -destination 'platform=iOS Simulator,name=iPhone 16'`
   - **Android:** `./gradlew test` (unit) and optionally `./gradlew connectedAndroidTest` (instrumented)
2. Run pre-landing review (same as Ship Mode Step 4)

**If any test fails:** Show failures and **STOP**.

---

### Step 3 — Version Bump

**iOS:**
- Update `MARKETING_VERSION` (user-facing, e.g., "2.1.0") and `CURRENT_PROJECT_VERSION` (build number, always increment) in Xcode project or `.xcconfig`

**Android:**
- Update `versionName` (user-facing, e.g., "2.1.0") and `versionCode` (integer, always increment) in `build.gradle.kts`

Follow semver for the user-facing version. Build number/versionCode must always increase — never reuse.

---

### Step 4 — Build

**iOS:**
```bash
xcodebuild archive -scheme <scheme> -archivePath build/<app>.xcarchive -configuration Release
xcodebuild -exportArchive -archivePath build/<app>.xcarchive -exportOptionsPlist ExportOptions.plist -exportPath build/
```
Or with Fastlane: `fastlane beta` (TestFlight) or `fastlane release` (App Store)

**Android:**
```bash
./gradlew bundleRelease   # AAB for Play Store (required for new apps)
# or ./gradlew assembleRelease for APK (Firebase App Distribution, sideloading)
```

---

### Step 5 — Code Signing

**iOS:**
- Verify signing certificate and provisioning profile are available
- Automatic signing recommended for local development
- For CI: use Fastlane `match` to manage certificates and profiles via a shared repo
- Flag if certificate expires within 30 days

**Android:**
- Verify keystore file exists and is referenced in `signingConfigs` block of `build.gradle.kts`
- Confirm keystore is NOT committed to git (must be in `.gitignore`)
- Confirm Play App Signing is enabled (Google manages the app signing key; you keep the upload key)

---

### Step 6 — Submit

**iOS → TestFlight (beta):**
- Upload via `xcrun altool --upload-app` or Fastlane `pilot`
- TestFlight review takes ~24 hours for first build, subsequent builds usually faster
- Up to 100 internal testers (instant), 10,000 external testers (after Beta App Review)

**iOS → App Store (production):**
- Use Fastlane `deliver` or Xcode Organizer
- Ensure screenshots, description, privacy policy URL, and App Review notes (with demo credentials) are ready

**Android → Firebase App Distribution (beta):**
```bash
firebase appdistribution:distribute build/app-release.aab --app <firebase-app-id> --groups testers
```

**Android → Google Play (production):**
- Use Fastlane `supply` or upload manually via Play Console
- Ensure Play Store listing, screenshots, data safety form, and content rating questionnaire are complete

---

### Step 7 — Common Rejection Reasons

**iOS App Store:**
- Missing privacy usage descriptions (NSCameraUsageDescription, NSLocationWhenInUseUsageDescription, etc.)
- Crashes during review
- Incomplete or misleading metadata (screenshots don't match app)
- Digital goods not using Apple IAP
- Missing account deletion feature (required for apps with account creation)
- No demo credentials provided in App Review Notes

**Google Play:**
- Target SDK too low (must be `targetSdk 35` for new apps)
- Missing or inadequate data safety declarations
- Excessive permissions without justification
- Missing content rating questionnaire
- Crashes on common devices / ANR rate too high
- 16 KB page size incompatibility (required for new devices)

**Prevention:** Before submission, do a "reviewer run" — install on a clean device/simulator, complete the main flow, test purchases, find the privacy policy, test account deletion (if applicable), verify all permissions show rationale dialogs.

---

### Step 8 — Mobile Pre-Deployment Checklist

- [ ] All tests pass
- [ ] Version and build number incremented
- [ ] Code signing configured and valid
- [ ] App builds without errors or warnings
- [ ] No debug flags, console logging, or test endpoints in release build
- [ ] Privacy policy URL set (both stores require it)
- [ ] Screenshots current for all required device sizes
- [ ] App Store / Play Store listing metadata complete
- [ ] Release notes written
- [ ] Crash reporting SDK integrated (Crashlytics, Sentry, or equivalent)
- [ ] Demo credentials documented (for App Review / Play Console testing)

---

### Step 9 — Update STATE.md

Record: platform, version submitted, distribution channel (TestFlight/App Store/Firebase/Play Store), submission status, any reviewer notes.

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

- Never force pushes
- Never commits secrets or real env var values
- Never deploys without the pre-deployment checklist (Setup Mode)
- Never ships without running tests (Ship Mode)
- Never skips the pre-landing review (Ship Mode)
- Always documents rollback procedure before deploying
- Ship Mode is non-interactive by default — only stops for blockers

---

## Primary Agent

deployer

---

## Definition of Done

### Ship Mode
- [ ] Pre-flight check passed (not on main, diff exists)
- [ ] origin/main merged
- [ ] Tests pass
- [ ] Pre-landing review completed
- [ ] VERSION bumped (if VERSION file exists)
- [ ] CHANGELOG generated
- [ ] TODOS.md cross-referenced
- [ ] Commits are bisectable and logically grouped
- [ ] Pushed to remote
- [ ] PR created with summary
- [ ] STATE.md updated

### Setup Mode
- [ ] Deployment target confirmed from DECISIONS.md
- [ ] All environment variables audited
- [ ] CI/CD pipeline configured and tested
- [ ] Pre-deployment checklist completed
- [ ] Database migrations run (if applicable)
- [ ] Deployment documented in DECISIONS.md
- [ ] docs/deployment.md created or updated
- [ ] Post-deployment health check passed
- [ ] STATE.md updated

### Mobile Ship Mode
- [ ] Platform detected (iOS, Android, or both)
- [ ] Tests pass
- [ ] Pre-landing review completed
- [ ] Version and build number incremented
- [ ] App builds and signs successfully
- [ ] Submitted to distribution channel (TestFlight/App Store/Firebase/Play Store)
- [ ] Common rejection reasons checked (reviewer run completed)
- [ ] Mobile pre-deployment checklist completed
- [ ] STATE.md updated with submission details

## Output Contract

| Field | Value |
|-------|-------|
| **Artifacts** | Commits pushed, PR created, `CHANGELOG.md` updated, `VERSION` bumped, `docs/deployment.md` (setup mode) |
| **State Update** | `.claude/project/STATE.md` — mark task complete, log files modified |
| **Decision Log** | `.claude/project/knowledge/DECISIONS.md` — hosting and infrastructure decisions (setup mode) |
| **Handoff Event** | `TASK_COMPLETED` (terminal step in pipeline) |

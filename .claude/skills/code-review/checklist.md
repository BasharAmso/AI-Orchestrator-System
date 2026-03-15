# Code Review Checklist

> Customizable review checklist used by SKL-0016 (Code Review).
> Projects can override this file with project-specific concerns.

---

## Pass 1 — CRITICAL (Must Fix)

These are production-breaking risks that tests typically don't catch.

### Security Vulnerabilities
- [ ] SQL injection — raw string interpolation in queries
- [ ] XSS — unescaped user input rendered in HTML/templates
- [ ] Command injection — user input passed to shell commands or `exec`
- [ ] Path traversal — user input used in file paths without sanitization
- [ ] SSRF — user-supplied URLs fetched by the server
- [ ] Hardcoded credentials, API keys, or secrets in source code
- [ ] Missing authentication on new endpoints
- [ ] Missing authorization — can user A access user B's data?
- [ ] CSRF protection missing on state-changing operations
- [ ] Insecure deserialization of user-supplied data

### Data Safety
- [ ] Destructive database operations without confirmation or safeguards
- [ ] Missing database transactions where atomicity is needed
- [ ] Data loss risk — DELETE/UPDATE without WHERE clause or backup
- [ ] Schema changes that break existing data or queries
- [ ] Missing input validation at system boundaries (API inputs, form data)

### Trust Boundary Violations
- [ ] LLM/AI output used directly without sanitization or validation
- [ ] External API responses trusted without verification
- [ ] User-generated content rendered without escaping
- [ ] Assuming upstream services always return valid data

---

## Pass 2 — INFORMATIONAL (Should Fix / Consider)

These improve quality but aren't production-breaking.

### Logic & Edge Cases
- [ ] Off-by-one errors in loops or array indexing
- [ ] Null/undefined handling — what happens when values are missing?
- [ ] Empty state handling — empty arrays, zero results, blank strings
- [ ] Race conditions in async code or concurrent operations
- [ ] Error messages that leak internal details to users

### Code Quality
- [ ] DRY violations — repeated logic that should be extracted
- [ ] Magic numbers or hardcoded strings that should be constants
- [ ] Dead code — unreachable branches, unused variables/functions
- [ ] Functions doing too many things (>20 lines, multiple responsibilities)
- [ ] Unclear naming — variables, functions, or files with ambiguous names
- [ ] Missing error handling — try/catch absent where operations can fail

### Consistency
- [ ] New code doesn't follow existing project patterns
- [ ] Import/dependency style inconsistent with rest of project
- [ ] File organization doesn't match project conventions
- [ ] Inconsistent naming conventions (camelCase vs snake_case mixing)

### Test Gaps
- [ ] New functionality without corresponding tests
- [ ] Tests only cover happy path — no error/edge case tests
- [ ] Test assertions that are too broad (e.g., "expect result to be truthy")
- [ ] Tests that depend on execution order or external state

### Performance
- [ ] N+1 query patterns (database call inside a loop)
- [ ] Large datasets loaded into memory without pagination
- [ ] Missing database indexes for new queries
- [ ] Synchronous blocking calls that should be async
- [ ] Missing caching for expensive repeated operations

---

## Suppressions — DO NOT Flag

These are intentionally excluded to reduce noise:

- Style preferences that don't affect correctness (bracket style, trailing commas)
- Missing comments on self-documenting code
- Import ordering
- Minor whitespace inconsistencies
- Using `console.log` in development-only code
- TODO/FIXME comments (these are tracked separately via TODOS.md)
- Type annotation completeness (unless it causes actual type errors)

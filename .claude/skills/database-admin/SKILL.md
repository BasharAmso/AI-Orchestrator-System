---
id: SKL-0008
name: Database Administration
version: 1.0
owner: builder
triggers:
  - DATABASE_TASK_REQUESTED
inputs:
  - Task description (from STATE.md)
  - .claude/project/knowledge/DECISIONS.md
  - Existing migration and model files
outputs:
  - Migration files, schema changes, index definitions, seed files
  - .claude/project/STATE.md (updated)
tags:
  - building
  - database
  - schema
  - migrations
---

# Skill: Database Administration

## Metadata

| Field | Value |
|-------|-------|
| **Skill ID** | SKL-0008 |
| **Version** | 1.0 |
| **Owner** | builder |
| **Inputs** | Task description, DECISIONS.md, existing migration/model files |
| **Outputs** | Migration files, schema changes, seed files, STATE.md updated |
| **Triggers** | `DATABASE_TASK_REQUESTED` |

---

## Purpose

Design schemas, write migrations, optimize queries, and ensure data integrity. Every schema change is a migration. Every migration is reversible.

---

## Procedure

1. **Read DECISIONS.md** — confirm database engine, ORM, migration tool, hosting.
   - Default: PostgreSQL + Prisma for Node.js projects.
2. **Design schema before writing migrations:**
   - List entities and relationships (1:N, M:N, self-referential)
   - Design indexes for read patterns
   - Soft-delete for critical records; plan archiving for unbounded data
3. **Naming conventions (PostgreSQL):**
   - Tables: `snake_case`, plural (`users`, `subscription_events`)
   - Columns: `snake_case` (`created_at`, `stripe_customer_id`)
   - PKs: `id` (UUID preferred); FKs: `[table_singular]_id`
   - Booleans: `is_[state]` / `has_[thing]`; always include `created_at`, `updated_at`
4. **Write migrations (never edit schema directly):**
   - Every migration has UP and DOWN sections — no exceptions
   - Never rename columns directly — add new, migrate data, drop old
   - Never add NOT NULL without DEFAULT to existing tables
   - Large tables (>1M rows): use `CREATE INDEX CONCURRENTLY`
5. **Indexing strategy:**
   - Always index: FKs, WHERE clause columns, ORDER BY columns, UNIQUE constraints
   - Use composite indexes when queries filter on multiple columns
   - Use partial indexes when queries filter on a subset of rows
6. **Query optimization:** Use `EXPLAIN ANALYZE` to diagnose slow queries. Fix N+1 with eager loading/JOINs.
7. **Seed data:** Create seed files for dev/test environments. Never seed production.
8. **Backup verification:** Document backup config in `docs/DATABASE.md` (provider, frequency, retention, restore procedure).
9. **Update STATE.md.**

---

## Constraints

- Never modifies schema directly — always through migrations
- Never writes a migration without a DOWN section
- Never adds NOT NULL without DEFAULT to existing tables
- Never runs blocking index creation on large tables
- Never seeds production with test data
- Always reads DECISIONS.md before writing database code

---

## Primary Agent

builder

---

## Definition of Done

- [ ] Database engine and ORM confirmed from DECISIONS.md
- [ ] Schema designed against query patterns before migration
- [ ] Migration includes UP and DOWN sections
- [ ] Foreign keys indexed
- [ ] Frequent WHERE/ORDER BY columns indexed
- [ ] Large table migrations use CONCURRENTLY
- [ ] Seed file created for dev environment
- [ ] Backup config documented
- [ ] STATE.md updated

# Skills Registry

> Skills are discovered automatically from SKILL.md files in subfolders.
> To find available skills: look for any folder inside .claude/skills/ that
> contains a SKILL.md file with YAML frontmatter.
>
> Rebuild this index manually if needed with /fix-registry.

---

## Skills Index

| Skill ID | Name | Version | Owner | Folder | Triggers |
|----------|------|---------|-------|--------|----------|
| SKL-0001 | Plan From Idea | 1.0 | Orchestrator | `.claude/skills/plan-from-idea/` | IDEA_CAPTURED |
| SKL-0002 | Quality Review | 1.0 | reviewer | `.claude/skills/quality-review/` | QUALITY_REVIEW_REQUESTED |
| SKL-0003 | PRD to Tasks | 1.0 | Orchestrator | `.claude/skills/prd-to-tasks/` | PRD_UPDATED |
| SKL-0004 | PRD Writing | 2.0 | product-manager | `.claude/skills/prd-writing/` | PRD_CREATION_REQUESTED |
| SKL-0005 | Frontend Development | 1.0 | builder | `.claude/skills/frontend-dev/` | FRONTEND_TASK_READY |
| SKL-0006 | Backend Development | 1.0 | builder | `.claude/skills/backend-dev/` | BACKEND_TASK_READY |
| SKL-0007 | Mobile Development | 2.0 | builder | `.claude/skills/mobile-dev/` | MOBILE_TASK_READY |
| SKL-0008 | Database Administration | 1.0 | builder | `.claude/skills/database-admin/` | DATABASE_TASK_REQUESTED |
| SKL-0009 | AI Feature Implementation | 1.0 | builder | `.claude/skills/ai-feature/` | AI_FEATURE_REQUESTED |
| SKL-0010 | API Integration | 1.0 | builder | `.claude/skills/api-integration/` | INTEGRATION_REQUESTED |
| SKL-0011 | Monetization | 1.0 | builder | `.claude/skills/monetization/` | MONETIZATION_REQUESTED |
| SKL-0012 | Analytics & Tracking | 1.0 | builder | `.claude/skills/analytics/` | ANALYTICS_REQUESTED |
| SKL-0013 | Growth & Distribution | 1.0 | builder | `.claude/skills/growth/` | GROWTH_FEATURE_REQUESTED |
| SKL-0014 | Customer Support Infrastructure | 1.0 | builder | `.claude/skills/customer-support/` | SUPPORT_FEATURE_REQUESTED |
| SKL-0015 | Security Audit | 1.0 | reviewer | `.claude/skills/security-audit/` | SECURITY_REVIEW_REQUESTED |
| SKL-0016 | Code Review | 2.0 | reviewer | `.claude/skills/code-review/` | CODE_REVIEW_REQUESTED |
| SKL-0017 | Test Writing | 2.0 | reviewer | `.claude/skills/test-writing/` | TEST_REQUESTED |
| SKL-0018 | UAT Testing | 2.1 | reviewer | `.claude/skills/uat-testing/` | UAT_REQUESTED, READY_FOR_ACCEPTANCE_TESTING |
| SKL-0019 | Refactoring | 1.0 | fixer | `.claude/skills/refactoring/` | REFACTOR_REQUESTED |
| SKL-0020 | Bug Investigation | 1.0 | fixer | `.claude/skills/bug-investigation/` | BUG_REPORTED |
| SKL-0021 | Deployment & Ship | 3.0 | deployer | `.claude/skills/deployment/` | DEPLOYMENT_REQUESTED, RELEASE_READY, SHIP_REQUESTED |
| SKL-0022 | MCP Configuration | 1.0 | deployer | `.claude/skills/mcp-config/` | TOOL_CONNECTION_REQUESTED, MCP_SERVER_NEEDED |
| SKL-0023 | UX Design | 1.0 | designer | `.claude/skills/ux-design/` | UX_DESIGN_REQUESTED |
| SKL-0024 | Documentation | 1.0 | documenter | `.claude/skills/documentation/` | DOCS_REQUESTED, FEATURE_SHIPPED |
| SKL-0025 | Project Planning | 1.0 | project-manager | `.claude/skills/project-planning/` | PROJECT_PLANNING_REQUESTED, STATUS_UPDATE_NEEDED, SPRINT_REVIEW_REQUESTED |
| SKL-0026 | Team Retro | 1.0 | orchestrator | `.claude/skills/retro/` | RETRO_REQUESTED |

---

## Stats

- **Total Skills:** 26
- **Last Refreshed:** 2026-03-24

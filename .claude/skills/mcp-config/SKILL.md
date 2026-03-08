---
id: SKL-0022
name: MCP Configuration
version: 1.0
owner: deployer
triggers:
  - TOOL_CONNECTION_REQUESTED
  - MCP_SERVER_NEEDED
inputs:
  - Task description (from active task or event)
  - .claude/project/STATE.md
  - Existing .mcp.json (if any)
outputs:
  - .mcp.json at project root (created or updated)
  - .claude/project/STATE.md (updated with Active MCP Integrations)
tags:
  - mcp
  - tooling
  - integration
  - configuration
---

# Skill: MCP Configuration

## Metadata

| Field | Value |
|-------|-------|
| **Skill ID** | SKL-0022 |
| **Version** | 1.0 |
| **Owner** | deployer |
| **Inputs** | Task description, STATE.md, existing .mcp.json |
| **Outputs** | .mcp.json, STATE.md updated |
| **Triggers** | `TOOL_CONNECTION_REQUESTED`, `MCP_SERVER_NEEDED` |

---

## Purpose

Configure Claude Code's `.mcp.json` to connect the project to external tools (GitHub, Notion, Slack, databases, etc.) via MCP servers. This is framework-level wiring — not application code that calls these services.

---

## Transport Defaults

| Context | Transport | Example |
|---------|-----------|---------|
| Local npm/Docker server | stdio | GitHub MCP, Postgres MCP |
| Remote cloud API | HTTP | Notion OAuth, Linear OAuth |

**Never use SSE transport** — deprecated and removed in Claude Code v2.0.9+.

---

## Server Defaults Table

| Service | Package / Endpoint | Transport | Credentials |
|---------|-------------------|-----------|-------------|
| GitHub | `@github/github-mcp-server` | stdio | `GITHUB_PERSONAL_ACCESS_TOKEN` |
| Notion (OAuth) | `https://mcp.notion.com/mcp` | HTTP | OAuth browser flow |
| Notion (API key) | `@notionhq/notion-mcp-server` | stdio | `NOTION_TOKEN` |
| Slack | `zencoderai/slack-mcp-server` | stdio | `SLACK_BOT_TOKEN`, `SLACK_TEAM_ID` |
| Linear | `https://mcp.linear.app/mcp` | HTTP | OAuth browser flow |
| PostgreSQL | `@modelcontextprotocol/server-postgres` | stdio | `POSTGRES_CONNECTION_STRING` |
| Supabase | `@modelcontextprotocol/server-supabase` | stdio | `SUPABASE_URL`, `SUPABASE_ANON_KEY` |
| Filesystem | `@modelcontextprotocol/server-filesystem` | stdio | none |
| Brave Search | `brave/brave-search-mcp-server` | stdio | `BRAVE_API_KEY` |

> If service not in this table, consult Explorer agent to research the correct server.

---

## Procedure

1. **Clarify what to connect:**
   - Which service(s)?
   - What capabilities needed? (read issues, write pages, query tables)
   - Project scope (committed) or local scope (developer-only)?

2. **Read existing .mcp.json** — preserve all existing server entries.

3. **Build config block** using transport defaults:
   - stdio: `"command": "npx", "args": ["-y", "<package>"], "env": {"<VAR>": "${<VAR>}"}`
   - HTTP: `"type": "http", "url": "<endpoint>"`
   - HTTP+OAuth: `"type": "http", "url": "<endpoint>"` (no token needed)

4. **Write updated .mcp.json** — merge new server with existing servers.

5. **Provide credential setup instructions:**
   - Export block for each `${ENV_VAR}` referenced.
   - Link to where the user obtains each token.

6. **Verify connection** via `claude mcp list` and `/mcp` command.

7. **Log to STATE.md** under Active MCP Integrations section.

---

## Common Errors

| Error | Cause | Fix |
|-------|-------|-----|
| `Connection closed` / `MCP error -32000` | Windows: npx can't run directly | Change to `"command": "cmd"`, prefix args with `"/c", "npx"` |
| `spawn npx ENOENT` | npx not in PATH | Use absolute path or fix shell PATH |
| Server not in `claude mcp list` | .mcp.json in wrong location | Must be at project root |
| Silent no-op | JSON syntax error | Validate with JSON linter |

---

## Constraints

- Never store raw secrets in .mcp.json — always use `${ENV_VAR}` expansion
- Never overwrite existing .mcp.json without reading and preserving existing servers
- Never configure SSE transport
- Never add servers the user hasn't requested
- Always use project scope for team-shared servers

---

## Primary Agent

deployer

---

## Definition of Done

- [ ] Requested MCP server(s) configured in .mcp.json
- [ ] All credentials use ${ENV_VAR} expansion (no raw secrets)
- [ ] Existing servers preserved
- [ ] Credential setup instructions provided
- [ ] Connection verified via `claude mcp list`
- [ ] STATE.md updated with Active MCP Integrations

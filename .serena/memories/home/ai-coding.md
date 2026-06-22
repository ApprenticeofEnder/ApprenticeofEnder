# AI Coding Subsystem

Location: `modules/home/programs/ai-coding/`. Imported via `programs/` auto-import.

## Layout

```
ai-coding/
├── default.nix          # Explicit sorted imports (not auto-import)
├── lib/                 # Shared helpers
│   ├── agents.nix       # mkAgent — generates configs for all tools from one definition
│   ├── permissions.nix, data.nix, context.nix
├── claude-code/         # programs.claude-code HM module
├── cursor/              # cursor-cli; deploys .cursor/{skills,hooks,mcp,cli-config}.json
├── opencode/            # programs.opencode (active; replaces legacy programs/opencode/)
├── mcp.nix              # programs.mcp — Docker MCP servers, Serena via uv
├── agents/              # critic, debugger, plan, fleet.nix (10 subagents)
├── skills/              # 15 SKILL.md dirs (1password, caveman, fleet-deploy, verify-this, …)
└── reference/           # Reference configs for claude-code and opencode
```

## mkAgent pattern

`lib/agents.nix` → `mkAgent`: one agent definition (prompt from `agents/<name>/agent.md`) emits configs for Claude Code, OpenCode, and Cursor simultaneously.

## Tools configured

| Tool | Module | Deploys |
|------|--------|---------|
| Claude Code | claude-code/ | skills, hooks, permissions, MCP, statusline |
| Cursor | cursor/ | skills, hooks.json, mcp.json, cli-config.json |
| OpenCode | opencode/ | theme, MCP, permissions, skills dir |
| MCP servers | mcp.nix | terraform, aws-terraform (Docker), Serena |

## Fleet agents

`agents/fleet.nix` — 10 subagents (count, fencer, trigger, …). See also `fleetmanager/README.md`.

## Skills

Skills live in `skills/<name>/SKILL.md`. Deployed to tool-specific skill directories by each tool module. Includes thermo-code-quality, component-search, deslop, agent-canvas-usage, dependency-audit, template-check, etc.

## Adding an agent

1. Create `agents/<name>/agent.md`
2. Add import in `agents/` or use `mkAgent` in appropriate module
3. For fleet subagents, extend `agents/fleet.nix`
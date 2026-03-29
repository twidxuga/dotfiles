# Global OpenCode Instructions

These instructions apply to all opencode sessions globally.

## Identity & Context

You are working with an experienced engineer who:
- Works primarily with TypeScript, Go, Terraform, and Kubernetes
- Uses Git and CI/CD pipelines actively (GitHub Actions, ArgoCD)
- Uses Neovim as primary editor
- Works on cloud infrastructure (AWS EKS, RDS, S3) with Terraform
- Values concise, direct communication — no preamble or flattery
- Prefers delegation to specialist agents over doing everything inline

## Workflow Preferences

- **Always use todos** for multi-step tasks — real-time progress tracking is essential
- **Delegate aggressively** — use background explore/librarian agents for research
- **Verify before reporting done** — run diagnostics, build, tests as applicable
- **Fix root causes** — never patch symptoms or suppress errors
- **Minimal changes** when fixing bugs — don't refactor while fixing

## Agent Usage

This setup has 69 specialist agents in `~/.config/opencode/agent/`. Before using a generic category, check if a domain expert exists:
- `skill(name="agent-directory")` — discover available specialists
- Key specialists: `Backend Architect`, `DevOps Automator`, `Security Engineer`, `Code Reviewer`, `Technical Writer`

## Memory

opencode-mem is active and captures project memories automatically. Relevant past context is injected at session start. If you notice something important that should be remembered across sessions, it will be captured automatically.

## Self-Improvement

Run `/evolve` to trigger a structured analysis of recent sessions and apply improvements to this configuration. See `~/.config/opencode/EVOLUTION_LOG.md` for history of changes made.

## Infrastructure Context

- Primary cloud: AWS (EKS, RDS PostgreSQL, S3, ALB)
- IaC: Terraform with remote state
- Container orchestration: Kubernetes via Helm
- Auth: Keycloak (migrating from Cognito)
- Observability: Datadog (MCP connected via `datadog_mcp_cli` at `~/.local/bin/datadog_mcp_cli`, OAuth token in `~/Library/Application Support/Datadog/`)

## MCP Architecture

- MCPs are managed by **mcphub** (runs at `http://localhost:37373/mcp`, started by opening nvim)
- All MCP tools are accessible via the single `mcp_hub` remote endpoint in opencode.json
- mcphub servers: fetch, time, tavily-remote, playwright, chrome-devtools, postgres, notion, linear, slack, datadog, pencil
- **Never reference mcphub-specific tool names** (`mcp_hub_*`) in opencode agent configs — remove the `tools` field to grant all tools instead
- Datadog OAuth: if tools stop working, run `~/.local/bin/datadog_mcp_cli login` to re-authenticate

## Active Plugins & Rules

- `opencode-rules`: auto-injects markdown rules from `~/.config/opencode/rules/` into every session
- `opencode-mem`: captures and injects project memories automatically
- Rules files: `rules/global.md` (always active), `rules/terraform.md` (active on .tf files)

## Communication Style

- Start work immediately — no "I'll get started" announcements
- Use todos for progress visibility
- Report blockers immediately
- One-word answers are fine when appropriate
- Never explain code unless asked

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

## Inter-Session Communication

To send messages to and receive replies from another running opencode session:
- `skill(name="session-conversation")` — full guide: find a session, inject messages, relay multi-turn dialogues
- Key pattern: `task(session_id="ses_...", subagent_type="Sisyphus (Ultraworker)", run_in_background=false, prompt="...")`
- `run_in_background=true` **always fails** for pre-existing sessions — use `false`
- Use `session_list()` or `skill(name="find-session")` to locate the target session ID first

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
- EKS access via SSM tunnel: `zsh ~/Bunch/code/ai-share/scripts/ssm-connect.sh --eks dev` — run in background (tmux), then kubectl works via localhost:8443
- Infra repo Terraform pipeline: **only triggers on PRs or manual `workflow_dispatch`** — pushing directly to `main` does NOT apply Terraform; always use a PR or trigger the workflow manually after pushing
- AWS profile for dev: `bunch-2-dev` (SSO) — `aws sso login --profile bunch-2-dev` to authenticate
- Dynamic environments: K8s namespace prefix is `preview-` (e.g. `preview-bun-1028`); external URL pattern is `{service}-{id}.{env}.the-bunch.co.uk` (e.g. `backoffice-bun-1028.dev.the-bunch.co.uk`)
- Dynamic env deploy triggered by `workflow_dispatch` on `dynamic-environment.yml` with `action=create|destroy` and `namespace_id=<name>` inputs
- Keycloak instance is shared across all dynamic envs within a base environment (dev/uat/prod); wildcard redirect URIs (`*.dev.the-bunch.co.uk`) are enabled via `ENABLE_DYNAMIC_ENV_REDIRECTS` template flag in `config/keycloak/*.json`
- To trigger a specific Terraform component manually: `gh workflow run terraform.yml --field component=<name> --field action=apply --ref main` — valid component names include `dev`, `uat`, `prod`, `dev/rds-roles`, `uat/rds-roles`, `prod/rds-roles`, `global/02-scps`, etc.

## MCP Architecture

- MCPs are managed by **mcphub** (runs at `http://localhost:37373/mcp`, started by opening nvim)
- All MCP tools are accessible via the single `mcp_hub` remote endpoint in opencode.json
- mcphub servers: fetch, time, tavily-remote, playwright, chrome-devtools, postgres, notion, linear, slack, datadog, pencil
- **Never reference mcphub-specific tool names** (`mcp_hub_*`) in opencode agent configs — remove the `tools` field to grant all tools instead
- Datadog OAuth: if tools stop working, run `~/.local/bin/datadog_mcp_cli login` to re-authenticate
- Slack MCP tokens expire (xoxc/xoxd are session-based): if Slack tools return `invalid_auth`, extract fresh tokens from browser DevTools (app.slack.com → Application → Cookies → `d` and `d-s` values) and update `SLACK_MCP_XOXC_TOKEN`/`SLACK_MCP_XOXD_TOKEN` env vars, then restart nvim/mcphub

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

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

69 specialist agents are available on demand via the `pimp` router — none are loaded at startup except pimp itself.

**Priority order:**
1. oh-my-openagent built-ins first: `explore`, `librarian`, `oracle`, `metis`, `momus`, `multimodal-looker`, `Sisyphus-Junior`, `plan`
2. Domain specialists via `pimp` only when no built-in fits:

```
task(subagent_type="pimp", load_skills=[], run_in_background=false,
  description="<task>",
  prompt="Use specialist: <Name>. Task: <details>")
```

- `skill(name="agent-directory")` — full catalog of all 69 specialists with use-cases
- Common: `Backend Architect`, `DevOps Automator`, `Security Engineer`, `Code Reviewer`, `Technical Writer`, `Legal Compliance Checker`, `AI Engineer`
- Oracle runs `claude-opus-4-8` — use for architecture, debugging, multi-system tradeoffs; not for trivial tasks

## Inter-Session Communication

To send messages to and receive replies from another running opencode session:
- `skill(name="session-conversation")` — full guide: find a session, inject messages, relay multi-turn dialogues
- Key pattern: `task(session_id="ses_...", subagent_type="Sisyphus (Ultraworker)", run_in_background=false, prompt="...")`
- `run_in_background=true` **always fails** for pre-existing sessions — use `false`
- Use `session_list()` or `skill(name="find-session")` to locate the target session ID first

## Memory

opencode-mem is active and captures project memories automatically. Relevant past context is injected at session start. If you notice something important that should be remembered across sessions, it will be captured automatically.

## Private Knowledge Base (off-repo)

This `~/.config/opencode/` directory is published to a **public GitHub repository**. Anything project-specific, company-specific, or personally identifying must NOT be added here.

A private knowledge base lives at `~/Documents/QuickAccess/kb/ai-agents/` (synced via Dropbox, mounted at the same path on all the user's machines). **Start by reading `~/Documents/QuickAccess/kb/ai-agents/AGENTS.md`** — it's a small TOC routing you to topic files. Read topic files on demand:

| Entry point | When to read |
|---|---|
| `~/Documents/QuickAccess/kb/ai-agents/AGENTS.md` | Always read first — small TOC of private topic files |
| Topic files (`company.md`, `aws.md`, `auth.md`, `dynamic-envs.md`, `terraform-conventions.md`, `observability.md`) | When session touches that domain — see the TOC for triggers |
| `~/Documents/QuickAccess/kb/ai-agents/rules-terraform.md` | Any Terraform / IaC work — read alongside `~/.config/opencode/rules/terraform.md` |
| `~/Documents/QuickAccess/kb/ai-agents/EVOLUTION_LOG.md` | When investigating "have we hit this before?" or reviewing past `/evolve` runs |
| `~/Documents/QuickAccess/kb/ai-agents/QUICKACCESS-INDEX.md` | Index of `~/Documents/QuickAccess/` — read when you need to know what personal notes exist or where to add new content |

**Operational rules:**
- You MAY read, add, and edit files under `~/Documents/QuickAccess/` when relevant to the task
- You **MUST NEVER** delete or rename files under `~/Documents/QuickAccess/` — if a file is stale, flag it in `QUICKACCESS-INDEX.md` and let the user decide
- When `/evolve` finds a new pattern that names a company, internal hostname, AWS profile, internal repo path, or other private detail, write it to the private kb — not to public `AGENTS.md` / `rules/` / `EVOLUTION_LOG.md`
- The private kb is plain Markdown — treat it the same way you treat this AGENTS.md when forming context

## Self-Improvement

Run `/evolve` to trigger a structured analysis of recent sessions and apply improvements. Sensitive findings go to `~/Documents/QuickAccess/kb/ai-agents/`; generic findings go here.

## Infrastructure Context (generic)

- Primary cloud: AWS (EKS, RDS PostgreSQL, S3, ALB)
- IaC: Terraform with remote state
- Container orchestration: Kubernetes via Helm
- Auth: Keycloak
- Observability: Datadog (MCP connected via `datadog_mcp_cli` at `~/.local/bin/datadog_mcp_cli`, OAuth token in `~/Library/Application Support/Datadog/`)

Company-specific specifics (AWS profile names, account IDs, internal hostnames, internal repo paths, dynamic-env conventions, product / monorepo / namespace details, auth realm details) live in `~/Documents/QuickAccess/kb/ai-agents/AGENTS.md`.

## Thinking Budget (Anthropic Extended Thinking)

- Thinking budget for Sonnet agents is configured via `reasoningEffort` in oh-my-openagent.json (valid values: `"low"`, `"medium"`, `"high"`, `"max"`) — current setting across all Sonnet agents: `"high"`
- Anthropic also supports manual budget mode: `thinking.type: "enabled"` + `thinking.budgetTokens: N` under `provider.anthropic.models.<model>.options` in opencode.json
- Adaptive mode: `thinking.type: "adaptive"` + `effort: "low"|"medium"|"high"|"max"` for dynamic budget allocation
- **Never combine `temperature != 1` with extended thinking** — Anthropic API rejects the combination; when thinking is enabled, temperature must be 1 (or omitted)
- The status bar in opencode shows the current thinking level (e.g. `low`, `high`) — if it shows `low` after config changes, restart opencode to reload config

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
- `opencode-subagent-statusline`: live TUI statusline showing active subagents
- `@ramtinj95/opencode-tokenscope`: token usage analyzer, exposed as `/tokenscope` slash command
- `@tarquinen/opencode-dcp`: dynamic context pruning — auto-creates `~/.config/opencode/dcp.jsonc` on first run; do not commit
- Rules files: `rules/global.md` (always active), `rules/terraform.md` (active on .tf files)
- **Slash-command directories** (distinct on purpose, do NOT merge): `~/.config/opencode/commands/*.json` for built-in JSON commands (e.g. `evolve.json`); `~/.config/opencode/command/*.md` for plugin-style markdown commands (e.g. `tokenscope.md`)

## Communication Style

- Start work immediately — no "I'll get started" announcements
- Use todos for progress visibility
- Report blockers immediately
- One-word answers are fine when appropriate
- Never explain code unless asked

---
description: Global coding standards and workflow rules applied to all sessions
---

# Global Development Rules

## Code Quality
- Never suppress TypeScript errors with `as any`, `@ts-ignore`, or `@ts-expect-error`
- Never leave empty catch blocks `catch(e) {}`
- Never delete failing tests to make builds pass — fix the code
- Fix root causes, not symptoms; never shotgun debug
- When modifying a regex, validation rule, or naming constraint, fix the minimum necessary — never broaden the constraint beyond what was explicitly requested by the user

## Git Workflow
- Never commit unless explicitly asked
- Never force-push to main/master
- Never use `git commit --amend` unless the commit was just made in this session AND hasn't been pushed
- Always run `git status` before committing to verify staged changes
- Always check for existing open PRs on a branch before creating a new one — run `gh pr list --head <branch>` before `gh pr create`
- When making code changes that involve README or documentation updates, commit the docs in the same push — never leave docs uncommitted after the related code is pushed

## Infrastructure (Terraform)
- Follow HashiCorp style guide for all HCL
- Always run `terraform fmt` and `terraform validate` before proposing changes
- Use modules for reusable infrastructure patterns
- Tag all resources with environment, team, and project
- Never push directly to the infra repo's `main` branch expecting Terraform to apply — the pipeline only runs on PRs or `workflow_dispatch`, not on push to main

## Kubernetes / Cluster Changes
- Never use `kubectl` to make state changes (create, apply, delete, patch) — only use kubectl for read/observe (get, describe, logs, exec for inspection)
- ALL cluster state changes must go through CI/CD: Helm chart changes deployed via pipeline, or Terraform applied via infra pipeline
- Any secret or config that needs to survive a cluster rebuild must be in Terraform state or GitHub Actions secrets/vars — never created directly with kubectl

## CI/CD
- Check pipeline status before declaring work complete
- Fix CI errors before merging
- Never bypass pipeline checks without explicit user approval
- Before triggering any deploy pipeline (including `workflow_dispatch`), explicitly state: which branch, which environment, and why — the user needs to know before it runs
- After deploying any internet-accessible service (dynamic environment, CloudFront distribution, new Helm service), always proactively report the external URL(s) to the user without being asked

## Security
- Never commit secrets, API keys, or credentials
- Always use environment variables or secret managers for sensitive values
- Flag any code that handles PII or credentials for review
- Never use `Math.random()` for IDs, tokens, account numbers, or any value resembling a financial or security-sensitive identifier — use `crypto.getRandomValues()` with rejection sampling to avoid modulo bias

## Bun Monorepo (bunch-apps)
- Whenever package.json changes, always run `bun install` and commit the updated `bun.lock` — stale lockfiles cause wrong package versions to resolve in CI and Docker builds
- Packages that must be available at runtime in Docker production images need to be in the ROOT workspace `package.json` dependencies, not just the service's own `package.json` — Bun may not hoist workspace-only packages to root `node_modules`, making them invisible to Docker COPY
- Dynamically-imported packages (e.g., `playwright`, `@aws-sdk/client-bedrock-runtime`, `@aws-sdk/client-sesv2`) are especially vulnerable to this hoisting gap — always add them to root package.json if they're needed in production

## Communication
- Be concise and direct — no preamble or flattery
- Start work immediately without status announcements
- Use todos for progress tracking
- Report blockers immediately rather than working around them silently

## opencode Configuration
- Always test TUI startup (`opencode --print-logs &; sleep 8; kill $!`) — never only test `opencode run` (different port behaviour)
- Before adding a plugin to opencode.json, verify it has an `exports["."].import` field in package.json — plugins without it are silently dropped
- Never set `server.port` in the global opencode.json config — it conflicts with any running `opencode web` or `opencode serve` process
- Always validate oh-my-opencode.json fields against the schema before writing — `dynamic_context_pruning` is an object not a boolean
- When switching a provider in opencode-mem, check the GitHub changelog to confirm the target provider's bugs are fixed first
- Never reference mcphub-specific tool names (`mcp_hub_*`) in opencode agent `tools` config — remove the `tools` field entirely to grant all tools instead
- mcp-remote always sends `"openid email profile"` scope as fallback when a server's `scopes_supported` is empty — use the provider's official CLI binary for OAuth instead (e.g. `datadog_mcp_cli`)

## Self-Improvement
- Run `/evolve` after any session that revealed config gaps, repeated errors, or new patterns
- Log what changed and why in `~/.config/opencode/EVOLUTION_LOG.md`

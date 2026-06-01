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
- CI steps that only run on **apply** (post-merge) are invisible during PR plan runs — shell scripts in those steps must be tested locally with `set -euo pipefail` before merging; broken-pipe bugs and other runtime errors won't surface in PR CI
- When generating passwords/random strings in `pipefail` shell scripts from `/dev/urandom`, always use `|| true` in the pipeline: `PASSWORD=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 32 || true)` — both `head` and `dd` cause SIGPIPE in `tr`, which `pipefail` treats as fatal
- When triggering multiple `workflow_dispatch` runs on the same branch/ref simultaneously, they share the same concurrency group and cancel each other — trigger sequentially (wait for each to start before firing the next)
- After EVERY merge to main, fire a background watcher on the post-merge main CI run before moving to the next task — silently-red main blocks all downstream PRs and is easy to miss when context shifts <!-- rule:r52c8b1 -->
- Never write `if [ -n "$VAR" ]` to skip a verification step when the var is empty — that "skip when empty" branch IS the bug. Make the var required (`[ -z "$VAR" ] && exit 1`) and let the workflow refuse to ship without it <!-- rule:r08d040 -->
- When verifying that a literal string appears in a file (e.g. an env value baked into HTML/JSON), use `grep -Fq` not `grep -qE` — production values often contain regex metacharacters (`*`, `.`, `+`, `[`) that ERE mis-handles <!-- rule:rfb0be1 -->
- When merging a workflow-file change that's coupled to an infra IAM change, the apps push-event deploy will race terraform apply (apply takes 3-5 min, OIDC retry budget is ~40s) — prefer `workflow_dispatch` after both merges land, or remove the `push:` trigger entirely on prod deploy workflows <!-- rule:r39cbc2 -->
- Turbo's hermetic env mode strips env vars not declared in `tasks.<task>.env` of `turbo.json` — when a workflow needs to pass new env to a build step (e.g. `ALLOWLIST`, `HB_API_BASE_URL`), update `turbo.json` BEFORE the workflow expects it to propagate <!-- rule:r9b3317 -->
- A successful deploy returning HTTP 200 is NECESSARY but not SUFFICIENT — always verify the actual served content (correct allowlist baked in, correct env vars resolved, expected bundle hash) against a real surface check, not just status codes <!-- rule:r06289e -->

## Security
- Never commit secrets, API keys, or credentials
- Always use environment variables or secret managers for sensitive values
- Flag any code that handles PII or credentials for review
- Never use `Math.random()` for IDs, tokens, account numbers, or any value resembling a financial or security-sensitive identifier — use `crypto.getRandomValues()` with rejection sampling to avoid modulo bias

## Bun Workspace / Monorepo
- Whenever package.json changes, always run `bun install` and commit the updated `bun.lock` — stale lockfiles cause wrong package versions to resolve in CI and Docker builds
- Packages that must be available at runtime in Docker production images need to be in the ROOT workspace `package.json` dependencies, not just the service's own `package.json` — Bun may not hoist workspace-only packages to root `node_modules`, making them invisible to Docker COPY
- Dynamically-imported packages (e.g., `playwright`, `@aws-sdk/client-bedrock-runtime`, `@aws-sdk/client-sesv2`) are especially vulnerable to this hoisting gap — always add them to root package.json if they're needed in production

## Reports & Diagrams
- When producing any report or documentation that requires diagrams, use Mermaid by default
- Exception: folder/directory trees must always use ASCII art, never Mermaid
- Never include raw `\n` escape sequences inside Mermaid node labels or box text — use `<br>` for line breaks within labels instead
- This applies equally to Markdown output and Notion pages

## Communication
- Be concise and direct — no preamble or flattery
- Start work immediately without status announcements
- Use todos for progress tracking
- Report blockers immediately rather than working around them silently

## opencode Configuration
- Always test TUI startup (`opencode --print-logs &; sleep 8; kill $!`) — never only test `opencode run` (different port behaviour)
- Before adding a plugin to opencode.json, verify its package.json has either `exports["."].import` OR both `main` and `"type":"module"` — plugins without a valid ESM entry point are silently dropped <!-- rule:r9f1a2b -->
- Never set `server.port` in the global opencode.json config — it conflicts with any running `opencode web` or `opencode serve` process
- Always validate oh-my-openagent.json fields against the schema before writing — `dynamic_context_pruning` is an object not a boolean
- When switching a provider in opencode-mem, check the GitHub changelog to confirm the target provider's bugs are fixed first
- Never reference mcphub-specific tool names (`mcp_hub_*`) in opencode agent `tools` config — remove the `tools` field entirely to grant all tools instead
- mcp-remote always sends `"openid email profile"` scope as fallback when a server's `scopes_supported` is empty — use the provider's official CLI binary for OAuth instead (e.g. `datadog_mcp_cli`)
- Never set `temperature` on an Anthropic agent that uses extended thinking (reasoningEffort or thinking.budgetTokens) — Anthropic requires temperature=1 for extended thinking; setting any other value causes an API error <!-- rule:r-RETRO-1 -->
- Never pin version numbers for opencode plugins or Neovim plugins — allow auto-update; pinning prevents security fixes and feature updates from landing automatically <!-- rule:r-RETRO-2 -->
- `dcp.jsonc` is plugin runtime state generated by `@tarquinen/opencode-dcp` — never commit it; lives at `~/.config/opencode/dcp.jsonc` and regenerates on next opencode start if deleted <!-- rule:r-NEW-2 -->

## macOS CLI Differences
- macOS uses BSD `ps`, not GNU — `ps aux --sort=-%mem` is invalid; use `ps aux -m` to sort by memory (descending) or `ps aux -r` for CPU
- macOS uses BSD `du` — use `-d 1` for max-depth instead of GNU's `--max-depth=1`
- macOS `sort` does not support `-h` (human-readable) by default — pipe through `gsort -h` (from coreutils) if needed

## Notion Publishing
- When publishing a report or document to a Notion page, always create a **child page** under the target page — never replace the content of an existing page
- Use `mcp_hub_notion__notion-create-pages` with `parent: {page_id: "<target-page-id>"}` to create the child
- First `fetch` the target page to confirm its ID and see its existing structure before publishing

## Testing with Real Infrastructure
- When testing CI/CD workflows, always create **new branches from main** for testing — never make edits on existing feature branches
- Always clean up test namespaces (and their ingresses) immediately after testing — stale ingresses in a shared ALB ingress group (`alb.ingress.kubernetes.io/group.name`) block the group from reconciling for ALL environments until removed
- Before adding Cognito or any auth annotation to an ALB ingress, **verify the feature is actually used** — invalid Cognito client IDs in a shared group cause 503s across all environments in the group

## Bun Bundling (`--external`)
- `bun build --external <pkg>` means `<pkg>` is NOT bundled — it must exist at runtime in `node_modules` of the production image
- Services that only copy `dist/` to production (no `node_modules`) will crash with `Cannot find module` for any `--external` package that has a top-level import
- Use **conditional `require()`** (not top-level `import`) for optional/external packages so the require only executes when the feature is actually enabled: `if (featureEnabled) { const lib = require('optional-pkg'); }`
- ECR BuildKit cache uses a `:buildcache` tag per repo — add a lifecycle policy to expire it after 7 days to prevent accumulation

## Self-Improvement
- Run `/evolve` after any session that revealed config gaps, repeated errors, or new patterns
- Log what changed and why in `~/.config/opencode/EVOLUTION_LOG.md`
- Do not call Oracle to verify trivial tasks (CLI queries, single-command lookups, factual lookups) — Oracle is for architecture, debugging, and multi-system tradeoffs; calling it for trivial tasks wastes tokens and breaks ulw-loop verification
- When Oracle gives a high-confidence recommendation that involves a config change (resolve.conditions, package.json exports, build tool options), reproduce locally to verify before applying — Oracle reasons from spec/docs, not from your specific tool versions, and its recommendation can be correct-in-theory but wrong-in-your-setup <!-- rule:r0d29ec -->

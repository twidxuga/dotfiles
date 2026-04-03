# Evolution Log

Tracks changes made by `/evolve` runs and manual configuration improvements.

---

## 2026-03-28 — Session: opencode Reconfiguration Audit

### Sessions Analysed
- 1 long manual session covering full opencode config audit, plugin testing, and debugging
- Key patterns found: 3 config bugs introduced and fixed, 2 silent failures discovered, 1 startup hang caused by config

### Changes Applied

**`rules/global.md`**
- Added `## opencode Configuration` section with 5 rules derived from bugs hit in this session:
  - Always test TUI startup, not just `opencode run`
  - Verify plugin `exports` field before adding to plugin list
  - Never set `server.port` globally (conflicts with running web/serve processes)
  - Validate oh-my-opencode.json fields against schema (`dynamic_context_pruning` is object not boolean)
  - Check provider changelog before switching opencode-mem AI provider
- Added `## Self-Improvement` section with `/evolve` usage reminder

**`AGENTS.md`**
- Added `## Self-Improvement` section pointing to this log and the `/evolve` command

### Bugs That Generated These Rules

| Bug | Root Cause | Rule Added |
|-----|-----------|------------|
| TUI hung on startup | `server: {port: 4096}` conflicted with running `opencode web` | Never set server.port globally |
| `opencode-notify` silently not loaded | No `exports["."]` field in package.json | Verify exports before adding plugin |
| `dynamic_context_pruning: true` type error | Should be object `{enabled: true, ...}` not boolean | Validate against schema first |
| opencode-mem timeouts | Provider switch needed changelog verification | Check changelog before switching provider |
| Tested with wrong command | `opencode run` uses random port, TUI uses config port | Always test actual TUI startup |

### Skipped (low confidence)
- Potential rule about `preemptive_compaction_threshold` — field not in current schema but was in original config; behavior unclear, monitoring

### Configuration Files Added This Session
- `~/.config/opencode/commands/evolve.json` — the `/evolve` command itself
- `~/.config/opencode/skills/evolve/SKILL.md` — 5-phase evolution framework
- `~/.config/opencode/rules/terraform.md` — Terraform-specific rules
- `~/.config/opencode/AGENTS.md` — global instructions file

---

## 2026-03-29 — Evolution Run (via /evolve)

### Sessions Analysed
- 2 substantive sessions from 2026-03-28 to 2026-03-29
- `ses_2c9bb65c7ffe` (111 msgs): MCP reconfiguration, Datadog OAuth investigation, datadog_mcp_cli installation
- `ses_2cba9b55bfferd` (171 msgs): Full opencode audit and reconfiguration

### Key Patterns Found
- 1 correction (git commit without permission — rule already exists, rule text reinforced)
- 2 config bugs (mcphub tool name abstraction leak, mcp-remote OAuth scope fallback)
- 3 missing context items (mcphub architecture, datadog_mcp_cli, opencode-rules plugin)

### Changes Applied

**`AGENTS.md`**
- Expanded `## Infrastructure Context`: added `datadog_mcp_cli` install location and OAuth token path
- Added `## MCP Architecture` section: mcphub port/lifecycle, server list, tool naming rule, Datadog OAuth re-auth command
- Added `## Active Plugins & Rules` section: documents opencode-rules, opencode-mem, and which rule files are active

**`rules/global.md`** — Added 2 rules to `## opencode Configuration`:
- Never reference `mcp_hub_*` tool names in opencode agent configs — remove `tools` field to grant all tools
- mcp-remote always sends `"openid email profile"` fallback scope when `scopes_supported: []` — use provider's official CLI binary instead

### Root Causes That Generated These Rules

| Pattern | Root Cause | Rule Added |
|---------|-----------|------------|
| reflection agent had `mcp_hub_tavily_*` in tools config | Hardcoded mcphub names break abstraction | Remove `tools` field; never use `mcp_hub_*` names in config |
| Datadog OAuth `invalid_scope` via mcp-remote | mcp-remote falls back to `"openid email profile"` when `scopes_supported: []` | Use `datadog_mcp_cli` binary; document in AGENTS.md |
| Datadog MCP config not in AGENTS.md | Not documented after install | Added mcphub + datadog_mcp_cli full section to AGENTS.md |

### Skipped (low confidence)
- Potential rule about git commit guard — correction happened once, existing rule sufficient; monitoring

### Next Evolution Focus
- Watch for: agent delegation patterns (are specialist agents being invoked?), opencode-rules rule file quality, memory injection effectiveness

---

---

## 2026-03-30 — Evolution Run (via /evolve)

### Sessions Analysed
- 1 very large session (`ses_2d97cb36effenOdt7MRvD7fPC2`, 1915 messages, 2026-03-25 to 2026-03-30)
- Full hellobill deployment cycle: pipeline fixes, quote-engine-worker, CI remediation

### Key Patterns Found

| Pattern | Type | Source |
|---|---|---|
| Agent used `kubectl` to create K8s secrets directly | Correction ×2 | "don't make changes to the cluster outside GitHub using PRs, CI and the pipelines" |
| Agent triggered deploy without explaining branch/env/why | Correction | "why are you deploying microservices? from which branch?" |
| bun.lock not committed when package.json changed | New pattern | relay-api typecheck broke — stale lockfile resolved wrong zod version |
| Bun workspace root hoisting gap | New pattern | playwright, bedrock-runtime, sesv2 missing from root node_modules in Docker |
| Math.random() used for financial account numbers | Security gap | CodeQL CWE-338 on wallet-api (caught by Oracle during /evolve verification) |
| Infra Terraform doesn't run on push to main | Missing context | 45 min debugging why policy change didn't apply after direct push |
| EKS SSM tunnel script location unknown | Missing context | Had to discover at runtime each session |

### Changes Applied

**`rules/global.md`**
- Added `## Kubernetes / Cluster Changes` section: never use kubectl for state changes; all changes via CI/CD; secrets must be in Terraform/GitHub Actions not kubectl
- Added `## Bun Monorepo (bunch-apps)` section: bun.lock must be committed with package.json; root package.json must include runtime-critical packages; dynamically-imported packages especially vulnerable to hoisting gap
- Extended `## Infrastructure (Terraform)`: added rule that infra pipeline only runs on PRs or workflow_dispatch, not on push to main
- Extended `## CI/CD`: added rule to explicitly state branch, environment, and reason before triggering any deploy pipeline
- Extended `## Security`: added Math.random() prohibition for financial/security-sensitive identifiers; use crypto.getRandomValues() with rejection sampling

**`AGENTS.md`**
- Extended `## Infrastructure Context`: added EKS SSM tunnel script path and usage, Terraform pipeline trigger clarification, AWS SSO profile for dev

### Skipped (low confidence)
- Potential rule about IRSA ARNs being set via infra pipeline vs manual — project-specific, not universal enough for global rules
- Potential Bun Dockerfile pattern (fake root package.json in builder stage) — too specific to one project's setup

### Next Evolution Focus
- Watch for: Claude-guided browser navigation patterns (procedures vs prompts debate), public endpoint security patterns, Bun hoisting issues in other services

---

---

## 2026-04-03 — Evolution Run (via /evolve)

### Sessions Analysed
- 7 substantive sessions from 2026-03-31 to 2026-04-03
- `ses_2b768a670ffeVUDd9sY1Bybxpm` (1038 msgs): Dynamic environment frontend URL support — Keycloak wildcard redirect URIs, dynamic env URL conventions, PR management
- `ses_2bd2766e8ffewCzKm8BtceZjv3` (650 msgs): BT broadband switch automation (Playwright scripts)
- `ses_2c1841487ffewFYP6uyheY3Omn` (342 msgs): Octopus energy switch automation
- `ses_2dfe65550ffeiXha8l2Nj16O94` (121 msgs): Customer surveys CloudFront/S3 static site
- `ses_2c60bb82fffeNFF2l2AWDwcktS` (81 msgs): Infra pipeline monitoring and session-watch workflows

### Key Patterns Found

| Pattern | Type | Source |
|---|---|---|
| Agent widened `preview-bun-*` regex to `preview-*` when user wanted narrower targeted fix | Correction | "That PR is wrong. the namespace must start with preview- instead of preview-bun- but we shouldn't relax it completely" |
| Agent created PR without checking if branch already had one | Correction | "PR 351 was already merged..." |
| Agent completed task without committing README | Correction ×2 | "Ok you didn't commit the readme!" (surveys + infra sessions) |
| Agent didn't report external URL after deploying dynamic env | Missing behavior | "Obviously I need the external link to the backoffice for the new dynamic env" |
| Dynamic env namespace prefix re-discovered each session | Missing context | Repeated discovery in infra sessions: prefix is `preview-`, not `preview-bun-` |

### Changes Applied

**`rules/global.md`**
- Added rule to `## Code Quality`: never broaden regex/validation constraints beyond what was explicitly requested
- Added rule to `## Git Workflow`: always `gh pr list --head <branch>` before `gh pr create`; commit README/docs in same push as related code
- Added rule to `## CI/CD`: proactively report external URLs after any internet-accessible service is deployed

**`AGENTS.md`**
- Extended `## Infrastructure Context`: added dynamic environment conventions (namespace prefix `preview-`, URL pattern, workflow_dispatch trigger, Keycloak wildcard flag)

### Root Causes That Generated These Rules

| Pattern | Root Cause | Rule Added |
|---------|-----------|------------|
| Constraint over-relaxed | Agent interpreted "fix the namespace prefix" as "make it more general" | Only widen constraint by minimum required |
| PR created without state check | No habit of `gh pr list` before `gh pr create` | Explicit pre-create check in git rules |
| README left uncommitted | Agent declared "done" without verifying all changed files were committed | Doc commits in same push as code |
| URL not reported proactively | Agent only reported when asked | Always proactively report external URLs on deploy |
| Dynamic env conventions re-discovered | Context not in AGENTS.md | Added to infra context section |

### Skipped (low confidence)
- Potential rule about Keycloak doc-checking — only one explicit mention, and existing librarian delegation covers it
- Potential rule about context compaction workflow (user frustration: "Fuck this please continue!") — caused by long sessions, not a config gap

### Next Evolution Focus
- Watch for: constraints over-relaxed in other contexts (API validation, naming rules)
- Watch for: Keycloak configuration errors caused by missing doc-lookup

*This log is maintained by `/evolve` and manual sessions. Run `/evolve` to add a new entry.*

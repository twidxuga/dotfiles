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

*This log is maintained by `/evolve` and manual sessions. Run `/evolve` to add a new entry.*

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

*This log is maintained by `/evolve` and manual sessions. Run `/evolve` to add a new entry.*

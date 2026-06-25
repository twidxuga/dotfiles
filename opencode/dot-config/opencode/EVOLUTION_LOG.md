# Evolution Log (Public)

Tracks generic, non-sensitive changes made by `/evolve` runs and manual configuration improvements.

> **Sensitive findings** (anything naming the user's employer, internal hostnames, AWS profiles, internal repo paths, PR numbers, internal namespaces, etc.) live in `~/Documents/QuickAccess/kb/ai-agents/EVOLUTION_LOG.md` — that file contains the full evolve history including the company-specific entries from 2026-03 through 2026-05.

---

## 2026-05-15 — Privacy Migration

### Trigger
Public `~/.config/opencode/` is published to `github.com/<user>/dotfiles` (public). `/evolve` had been writing company-identifying content into public files (AGENTS.md, EVOLUTION_LOG.md, rules/terraform.md).

### Changes Applied

**Private kb created at `~/Documents/QuickAccess/kb/ai-agents/`** (Dropbox-synced, never pushed to git):
- `AGENTS.md` — company / infrastructure / auth / dynamic-env / product-name / SSM tunnel specifics
- `rules-terraform.md` — SCP details, IRSA conventions, internal namespace names, monorepo bundling specifics
- `EVOLUTION_LOG.md` — full history including all company-named entries
- `QUICKACCESS-INDEX.md` — recursive index of `~/Documents/QuickAccess/` for agents

**Public `AGENTS.md` scrubbed**:
- Removed AWS profile name, internal hostnames, internal repo paths, dynamic-env conventions, product URL details, Keycloak realm names
- Added `## Private Knowledge Base (off-repo)` section pointing agents to read `~/Documents/QuickAccess/kb/ai-agents/*` when relevant
- Added operational rules: agents MAY read/add/edit but NEVER delete or rename files in `~/Documents/QuickAccess/`

**Public `rules/terraform.md` scrubbed**:
- Replaced SCP-named rules and IRSA-namespace rules with generic patterns
- Added pointer to private `kb/ai-agents/rules-terraform.md` for company-specific rules

**Evolve skill updated** (`skills/evolve/SKILL.md`):
- New Phase 2 sub-step: classify findings as `generic` vs `sensitive` before writing
- New routing table: sensitive content goes to `~/Documents/QuickAccess/kb/ai-agents/`
- New Phase 6: maintain `QUICKACCESS-INDEX.md`
- New safety constraint: never write company identifiers into `~/.config/opencode/`

### Next Evolution Focus
- Watch for: agents writing sensitive content to public files (regression check on each `/evolve` run)
- Watch for: stale entries in `QUICKACCESS-INDEX.md` as files are added/changed

---

*Older entries (2026-03 through 2026-05) were moved to the private kb. They describe `/evolve` improvements but contain too many company-identifying strings to stay public. See `~/Documents/QuickAccess/kb/ai-agents/EVOLUTION_LOG.md` for the full history.*

---

## 2026-05-15 — Evolution Run [v2, applied]

### Sessions Analysed
- ~10 sessions reviewed (May 1–15)
- Patterns: skill self-gaps, plugin-install rule overfitting, untracked plugin runtime files

### Applied (Public)
- `skills/evolve/SKILL.md` r-NEW-1 → Phase 0 file list now includes `command/*.md` and `dcp.jsonc` (skill-gap, Value=100)
- `AGENTS.md` r-NEW-3 → Documented `commands/` vs `command/` directory split + new plugin entries (missing-context, Value=30)
- `opencode.json` + `rules/global.md` r-NEW-2 → `dcp.jsonc` added to watcher.ignore; rule added explaining it as plugin runtime state (friction, Value=60)
- `skills/evolve/SKILL.md` r-NEW-4 → Phase 6c clarified for `--dry-run` mode (skill-gap, Value=40)

### Queued (4 candidates)
- qa1b2c3: evolve.json --dry-run description gap (Value=40, outdated-context)
- qd4e5f6: new plugin usage docs missing (Value=15)
- qg7h8i9: plugin install rule too strict, proposed OR rewrite (Value=24, overfitting)
- qj0k1l2: Category+Skill Reminder noise in tool outputs (Value=1.25, source TBD)

### Telemetry backfill
- r-RETRO-1: temperature=1 with extended thinking (from May 13 run)
- r-RETRO-2: never pin plugin versions (from May 1 run)

### Privacy regressions (Phase 0)
- None — clean pass

### Next focus
- Identify source of `[Category+Skill Reminder]` injection
- Watch for citations / recurrences of r-NEW-1..4 in next 2 weeks

---

## 2026-05-16 — Evolution Run [v3, applied]

### Sessions Analysed
- opencode-config sessions from May 15–16 reviewed
- No new patterns beyond May 15 run — this run focused on queue promotion and telemetry

### Applied (Public)
- `rules/global.md` r9f1a2b → Plugin ESM entry-point rule updated: OR clause added for `main`+`"type":"module"` alternative (overfitting fix, promoted from qg7h8i9, Value=24)

### Queued (3 remaining)
- qa1b2c3: evolve.json --dry-run description gap (Value=40, outdated-context, pending)
- qd4e5f6: new plugin usage docs missing (Value=15, missing-context, pending)
- qj0k1l2: Category+Skill Reminder noise in tool outputs (Value=1.25, source TBD, pending)

### Reflexion (Phase 6a)
- 6 rules from May 15 run: all `monitoring` — too early to validate (<2 days old, no citations yet)
- Next reflexion opportunity: ~2026-05-29 (2-week window)

### Privacy regressions (Phase 0)
- None — clean pass

### Next focus
- Continue watching for `[Category+Skill Reminder]` injection source
- Monitor r-NEW-1..4 and r-RETRO-1..2 for first citations

---

## 2026-05-29 — Evolution Run [v2, applied]

### Sessions Analysed
- Today's prod-CDN deploy cascade session (primary; ~80min wall-clock, 5 PRs through CI, 2 deploys) — full details in private kb
- 7 distinct learnings extracted from direct in-session observation

### Applied (Public)
- `rules/global.md` r52c8b1 → CI/CD: monitor post-merge main CI after EVERY merge via background watcher (correction, Value=125)
- `rules/global.md` r0d29ec → Self-Improvement: reproduce Oracle config-change recommendations locally before applying (oracle-mis-invocation, Value=80)
- `rules/global.md` r08d040 → CI/CD: never use `if [ -n "$VAR" ]` to skip a verify step; make the var required (correction, Value=100)
- `rules/global.md` rfb0be1 → CI/CD: use `grep -Fq` not `grep -qE` when verifying a literal string in a file (correction, Value=75)
- `rules/global.md` r39cbc2 → CI/CD: workflow push-event triggers race coupled infra IAM applies; prefer `workflow_dispatch` (tool-failure-pattern, Value=48)
- `rules/global.md` r9b3317 → CI/CD: turbo hermetic mode strips env vars not declared in `tasks.<task>.env` of `turbo.json` (missing-context, Value=100)
- `rules/global.md` r06289e → CI/CD: HTTP 200 is necessary but not sufficient; verify actual served content (correction, Value=125)

### Queued
- None this run — all 7 findings scored well above the >4 apply threshold

### Reflexion (Phase 6a)
- Skipped this run — focus was on capturing today's high-density signal; reflexion deferred to next scheduled `/evolve` (validates ~2 week window since May 16 run)

### Privacy regressions (Phase 0)
- None — clean pass on both term-list and regex-pack scans

### Patterns observed this run
- 4 of 7 findings were corrections (workflow safety: silent fallbacks, regex confusion, race conditions, surface verification)
- Today's bug ("dev default leaked to prod") had a recognisable structural pattern: silent-fallback at one layer + skip-when-empty at the validation layer = both safety nets disabled
- "Verify with real surface, not just CI" was already implicit in methodology but wasn't a written rule until this run

### Next focus
- Watch for first citations of r52c8b1 (post-merge monitoring) and r06289e (verify content not just HTTP) — both should fire on EVERY future merge + deploy cascade
- If r52c8b1 isn't cited within 2 weeks but post-merge red-main incidents continue, the rule needs strengthening (e.g. promote to a hook)

## 2026-06-25 — Evolution Run [v2]

### Sessions Analysed
- 1 primary session (opencode/macOS maintenance & energy troubleshooting); mem + 15 recent sessions scanned. Most mem memories were company-specific (routed private/by-association).

### Applied (Public)
- `rules/global.md` rule:r7c1e4a → "opencode caches `@latest` plugins and does NOT re-resolve on launch; plugins drift behind an auto-upgraded core and break SDK-coupled features (background-task completion notifications → sub-agent hang). Force re-resolve by clearing the cache dir + shared node_modules + bun.lock after a core upgrade."
- `rules/global.md` rule:r2d9b88 → "VACUUM on opencode.db while opencode is running (WAL mode) doesn't reclaim space — quit first, then wal_checkpoint(TRUNCATE)+VACUUM."

### Queued
- qd1f3a2 "AGENTS.md lists @tarquinen/opencode-dcp as active but it's absent from every plugin array" (outdated-context) → confirm intent before editing docs
- qr2b7e9 "rule r-RETRO-2 'never pin plugin versions' contradicted by evidence — @latest auto-update is the mechanism behind the sub-agent-hang drift" (overfitting) → user decides refinement

### Demoted / Flagged
- r-RETRO-2: `recurrence_detected` — its "always auto-update, never pin" stance is the root mechanism of the drift bug. Not auto-rewritten (contradiction surfaced to user).

### Privacy regressions (Phase 0)
- None — public files clean against PRIVATE-TERMS + SENSITIVITY-REGEX.

### Next focus
- Resolve the r-RETRO-2 contradiction (auto-update vs periodic forced re-resolve vs major-version pin).
- Decide dcp's fate: re-register in plugin array or remove from AGENTS.md.

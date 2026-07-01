# opencode memory-leak investigation guide

The monitor answers two questions: **is opencode leaking**, and **which component**.
It cannot magically isolate an in-process plugin by PID (plugins run inside the
opencode process), so it uses correlation + ablation. This doc is the decision tree.

## Step 1 — is there a leak at all?

Let the loop accumulate for at least **1–2 hours** (ideally across an active
session, since idle opencode won't exercise most leak paths), then:

```sh
~/.config/opencode/tools/memmon/loop.sh analyze
```

Read the verdict per role:

- **PLATEAU everywhere** → no leak. What looks like "opencode eating memory" is
  the baseline topology: multiple concurrent `opencode` processes + always-on
  MCP/helper children + a large session DB. Not a leak.
- **LEAK / SLOW on some role** → that role's process group is growing. Continue.

The window-minimum + slope math means short-lived spikes and GC sawtooth do NOT
trigger LEAK — only a rising floor across many samples does.

## Step 2 — attribute the growth

### Case A: a CHILD process role is LEAK/SLOW (PID-isolatable)

`mcphub`, `lsp-daemon`, `chroma-mem`, `claude-mem`, `mcp-*` are separate
processes. If one of these is the culprit, the `WORST_PID` column names it
directly. Restart that specific helper (or its parent) and re-watch — if the
floor resets and climbs again, that child is the leak.

### Case B: `opencode-tui` / `opencode-web` is LEAK/SLOW (in-process)

A leak here lives inside the opencode process — either core or an in-process
plugin (`opencode-mem`, `@ramtinj95/opencode-tokenscope`,
`@franlol/opencode-md-table-formatter`). Use the DB correlation line the analyzer
prints from `summary.csv`:

```
opencode-core RSS slope +X MiB/hr; opencode.db slope +Y MiB/hr
```

- **Core RSS AND opencode.db both rising together** → the session store is
  growing and being held in memory. `opencode-mem` is the prime suspect (its
  source has an unbounded DB-connection Map + per-shard vector-index Maps).
  Note `opencode.db` is already ~2.6 GB.
- **Core RSS rising, DB flat** → native/JS heap leak unrelated to the session
  store → ablate plugins (Step 3).

### phys_footprint vs rss

The `footprint_kb` column (opencode roles only) is Apple's physical footprint
ledger and is the more honest number — during setup, opencode-web showed
footprint ~1393 MB vs RSS ~302 MB, and a `phys_footprint_peak` of ~3683 MB.
A footprint floor that keeps rising while RSS looks calm is still a leak.

## Step 3 — ablation (only for an in-process opencode leak)

Disable one plugin at a time and re-measure. Edit the `plugin` array in
`~/.config/opencode/opencode.json`, remove ONE entry, restart the opencode TUI,
let the loop gather ~1 h, `loop.sh analyze`. Suggested order (most→least likely):

1. `opencode-mem`
2. `@ramtinj95/opencode-tokenscope`
3. `@franlol/opencode-md-table-formatter`

If removing a plugin flattens the `opencode-tui` slope, that plugin is the leak.

## Notes / non-suspects

- The hourly **heartbeat** cron spawns a headless `opencode run` that EXITS after
  its task register — its memory is reclaimed on exit. Such PIDs are classified
  `TRANSIENT` (seen in too few samples to judge) and never counted as a leak.
- Multiple resident `opencode` processes are normal for concurrent sessions; the
  monitor scores each PID independently, so N idle sessions ≠ a leak.

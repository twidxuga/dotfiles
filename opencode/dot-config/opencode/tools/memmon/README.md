# memmon — opencode memory-leak monitor

Time-series memory sampler + leak analyzer for the opencode process forest on macOS.
Samples every 5 minutes, attributes memory growth per-process and per-role, and
renders a `LEAK / SLOW / PLATEAU / TRANSIENT` verdict so a real leak can be told
apart from GC sawtooth, a large session DB, or transient headless runs.

## Files

| File | Purpose |
|---|---|
| `sampler.sh` | One snapshot: walks the opencode process tree + MCP/helper children, tags each PID by role, records `rss` + Apple `phys_footprint` + cpu + elapsed + `opencode.db` size to CSV. PID-death safe. |
| `analyzer.py` | Reads the CSV, per-PID window-minimum RSS + OLS slope (MiB/hr), verdict per role. `--json` for machine output. Exit 2 if any LEAK. |
| `loop.sh` | `start` / `stop` / `status` / `analyze` background driver (default 300s). |
| `tests/fixtures/` | Synthetic CSVs (rising / flat / transient) that pin the analyzer's classification. |
| `INVESTIGATION.md` | How to read output + decision tree to pin the leaking component. |

Logs live in `~/.local/share/opencode-memmon/` (`samples.csv`, `summary.csv`, `loop.log`, `loop.pid`) — not committed.

## Usage

```sh
loop.sh start            # begin sampling every 5 min in background
loop.sh status           # is it running? how many samples, last timestamp
loop.sh analyze          # verdict table over accumulated data
loop.sh stop             # end sampling

# ad-hoc:
bash sampler.sh                                  # one manual sample
python3 analyzer.py ~/.local/share/opencode-memmon/samples.csv
```

## Roles tagged

`opencode-tui`, `opencode-web`, `opencode-run` (transient headless, e.g. heartbeat),
`mcphub`, `mcp-notion`, `mcp-tavily`, `mcp-chrome-devtools`, `mcp-slack`,
`mcp-datadog`, `mcp-pencil`, `lsp-daemon`, `chroma-mem`, `claude-mem`,
`git-bash-mcp`, `other`.

`opencode-*` roles additionally get Apple `phys_footprint` (KiB) — the physical
footprint ledger, more truthful than RSS for real memory pressure.

## Tuning (env)

`MEMMON_LEAK_MB_HR` (default 60), `MEMMON_SLOW_MB_HR` (6), `MEMMON_MIN_SAMPLES` (3),
`MEMMON_WINDOW` (3), `INTERVAL_SEC` (300), `FOOTPRINT` (1).

#!/usr/bin/env python3
"""Analyze memmon samples.csv: per-PID and per-role memory-leak verdicts.

Reads the sampler CSV, groups by PID (and rolls PIDs up by role), then for each
persistent series computes a window-minimum RSS trend (filters GC sawtooth) and
an ordinary-least-squares slope in MiB/hour. A PID seen in only one sample is
classified TRANSIENT (e.g. a heartbeat headless `opencode run`), never LEAK.

Verdicts:
  LEAK       slope > LEAK_MB_HR and window-min non-decreasing over last >=3 wins
  SLOW       slope > SLOW_MB_HR (mild upward drift, worth watching)
  PLATEAU    |slope| <= SLOW_MB_HR
  TRANSIENT  < MIN_SAMPLES observations (cannot judge)

Exit code 2 if any LEAK verdict, else 0. Thresholds override via env.
"""
from __future__ import annotations

import argparse
import csv
import os
import sys
from dataclasses import dataclass, field

LEAK_MB_HR = float(os.environ.get("MEMMON_LEAK_MB_HR", "60"))   # ~1 MiB/min
SLOW_MB_HR = float(os.environ.get("MEMMON_SLOW_MB_HR", "6"))    # mild drift
MIN_SAMPLES = int(os.environ.get("MEMMON_MIN_SAMPLES", "3"))
MIN_LEAK_SAMPLES = int(os.environ.get("MEMMON_MIN_LEAK_SAMPLES", "8"))
WINDOW = int(os.environ.get("MEMMON_WINDOW", "3"))


@dataclass
class Series:
    pid: str
    role: str
    ppid: str
    epochs: list[int] = field(default_factory=list)
    rss_kb: list[int] = field(default_factory=list)
    fp_kb: list[int] = field(default_factory=list)
    cmd: str = ""


def load(path: str) -> dict[str, Series]:
    series: dict[str, Series] = {}
    with open(path, newline="") as fh:
        reader = csv.DictReader(fh)
        for row in reader:
            pid = (row.get("pid") or "").strip()
            if not pid:
                continue
            try:
                epoch = int(row["epoch"])
                rss = int(row["rss_kb"])
            except (KeyError, ValueError):
                continue  # skip malformed row, do not crash
            s = series.get(pid)
            if s is None:
                s = Series(pid=pid, role=row.get("role", "other"), ppid=row.get("ppid", ""))
                series[pid] = s
            s.epochs.append(epoch)
            s.rss_kb.append(rss)
            fp = (row.get("footprint_kb") or "").strip()
            s.fp_kb.append(int(fp) if fp.isdigit() else 0)
            s.cmd = row.get("command", s.cmd)
    return series


def window_min(vals: list[int], w: int) -> list[int]:
    if len(vals) < w:
        return [min(vals)] if vals else []
    return [min(vals[i : i + w]) for i in range(len(vals) - w + 1)]


def ols_slope_per_hr(xs: list[int], ys_kb: list[int]) -> float:
    """Least-squares slope of ys (KiB) vs xs (epoch sec), returned in MiB/hour."""
    n = len(xs)
    if n < 2:
        return 0.0
    mx = sum(xs) / n
    my = sum(ys_kb) / n
    denom = sum((x - mx) ** 2 for x in xs)
    if denom == 0:
        return 0.0
    slope_kb_per_sec = sum((x - mx) * (y - my) for x, y in zip(xs, ys_kb)) / denom
    return slope_kb_per_sec * 3600.0 / 1024.0


def non_decreasing_tail(vals: list[int], k: int) -> bool:
    tail = vals[-k:]
    if len(tail) < k:
        return False
    return all(tail[i] <= tail[i + 1] for i in range(len(tail) - 1))


def verdict(s: Series) -> tuple[str, float]:
    n = len(s.rss_kb)
    if n < MIN_LEAK_SAMPLES:
        return "TRANSIENT", 0.0
    wmin = window_min(s.rss_kb, WINDOW)
    if len(wmin) < 2:
        return "TRANSIENT", 0.0
    wmin_epochs = s.epochs[-len(wmin):]
    slope = ols_slope_per_hr(wmin_epochs, wmin)
    # A real leak needs a rising FLOOR, not a spiky raw slope. Require the
    # window-min to actually end well above where it started (in MiB), which
    # rejects PID-reuse noise and one-sample spikes that inflate OLS slope.
    span_hr = (wmin_epochs[-1] - wmin_epochs[0]) / 3600.0
    floor_rise_mb = (wmin[-1] - min(wmin)) / 1024.0
    rising = slope > 0 and non_decreasing_tail(wmin, min(3, len(wmin)))
    if slope > LEAK_MB_HR and rising and floor_rise_mb > LEAK_MB_HR * max(span_hr, 0.5) * 0.5:
        return "LEAK", slope
    if slope > SLOW_MB_HR and floor_rise_mb > SLOW_MB_HR:
        return "SLOW", slope
    return "PLATEAU", slope


def summarize_by_role(series: dict[str, Series]) -> dict[str, dict]:
    roles: dict[str, dict] = {}
    for s in series.values():
        v, slope = verdict(s)
        r = roles.setdefault(
            s.role,
            {"verdict": "PLATEAU", "worst_slope": 0.0, "worst_pid": "", "pids": 0, "transient": 0},
        )
        r["pids"] += 1
        if v == "TRANSIENT":
            r["transient"] += 1
            continue
        if slope > r["worst_slope"]:
            r["worst_slope"] = slope
            r["worst_pid"] = s.pid
        rank = {"PLATEAU": 0, "SLOW": 1, "LEAK": 2}
        if rank.get(v, 0) > rank.get(r["verdict"], 0):
            r["verdict"] = v
    return roles


def main() -> int:
    ap = argparse.ArgumentParser(description="memmon leak analyzer")
    ap.add_argument("samples", nargs="?", help="samples.csv path")
    ap.add_argument("--samples", dest="samples_opt", help="samples.csv path")
    ap.add_argument("--summary", help="summary.csv path (optional, for db correlation)")
    ap.add_argument("--json", action="store_true", help="emit JSON")
    args = ap.parse_args()

    path = args.samples_opt or args.samples
    if not path:
        default = os.path.expanduser("~/.local/share/opencode-memmon/samples.csv")
        path = default
    if not os.path.exists(path):
        print(f"memmon-analyze: no such file: {path}", file=sys.stderr)
        return 0

    series = load(path)
    if not series:
        print("memmon-analyze: no data", file=sys.stderr)
        return 0

    per_pid = {}
    for pid, s in series.items():
        v, slope = verdict(s)
        per_pid[pid] = {"role": s.role, "verdict": v, "slope_mb_hr": round(slope, 1),
                        "samples": len(s.rss_kb), "last_rss_mb": round(s.rss_kb[-1] / 1024, 1)}
    roles = summarize_by_role(series)

    db_note = ""
    if args.summary and os.path.exists(args.summary):
        with open(args.summary, newline="") as fh:
            rows = list(csv.DictReader(fh))
        if len(rows) >= 2:
            eps = [int(r["epoch"]) for r in rows]
            core = [int(r["opencode_core_rss_kb"]) for r in rows]
            dbb = [int(r["opencode_db_bytes"]) // 1024 for r in rows]
            cs = ols_slope_per_hr(eps, core)
            ds = ols_slope_per_hr(eps, dbb)
            db_note = f"opencode-core RSS slope {cs:+.1f} MiB/hr; opencode.db slope {ds:+.1f} MiB/hr"
            if cs > SLOW_MB_HR and ds > SLOW_MB_HR:
                db_note += "  -> core RSS AND DB growing together: opencode-mem is prime suspect"

    has_leak = any(r["verdict"] == "LEAK" for r in roles.values())

    if args.json:
        import json
        out = {"roles": {k: {"verdict": v["verdict"], "worst_slope_mb_hr": round(v["worst_slope"], 1),
                             "worst_pid": v["worst_pid"], "pids": v["pids"], "transient": v["transient"]}
                         for k, v in roles.items()},
               "pids": per_pid, "db_note": db_note, "has_leak": has_leak}
        print(json.dumps(out, indent=2))
    else:
        print(f"{'ROLE':<22}{'VERDICT':<11}{'WORST MiB/hr':>13}{'PIDs':>6}{'TRANS':>7}  WORST_PID")
        for role in sorted(roles, key=lambda k: -roles[k]["worst_slope"]):
            r = roles[role]
            print(f"{role:<22}{r['verdict']:<11}{r['worst_slope']:>13.1f}{r['pids']:>6}{r['transient']:>7}  {r['worst_pid']}")
        if db_note:
            print("\n" + db_note)
        print(f"\nverdict: {'LEAK DETECTED' if has_leak else 'no leak'}")

    return 2 if has_leak else 0


if __name__ == "__main__":
    raise SystemExit(main())

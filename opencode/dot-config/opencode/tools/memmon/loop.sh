#!/usr/bin/env bash
# memmon loop — background 5-minute sampler driver with start/stop/status.
#
# Usage:  loop.sh start | stop | status | analyze
# Env:    INTERVAL_SEC (default 300), LOG_DIR (default ~/.local/share/opencode-memmon)
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="${LOG_DIR:-$HOME/.local/share/opencode-memmon}"
INTERVAL_SEC="${INTERVAL_SEC:-300}"
PID_FILE="$LOG_DIR/loop.pid"
LOOP_LOG="$LOG_DIR/loop.log"
SAMPLES_CSV="$LOG_DIR/samples.csv"
SAMPLER="$HERE/sampler.sh"
ANALYZER="$HERE/analyzer.py"

mkdir -p "$LOG_DIR"

alive() { [ -n "${1:-}" ] && kill -0 "$1" 2>/dev/null; }

running_pid() {
  [ -f "$PID_FILE" ] || return 1
  local p; p="$(cat "$PID_FILE" 2>/dev/null || true)"
  if alive "$p"; then echo "$p"; return 0; fi
  return 1
}

cmd_start() {
  local existing
  if existing="$(running_pid)"; then
    echo "memmon loop already running (pid $existing)"; return 1
  fi
  rm -f "$PID_FILE"
  LOG_DIR="$LOG_DIR" INTERVAL_SEC="$INTERVAL_SEC" nohup bash -c '
    while true; do
      LOG_DIR="'"$LOG_DIR"'" bash "'"$SAMPLER"'" || true
      sleep "'"$INTERVAL_SEC"'"
    done
  ' >> "$LOOP_LOG" 2>&1 &
  local child=$!
  echo "$child" > "$PID_FILE"
  echo "memmon loop started (pid $child, interval ${INTERVAL_SEC}s, log $LOOP_LOG)"
}

cmd_stop() {
  local p
  if p="$(running_pid)"; then
    kill "$p" 2>/dev/null || true
    sleep 0.3
    alive "$p" && kill -9 "$p" 2>/dev/null || true
    rm -f "$PID_FILE"
    echo "memmon loop stopped (was pid $p)"
  else
    rm -f "$PID_FILE"
    echo "memmon loop not running"
  fi
}

cmd_status() {
  local p last
  if p="$(running_pid)"; then
    echo "status: RUNNING (pid $p, interval ${INTERVAL_SEC}s)"
    echo "log:    $LOOP_LOG"
    if [ -f "$SAMPLES_CSV" ]; then
      local rows; rows=$(($(wc -l < "$SAMPLES_CSV") - 1))
      [ "$rows" -lt 0 ] && rows=0
      if [ "$rows" -gt 0 ]; then
        last="$(tail -1 "$SAMPLES_CSV" 2>/dev/null | cut -d, -f1)"
      else
        last="none"
      fi
      echo "samples: $rows rows, last @ $last"
    fi
  else
    echo "status: not running"
  fi
}

cmd_analyze() {
  python3 "$ANALYZER" --samples "$SAMPLES_CSV" --summary "$LOG_DIR/summary.csv" "$@"
}

case "${1:-status}" in
  start)   cmd_start ;;
  stop)    cmd_stop ;;
  status)  cmd_status ;;
  analyze) shift; cmd_analyze "$@" ;;
  *) echo "usage: $0 {start|stop|status|analyze}" >&2; exit 64 ;;
esac

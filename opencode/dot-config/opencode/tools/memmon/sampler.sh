#!/usr/bin/env bash
# memmon sampler — one memory snapshot of the opencode process forest + helpers.
# Appends one CSV row per live PID plus a summary row, tagged by role, so a
# time-series analyzer can attribute memory growth to a specific component.
#
# Env:
#   LOG_DIR       override log directory (default ~/.local/share/opencode-memmon)
#   FOOTPRINT     1 (default) = also record Apple phys_footprint for opencode-* PIDs; 0 = skip
#   PS_BIN        override `ps` binary (tests inject a stub)
#   PGREP_BIN     override `pgrep` binary (tests inject a stub)
#   VERBOSE       1 = echo a one-line summary to stdout
#
# Safe against: PIDs dying mid-sample, zero opencode processes, missing opencode.db.
set -uo pipefail

LOG_DIR="${LOG_DIR:-$HOME/.local/share/opencode-memmon}"
FOOTPRINT="${FOOTPRINT:-1}"
PS_BIN="${PS_BIN:-ps}"
PGREP_BIN="${PGREP_BIN:-pgrep}"
DB_PATH="${MEMMON_DB_PATH:-$HOME/.local/share/opencode/opencode.db}"

mkdir -p "$LOG_DIR"
SAMPLES_CSV="$LOG_DIR/samples.csv"
SUMMARY_CSV="$LOG_DIR/summary.csv"

SAMPLES_HEADER="iso_ts,epoch,pid,ppid,role,rss_kb,footprint_kb,cpu_pct,etime_sec,command"
SUMMARY_HEADER="iso_ts,epoch,pid_count,total_rss_kb,opencode_core_rss_kb,opencode_db_bytes"

[ -f "$SAMPLES_CSV" ] || echo "$SAMPLES_HEADER" > "$SAMPLES_CSV"
[ -f "$SUMMARY_CSV" ] || echo "$SUMMARY_HEADER" > "$SUMMARY_CSV"

ISO_TS="$(date '+%Y-%m-%dT%H:%M:%S%z')"
EPOCH="$(date '+%s')"

# --- discover root PIDs of interest (each wrapped so a no-match doesn't abort) ---
roots=""
for pat in \
  "-x opencode" \
  "-f mcphub" \
  "-f mcp-hub" \
  "-f datadog_mcp" \
  "-f mcp-remote" \
  "-f chrome-devtools-mcp" \
  "-f lsp-daemon" \
  "-f chroma-mcp" \
  "-f git-bash-mcp"
do
  # shellcheck disable=SC2086
  found="$("$PGREP_BIN" $pat 2>/dev/null || true)"
  roots="$roots $found"
done

# --- recursively collect descendants ---
collect_tree() {
  local pid="$1" child
  printf '%s\n' "$pid"
  for child in $("$PGREP_BIN" -P "$pid" 2>/dev/null || true); do
    collect_tree "$child"
  done
}

all_pids=""
for r in $roots; do
  [ -n "$r" ] || continue
  all_pids="$all_pids $(collect_tree "$r")"
done
# dedupe, drop empties
all_pids="$(printf '%s\n' $all_pids | grep -E '^[0-9]+$' | sort -un || true)"

# --- role classification from the command string ---
role_for() {
  local cmd="$1"
  # Branch order is load-bearing: lsp-daemon/mcp children run under opencode's
  # cache path, so specific patterns must precede the opencode-tui catch-all.
  case "$cmd" in
    *lsp-daemon*)                                    echo "lsp-daemon" ;;
    *git-bash-mcp*)                                  echo "git-bash-mcp" ;;
    *mcphub*|*mcp-hub*)                              echo "mcphub" ;;
    *datadog_mcp*)                                   echo "mcp-datadog" ;;
    *mcp-remote*notion*|*"mcp.notion"*)              echo "mcp-notion" ;;
    *mcp-remote*tavily*|*"mcp.tavily"*)              echo "mcp-tavily" ;;
    *chrome-devtools-mcp*|*chrome-devtools*)         echo "mcp-chrome-devtools" ;;
    *slack-mcp*)                                     echo "mcp-slack" ;;
    *Pencil.app*|*mcp-server-darwin*)                echo "mcp-pencil" ;;
    *mcp-remote*)                                    echo "mcp-remote-other" ;;
    *chroma-mcp*|*chroma*)                           echo "chroma-mem" ;;
    *claude-mem*|*"claude/plugins"*)                 echo "claude-mem" ;;
    *"opencode web"*|*"opencode serve"*)             echo "opencode-web" ;;
    *"opencode run"*)                                echo "opencode-run" ;;   # transient headless (heartbeat etc.)
    opencode|*"/opencode"*|*"opencode "*)            echo "opencode-tui" ;;
    *)                                               echo "other" ;;
  esac
}

# --- footprint (Apple phys_footprint, KB) for a pid; empty on failure ---
footprint_kb() {
  local pid="$1"
  [ "$FOOTPRINT" = "1" ] || { echo ""; return; }
  command -v footprint >/dev/null 2>&1 || { echo ""; return; }
  # "    phys_footprint: 1393 MB" -> normalize value+unit (B/KB/MB/GB) to KB
  footprint -p "$pid" 2>/dev/null | awk '
    /phys_footprint:/ {
      v=$2; u=$3
      if (u=="B")  printf "%d", v/1024
      else if (u=="KB") printf "%d", v
      else if (u=="MB") printf "%d", v*1024
      else if (u=="GB") printf "%d", v*1024*1024
      else printf "%s", v
      exit
    }' 2>/dev/null || echo ""
}

# etime like [[dd-]hh:]mm:ss -> seconds
etime_to_sec() {
  local t="$1" days=0 rest secs
  case "$t" in
    *-*) days="${t%%-*}"; rest="${t#*-}" ;;
    *)   rest="$t" ;;
  esac
  # rest is [hh:]mm:ss
  local IFS=':'; set -- $rest
  case "$#" in
    3) secs=$(( ${1#0}*3600 + ${2#0}*60 + ${3#0} )) ;;
    2) secs=$(( ${1#0}*60 + ${2#0} )) ;;
    1) secs=$(( ${1#0} )) ;;
    *) secs=0 ;;
  esac
  echo $(( days*86400 + secs ))
}

total_rss=0
core_rss=0
pid_count=0

for pid in $all_pids; do
  # single ps call; skip silently if the pid vanished
  line="$("$PS_BIN" -o ppid=,rss=,pcpu=,etime=,command= -p "$pid" 2>/dev/null || true)"
  [ -n "$line" ] || continue

  ppid="$(echo "$line" | awk '{print $1}')"
  rss="$(echo "$line" | awk '{print $2}')"
  cpu="$(echo "$line" | awk '{print $3}')"
  etime_raw="$(echo "$line" | awk '{print $4}')"
  # command is everything from field 5 on
  cmd="$(echo "$line" | awk '{$1=$2=$3=$4=""; sub(/^ +/,""); print}')"

  [ -n "$rss" ] || continue
  role="$(role_for "$cmd")"
  etime_sec="$(etime_to_sec "$etime_raw")"

  fp=""
  case "$role" in opencode-tui|opencode-web|opencode-run) fp="$(footprint_kb "$pid")" ;; esac

  # escape commas/newlines in command for CSV
  cmd_csv="$(printf '%s' "$cmd" | tr ',\n' '; ' | cut -c1-200)"

  echo "$ISO_TS,$EPOCH,$pid,$ppid,$role,$rss,$fp,$cpu,$etime_sec,$cmd_csv" >> "$SAMPLES_CSV"

  total_rss=$(( total_rss + rss ))
  case "$role" in opencode-tui|opencode-web|opencode-run) core_rss=$(( core_rss + rss )) ;; esac
  pid_count=$(( pid_count + 1 ))
done

# opencode.db size (bytes); 0 if missing
db_bytes=0
if [ -f "$DB_PATH" ]; then
  db_bytes="$(stat -f%z "$DB_PATH" 2>/dev/null || echo 0)"
fi

echo "$ISO_TS,$EPOCH,$pid_count,$total_rss,$core_rss,$db_bytes" >> "$SUMMARY_CSV"

if [ "${VERBOSE:-0}" = "1" ]; then
  echo "memmon: $ISO_TS pids=$pid_count total_rss=${total_rss}KB core=${core_rss}KB db=${db_bytes}B"
fi
exit 0

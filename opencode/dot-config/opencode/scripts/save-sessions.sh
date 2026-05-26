#!/usr/bin/env bash
# save-sessions.sh — Append the list of currently running opencode sessions to ~/.opencode-sessions
#
# Identifies each running opencode (TUI or `opencode web`) process and resolves its loaded session
# via two strategies, in order:
#   1) CONFIDENT (✓): inspect the per-process log file (kept open by opencode) and extract the most
#      recent `service=session id=ses_*` line.
#   2) HEURISTIC (?): if the log file has been rotated away (opencode keeps only 10 most recent on
#      disk), fall back to picking the most-recently-updated top-level session whose `directory`
#      column in opencode.db matches the process's cwd.
#
# Output format (appended to ~/.opencode-sessions):
#   =================================================================
#   YYYY-MM-DD HH:MM:SS
#   =================================================================
#   <conf> <ses_id> | <title> | <folder> | pid <pid>
#
# Exit codes:
#   0 — success
#   1 — opencode DB missing
#   2 — sqlite3 missing

set -uo pipefail
# Note: -e omitted intentionally — bash 3.2 exits on [[ string comparison ]] returning 1 in
# some contexts, and subshell substitutions that return empty are common here.

OUTPUT_FILE="${HOME}/.opencode-sessions"
DB="${HOME}/.local/share/opencode/opencode.db"

# Portable across bash 3.2 (macOS default) and bash 4+/5+.
# bash 3.2 lacks `mapfile`, `${var^^}`, and some other niceties.
# Use ASCII confidence markers internally (C=confident, Q=heuristic) to avoid
# UTF-8 comparison issues in bash 3.2; translate to ✓/? only at output time.

if ! command -v sqlite3 >/dev/null 2>&1; then
  echo "save-sessions: sqlite3 not found on PATH" >&2
  exit 2
fi

if [[ ! -f "$DB" ]]; then
  echo "save-sessions: opencode DB not found at $DB" >&2
  exit 1
fi

# Collect all opencode PIDs (TUI + `opencode web`). Portable across bash 3.2.
PIDS=()
while IFS= read -r _pid; do
  [[ -n "$_pid" ]] && PIDS+=("$_pid")
done < <(pgrep -x opencode 2>/dev/null || true)

# Build lines into a temp file so we can sort before writing
TMP="$(mktemp /tmp/save-sessions.XXXXXX)"
trap 'rm -f "$TMP"' EXIT

resolve_session_for_pid() {
  local pid="$1"
  local conf="Q"
  local sid=""
  local title=""
  local cwd=""

  # cwd from lsof. On macOS, -a is required so -p actually filters; without -a,
  # `lsof -p PID -d cwd` returns ALL processes' cwd entries.
  cwd="$(lsof -a -p "$pid" -d cwd 2>/dev/null | awk 'NR==2 {print $NF}')" || true
  if [[ -z "$cwd" ]]; then
    cwd="(unknown)"
  fi

  # Strategy 1: extract from open log file
  local logpath
  logpath="$(lsof -a -p "$pid" 2>/dev/null \
    | awk '$NF ~ /\/opencode\/log\/.*\.log$/ {print $NF; exit}')" || true
  if [[ -n "$logpath" && -f "$logpath" && -r "$logpath" ]]; then
    sid="$(grep -oE 'service=session id=ses_[A-Za-z0-9]+' "$logpath" 2>/dev/null \
      | tail -1 \
      | sed 's/^service=session id=//')" || true
    if [[ -n "$sid" ]]; then
      conf="C"
    fi
  fi

  # Strategy 2: heuristic via cwd → most-recently-updated top-level session
  if [[ -z "$sid" && "$cwd" != "(unknown)" ]]; then
    local escaped_cwd
    escaped_cwd="${cwd//\'/\'\'}"
    sid="$(sqlite3 "$DB" \
      "SELECT id FROM session WHERE directory = '${escaped_cwd}' AND parent_id IS NULL ORDER BY time_updated DESC LIMIT 1;" \
      2>/dev/null)" || true
  fi

  if [[ -z "$sid" ]]; then
    printf '%s\t? (no session) | (no session resolved) | %s | pid %s\n' "2" "$cwd" "$pid" >> "$TMP"
    return 0
  fi

  # Look up title
  local escaped_sid
  escaped_sid="${sid//\'/\'\'}"
  title="$(sqlite3 "$DB" \
    "SELECT COALESCE(title, '(untitled)') FROM session WHERE id = '${escaped_sid}';" \
    2>/dev/null)" || true
  if [[ -z "$title" ]]; then
    title="(untitled)"
  fi

  # Use ASCII sort key (0=confident, 1=heuristic) then translate to symbols at output
  local sortkey display_conf
  if [[ "$conf" == "C" ]]; then
    sortkey=0
    display_conf="✓"
  else
    sortkey=1
    display_conf="?"
  fi
  printf '%s\t%s %s | %s | %s | pid %s\n' "$sortkey" "$display_conf" "$sid" "$title" "$cwd" "$pid" >> "$TMP"
  return 0
}

if [[ ${#PIDS[@]} -gt 0 ]]; then
  for pid in "${PIDS[@]}"; do
    resolve_session_for_pid "$pid" || true
  done
fi

# Append to output file with header, sorted (✓ before ?, then by session id)
{
  echo "================================================================="
  date '+%Y-%m-%d %H:%M:%S'
  echo "================================================================="
  if [[ -s "$TMP" ]]; then
    sort -t $'\t' -k1,1n -k2,2 "$TMP" | cut -f2-
  else
    echo "(no running opencode processes)"
  fi
  echo
} >> "$OUTPUT_FILE"

echo "Saved session list to $OUTPUT_FILE"

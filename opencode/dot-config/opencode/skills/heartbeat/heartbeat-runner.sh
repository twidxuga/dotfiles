#!/usr/bin/env bash
# heartbeat-runner.sh — executed by cron every hour
# Runs headless opencode in the "heartbeat" session, processes all due tasks.
set -euo pipefail

# ── Paths ──────────────────────────────────────────────────────────────────
HEARTBEAT_DIR="${HOME}/.local/share/heartbeat"
TASK_REGISTER="${HEARTBEAT_DIR}/heartbeat-tasks.json"
SESSION_ID_FILE="${HEARTBEAT_DIR}/heartbeat-session.id"
OUTPUT_LOG="${HEARTBEAT_DIR}/heartbeat-output.log"
MODEL="anthropic/claude-sonnet-4-6"

# Resolve opencode binary: check well-known install location, then PATH
OPENCODE_BIN="${HOME}/.local/share/opencode/bin/opencode"
if [[ ! -x "${OPENCODE_BIN}" ]]; then
  OPENCODE_BIN="$(command -v opencode 2>/dev/null || true)"
fi
if [[ -z "${OPENCODE_BIN}" ]]; then
  # Homebrew on macOS
  OPENCODE_BIN="$(command -v opencode 2>/dev/null || ls /opt/homebrew/bin/opencode 2>/dev/null || true)"
fi
if [[ -z "${OPENCODE_BIN}" || ! -x "${OPENCODE_BIN}" ]]; then
  echo "heartbeat $(date '+%Y-%m-%d %H:%M:%S') — ERROR: opencode binary not found" >&2
  exit 1
fi

# ── Logging helpers ─────────────────────────────────────────────────────────
RUN_TS="$(date '+%Y-%m-%d %H:%M:%S')"
SEP="════════════════════════════════════════════════════════════════════════════════"

log_run_header() {
  {
    echo ""
    echo "${SEP}"
    echo "  HEARTBEAT RUN — ${RUN_TS}"
    echo "${SEP}"
  } >> "${OUTPUT_LOG}"
}

log_run_footer() {
  local status="${1:-OK}"
  {
    echo "── Run complete: ${status} ──────────────────────── ${RUN_TS}"
    echo ""
  } >> "${OUTPUT_LOG}"
}

log_task() {
  local task_name="${1}"
  local task_output="${2}"
  {
    echo ""
    echo "  ┌── Task: ${task_name}"
    echo "${task_output}" | sed 's/^/  │ /'
    echo "  └────────────────────────────────────"
  } >> "${OUTPUT_LOG}"
}

summary() {
  echo "heartbeat ${RUN_TS} — ${1}"
}

# ── Ensure task register exists ─────────────────────────────────────────────
if [[ ! -f "${TASK_REGISTER}" ]]; then
  echo "heartbeat ${RUN_TS} — ERROR: task register not found at ${TASK_REGISTER} (run /heartbeat heartbeat-deploy)" >&2
  exit 1
fi

# ── Resolve or create the persistent heartbeat session ──────────────────────
resolve_session() {
  local session_id=""

  if [[ -f "${SESSION_ID_FILE}" ]]; then
    session_id="$(cat "${SESSION_ID_FILE}")"
    # Verify the session still exists in opencode
    if "${OPENCODE_BIN}" session list 2>/dev/null | grep -q "${session_id}"; then
      echo "${session_id}"
      return
    fi
    # Session gone — clear the stale ID
    rm -f "${SESSION_ID_FILE}"
  fi

  # Create a new session; extract session ID from JSON event stream
  local tmp_out
  tmp_out="$(mktemp)"

  "${OPENCODE_BIN}" run \
    --dir "${HEARTBEAT_DIR}" \
    --model "${MODEL}" \
    --title "heartbeat" \
    --dangerously-skip-permissions \
    --format json \
    "Heartbeat session initialised. Reply only with: READY" \
    2>/dev/null > "${tmp_out}" || true

  # Extract session ID from JSON stream (sessionID field appears in events)
  session_id="$(grep -o '"sessionID":"[^"]*"' "${tmp_out}" | head -1 | sed 's/"sessionID":"//;s/"//' || true)"
  rm -f "${tmp_out}"

  if [[ -z "${session_id}" ]]; then
    # Fallback: query session list for most recent session titled "heartbeat"
    session_id="$("${OPENCODE_BIN}" session list 2>/dev/null | awk '/heartbeat/ {print $1; exit}')"
  fi

  if [[ -n "${session_id}" ]]; then
    echo "${session_id}" > "${SESSION_ID_FILE}"
    echo "${session_id}"
  else
    echo ""
  fi
}

# ── Get tasks due for this run ───────────────────────────────────────────────
now_epoch="$(date +%s)"

get_due_tasks() {
  # Use inline Python with shell-interpolated variables (no heredoc stdin conflict)
  python3 -c "
import json
from datetime import datetime

with open('${TASK_REGISTER}') as f:
    data = json.load(f)

now = ${now_epoch}
due = []
for task in data.get('tasks', []):
    if not task.get('enabled', True):
        continue
    freq_h = task.get('frequency_hours', 1)
    last_run = task.get('last_run', '')
    if not last_run:
        due.append(task)
        continue
    try:
        dt = datetime.fromisoformat(last_run.replace('Z', '+00:00'))
        last_epoch = int(dt.timestamp())
    except Exception:
        due.append(task)
        continue
    elapsed_h = (now - last_epoch) / 3600.0
    if elapsed_h >= freq_h:
        due.append(task)

print(json.dumps(due))
"
}

update_last_run() {
  local task_name="${1}"
  local ts="${2}"
  python3 -c "
import json

with open('${TASK_REGISTER}') as f:
    data = json.load(f)

for task in data.get('tasks', []):
    if task['name'] == '${task_name}':
        task['last_run'] = '${ts}'
        break

with open('${TASK_REGISTER}', 'w') as f:
    json.dump(data, f, indent=2)
"
}

# ── Main ────────────────────────────────────────────────────────────────────
log_run_header

# Collect due tasks
due_tasks_json="$(get_due_tasks)"
due_count="$(python3 -c "import json,sys; print(len(json.loads(sys.argv[1])))" "${due_tasks_json}")"

if [[ "${due_count}" -eq 0 ]]; then
  log_task "scheduler" "No tasks due this run."
  log_run_footer "OK (no tasks due)"
  summary "no tasks due"
  exit 0
fi

# Resolve persistent session (only needed for prompt-based tasks)
SESSION_ID=""

# Execute each due task
run_iso="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
RESULTS_TMP="$(mktemp)"

# Emit one JSON object per line for safe field extraction (avoids TSV empty-field bugs)
python3 -c "
import json, sys
tasks = json.loads(sys.argv[1])
for t in tasks:
    print(json.dumps({'name': t['name'], 'prompt': t.get('prompt',''), 'script': t.get('script','')}))
" "${due_tasks_json}" | while IFS= read -r line; do

  task_name="$(python3   -c "import json,sys; print(json.loads(sys.argv[1])['name'])"   "${line}")"
  task_prompt="$(python3 -c "import json,sys; print(json.loads(sys.argv[1])['prompt'])" "${line}")"
  task_script="$(python3 -c "import json,sys; print(json.loads(sys.argv[1])['script'])" "${line}")"

  # Expand leading ~ to $HOME
  task_script="${task_script/#\~/$HOME}"

  task_output=""

  if [[ -n "${task_script}" && -x "${task_script}" ]]; then
    # Script-based task: run the script directly
    task_output="$("${task_script}" 2>&1 || true)"

  elif [[ -n "${task_prompt}" ]]; then
    # Prompt-based task: send to the persistent heartbeat opencode session
    if [[ -z "${SESSION_ID}" ]]; then
      SESSION_ID="$(resolve_session)"
    fi
    if [[ -z "${SESSION_ID}" ]]; then
      task_output="ERROR: could not resolve heartbeat session for prompt task '${task_name}'"
    else
      task_output="$(
        "${OPENCODE_BIN}" run \
          --session "${SESSION_ID}" \
          --dir "${HEARTBEAT_DIR}" \
          --model "${MODEL}" \
          --dangerously-skip-permissions \
          "${task_prompt}" 2>&1 || true
      )"
    fi

  else
    task_output="SKIP: task '${task_name}' has neither an executable script nor a prompt"
  fi

  log_task "${task_name}" "${task_output}"
  update_last_run "${task_name}" "${run_iso}"

  first_line="$(printf '%s\n' "${task_output}" | grep -v '^[[:space:]]*$' | tail -1)"
  echo "${task_name}: ${first_line}" >> "${RESULTS_TMP}"

done

log_run_footer "OK"

ran_summary="$(paste -sd '; ' "${RESULTS_TMP}" 2>/dev/null || true)"
rm -f "${RESULTS_TMP}"
summary "ran ${due_count} task(s) — ${ran_summary:-done}"

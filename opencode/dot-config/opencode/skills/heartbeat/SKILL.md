---
name: heartbeat
description: Manage the opencode heartbeat system — hourly cron-driven headless opencode sessions that execute a task register. Primitives: heartbeat-deploy, heartbeat-add, heartbeat-remove, heartbeat-uninstall, heartbeat-read.
---

# heartbeat

The heartbeat system runs a headless opencode session on a cron schedule (hourly by default). Each run consults a task register and executes any tasks that are due. All output is timestamped and appended to a log file with clear separators.

## Paths (all systems)

```
HEARTBEAT_DIR  = ~/Documents/QuickAccess/kb/ai-agents/
TASK_REGISTER  = ~/Documents/QuickAccess/kb/ai-agents/heartbeat-tasks.json
SESSION_ID     = ~/Documents/QuickAccess/kb/ai-agents/heartbeat-session.id
OUTPUT_LOG     = ~/Documents/QuickAccess/kb/ai-agents/heartbeat-output.log
RUNNER         = ~/.config/opencode/skills/heartbeat/heartbeat-runner.sh
SKILL_DIR      = ~/.config/opencode/skills/heartbeat/
```

The session in opencode is titled **"heartbeat"** and uses model **`anthropic/claude-sonnet-4-6`**.  
Working directory for the heartbeat opencode session: `~/Documents/QuickAccess/kb/ai-agents/`.

---

## Primitive: heartbeat-deploy

**When invoked:** User says "heartbeat-deploy", "install heartbeat", "setup heartbeat cron", or similar.

**What it does:** Installs the heartbeat cron job (or launchd plist on macOS) so the runner fires every hour. Creates the task register if it doesn't exist yet.

**Steps to execute:**

1. Detect OS: `uname -s`
2. Resolve the runner path: `RUNNER="${HOME}/.config/opencode/skills/heartbeat/heartbeat-runner.sh"`
3. Ensure the runner is executable: `chmod +x "${RUNNER}"`
4. Ensure HEARTBEAT_DIR exists: `mkdir -p "${HOME}/Documents/QuickAccess/kb/ai-agents"`
5. Initialise task register if missing (see schema below).
6. Install the cron entry:

```bash
# The cron line to install (runs at minute 0 of every hour):
CRON_LINE="0 * * * * ${HOME}/.config/opencode/skills/heartbeat/heartbeat-runner.sh >> ${HOME}/Documents/QuickAccess/kb/ai-agents/heartbeat-cron.log 2>&1"

# Install:
( crontab -l 2>/dev/null | grep -v "heartbeat-runner.sh" ; echo "${CRON_LINE}" ) | crontab -
```

7. Verify installation: `crontab -l | grep heartbeat-runner`
8. Report: print the installed cron line and the path to the task register.

**macOS note:** crontab works fine on macOS. launchd is NOT required — use crontab for portability.

**Task register initial schema (if creating from scratch):**
```json
{
  "version": 1,
  "tasks": []
}
```

---

## Primitive: heartbeat-add

**When invoked:** User says "heartbeat-add", "add task to heartbeat", or describes a new recurring task.

**What it does:** Adds a new task entry to the task register.

**Required fields to collect from user (ask if not provided):**
- `name` — unique short identifier (snake_case, no spaces)
- `description` — human-readable description
- `frequency_hours` — how often to run (integer, minimum 1, default 1)
- `enabled` — boolean, default true
- ONE of:
  - `script` — absolute path to a shell script to execute (script-based tasks)
  - `prompt` — string prompt to send to the heartbeat opencode session (LLM-based tasks)

**Steps to execute:**

```bash
TASK_REGISTER="${HOME}/Documents/QuickAccess/kb/ai-agents/heartbeat-tasks.json"
```

1. Read the current register.
2. Check for duplicate `name` — if exists, refuse and ask the user to remove first or use a different name.
3. Build the new task object:
```json
{
  "name": "<name>",
  "description": "<description>",
  "frequency_hours": <N>,
  "enabled": true,
  "script": "<path or omit>",
  "prompt": "<prompt or omit>",
  "last_run": ""
}
```
4. Append to `tasks` array, write back to register with `indent=2`.
5. Confirm to user: "Task `<name>` added. Next heartbeat run will execute it."

---

## Primitive: heartbeat-remove

**When invoked:** User says "heartbeat-remove", "remove task", "delete heartbeat task", or names a task to remove.

**What it does:** Removes a task from the task register by name.

**Steps to execute:**

1. Read `heartbeat-tasks.json`.
2. List current tasks with names and descriptions so user can confirm the right one.
3. Confirm: "Remove task `<name>`? (yes/no)"
4. On confirmation: filter out the task and write back.
5. Report: "Task `<name>` removed."

**Note:** Does NOT stop a currently-running heartbeat. Takes effect on the next run.

---

## Primitive: heartbeat-uninstall

**When invoked:** User says "heartbeat-uninstall", "remove heartbeat cron", "uninstall heartbeat", or similar.

**What it does:** Removes the cron entry. Leaves the task register, output log, and session ID intact.

**Steps to execute:**

```bash
# Remove the heartbeat cron line:
crontab -l 2>/dev/null | grep -v "heartbeat-runner.sh" | crontab -

# Verify removal:
if crontab -l 2>/dev/null | grep -q "heartbeat-runner.sh"; then
  echo "WARNING: cron entry still present — remove manually"
else
  echo "Heartbeat cron removed."
fi
```

Report: "Heartbeat cron uninstalled. Task register and logs preserved at ${HOME}/Documents/QuickAccess/kb/ai-agents/."

---

## Primitive: heartbeat-read

**When invoked:** User says "heartbeat-read", "show heartbeat log", "what did heartbeat do", "check heartbeat output", or similar.

**What it does:** Reads and displays the heartbeat output log (and optionally the Datadog alerts log).

**Steps to execute:**

```bash
OUTPUT_LOG="${HOME}/Documents/QuickAccess/kb/ai-agents/heartbeat-output.log"
ALERTS_LOG="${HOME}/Documents/QuickAccess/kb/ai-agents/heartbeat-datadog-alerts.log"
```

1. Check if `OUTPUT_LOG` exists. If not: "No heartbeat runs recorded yet."
2. By default show the **last 100 lines** of OUTPUT_LOG (use `tail -n 100`).
3. If user asks for "all" or "full", show the entire file.
4. If user asks specifically about "alerts" or "Datadog", show the last 100 lines of ALERTS_LOG instead.
5. Also show current task register summary: `cat heartbeat-tasks.json | python3 -c "import json,sys; d=json.load(sys.stdin); [print(f'  {t[\"name\"]} (every {t[\"frequency_hours\"]}h, last: {t.get(\"last_run\",\"never\")})') for t in d[\"tasks\"]]"`

**Additional flags (user may ask for):**
- "last N runs" — show last N run separators and their content
- "task <name>" — filter log lines to only show entries for that task
- "errors" — filter to lines containing ERROR or WARN

---

## Task Register Schema

```json
{
  "version": 1,
  "tasks": [
    {
      "name": "string — unique snake_case identifier",
      "description": "string — human description",
      "frequency_hours": 1,
      "enabled": true,
      "script": "/absolute/path/to/script.sh",
      "prompt": "omit if using script",
      "last_run": "2026-06-25T14:00:00Z or empty string"
    }
  ]
}
```

**Rules:**
- `name` must be unique. snake_case. No spaces.
- Exactly one of `script` or `prompt` must be set (not both, not neither).
- `frequency_hours` minimum: 1.
- `last_run` is managed automatically by the runner — never set manually.
- `enabled: false` skips the task without removing it.

---

## Built-in Tasks

The following tasks ship with the heartbeat skill and can be added via `heartbeat-add`:

### datadog-alert-diff

Monitors Datadog for CRITICAL and HIGH severity alerts. Logs only changes (new, resolved, changed) vs the previous run. First run logs the full snapshot.

```json
{
  "name": "datadog-alert-diff",
  "description": "Log new/resolved/changed Datadog CRITICAL and HIGH alerts vs previous hour",
  "frequency_hours": 1,
  "enabled": true,
  "script": "~/.config/opencode/skills/heartbeat/heartbeat-datadog-alerts.sh",
  "last_run": ""
}
```

Output log: `~/Documents/QuickAccess/kb/ai-agents/heartbeat-datadog-alerts.log`  
State file: `~/Documents/QuickAccess/kb/ai-agents/heartbeat-datadog-alerts.state.json`

Requires: `DD_API_KEY` and `DD_APP_KEY` environment variables, OR a Datadog config file at `~/Library/Application Support/Datadog/config.json` containing `api_key` and `app_key` fields.

---

## Runner Architecture

```
cron (every hour)
  └─ heartbeat-runner.sh
       ├─ Reads heartbeat-tasks.json
       ├─ Filters tasks by frequency_hours + last_run
       ├─ Resolves/creates persistent "heartbeat" opencode session
       │    └─ Stored in heartbeat-session.id
       │    └─ opencode run --session <id> --dir HEARTBEAT_DIR --model anthropic/claude-sonnet-4-6
       └─ For each due task:
            ├─ script tasks → exec the script directly
            └─ prompt tasks → opencode run --session <id> "<prompt>"
            └─ Appends output to heartbeat-output.log with timestamp + separator
            └─ Updates last_run in task register
```

---

## Troubleshooting

**Cron not firing:**
- Check `crontab -l` for the entry.
- Check `~/Documents/QuickAccess/kb/ai-agents/heartbeat-cron.log` for raw cron output.
- On macOS, ensure "Full Disk Access" is granted to `/usr/sbin/cron` in System Preferences → Privacy & Security.

**Session not resuming:**
- Delete `heartbeat-session.id` to force creation of a new session next run.

**Datadog task failing:**
- Ensure `DD_API_KEY` and `DD_APP_KEY` are set in the cron environment (add to the cron line: `DD_API_KEY=xxx DD_APP_KEY=yyy 0 * * * * ...`), or configure them in `~/Library/Application Support/Datadog/config.json`.
- Run the script manually: `~/.config/opencode/skills/heartbeat/heartbeat-datadog-alerts.sh`

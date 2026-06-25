#!/usr/bin/env bash
# heartbeat-datadog-alerts.sh — Datadog critical/high alert diff task
# Fetches current CRITICAL and HIGH alerts, diffs against previous run,
# writes only NEW/CHANGED/RESOLVED alerts to heartbeat-datadog-alerts.log
# Nothing is written if nothing changed.
set -uo pipefail

HEARTBEAT_DIR="${HOME}/Documents/QuickAccess/kb/ai-agents"
ALERTS_LOG="${HEARTBEAT_DIR}/heartbeat-datadog-alerts.log"
STATE_FILE="${HEARTBEAT_DIR}/heartbeat-datadog-alerts.state.json"
RUN_TS="$(date '+%Y-%m-%d %H:%M:%S')"
SEP="────────────────────────────────────────────────────────────────────────────────"
TMP_RAW="$(mktemp)"
TMP_CURRENT="$(mktemp)"
TMP_DIFF="$(mktemp)"
cleanup() { rm -f "${TMP_RAW}" "${TMP_CURRENT}" "${TMP_DIFF}"; }
trap cleanup EXIT

mkdir -p "${HEARTBEAT_DIR}"

# ── Resolve Datadog credentials ───────────────────────────────────────────────
DD_SITE="${DD_SITE:-datadoghq.com}"

if [[ -z "${DD_API_KEY:-}" || -z "${DD_APP_KEY:-}" ]]; then
  DD_CONFIG="${HOME}/Library/Application Support/Datadog/config.json"
  if [[ -f "${DD_CONFIG}" ]]; then
    DD_API_KEY="$(python3 -c "import json; d=json.load(open('${DD_CONFIG}')); print(d.get('api_key',''))" 2>/dev/null || true)"
    DD_APP_KEY="$(python3 -c "import json; d=json.load(open('${DD_CONFIG}')); print(d.get('app_key',''))" 2>/dev/null || true)"
  fi
fi

# Resolve DD_SITE from the MCP CLI config if not already set
if [[ "${DD_SITE}" == "datadoghq.com" ]]; then
  MCP_CLI_CONFIG="${HOME}/Library/Application Support/Datadog/datadog_mcp_cli.json"
  if [[ -f "${MCP_CLI_CONFIG}" ]]; then
    BASE_DOMAIN="$(python3 -c "import json; d=json.load(open('${MCP_CLI_CONFIG}')); print(d.get('base_api_domain',''))" 2>/dev/null || true)"
    if [[ -n "${BASE_DOMAIN}" ]]; then
      DD_SITE="${BASE_DOMAIN#api.}"
    fi
  fi
fi

if [[ -z "${DD_API_KEY:-}" || -z "${DD_APP_KEY:-}" ]]; then
  echo "ERROR: DD_API_KEY and DD_APP_KEY not set. Set them as env vars or add api_key/app_key to ~/Library/Application Support/Datadog/config.json"
  exit 1
fi

# ── Fetch monitors in Alert state ────────────────────────────────────────────
HTTP_CODE="$(curl -s --max-time 30 -w "%{http_code}" -o "${TMP_RAW}" \
  -H "DD-API-KEY: ${DD_API_KEY}" \
  -H "DD-APPLICATION-KEY: ${DD_APP_KEY}" \
  "https://api.${DD_SITE}/api/v1/monitor?monitor_search=status%3AAlert&page_size=200" \
  2>/dev/null || echo "000")"

if [[ "${HTTP_CODE}" != "200" ]]; then
  echo "ERROR: Datadog API returned HTTP ${HTTP_CODE}"
  cat "${TMP_RAW}" 2>/dev/null || true
  exit 1
fi

# ── Parse: filter to CRITICAL and HIGH only ──────────────────────────────────
python3 -c "
import json, sys

with open('${TMP_RAW}') as f:
    raw = f.read()

try:
    monitors = json.loads(raw)
except Exception as e:
    print(json.dumps([{'id': 'parse_error', 'name': str(e), 'severity': 'ERROR', 'status': 'ERROR', 'tags': []}]))
    sys.exit(0)

if not isinstance(monitors, list):
    monitors = monitors.get('monitors', []) if isinstance(monitors, dict) else []

alerts = []
for m in monitors:
    state = m.get('overall_state', '')
    if state not in ('Alert', 'No Data'):
        continue
    tags = m.get('tags', [])
    priority = m.get('priority')
    severity = None
    if priority == 1:
        severity = 'CRITICAL'
    elif priority == 2:
        severity = 'HIGH'
    else:
        tl = [t.lower() for t in tags]
        if any(t in ('p1', 'priority:1', 'priority:critical', 'severity:critical') for t in tl):
            severity = 'CRITICAL'
        elif any(t in ('p2', 'priority:2', 'priority:high', 'severity:high') for t in tl):
            severity = 'HIGH'
    if severity is None:
        continue
    alerts.append({'id': str(m.get('id','')), 'name': m.get('name',''), 'status': state,
                   'severity': severity, 'type': m.get('type',''), 'tags': tags,
                   'modified': m.get('modified','')})

alerts.sort(key=lambda x: (x['severity'], x['name']))
print(json.dumps(alerts))
" > "${TMP_CURRENT}"

# ── Diff vs previous state ────────────────────────────────────────────────────
python3 -c "
import json

with open('${TMP_CURRENT}') as f:
    current = json.load(f)

try:
    with open('${STATE_FILE}') as f:
        previous = json.load(f)
except FileNotFoundError:
    previous = []
except Exception:
    previous = []

is_first = len(previous) == 0
prev_by_id = {a['id']: a for a in previous}
curr_by_id = {a['id']: a for a in current}

new_alerts = [a for id_, a in curr_by_id.items() if id_ not in prev_by_id]
resolved   = [a for id_, a in prev_by_id.items() if id_ not in curr_by_id]
changed    = [curr_by_id[id_] for id_ in curr_by_id
              if id_ in prev_by_id and prev_by_id[id_] != curr_by_id[id_]]

print(json.dumps({'new': new_alerts, 'resolved': resolved, 'changed': changed,
                  'is_first': is_first, 'total': len(current)}))
" > "${TMP_DIFF}"

# ── Format and write ──────────────────────────────────────────────────────────
python3 -c "
import json, sys

with open('${TMP_DIFF}') as f:
    d = json.load(f)

is_first   = d['is_first']
new_alerts = d['new']
resolved   = d['resolved']
changed    = d['changed']
total      = d['total']

if not is_first and not new_alerts and not resolved and not changed:
    print('__NO_CHANGE__')
    sys.exit(0)

lines = []
if is_first:
    lines.append(f'  [INITIAL SNAPSHOT] {total} CRITICAL/HIGH alert(s) currently active')
    for a in new_alerts:
        lines.append(f'    [{a[\"severity\"]:8s}] {a[\"name\"]}  (id:{a[\"id\"]})')
    if not new_alerts:
        lines.append('    (none)')
else:
    if new_alerts:
        lines.append(f'  NEW ({len(new_alerts)}):')
        for a in new_alerts:
            lines.append(f'    [{a[\"severity\"]:8s}] {a[\"name\"]}  (id:{a[\"id\"]})')
    if resolved:
        lines.append(f'  RESOLVED ({len(resolved)}):')
        for a in resolved:
            lines.append(f'    [{a[\"severity\"]:8s}] {a[\"name\"]}  (id:{a[\"id\"]})')
    if changed:
        lines.append(f'  CHANGED ({len(changed)}):')
        for a in changed:
            lines.append(f'    [{a[\"severity\"]:8s}] {a[\"name\"]}  (id:{a[\"id\"]})')

print('\n'.join(lines))
" > "${TMP_DIFF}.fmt"

FORMATTED="$(cat "${TMP_DIFF}.fmt")"
rm -f "${TMP_DIFF}.fmt"

if [[ "${FORMATTED}" == "__NO_CHANGE__" ]]; then
  echo "No alert changes this run — nothing logged."
  exit 0
fi

{
  echo ""
  echo "${SEP}"
  echo "  Datadog Alerts — ${RUN_TS}"
  echo "${SEP}"
  echo "${FORMATTED}"
  echo ""
} >> "${ALERTS_LOG}"

cp "${TMP_CURRENT}" "${STATE_FILE}"

echo "${FORMATTED}"
echo "Written to: ${ALERTS_LOG}"

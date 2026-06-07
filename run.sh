#!/usr/bin/env bash
set -e

# HomeAssistant add-on wrapper for databasus/databasus.
#
# The upstream image's real entrypoint is /app/start.sh, which initialises
# PostgreSQL, generates the runtime config and finally execs the application.
# This Dockerfile overrides ENTRYPOINT to [], so we must hand off to it here.
#
# HomeAssistant writes the add-on user configuration to /data/options.json.
# We translate every top-level option into an environment variable (the names
# databasus expects are upper-case, e.g. PUID, PGID, SMTP_HOST, DATABASUS_URL)
# so it can be configured from the add-on UI.

OPTIONS_FILE="/data/options.json"

if [ -f "${OPTIONS_FILE}" ] && command -v jq >/dev/null 2>&1; then
    echo "Applying HomeAssistant add-on options from ${OPTIONS_FILE}..."
    while IFS="=" read -r key value; do
        [ -z "${key}" ] && continue
        export "${key}=${value}"
    done < <(jq -r 'to_entries[] | "\(.key)=\(.value)"' "${OPTIONS_FILE}")
fi

echo "Handing off to upstream entrypoint (/app/start.sh)..."
exec /app/start.sh

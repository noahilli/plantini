#!/bin/sh
set -eu

: "${PLANTINI_API_BASE_URL:=https://api.plantini.eu/api/v1}"
: "${PLANTINI_OIDC_ISSUER_URL:=https://auth.plantini.eu/realms/plantini}"
: "${PLANTINI_OIDC_CLIENT_ID:=plantini-teacher-production}"
: "${TEACHER_LISTEN_PORT:=8080}"

# Validate before interpolating values into an Nginx header. Only public config.
validate_url() {
  jq -en --arg value "$1" '$value | test("^https?://[A-Za-z0-9.-]+(:[0-9]{1,5})?(/[A-Za-z0-9._~/-]*)?$")' >/dev/null
}
if ! validate_url "$PLANTINI_API_BASE_URL" || ! validate_url "$PLANTINI_OIDC_ISSUER_URL"; then
  echo 'Teacher: API base and issuer must be plain HTTP(S) URLs without credentials, query or fragment.' >&2
  exit 1
fi
if ! jq -en --arg value "$PLANTINI_OIDC_CLIENT_ID" '$value | test("^[A-Za-z0-9._-]+$")' >/dev/null; then
  echo 'Teacher: invalid public OIDC client ID.' >&2
  exit 1
fi
case "$TEACHER_LISTEN_PORT" in ''|*[!0-9]*) echo 'Teacher: invalid listen port.' >&2; exit 1 ;; esac
if [ "$TEACHER_LISTEN_PORT" -lt 1024 ] || [ "$TEACHER_LISTEN_PORT" -gt 65535 ]; then
  echo 'Teacher: unprivileged listen port must be between 1024 and 65535.' >&2
  exit 1
fi
API_ORIGIN=$(jq -nr --arg value "$PLANTINI_API_BASE_URL" '$value | capture("^(?<origin>https?://[^/]+)").origin')
OIDC_ORIGIN=$(jq -nr --arg value "$PLANTINI_OIDC_ISSUER_URL" '$value | capture("^(?<origin>https?://[^/]+)").origin')
export TEACHER_LISTEN_PORT API_ORIGIN OIDC_ORIGIN

umask 077
jq -n --arg apiBase "$PLANTINI_API_BASE_URL" --arg issuer "$PLANTINI_OIDC_ISSUER_URL" --arg clientId "$PLANTINI_OIDC_CLIENT_ID" \
  '{apiBase:$apiBase,issuer:$issuer,clientId:$clientId}' > /tmp/teacher-config.json
envsubst '${TEACHER_LISTEN_PORT} ${API_ORIGIN} ${OIDC_ORIGIN}' \
  < /opt/teacher/nginx.conf.template > /tmp/teacher-nginx.conf
nginx -t -c /tmp/teacher-nginx.conf
exec "$@"

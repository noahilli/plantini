#!/usr/bin/env bash
# Sets the complete Keycloak realm SMTP configuration through kcadm inside the
# running container. The password comes from the root-only production env file,
# so it never lands in the versioned realm JSON or in shell history.
# Note: `kcadm get --fields smtpServer` prints `{ }`; read the full realm instead.
# Usage (on the server): sudo ./configure-smtp.sh /opt/plantini/production.env
# Env: SMTP_HOST, SMTP_PORT (implicit TLS, e.g. 465), SMTP_USER, SMTP_PASSWORD
set -euo pipefail
env_file="${1:?path to production.env}"
set -a; . "$env_file"; set +a
: "${SMTP_HOST:?}" "${SMTP_PORT:?}" "${SMTP_USER:?}" "${SMTP_PASSWORD:?}" "${KEYCLOAK_ADMIN_USERNAME:?}" "${KEYCLOAK_ADMIN_PASSWORD:?}"
compose=(docker compose --env-file "$env_file" -f "$(dirname "$0")/../compose.production.yaml")
"${compose[@]}" exec -T \
  -e SMTP_HOST -e SMTP_PORT -e SMTP_USER -e SMTP_PASSWORD \
  -e KC_ADMIN="$KEYCLOAK_ADMIN_USERNAME" -e KC_ADMIN_PW="$KEYCLOAK_ADMIN_PASSWORD" keycloak bash -c '
  set -euo pipefail
  kcadm=/opt/keycloak/bin/kcadm.sh
  $kcadm config credentials --server http://127.0.0.1:8080 --realm master --user "$KC_ADMIN" --password "$KC_ADMIN_PW" >/dev/null
  $kcadm update realms/plantini \
    -s smtpServer.host="$SMTP_HOST" -s smtpServer.port="$SMTP_PORT" \
    -s smtpServer.from="$SMTP_USER" -s smtpServer.fromDisplayName=Plantini \
    -s smtpServer.ssl=true -s smtpServer.starttls=false -s smtpServer.auth=true \
    -s smtpServer.user="$SMTP_USER" -s smtpServer.password="$SMTP_PASSWORD" >/dev/null
  echo "SMTP configuration stored in realm plantini."'

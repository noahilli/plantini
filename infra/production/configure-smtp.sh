#!/usr/bin/env bash
# Sets the Keycloak realm SMTP password from the root-only production env file
# using kcadm inside the running container, so the password never lands in the
# versioned realm JSON or in shell history.
# Usage (on the server): sudo ./configure-smtp.sh /opt/plantini/production.env
set -euo pipefail
env_file="${1:?path to production.env}"
set -a; . "$env_file"; set +a
: "${SMTP_PASSWORD:?missing SMTP_PASSWORD}" "${KEYCLOAK_ADMIN_USERNAME:?}" "${KEYCLOAK_ADMIN_PASSWORD:?}"
compose=(docker compose --env-file "$env_file" -f "$(dirname "$0")/../compose.production.yaml")
"${compose[@]}" exec -T -e SMTP_PASSWORD -e KC_ADMIN="$KEYCLOAK_ADMIN_USERNAME" -e KC_ADMIN_PW="$KEYCLOAK_ADMIN_PASSWORD" keycloak bash -c '
  set -euo pipefail
  kcadm=/opt/keycloak/bin/kcadm.sh
  $kcadm config credentials --server http://127.0.0.1:8080 --realm master --user "$KC_ADMIN" --password "$KC_ADMIN_PW" >/dev/null
  $kcadm update realms/plantini -s "smtpServer.password=$SMTP_PASSWORD" >/dev/null
  echo "SMTP password stored in realm plantini."'

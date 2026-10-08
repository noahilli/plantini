#!/bin/sh
# Builds the Flutter web app for the local network and starts the demo stack so that
# other computers on the same network can open http://<this computer>:3100.
# Own compose project (plantini-lan), own ports; the loopback E2E stack is not touched.
#   tools/scripts/start-lan-demo.sh [<IPv4 of this computer>] [--skip-build]
#   tools/scripts/start-lan-demo.sh --stop
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo_dir=$(CDPATH= cd -- "$script_dir/../.." && pwd)
runtime="$repo_dir/tools/e2e/.runtime/lan"
env_file="$runtime/lan.env"
compose() {
  docker compose -p plantini-lan --env-file "$env_file" \
    -f "$repo_dir/infra/compose.e2e.yaml" -f "$repo_dir/infra/compose.lan.yaml" "$@"
}

if [ "${1:-}" = "--stop" ]; then
  [ -f "$env_file" ] && compose down
  exit 0
fi

host=""
build=true
for arg in "$@"; do
  case "$arg" in
    --skip-build) build=false ;;
    *) host=$arg ;;
  esac
done
if [ -z "$host" ]; then
  host=$(ip -4 route get 1.1.1.1 | awk '{for (i = 1; i < NF; i++) if ($i == "src") {print $(i + 1); exit}}')
fi

node "$repo_dir/tools/e2e/scripts/prepare-lan-env.mjs" "$host" ${LAN_DEMO_PASSWORD:+"$LAN_DEMO_PASSWORD"}

if [ "$build" = true ]; then
  (
    cd "$repo_dir/apps/flutter"
    flutter pub get
    flutter build web --release --output build/web-lan \
      --dart-define=PLANTINI_ENV=development \
      --dart-define="PLANTINI_API_BASE_URL=http://$host:1438/api/v1" \
      --dart-define="PLANTINI_OIDC_ISSUER_URL=http://$host:8182/realms/plantini" \
      --dart-define=PLANTINI_OIDC_CLIENT_ID=plantini-web-dev
  )
fi

export COMPOSE_PARALLEL_LIMIT=1
compose up --detach --build --wait \
  postgres-platform postgres-keycloak redis plantnet-mock keycloak platform web
compose run --rm --no-deps keycloak-bootstrap

username=$(awk -F= '$1 == "E2E_USERNAME" {sub(/^[^=]*=/, ""); print; exit}' "$env_file")
password=$(awk -F= '$1 == "E2E_USER_PASSWORD" {sub(/^[^=]*=/, ""); print; exit}' "$env_file")
curl -4 --fail --silent --show-error "http://$host:1438/api/v1/health" >/dev/null
curl -4 --fail --silent --show-error "http://$host:3100/healthz" >/dev/null

printf '\nPlantini-LAN-Demo ist bereit.\n'
printf 'Web-App:  http://%s:3100\n' "$host"
printf 'Login:    %s\n' "$username"
printf 'Passwort: %s\n' "$password"
printf 'Hinweis:  Entwicklungsstack ohne HTTPS, nur im vertrauten Netz; beenden mit --stop.\n\n'

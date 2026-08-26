#!/bin/sh
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
e2e_dir=$(CDPATH= cd -- "$script_dir/.." && pwd)
repo_dir=$(CDPATH= cd -- "$e2e_dir/../.." && pwd)
env_file="$e2e_dir/.runtime/e2e.env"

node "$script_dir/prepare-e2e-env.mjs"

(
  cd "$repo_dir/apps/flutter"
  XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp/plantini-flutter-cache}" \
    flutter build web --release \
    --dart-define=PLANTINI_ENV=development \
    --dart-define=PLANTINI_API_BASE_URL=http://127.0.0.1:1338/api/v1 \
    --dart-define=PLANTINI_OIDC_ISSUER_URL=http://127.0.0.1:8082/realms/plantini \
    --dart-define=PLANTINI_OIDC_CLIENT_ID=plantini-web-dev
)

docker compose --env-file "$env_file" -f "$repo_dir/infra/compose.e2e.yaml" down --volumes --remove-orphans
docker compose --env-file "$env_file" -f "$repo_dir/infra/compose.e2e.yaml" up --detach --build --wait
docker compose --env-file "$env_file" -f "$repo_dir/infra/compose.e2e.yaml" wait keycloak-bootstrap

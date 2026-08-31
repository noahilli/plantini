#!/bin/sh
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
e2e_dir=$(CDPATH= cd -- "$script_dir/.." && pwd)
repo_dir=$(CDPATH= cd -- "$e2e_dir/../.." && pwd)
env_file="$e2e_dir/.runtime/e2e.env"
runtime_dir="$e2e_dir/.runtime"
test_results_dir="$runtime_dir/test-results"
html_report_dir="$runtime_dir/playwright-report"
required_flutter_version=${PLANTINI_E2E_FLUTTER_VERSION:-3.47.1}
# Docker Compose 5.5 can race duplicate create requests in this stack on
# developer machines. A serial default keeps fresh E2E runs deterministic;
# callers can explicitly raise it on a verified Compose version.
export COMPOSE_PARALLEL_LIMIT=${PLANTINI_E2E_COMPOSE_PARALLEL_LIMIT:-1}

if ! command -v flutter >/dev/null 2>&1; then
  echo 'Flutter is required to build the E2E web application.' >&2
  exit 127
fi

installed_flutter_version=$(flutter --version | awk 'NR == 1 { print $2 }')
if [ "$installed_flutter_version" != "$required_flutter_version" ]; then
  echo "E2E requires Flutter $required_flutter_version; found ${installed_flutter_version:-unknown}." >&2
  exit 64
fi

node "$script_dir/prepare-e2e-env.mjs"

# Keep Playwright output below the ignored, user-writable E2E runtime folder.
# This deliberately avoids stale root-owned report directories from a prior
# containerized run and prevents test artifacts from appearing in the source tree.
mkdir -p "$test_results_dir" "$html_report_dir"
chmod 700 "$runtime_dir" "$test_results_dir" "$html_report_dir"
node "$script_dir/run-with-e2e-env.mjs" \
  node --dns-result-order=ipv4first "$script_dir/verify-e2e-env.mjs"

docker compose --env-file "$env_file" -f "$repo_dir/infra/compose.e2e.yaml" down --volumes --remove-orphans

(
  cd "$repo_dir/apps/flutter"
  export XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp/plantini-flutter-cache}"
  flutter pub get
  flutter build web --release \
    --dart-define=PLANTINI_ENV=development \
    --dart-define=PLANTINI_API_BASE_URL=http://127.0.0.1:1338/api/v1 \
    --dart-define=PLANTINI_OIDC_ISSUER_URL=http://127.0.0.1:8082/realms/plantini \
    --dart-define=PLANTINI_OIDC_CLIENT_ID=plantini-web-dev
)

# The Keycloak bootstrap is a successful one-shot job. Compose 5.5 either
# treats it as a failed long-running service under `up --wait` or loses it
# before `compose wait` can address it. Start and health-check only durable
# services, then execute the bootstrap explicitly with its exit status.
docker compose --env-file "$env_file" -f "$repo_dir/infra/compose.e2e.yaml" \
  up --detach --build --wait \
  postgres-platform postgres-keycloak redis plantnet-mock keycloak platform web
docker compose --env-file "$env_file" -f "$repo_dir/infra/compose.e2e.yaml" \
  run --rm --no-deps keycloak-bootstrap
node "$script_dir/run-with-e2e-env.mjs" \
  node --dns-result-order=ipv4first "$script_dir/verify-e2e-env.mjs" --check-readiness

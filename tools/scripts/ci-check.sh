#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
echo "🧪 Starte vollständigen lokalen CI & Quality Check..."
echo "==================================================="

echo "[1/4] Backend & Identity Tests..."
cd "$SCRIPT_DIR/services/platform"
npm run lint
npm run check
npm test
npm run build
cd "$SCRIPT_DIR"
node --test services/identity/test/*.test.mjs

echo ""
echo "[2/4] Flutter Static Analysis & Unit Tests..."
cd "$SCRIPT_DIR/apps/flutter"
flutter --no-version-check analyze
flutter --no-version-check test

echo ""
echo "[3/4] Flutter Web & Linux Build Verification..."
flutter --no-version-check build web
PLANTINI_ENV=development \
PLANTINI_API_BASE_URL=http://127.0.0.1:1338/api/v1 \
PLANTINI_OIDC_ISSUER_URL=http://127.0.0.1:8082/realms/plantini \
PLANTINI_OIDC_CLIENT_ID=plantini-mobile-dev \
  ./tool/build-linux.sh

echo ""
echo "[4/4] API Smoke Tests (gegen lokale Docker-Umgebung auf IPv4)..."
cd "$SCRIPT_DIR"

check_ep() {
  local name="$1" url="$2" expect="$3"
  local status
  if ! status=$(curl --ipv4 --max-time 10 -sS -o /dev/null -w "%{http_code}" "$url"); then
    status="000"
  fi
  if [ "$status" = "$expect" ]; then
    echo "  ✅ $name → HTTP $status"
  else
    echo "  ❌ $name → HTTP $status (erwartet $expect)"
    smoke_failures=$((smoke_failures + 1))
  fi
}

smoke_failures=0
check_ep "GET /api/v1/health" "http://127.0.0.1:1338/api/v1/health" "200"
check_ep "GET /api/v1/content/manifest" "http://127.0.0.1:1338/api/v1/content/manifest" "200"
check_ep "GET /api/v1/ecosystems" "http://127.0.0.1:1338/api/v1/ecosystems" "200"
check_ep "Keycloak OIDC Discovery" "http://127.0.0.1:8082/realms/plantini/.well-known/openid-configuration" "200"

if (( smoke_failures > 0 )); then
  echo ""
  echo "❌ API Smoke Tests fehlgeschlagen. Starte die lokale Compose-Umgebung und prüfe deren Healthchecks."
  exit 1
fi

echo ""
echo "✅ Quality Check erfolgreich abgeschlossen!"

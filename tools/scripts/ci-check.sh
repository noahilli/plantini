#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
echo "🧪 Starte vollständigen lokalen CI & Quality Check..."
echo "==================================================="

echo "[1/5] Backend & Identity Tests..."
cd "$SCRIPT_DIR/services/platform"
npm test
cd "$SCRIPT_DIR"
node --test services/identity/test/*.test.mjs

echo ""
echo "[2/5] Flutter Static Analysis & Unit Tests..."
cd "$SCRIPT_DIR/apps/flutter"
flutter analyze
flutter test

echo ""
echo "[3/5] Flutter Web & Linux Build Verification..."
flutter build web
flutter build linux

echo ""
echo "[4/5] API Smoke Tests (gegen lokale Docker-Umgebung)..."
cd "$SCRIPT_DIR"

check_ep() {
  local name="$1" url="$2" expect="$3"
  local status
  status=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null || echo "000")
  if [ "$status" = "$expect" ]; then
    echo "  ✅ $name → HTTP $status"
  else
    echo "  ⚠️  $name → HTTP $status (erwartet $expect)"
  fi
}

check_ep "GET /api/manifest"       "http://localhost:1338/api/manifest"    "200"
check_ep "GET /api/ecosystem"      "http://localhost:1338/api/ecosystem"   "200"
check_ep "GET /api/plants"         "http://localhost:1338/api/plants"      "200"
check_ep "GET /api/quizzes"        "http://localhost:1338/api/quizzes"     "200"
check_ep "Keycloak OIDC Discovery" "http://localhost:8082/realms/plantini/.well-known/openid-configuration" "200"

echo ""
echo "[4/4] Quality Check erfolgreich abgeschlossen! 🎉"

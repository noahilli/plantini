#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_PLATFORM="${1:-linux}"

echo "🌱 Plantini – Gesamtumgebung starten"
echo "========================================="
echo "Ziel-Plattform: $TARGET_PLATFORM (Aufruf: ./start.sh [linux|web])"
echo ""

# ── 1. Docker-Infrastruktur ──────────────────────────────────────
echo "[1/4] Docker-Container hochfahren..."
docker compose -f "$SCRIPT_DIR/infra/compose.yaml" up -d

echo ""
echo "[2/4] Warte auf Healthchecks..."

wait_for() {
  local name="$1" url="$2" max="$3"
  for i in $(seq 1 "$max"); do
    if curl -sf "$url" > /dev/null 2>&1; then
      echo "  ✅ $name erreichbar"
      return 0
    fi
    sleep 2
  done
  echo "  ⚠️  $name nicht erreichbar nach ${max}x2s – weiter trotzdem"
  return 0
}

wait_for "PostgreSQL (Platform)" "http://localhost:1338/_health" 30
wait_for "Keycloak"              "http://localhost:8082/realms/plantini" 30
wait_for "Mailpit"               "http://localhost:8025/api/v1/info" 10

echo ""
echo "[3/4] Schnell-Test der API-Endpunkte..."

test_endpoint() {
  local name="$1" url="$2" expect="$3"
  local status
  status=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null || echo "000")
  if [ "$status" = "$expect" ]; then
    echo "  ✅ $name → HTTP $status"
  else
    echo "  ❌ $name → HTTP $status (erwartet $expect)"
  fi
}

test_endpoint "GET /api/manifest"   "http://localhost:1338/api/manifest"   "200"
test_endpoint "GET /api/ecosystem"  "http://localhost:1338/api/ecosystem"  "200"
test_endpoint "GET /api/plants"     "http://localhost:1338/api/plants"     "200"
test_endpoint "GET /api/quizzes"    "http://localhost:1338/api/quizzes"    "200"
test_endpoint "Keycloak OIDC"       "http://localhost:8082/realms/plantini/.well-known/openid-configuration" "200"

echo ""
echo "========================================="
echo "Infrastruktur-Übersicht:"
echo "  🔐 Keycloak Auth:    http://localhost:8082  (admin/admin)"
echo "  📦 Strapi Backend:   http://localhost:1338/admin"
echo "  📧 Mailpit (Mails):  http://localhost:8025"
echo "  💾 MinIO Storage:    http://localhost:9002"
echo "  🌐 PlantNet Mock:    http://localhost:1080"
echo "========================================="
echo ""

# ── 2. Flutter App ──────────────────────────────────────────────
cd "$SCRIPT_DIR/apps/flutter"

if [ "$TARGET_PLATFORM" = "web" ]; then
  echo "[4/4] Starte Flutter Web-App..."
  echo "  Die App wird auf http://localhost:3000 bereitgestellt."
  echo "  (Strg+C beendet nur die App. Docker läuft weiter.)"
  echo "-----------------------------------------"
  flutter run -d web-server --web-port 3000 --web-hostname 0.0.0.0
else
  echo "[4/4] Starte native Linux Desktop-App..."
  echo "  (Strg+C beendet die App. Docker läuft weiter.)"
  echo "-----------------------------------------"
  flutter run -d linux
fi

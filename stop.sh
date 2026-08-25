#!/bin/bash
echo "🛑 Stoppe Plantini Docker-Umgebung..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
docker compose -f "$SCRIPT_DIR/infra/compose.yaml" down
echo "✅ Alle Container gestoppt."

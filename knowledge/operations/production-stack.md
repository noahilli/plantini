# Production-Stack

`infra/compose.production.yaml` ist die einzige Compose-Definition für einen
Single-Host-Produktionsbetrieb. `infra/compose.yaml` bleibt ausschließlich für
lokale Entwicklung; `infra/compose.e2e.yaml` bleibt eine isolierte Testumgebung.

## Voraussetzungen

- Linux-Host mit Docker Compose und einem TLS-Reverse-Proxy
- öffentliche HTTPS-Adressen für Web, API und Keycloak
- immutable, geprüfte Image-Referenzen inklusive Digest
- extern verwaltete, zufällige Secrets
- ein vorab provisioniertes Production-Realm ohne Dev-Redirects
- getestete Backups der beiden PostgreSQL-Volumes und des privaten Medien-Volumes

## Preflight

```bash
cp infra/production.env.example .runtime/production.env
# Werte ausschließlich aus Secret Management ergänzen.
docker compose --env-file .runtime/production.env \
  -f infra/compose.production.yaml config --quiet
node services/identity/scripts/validate-realm-security.mjs \
  services/identity/realm/plantini-realm.json --environment=production
```

Ein fehlender Wert muss bereits bei `config` fehlschlagen. Der aktuelle
Development-Realm ist absichtlich kein Production-Realm und muss vor einem
öffentlichen Deployment mit echten Domains, TLS, SMTP und Production-Clients
provisioniert und anschließend exportiert/validiert werden.

## Start und Prüfung

```bash
docker compose --env-file .runtime/production.env \
  -f infra/compose.production.yaml up -d
docker compose --env-file .runtime/production.env \
  -f infra/compose.production.yaml ps
curl --fail --silent --show-error https://api.example.org/api/v1/health
curl --fail --silent --show-error \
  https://auth.example.org/realms/plantini/.well-known/openid-configuration
```

Der Reverse-Proxy darf öffentlich ausschließlich HTTPS bereitstellen. Die
Loopback-Ports 1338 und 8082 bleiben an `127.0.0.1` gebunden. Vor Freigabe sind
Login, Lernen, Quiz, PlantNet, Herbarium, Backup und Restore gegen die konkrete
Zielumgebung nachzuweisen.

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
- vertraglich bestätigtes tägliches Pl@ntNet-Limit und eine bewusst gewählte
  Quotenreserve (`PLANTNET_DAILY_REQUEST_LIMIT`, `PLANTNET_QUOTA_RESERVE`)

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

Der Identifikationsworker schützt die konfigurierte Tagesquote atomar in Redis.
Die Reserve wird nicht für reguläre Nutzeraufträge verbraucht. Wiederholte
transiente Providerfehler öffnen einen geteilten Circuit Breaker; nach fünf
erfolglosen Jobversuchen bleibt der Auftrag mit `deadLetteredAt` persistent und
kann in der App bewusst neu gestartet werden. Die Werte müssen zur tatsächlich
gebuchten Providerquote passen und sind kein Ersatz für FIELD-09-Vertrags- und
Datenschutzfreigaben.

## Ausrollung 05.10.2026: Lehrendenportal und nachgeholtes App-Release

Die bestehenden PostgreSQL-/Redis-/Keycloak-Volumes wurden weiterverwendet;
kein `down`, Realm-Neuimport oder Zurücksetzen bestehender Nutzer. Vorher wurde
das Produktionsbackup `20261005T105241Z` erfolgreich erstellt. Die vorherige
Compose-/Caddy-Konfiguration, Webdateien und Android-Downloads bleiben unter
`/opt/plantini/releases/3f00d12/` erhalten; die geschützte Env-Datei wurde vor
ihrer Änderung separat gesichert.

Aktiv sind `plantini/platform:059ac98`, `plantini/editor:059ac98` und
`plantini/teacher:059ac98`. Die kleinen Source-Overlays wurden auf den zuvor
inspizierten lokalen Image-IDs gebaut; Backend-Lint, Check und 45 Tests bestanden
im Build (vier optionale Redis-Tests übersprungen). Homepage und Keycloak-Image
blieben unverändert. Der bestehende Realm wurde deklarativ um Portalclient und
beschränktes Kontoverwaltungs-Servicekonto ergänzt. Selbstregistrierung ist aus.

- Lehrendenportal: https://portal.plantini.eu; Einrichtung und Rechte siehe
  `knowledge/teacher-portal.md`. Bestehende Systemadmins können im Studio unter
  Team Lehrende einladen; E-Mail-Zustellung benötigt funktionierendes SMTP.
- Web-App: https://app.plantini.eu, Version **0.6.4+8**.
- Signiertes Android-Paket: https://plantini.eu/download/plantini.apk;
  Metadaten unter `/download/plantini.json`, SHA-256 unter
  `/download/plantini.apk.sha256`. Lokale und ausgerollte APK-Prüfsummen stimmen.
- Aktiver Katalog: `2026.10.02-de.2`, drei Ökosysteme, 90 Level, 30 Pflanzen.
  Alle drei ausgelieferten Content-Pakete wurden auf Bytezahl und SHA-256
  geprüft. Die Mindest-App-Version `0.6.3` wird jetzt durch die App erzwungen.

HTTPS für Portal, Studio und App sowie API-Health und Container-Health wurden
live geprüft. Die unangemeldete Lehrenden-API liefert 401. Die bestehende lokale
E2E-Kernreise bestand zweimal, einschließlich Herbarium, Reload und erneuter
Anmeldung; ihre Pflanzenbestimmung verwendet weiterhin den Mock-Anbieter.
Dies ist kein Nachweis echter PlantNet-Antworten oder vollständiger
Produktionsreife. Atomic Publishing im Studio, signierte Content-Manifeste und
die weiteren offenen CMS-/Content-Abnahmebedingungen bleiben separate Aufgaben.

# Lokaler Präsentations-Stack

Für eine reproduzierbare Präsentation startet Plantini standardmäßig einen
frischen, isolierten IPv4-Stack mit Keycloak, PostgreSQL, Redis, deutschen
Demoinhalten und dem deterministischen PlantNet-Mock. Damit bleibt die gesamte
Kernreise auch ohne externes Netz und Providerquote vorführbar.

## Voraussetzungen

- Docker Compose, Node.js/npm, Flutter 3.47.1 und Chromium
- freie IPv4-Ports 3000 (Web), 1338 (API) und 8082 (Keycloak)

## Start

```bash
tools/scripts/start-local-demo.sh
```

Der Befehl baut App und Stack frisch, prüft die IPv4-Endpunkte, gibt die bei
jedem Start neu erzeugten Zugangsdaten aus und öffnet
`http://127.0.0.1:3000`. Ohne automatischen Browserstart:

```bash
tools/scripts/start-local-demo.sh --no-open
```

Der lokale Seed ist standardmäßig aktiv und veröffentlicht drei Ökosysteme,
neun Level, 30 Pflanzen und 90 Quizfragen. Mit
`PLATFORM_SEED_DEMO_CONTENT=false` kann absichtlich gegen ein leeres CMS
entwickelt werden. PostgreSQL, Redis, MinIO und private Feldfotos liegen in
benannten Volumes und überstehen Container-Recreates.

## Linux-App

```bash
cd apps/flutter
flutter run -d linux \
  --dart-define=PLANTINI_ENV=development \
  --dart-define=PLANTINI_API_BASE_URL=http://127.0.0.1:1338/api/v1 \
  --dart-define=PLANTINI_OIDC_ISSUER_URL=http://127.0.0.1:8082/realms/plantini \
  --dart-define=PLANTINI_OIDC_CLIENT_ID=plantini-mobile-dev
```

## Optional: echter PlantNet-Provider

Der echte Provider ist für die Präsentation nicht erforderlich. Für einen
gezielten Provider-Test muss die ignorierte Datei `docs/plantnet-credentials`
mit `API_KEY=...` vorhanden sein:

```bash
node tools/scripts/verify-plantnet-credentials.mjs
docker compose -f infra/compose.yaml \
  -f infra/compose.plantnet.local.yaml up -d --build
```

Dieser Modus besitzt bewusst keine Demo-Erfolgsgarantie: Internetzugang,
Providerquote und die Qualität des hochgeladenen Fotos beeinflussen das
Ergebnis.

## Lokaler Content-Cache

Der Demo-Start verwendet eine eigene native Isar-Datenbank im
Application-Support-Verzeichnis. Eine gespeicherte Content-Version wird nur
dann als aktuell akzeptiert, wenn Ökosysteme, Level und Pflanzen auch lokal
vorhanden sind. Eine leere Datenbank nach einem Reset lädt die veröffentlichte
Freigabe erneut. Der vollständige Produktumfang für Release-Migrationen und
Rollback bleibt unter `CONTENT-06` offen.

## Verifizierter Stand 2026-09-03

- Flutter-Analyse und vollständige Flutter-Testsuite ohne Befund
- Web-Release-Build erfolgreich
- acht Playwright-Tests gegen den IPv4-Stack grün
- Login -> benannte Pflanzensammelmission -> zehn Quizfragen -> Feld ->
  Herbarium -> Re-Login vollständig grün

Die Seed-Inhalte sind umfangreiche deutsche Demo-Inhalte, aber noch keine
fachredaktionell freigegebene Produktionsdatenbank. Medien und botanische
Quellen müssen vor öffentlicher Veröffentlichung separat lizenziert und
fachlich geprüft werden.

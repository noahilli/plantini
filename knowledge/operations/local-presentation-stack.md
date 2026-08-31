# Lokaler Präsentations-Stack

Dieser Stack startet die vollständige MVP-Kernreise mit persistenten Daten,
Keycloak und dem echten Pl@ntNet-Provider. Alle Host-Endpunkte sind explizit
an IPv4-Loopback gebunden. Er ist für lokale Abnahme und Präsentation gedacht;
für einen öffentlichen Betrieb gilt zusätzlich
`knowledge/operations/production-stack.md`.

## Voraussetzungen

- Docker Compose, Flutter 3.47.1 und ein Linux-Desktop
- die ignorierte Datei `docs/plantnet-credentials` mit `API_KEY=...`
- freie IPv4-Ports 1338 (API) und 8082 (Keycloak)

## Start

```bash
node tools/scripts/verify-plantnet-credentials.mjs
docker compose -f infra/compose.yaml \
  -f infra/compose.plantnet.local.yaml up -d --build
curl -4 --fail http://127.0.0.1:1338/api/v1/health
curl -4 --fail \
  http://127.0.0.1:8082/realms/plantini/.well-known/openid-configuration
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

Testkonto: `learner1@local.test`. Das Kennwort wird lokal provisioniert und
darf nicht in dieser Knowledgebase festgeschrieben werden.

## Verifizierter Stand 2026-08-31

- Flutter-Analyse ohne Befund, 76 Tests grün
- Backend: 20 Tests, davon 18 grün und zwei ohne Redis übersprungen; beide
  Redis-Queue-Integrationstests danach gegen den laufenden Redis grün
- frischer isolierter Browserlauf: Health, Content-Vertrag, Auth-Hard-Reload
  und Login -> Level -> zehn Quizfragen -> Feld -> Herbarium -> Re-Login grün
- echter Pl@ntNet-Aufruf über IPv4: drei Kandidaten, Top-Treffer
  `Quercus robur`, Modell `2026-03-20 (7.5)`

Die Seed-Inhalte sind umfangreiche deutsche Demo-Inhalte, aber noch keine
fachredaktionell freigegebene Produktionsdatenbank. Medien und botanische
Quellen müssen vor öffentlicher Veröffentlichung separat lizenziert und
fachlich geprüft werden.

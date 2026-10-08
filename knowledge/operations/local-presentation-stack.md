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

## Demo im lokalen Netz (LAN)

`tools/scripts/start-lan-demo.sh [<IPv4>] [--skip-build]` baut die Web-App für die Adresse dieses Rechners und startet den Demo-Stack so, dass andere Rechner im selben Netz ihn öffnen können: Web-App `http://<IPv4>:3100`, API `:1438`, Anmeldung (Keycloak) `:8182`. Beenden: `tools/scripts/start-lan-demo.sh --stop`.

- **Eigener Stack:** Compose-Projekt `plantini-lan` (`infra/compose.e2e.yaml` plus Override `infra/compose.lan.yaml`), eigene Volumes und Ports; der Loopback-Stack auf 3000/1338/8082 und die E2E-Tests bleiben unberührt. Web-Build in `apps/flutter/build/web-lan`.
- **Geheimnisse:** `tools/e2e/scripts/prepare-lan-env.mjs` erzeugt `tools/e2e/.runtime/lan/lan.env` (ignoriert) einmalig und eine Realm-Kopie, in der der Web-Client zusätzlich `http://<IPv4>:3100` erlaubt. Demo-Konto `demo@plantini.test`; das Passwort gibt das Skript am Ende aus (oder vorher mit `LAN_DEMO_PASSWORD=… setzen`).
- **Ohne HTTPS:** Browser stellen WebCrypto nur auf https und localhost bereit; `flutter_secure_storage` scheitert auf `http://192.168…` (Anmeldung kehrt in einer Schleife zu `/login` zurück, Konsole: `AuthService initialize failed`). Entwicklungs-Builds der Web-App (`PLANTINI_ENV=development`) fallen deshalb auf `InsecureDevCredentialStore` (Local Storage) zurück (`lib/auth/credential_store.dart`); Staging und Produktion nie. Kamera und Standort des Browsers gibt es ohne sicheren Kontext ebenfalls nicht.
- **Sicherheit:** Der Stack veröffentlicht einen Entwicklungs-Keycloak samt Admin-Konsole und Klartext-HTTP auf allen Schnittstellen. Nur im vertrauten Netz betreiben und danach stoppen.
- **Nachweis 08.10.2026:** Mit Chromium über die LAN-Adresse (unsicherer Kontext): Anmeldung, Charakterauswahl, Home mit schwebendem Modell, Lernpfad mit bewegtem Adler; Konsole ohne Fehler. Von einem **anderen** Rechner im Netz ist es nicht geprüft; eine Host-Firewall könnte die Ports blockieren.

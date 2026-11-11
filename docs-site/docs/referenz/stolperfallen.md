# Stolperfallen

Sammlung der Fallen, in die man bei Plantini tatsächlich laufen kann. Jeder Eintrag nennt **Symptom**, **Ursache**, **Lösung** und einen **Beleg** (Pfad im Repository). Aufgenommen ist nur, was ich im Code, in einem Skript oder in einer Konfigurationsdatei nachvollziehen konnte; wo ein Eintrag auf einer Aussage in `knowledge/` oder in einem Runbook beruht, steht das dabei. Betriebsdetails sind mit Platzhaltern (`<domain>`, `<server>`, `<installationsverzeichnis>`) geschrieben.

!!! note "Inhalt"
    [Lokale Umgebung und Tests](#lokale-umgebung-und-tests) · [Vertrag und Backend](#vertrag-und-backend) · [Identität](#identitat-keycloak) · [Betrieb](#betrieb) · [Android](#android) · [3D und Bilder](#3d-und-bilder) · [Zusammenarbeit](#zusammenarbeit) · [Widersprüche zwischen Doku und Code](#widerspruche-zwischen-doku-und-code)

## Lokale Umgebung und Tests

### Stack und Tests sind IPv4-first

- **Symptom:** Tests oder Anmeldung scheitern mit „not reachable“, Zeitüberschreitungen oder abgelehnter Konfiguration, sobald `localhost` oder ein IPv6-Literal im Spiel ist.
- **Ursache:** Alle Host-Ports binden an `127.0.0.1`; `verify-e2e-env.mjs` lehnt IPv6-Literale und Hostnamen ohne IPv4-Zuordnung ab; Playwright, Node und Chromium werden auf IPv4 gezwungen (`setDefaultResultOrder('ipv4first')`, `--host-resolver-rules`). Die App lehnt IPv6-Literale in `PLANTINI_API_BASE_URL` und `PLANTINI_OIDC_ISSUER_URL` ab, `tool/build-linux.sh` ebenfalls. Der genaue Grund (IPv6-Probleme der Entwicklungsrechner) ist in den Skripten nicht im Detail belegt.
- **Lösung:** immer `127.0.0.1` verwenden; für Hostnamen `PLANTINI_E2E_IPV4_HOSTS=host=IPv4`.
- **Beleg:** `tools/e2e/scripts/verify-e2e-env.mjs`, `tools/e2e/playwright.config.ts`, `apps/flutter/lib/app/app_config.dart`, `apps/flutter/tool/build-linux.sh`.

### `stack:up` löscht Daten und überschreibt `e2e.env`

- **Symptom:** Nach einem erneuten Start sind Konten, Inhalte und lokale Studio-/Portal-Einrichtung weg; ein Compose-Overlay bricht mit `run configure-managed-accounts.mjs` ab.
- **Ursache:** `run-e2e-stack.sh` ruft vor dem Start `docker compose down --volumes --remove-orphans` auf, und `prepare-e2e-env.mjs` schreibt `tools/e2e/.runtime/e2e.env` mit neuen Zufallswerten. Die Zeilen `PLATFORM_KEYCLOAK_ADMIN_CLIENT_*` aus `configure-managed-accounts.mjs` verschwinden damit.
- **Lösung:** nach jedem frischen Start `configure-local-editor.mjs` und `configure-managed-accounts.mjs` erneut ausführen, bevor du ein Overlay startest. Siehe [Entwicklungsumgebung](../mitmachen/setup.md).
- **Beleg:** `tools/e2e/scripts/run-e2e-stack.sh`, `tools/e2e/scripts/prepare-e2e-env.mjs`, `infra/compose.teacher.local.yaml` (`${PLATFORM_KEYCLOAK_ADMIN_CLIENT_ID:?run configure-managed-accounts.mjs}`).

### Flutter-Version muss exakt stimmen

- **Symptom:** `E2E requires Flutter 3.47.1; found …` (Exit 64).
- **Ursache:** `run-e2e-stack.sh` vergleicht `flutter --version` mit `.flutter-version`; `validate-ci-config.mjs` hält beide CI-Dateien synchron.
- **Lösung:** passende Version installieren. Mit `PLANTINI_E2E_SKIP_WEB_BUILD=true` ohne vorhandenes `apps/flutter/build/web/index.html` endet das Skript mit Exit 66.
- **Beleg:** `tools/e2e/scripts/run-e2e-stack.sh`, `.flutter-version`.

### Web-Login nur auf `127.0.0.1:3000`; Port-Kollision; Studio nicht über `localhost`

- **Symptom:** Keycloak lehnt die Anmeldung ab („Invalid parameter: redirect_uri“); `flutter run -d chrome` auf einem Zufallsport kann sich nicht anmelden; Port 3000 ist belegt.
- **Ursache:** Der Client `plantini-web-dev` erlaubt genau `http://127.0.0.1:3000/`, `…/auth/callback` und `…/auth/logout-callback`; `plantini-editor-dev` nur `http://127.0.0.1:8084/`, `plantini-teacher-dev` nur `http://127.0.0.1:8085/`. Port 3000 gehört im E2E-Stack dem Container `web`. Das Studio leitet seinen Redirect aus `location.origin` ab (`apps/editor/app.js`).
- **Lösung:** Dienste über `127.0.0.1` aufrufen; für Entwicklung auf Port 3000 den Container `web` vorher stoppen.
- **Beleg:** `services/identity/realm/plantini-realm.json`, `apps/editor/app.js`, `infra/compose.e2e.yaml`.

### Desktop-Anmeldung braucht Port 4000

- **Symptom:** Die Linux-App kann die Anmeldung nicht abschließen.
- **Ursache:** Der Redirect ist fest `http://127.0.0.1:4000/` (lokaler Empfänger); der Client `plantini-mobile-dev` erlaubt genau diese Adresse.
- **Lösung:** Port 4000 freihalten.
- **Beleg:** `apps/flutter/lib/auth/auth_platform_io.dart` (`desktopLoopbackRedirectUri`), `apps/flutter/README.md`.

### `flutter analyze` ohne `lib`

- **Symptom:** „Analyse sauber“ lokal, aber die CI ist rot.
- **Ursache:** `flutter analyze --no-pub lib` (so in älteren Handovers) übersieht `test/`. Die CI ruft `flutter analyze` ohne Pfad auf. Lokal gemessen am 05.10.2026: ein Fehler in `test/game05_herbarium_bottles_test.dart:311`.
- **Lösung:** immer `cd apps/flutter && flutter analyze`.
- **Beleg:** `.gitlab-ci.yml`, `.github/workflows/ci.yml`, `tools/scripts/ci-check.sh`; Details in [Tests und CI](../mitmachen/tests-ci.md).

### Redis-Tests werden übersprungen, nicht ausgeführt

- **Symptom:** „45 von 49 Tests grün“; vier Tests erscheinen als `skipped`.
- **Ursache:** `provider-guard.test.js` (2 Tests) und `field-identification-queue.test.js` (2 Tests) laufen nur mit `PLANTINI_TEST_REDIS_URL`.
- **Lösung:** eigenen Redis starten und die Variable setzen; sonst nicht als Vollnachweis zählen.
- **Beleg:** `services/platform/test/provider-guard.test.js:10-13`, `services/platform/test/field-identification-queue.test.js:22`.

### Playwright: Projekte ohne Tests, Tests ohne Projekt

- **Symptom:** `npm run test:resilience` oder `test:accessibility` melden keine Tests; neue Dateien unter `tools/e2e/qa/` laufen nie.
- **Ursache:** Die Projekte `resilience` und `accessibility` zeigen auf `qa/resilience.spec.ts` bzw. `accessibility/*.spec.ts`, die nicht existieren. `walking-skeleton.spec.ts`, `learning-flow.spec.ts` und `herbarium-conflict.spec.ts` passen auf keinen `testMatch`. `playwright test --list` zeigt lokal 8 Tests in 6 Dateien.
- **Lösung:** neue Specs in ein Projekt in `tools/e2e/playwright.config.ts` einhängen; mit `npm run test:list` prüfen.
- **Beleg:** `tools/e2e/playwright.config.ts`, `tools/e2e/package.json`.

### Compose-Overlays überschreiben sich gegenseitig

- **Symptom:** Portal oder Studio bekommen CORS-Fehler, sobald beide Overlays gleichzeitig laufen.
- **Ursache:** `compose.editor.local.yaml` setzt `CORS_ORIGINS` auf `…:3000,…:8084`, `compose.teacher.local.yaml` auf `…:3000,…:8084,…:8085`. Bei mehreren `-f`-Dateien gewinnt der Wert der zuletzt genannten Datei (Compose-Merge). Nicht ausgeführt, folgt aus den Dateien.
- **Lösung:** `compose.teacher.local.yaml` zuletzt nennen oder die Variable selbst setzen.
- **Beleg:** `infra/compose.editor.local.yaml`, `infra/compose.teacher.local.yaml`.

### Der Image-Build führt Lint und Tests aus

- **Symptom:** `docker compose … up --build` bricht ab, obwohl der Code „nur“ gestartet werden soll.
- **Ursache:** Die Build-Stufe von `services/platform/Dockerfile` und das `Dockerfile.release-overlay` führen `npm run lint`, `check` und `npm test` aus.
- **Lösung:** Lint und Tests lokal grün halten.
- **Beleg:** `services/platform/Dockerfile`, `services/platform/Dockerfile.release-overlay`.

### Das Wissens-Gate zählt fest

- **Symptom:** Eine neue Aufgaben-ID macht `validate_knowledge.py` rot, obwohl `todos.md` und Registry zusammenpassen.
- **Ursache:** Das Skript erwartet exakt 117 IDs (und 95 Anforderungen). Heute findet es 139 IDs; 15 fehlen in der Registry.
- **Lösung:** ID in `todos.md`, Zeile in `knowledge/state/STATUS_REGISTRY.csv` **und** Zahl im Skript anpassen; Altlasten klären. Siehe [Konventionen](../mitmachen/konventionen.md).
- **Beleg:** `knowledge/scripts/validate_knowledge.py`.

## Vertrag und Backend

### `packages/api` ist generiert

- **Symptom:** Handänderungen verschwinden; die CI scheitert an `git diff --exit-code -- packages/api` oder an der Digest-Prüfung.
- **Ursache:** `generate-api-client.sh` ersetzt das Paket mit `rsync --delete`; `validate-api-contract.mjs` prüft `SPEC_SHA256` und `TREE_SHA256`.
- **Lösung:** `contracts/api.yaml` ändern, dann `tools/scripts/generate-api-client.sh` (braucht Docker), danach `node tools/scripts/validate-api-contract.mjs`. Ergebnis mitcommitten.
- **Beleg:** `tools/scripts/generate-api-client.sh`, `tools/scripts/validate-api-contract.mjs`, `.gitlab-ci.yml`.

### Jede Route muss im Vertrag stehen

- **Symptom:** `Undocumented server route: …` oder `Implemented contract operation has no server route: …`.
- **Ursache:** Der Validator liest `routes/platform.js` und `contracts/api.yaml` gegeneinander; einzige Ausnahme ist `GET /health`. Eine als `planned` markierte Operation darf noch keine Route haben.
- **Lösung:** Vertrag und Route im selben Schritt ändern; `x-plantini-implementation-status: planned` entfernen, sobald die Route existiert. Siehe [Neuer Endpunkt](../backend/neuer-endpunkt.md).
- **Beleg:** `tools/scripts/validate-api-contract.mjs`.

### Veröffentlichen in Strapi wird von Lifecycles blockiert

- **Symptom:** Strapi meldet „Botanischer Review erforderlich …“, „Generierter Lernpfad noch nicht veröffentlichbar: …“ oder „Media must have a valid author/license.“
- **Ursache:** `plant` und `quiz` brauchen `reviewStatus = approved`. Ein generierter `level` braucht ein veröffentlichtes Ökosystem derselben `releaseVersion`, freigegebene und veröffentlichte Pflanzen, genau drei verschiedene Pflichtfragen, die ebenfalls freigegeben sind, eine fertig generierte Entwurfsserie, und Beziehungen sowie `completionRule` müssen **vorher im Entwurf** gespeichert sein. `media` braucht Autor und Lizenz. Das explizite Zurückziehen (`publishedAt = null`) bleibt immer möglich.
- **Lösung:** Reihenfolge einhalten: Ökosystem, Pflanzen, Fragen, dann Level; Beziehungen zuerst als Entwurf speichern.
- **Beleg:** `services/platform/src/api/level/content-types/level/lifecycles.js`, `…/plant/content-types/plant/lifecycles.js`, `…/quiz/content-types/quiz/lifecycles.js`, `…/media/content-types/media/lifecycles.js`.

### Der Demo-Seed ändert sich nicht, wenn das Release schon existiert

- **Symptom:** Änderungen an `demo-content.de.json` erscheinen auf einer bestehenden Datenbank nicht.
- **Ursache:** `seedDemoContent` sucht ein Release mit `DEMO_RELEASE_VERSION` (aktuell `'2026.10.02-de.2'`) und kehrt bei einem Treffer mit `{ seeded: false }` zurück. Der Seed läuft nur mit `PLATFORM_SEED_DEMO_CONTENT=true`; der Server warnt dabei, dies nie in Staging oder Produktion zu nutzen. Im E2E-Stack ist das Flag `true`, `compose.editor.local.yaml` setzt es auf `false`, `compose.production.yaml` hat den Standard `false`.
- **Lösung:** Release-Version in `demo-content.js` anheben oder die Volumes neu aufsetzen (`stack:up`). Demo-Inhalte sind nicht botanisch freigegeben.
- **Beleg:** `services/platform/src/api/platform/services/core/content/demo-seed.js`, `…/content/demo-content.js:6`, `services/platform/src/index.js`.

### Wikimedia antwortet mit 429

- **Symptom:** Pflanzenfotos fehlen; das Backend wirft intern `PHOTO_SOURCE_HTTP_429` oder `PHOTO_SOURCE_COOLDOWN`; der Prefetch-Bericht kann Pflanzen als `photo-unavailable` ausweisen.
- **Ursache:** Bei 429 oder 503 sperrt `wikimedia-photo-source.js` weitere Abfragen für mindestens 60 s (`providerRetryAt`, auch `Retry-After` wird beachtet). Das Prefetch-Skript fragt bewusst sequenziell.
- **Lösung:** nicht umgehen, keine ungeprüften Ersatzbilder einbauen; später erneut `node tools/prefetch-plant-photos.mjs` (verlangt `127.0.0.1` als Ziel). Abruf externer Fotos lässt sich mit `PLATFORM_EXTERNAL_PLANT_PHOTOS=disabled` abschalten (`platform-runtime.js`).
- **Beleg:** `services/platform/src/api/platform/services/core/content/wikimedia-photo-source.js`, `tools/prefetch-plant-photos.mjs`.

### Browser-Origins und Header: `CORS_ORIGINS`

- **Symptom:** Browser meldet einen CORS-Fehler gegen die API; ein neuer Request-Header wird blockiert.
- **Ursache:** `config/middlewares.js` liest `CORS_ORIGINS` (Komma-Liste) und erlaubt nur die Header `Content-Type`, `Authorization`, `Idempotency-Key`, `If-Match`, `If-None-Match`, `X-Correlation-Id` sowie die Methoden `GET, POST, PATCH, DELETE, OPTIONS`. In der Produktion setzt `compose.production.yaml` die Liste aus `WEB_PUBLIC_URL`, `EDITOR_PUBLIC_URL` und `TEACHER_PUBLIC_URL`; fehlt eine, bricht Compose ab.
- **Lösung:** Origin in die Umgebungsvariable aufnehmen, neue Header in der Liste ergänzen, Plattform neu starten.
- **Beleg:** `services/platform/config/middlewares.js`, `infra/compose.production.yaml`, `infra/compose.e2e.yaml`.

### Issuer und JWKS-Adresse sind absichtlich verschieden

- **Symptom:** Tokens werden abgelehnt oder der Provider-Check meldet „platform OIDC issuer differs from the host-visible Keycloak issuer“.
- **Ursache:** Clients erhalten Tokens mit dem Host-sichtbaren Issuer (`http://127.0.0.1:8082/realms/plantini`); die Plattform liest die Schlüssel über das Docker-Netz (`PLATFORM_OIDC_JWKS_URI: http://keycloak:8080/…`). `verify-e2e-env.mjs --check-readiness` prüft das ausdrücklich.
- **Lösung:** `PLATFORM_OIDC_ISSUER` auf den Browser-Issuer setzen, nur `PLATFORM_OIDC_JWKS_URI` auf den internen Namen.
- **Beleg:** `infra/compose.e2e.yaml`, `infra/compose.yaml` (Kommentar), `tools/e2e/scripts/verify-e2e-env.mjs`.

## Identität (Keycloak)

### Der Realm wird nur beim ersten Start importiert

- **Symptom:** Eine Änderung in `plantini-realm.json` (neuer Client, neue Rolle, geänderte Redirects) wirkt in einer bestehenden Instanz nicht.
- **Ursache:** Keycloak startet mit `--import-realm`, das den Realm nur anlegt, wenn er noch nicht existiert (Kommentar in `compose.production.yaml`: „`--import-realm` only creates the realm when it does not exist yet“). Auch `knowledge/editor-studio.md` hält fest: Ein Realm-Import aktualisiert einen neuen Client nicht.
- **Lösung:** neue Clients **live** per Admin-API oder `kcadm` anlegen und danach die Definition ins Realm-File nachziehen, damit Neuinstallationen sie haben. Die Skripte `tools/scripts/configure-local-editor.mjs` und `tools/scripts/configure-managed-accounts.mjs` machen das für Studio und Portal und lesen ihre Client-Vorlage **aus dem Realm-File** (`realm.clients.find(…)`): ein Client muss also dort stehen, bevor das Skript ihn anlegen kann.
- **Beleg:** `infra/compose.production.yaml:61-62`, `infra/compose.e2e.yaml`, `tools/scripts/configure-managed-accounts.mjs`.

### `kcadm get --fields` zeigt verschachtelte Objekte leer

- **Symptom:** `kcadm get realms/plantini --fields smtpServer` druckt `{ }`, obwohl SMTP gesetzt ist.
- **Ursache:** `--fields` filtert verschachtelte Objekte so, dass nichts erscheint (belegt für `smtpServer`). Ob dasselbe für `attributes` gilt, habe ich im Repository **nicht belegt gefunden**.
- **Lösung:** den ganzen Realm lesen und dort nachsehen.
- **Beleg:** `infra/production/configure-smtp.sh` (Kommentar, Zeile 5).

### Login mit E-Mail (versionierter Realm) oder Benutzername (nach `configure-managed-accounts.mjs`)

- **Symptom:** Anmeldung mit einem Benutzernamen schlägt fehl.
- **Ursache:** Der versionierte Realm hat `registrationEmailAsUsername: true`, daher ist der Anmeldename die E-Mail-Adresse. `configure-managed-accounts.mjs` schaltet `registrationEmailAsUsername` für den Realm aus und legt verwaltete Schülerkonten mit Benutzernamen an. Die Selbstregistrierung war vom 05.10. bis 10.11.2026 ausgeschaltet und ist seitdem wieder an (`registrationAllowed: true` in Realm-Quelle, `build-production-realm.mjs` und `configure-managed-accounts.mjs`).
- **Lösung:** In Tests die E-Mail als Login nehmen; Schülerkonten über das Portal anlegen.
- **Beleg:** `services/identity/realm/plantini-realm.json`, `tools/scripts/build-production-realm.mjs`, `tools/e2e/scripts/prepare-e2e-env.mjs`, `tools/scripts/configure-managed-accounts.mjs`.

## Betrieb

### Caddyfile in place überschreiben, dann neu laden

- **Symptom:** Nach einer Änderung der Datei und `caddy reload` gilt weiter die alte Konfiguration.
- **Ursache:** Die Datei ist als **einzelne Datei** eingehängt (`./Caddyfile:/etc/caddy/Caddyfile:ro` in `infra/production/compose.proxy.yaml`). Ersetzt man sie durch eine neue Datei (neuer Inode), hält der Container die alte.
- **Lösung:** den Inhalt in dieselbe Datei schreiben (`cat neu > Caddyfile`), dann Caddy im Container neu laden. Das Runbook beschreibt genau diese Reihenfolge; den vollständigen Reload-Aufruf hält es nicht fest. Siehe [Deployment](../betrieb/deployment.md).
- **Beleg:** `infra/production/compose.proxy.yaml`; Betriebsprotokoll des Betreibers (nicht öffentlich).

### Einstiegsdateien der Web-App nicht cachen

- **Symptom:** Nach einem Deployment sehen Nutzer die alte App.
- **Ursache:** Die Einstiegsdateien der Flutter-Web-App sind nicht inhaltsgehasht. Das Caddyfile setzt für `/`, `/index.html`, `/flutter_bootstrap.js`, `/flutter_service_worker.js`, `/main.dart.js`, `/version.json`, `/manifest.json` daher `Cache-Control: no-cache`; Studio (`apps/editor/nginx.conf`) und Portal (`apps/teacher`) liefern `no-cache` bzw. `no-store`.
- **Lösung:** neue Einstiegsdateien beim Rollout in die Liste aufnehmen und Header nicht entfernen.
- **Beleg:** `infra/production/Caddyfile` (Block `app.{$PLANTINI_DOMAIN}`), `apps/editor/nginx.conf`, `apps/teacher/README.md`.

### Nie `down -v` im Produktionsstack

- **Symptom:** (vermieden) Datenbanken, private Fotos und Zertifikate sind weg.
- **Ursache:** Der E2E-Stack nutzt `down --volumes` routinemäßig. Im Produktionsstack liegen Postgres, Keycloak, private Medien und Caddy-Zustand in benannten Volumes.
- **Lösung:** im Produktionsbetrieb nur `up -d`, `stop`, Neustarts; nie `down -v`, `docker volume rm` oder `docker system prune --volumes`. Die Sicherung schreibt `infra/production/backup.sh` nach `$BACKUP_DIR` (Standard `/var/backups/plantini`) auf dasselbe System; eine entfernte Kopie ist im Skript nicht vorgesehen. Siehe [Backup und Monitoring](../betrieb/backup-monitoring.md).
- **Beleg:** `operations/runbooks/backup-restore.md` (Abschnitt „Produktions-Sicherung auf dem Single-Host“), `infra/production/backup.sh`, `tools/e2e/package.json` (`stack:down`).

### `update-release-env.mjs` mit Scope `all` setzt mehr als Images

- **Symptom:** Nach dem Skript haben Portal-Variablen feste Werte.
- **Ursache:** Mit Scope `all` (Standard) schreibt das Skript neben `PLATFORM_IMAGE`, `TEACHER_IMAGE`, `EDITOR_IMAGE` auch `TEACHER_PUBLIC_URL` und `TEACHER_LOOPBACK_PORT` auf feste Werte. Scope `teacher` ändert nur `TEACHER_IMAGE`. Vorher legt es eine Kopie `*.bak-<Zeitstempel>` an und verlangt einen Commit-Hash von 7 bis 40 Hex-Zeichen.
- **Lösung:** Scope bewusst wählen; Datei danach prüfen (Inhalt nicht ausgeben).
- **Beleg:** `infra/production/update-release-env.mjs`.

### Overlay-Images nur für reine Quelltext-Updates

- **Symptom:** Ein per `Dockerfile.release-overlay` gebautes Image startet nicht oder verhält sich anders als das Basis-Image.
- **Ursache:** Das Overlay kopiert nur `src/` auf ein bereits übertragenes Image (`BASE_IMAGE` als lokal geprüfte unveränderliche Image-ID). Abhängigkeiten und Content-Modelle müssen zum Basis-Image passen; sonst das normale Dockerfile nutzen.
- **Beleg:** `services/platform/Dockerfile.release-overlay` (Kopfkommentar).

## Android

### Release-Build nie mit `--no-pub`, `GeneratedPluginRegistrant.java` nie löschen

- **Symptom:** Build bricht mit `package dev.flutter.plugins.integration_test does not exist` ab; oder die APK startet mit „Plantini konnte nicht sicher gestartet werden“ (`ClassNotFoundException: io.flutter.plugins.GeneratedPluginRegistrant`, dann `PlatformException(channel-error … shared_preferences …)`).
- **Ursache laut `knowledge/operations/android-release.md`:** `flutter pub get` erzeugt die Registrierung mit Dev-Plugins (`integration_test`); erst `flutter build apk` **ohne** `--no-pub` erzeugt sie für Release neu. Die Datei ist git-ignoriert (`apps/flutter/android/.gitignore`), liegt aber lokal. Mechanismus nicht von mir nachgestellt.
- **Lösung:** `flutter build apk --release …` ohne `--no-pub`, Datei nicht von Hand löschen. Siehe [Android-Release](../betrieb/android-release.md).
- **Beleg:** `knowledge/operations/android-release.md`, `apps/flutter/android/.gitignore`.

### Alle drei ABIs bauen

- **Symptom:** Auf x86-Geräten stürzt die App mit `UnsatisfiedLinkError … EM_AARCH64 instead of EM_X86_64` ab.
- **Ursache:** Plugins bringen auch x86_64-Bibliotheken mit; fehlt `libflutter.so` für x86_64, wählt Android diese ABI.
- **Lösung:** `--target-platform android-arm64,android-arm,android-x64`. Das Beispielkommando in `android-release.md` nennt nur `android-arm64,android-arm`, der erklärende Text verlangt alle drei: **Widerspruch in der Datei**, nimm alle drei.
- **Beleg:** `knowledge/operations/android-release.md`.

### Höheren `versionCode` verwenden

- **Symptom:** Eine neue APK lässt sich nicht als Update über eine installierte legen (Android-Verhalten bei gleichem oder niedrigerem `versionCode`).
- **Ursache:** `versionCode` kommt aus dem Teil nach `+` in `version:` der `pubspec.yaml` (`flutter.versionCode`); aktuell `0.6.5+9`. `prepare-app-release.mjs` bricht ohne dieses Muster ab (`A version name and increasing build number are required.`).
- **Lösung:** vor jedem Release die Zahl nach `+` erhöhen.
- **Beleg:** `apps/flutter/pubspec.yaml`, `apps/flutter/android/app/build.gradle.kts`, `tools/scripts/prepare-app-release.mjs`.

### Ohne `key.properties` wird mit dem Debug-Schlüssel signiert

- **Symptom:** Release-APK lässt sich bauen, ist aber nicht verteilbar.
- **Ursache:** Fehlt `android/key.properties`, nutzt `build.gradle.kts` für `release` den Debug-Schlüssel. Datei und Schlüsselspeicher sind git-ignoriert.
- **Lösung:** APK nie verteilen, die so gebaut wurde; Schlüssel sichern (Verlust verhindert Updates installierter Apps, laut `android-release.md`).
- **Beleg:** `apps/flutter/android/app/build.gradle.kts`, `apps/flutter/android/.gitignore`.

### Release-Builds erlauben nur HTTPS

- **Symptom:** Eine Release-APK erreicht den lokalen HTTP-Stack nicht.
- **Ursache:** Das Haupt-Manifest setzt `usesCleartextTraffic="false"`; nur der Debug-Build erlaubt Klartext. Ohne die `<queries>`-Abfrage für https-VIEW-Intents sieht `canLaunchUrl` ab Android 11 keinen Browser („Kein Browser kann die Anmeldung öffnen“).
- **Lösung:** lokal mit Debug-Build testen; `<queries>` nicht entfernen.
- **Beleg:** `apps/flutter/android/app/src/main/AndroidManifest.xml`, `apps/flutter/android/app/src/debug/AndroidManifest.xml`.

## 3D und Bilder

### Nach jeder Neuerzeugung der Welt-Module `add_night_lights.py` ausführen

- **Symptom:** Hütten, Laternen und Glühwürmchen fehlen in Wiese und Alpen.
- **Ursache:** `create_ecosystem_modules.py` baut Wiese und Alpen von Grund auf und verwirft die Zusätze; `add_night_lights.py` fügt sie wieder an (idempotent: entfernt zuvor Hinzugefügtes und baut neu).
- **Lösung:** `python3 tools/blender/add_night_lights.py` nach jeder Regenerierung. Siehe [Tageszeit und Licht](../3d/tageszeit-licht.md).
- **Beleg:** `tools/blender/add_night_lights.py` (Docstring), `tools/blender/create_ecosystem_modules.py`.

### Blender-Generatoren überschreiben nichts, `create_forest_world.py` bricht ab

- **Symptom:** `RuntimeError: Output already exists. Choose a new version directory.`
- **Ursache:** `create_forest_world.py` legt Ausgaben in einem festen Versionsordner unter `artifacts/3d/` ab (im Skript als absoluter Pfad einkodiert) und weigert sich, eine vorhandene `plantini-forest.blend` zu ersetzen. `create_ecosystem_modules.py` erzeugt eine eigene Szene („never clear or overwrite user scenes“).
- **Lösung:** einen neuen Versionsordner im Skript eintragen (und den Pfad auf deinen Rechner anpassen). Ausgabeordner versionieren. Für die übrigen Generatoren habe ich das Überschreibverhalten **nicht** geprüft. Siehe [Blender-Pipeline](../3d/blender-pipeline.md).
- **Beleg:** `tools/blender/create_forest_world.py:13-16`, `tools/blender/create_ecosystem_modules.py`.

### Zeichenkosten bei Vitrinen und Lernpfad

- **Symptom:** Ruckeln beim Scrollen der Startseite.
- **Ursache:** Mehrere getrennt gezeichnete Ebenen (Wand, Sockel, Modell, Glas) wurden jedes Bild neu gezeichnet. Die Vitrine ist deshalb pro Winkel **eine** gebackene Textur (heute `_FloatingModelPainter`, ohne Wand, Sockel und Glas).
- **Lösung:** neue Effekte so bauen, dass sie in die gebackene Textur passen; messen mit dem Leistungslauf aus [Tests und CI](../mitmachen/tests-ci.md).
- **Beleg:** `apps/flutter/lib/features/catalog/presentation/widgets/ecosystem_vitrine.dart`, `knowledge/handovers/herbarium-map-character-daytime.md`.

## Zusammenarbeit

### Geteilter Arbeitsbaum

- **Symptom:** Fremde, nicht committete Dateien verschwinden oder werden formatiert; Vergleiche gegen `HEAD` zeigen Chaos.
- **Ursache:** Mehrere Sitzungen schreiben in denselben Arbeitsbaum; `git stash`, `checkout`, `reset` oder Formatierung über fremde Dateien zerstören deren Arbeit.
- **Lösung:** nur eigene Dateien stagen; für Vergleiche ein separates `git worktree` anlegen. Siehe [Konventionen](../mitmachen/konventionen.md#arbeiten-im-geteilten-arbeitsbaum).
- **Beleg:** `CLAUDE.md` (Konventionen), `knowledge/delivery/coordination-protocol.md`.

### Pfade der Ownership-Tabelle, die es nicht gibt

- **Symptom:** Eine Review-Regel greift ins Leere.
- **Ursache:** `knowledge/agents/ownership.csv` nennt `apps/flutter/lib/features/auth/**` und `services/platform/src/api/content/**`; beide Verzeichnisse existieren nicht (Auth liegt in `apps/flutter/lib/auth/`). Für `apps/editor`, `apps/teacher`, `apps/homepage`, `packages/api`, `tools/blender` und `tools/scripts` gibt es keine Zeile.
- **Lösung:** Regel sinngemäß auf die echten Pfade anwenden; Änderungen in Pfaden ohne Eintrag mit dem Projektkontakt abstimmen.
- **Beleg:** `knowledge/agents/ownership.csv`.

## Widersprüche zwischen Doku und Code

Wo Quellen sich widersprechen, gilt der Code. Diese Abweichungen sind mir aufgefallen:

| Aussage (Quelle) | Befund im Code | Folge |
|---|---|---|
| Telefone nutzen den Loopback `http://127.0.0.1:4000/` (`knowledge/operations/android-release.md`, Abschnitt „Anmeldung und Keycloak“) | `auth_platform_io.dart` leitet Android/iOS über einen App Link (`mobileDeepLinkRedirectUri`, Fallback `eu.plantini.app://oauth2redirect`); nur der Desktop nutzt `127.0.0.1:4000` | Die Android-Anleitung ist für die Anmeldung überholt |
| Seeds liegen unter `content/seeds` (`CLAUDE.md`) | kein Skript und kein Quelltext liest `content/seeds/01-ecosystems-levels.json`; der Seed liest `…/content/demo-content.de.json` | Demo-Inhalte dort ändern |
| Der Demo-Stack nutze auch MinIO (`knowledge/operations/local-presentation-stack.md`) | `infra/compose.e2e.yaml` enthält kein MinIO (nur der alte `infra/compose.yaml`) | Doku überholt |
| `start.sh` prüft `/api/manifest`, `/api/plants` | Routen liegen unter `/api/v1/…` (`routes/platform.js`) | `start.sh` ist veraltet |
| Ältere Screens liegen in `lib/ui/*` (`CLAUDE.md`) | `apps/flutter/lib/ui/*` ist leer und nicht versioniert | Screens liegen in `lib/features/*/presentation/` |
| E2E-Suiten `resilience` und `accessibility` (`CLAUDE.md`, `knowledge/operations/playwright-e2e.md`) | keine Spec-Dateien dafür | Lücke, kein Test vorhanden |
| `engines` schließt Node >20 aus (`CLAUDE.md`) | `engines` ist `>=18.0.0 <=20.x.x`, im Repository gibt es aber keine `.npmrc`/`engine-strict`; Backend-Tests liefen unter Node 26.10.0 | Hinweis, kein harter Ausschluss |
| `validate_knowledge.py` ist ein blockierendes CI-Gate | läuft heute rot (139 statt 117 IDs, 15 fehlende Registry-Zeilen) | Gate und Daten angleichen |

Offene, nicht belegte Punkte, damit sie niemand als Fakt weiterträgt: ob Strapi im Overlay-Betrieb (`compose.authoring.local.yaml`) selbständig neu lädt; ob `infra/compose.yaml` (alter Stack) heute hochkommt; ob eine Android-Anmeldung gegen den lokalen Stack ohne die Produktions-Homepage möglich ist.

## Weiterführend

- [Entwicklungsumgebung](../mitmachen/setup.md), [Tests und CI](../mitmachen/tests-ci.md), [Konventionen](../mitmachen/konventionen.md)
- [Compose-Dateien](../betrieb/compose.md), [Deployment](../betrieb/deployment.md), [Identität & Keycloak](../betrieb/identity-keycloak.md), [Android-Release](../betrieb/android-release.md)
- [Glossar](glossar.md), [Ports und Dienste](ports-dienste.md)
- Quellen: `knowledge/operations/android-release.md`, `operations/runbooks/backup-restore.md`, `infra/`, `tools/`

# Bauen und Release

Diese Seite zeigt, wie du die App für Web, Linux und Android baust, wo Version und Signierung herkommen, was `prepare-app-release.mjs` erzeugt und wie du Frame-Zeiten misst. Alle Befehle sind gegen die Skripte und Dateien im Repository geprüft, aber hier **nicht ausgeführt**.

!!! note "Projektstatus"
    Plantini ist ein unveröffentlichter, unvollständiger Teaser, kein Open-Source-Projekt. Es gibt eine signierte Android-Test-APK zum Direktdownload auf der Projektwebseite; kein Store-Eintrag. Serverseitige Auslieferung und Betrieb beschreibt [Android-Release (Betrieb)](../betrieb/android-release.md), hier steht nur die App-Seite.

## Voraussetzungen und Werkzeugversionen

| Was | Wert | Quelle |
|---|---|---|
| Flutter | 3.47.1 | `.flutter-version`, `FLUTTER_VERSION` in `.gitlab-ci.yml` |
| Dart-SDK | `^3.13.1` | `apps/flutter/pubspec.yaml` (`environment.sdk`) |
| Android Gradle Plugin | 9.1.0 | `apps/flutter/android/settings.gradle.kts` |
| Java | 17 | `compileOptions` und `jvmTarget` in `apps/flutter/android/app/build.gradle.kts` |
| `compileSdk` | 37 | `build.gradle.kts`; `android.suppressUnsupportedCompileSdk=37` in `gradle.properties` (AGP 9.1 empfiehlt ≤ 36, zwei Plugins verlangen 37) |
| `minSdk` / `targetSdk` | 24 / 36 | kommen aus `flutter.minSdkVersion` / `flutter.targetSdkVersion`; in `packages/flutter_tools/gradle/src/main/kotlin/FlutterExtension.kt` des Flutter-SDK 3.47.1 sind das 24 und 36. Sie ändern sich mit der Flutter-Version. |
| Node (Release-Skript) | 20 | wie `.gitlab-ci.yml` (`node:20.20.2`); `prepare-app-release.mjs` braucht nur Node |

## Version festlegen

Die Version steht an genau einer Stelle:

```yaml title="apps/flutter/pubspec.yaml"
version: 0.6.5+9
```

`x.y.z` ist der Versionsname, die Zahl nach `+` der Android-`versionCode`. In `build.gradle.kts` setzt `versionCode = flutter.versionCode` und `versionName = flutter.versionName` diese Werte. **Jede neue APK braucht einen höheren Code**, sonst lässt sich nicht über die alte installieren.

Die App liest ihre Version auch zur Laufzeit, für die Mindestversion der Inhalte (`minimumAppVersion` im Content-Manifest, siehe [Offline](offline.md#content-sync)). `lib/app/app_version.dart` tut das so:

```dart title="apps/flutter/lib/app/app_version.dart"
static Future<String> read() async {
  const override = String.fromEnvironment('PLANTINI_APP_VERSION');
  if (override.isNotEmpty) return override;
  final pubspec = await rootBundle.loadString('pubspec.yaml');
  final version = RegExp(
    r'^version:\s*(\d+\.\d+\.\d+(?:\+\d+)?)\s*$',
    multiLine: true,
  ).firstMatch(pubspec)?.group(1);
  …
}
```

Deshalb ist `pubspec.yaml` selbst als Asset eingebunden (`flutter.assets` mit Kommentar „Single source for the runtime content compatibility check on Web and APK“). Verglichen werden nur Major.Minor.Patch, die Build-Nummer zählt nicht.

!!! warning "Stolperfalle: `--build-name` ändert die gebündelte `pubspec.yaml` nicht"
    Überschreibst du den Namen beim Build mit `--build-name=…`, bleibt die gebündelte `pubspec.yaml` auf dem alten Stand, und die Mindestversions-Prüfung liest den alten Wert. Der Kommentar in `app_version.dart` verlangt deshalb zusätzlich `--dart-define=PLANTINI_APP_VERSION=<build-name>`, „(Web too)“. Am einfachsten änderst du die Version direkt in `pubspec.yaml`.

## Konfiguration beim Bauen

Alle Builds brauchen die vier Pflicht-Defines `PLANTINI_ENV`, `PLANTINI_API_BASE_URL`, `PLANTINI_OIDC_ISSUER_URL`, `PLANTINI_OIDC_CLIENT_ID` (Regeln: [Überblick](index.md#konfiguration-per-dart-define)). Ohne sie startet die App nur bis zur Konfigurationsfehler-Seite. Für Produktion gilt zwingend HTTPS und der Pfad `/api/v1`. In den Beispielen unten stehen Platzhalter: `<domain>` ist die Domain der Installation.

| Ziel | Client-ID im Realm |
|---|---|
| Web (Entwicklung) | `plantini-web-dev` |
| Desktop/Telefon (Entwicklung) | `plantini-mobile-dev` |
| Web (Produktion) | `plantini-web-production` |
| Telefon/Desktop (Produktion) | `plantini-mobile-production` |

## Web

=== "Entwicklung (wie CI und E2E)"

    ```sh
    cd apps/flutter
    flutter pub get
    flutter build web --release \
      --dart-define=PLANTINI_ENV=development \
      --dart-define=PLANTINI_API_BASE_URL=http://127.0.0.1:1338/api/v1 \
      --dart-define=PLANTINI_OIDC_ISSUER_URL=http://127.0.0.1:8082/realms/plantini \
      --dart-define=PLANTINI_OIDC_CLIENT_ID=plantini-web-dev
    ```

    Dieselben Zeilen stehen in `tools/e2e/scripts/run-e2e-stack.sh` und im Job `flutter:build_web` in `.gitlab-ci.yml`. Das Ergebnis liegt in `apps/flutter/build/web/`.

=== "Produktion (Muster)"

    ```sh
    cd apps/flutter
    flutter build web --release --no-web-resources-cdn \
      --dart-define=PLANTINI_ENV=production \
      --dart-define=PLANTINI_API_BASE_URL=https://api.<domain>/api/v1 \
      --dart-define=PLANTINI_OIDC_ISSUER_URL=https://auth.<domain>/realms/plantini \
      --dart-define=PLANTINI_OIDC_CLIENT_ID=plantini-web-production
    ```

    Das Flag `--no-web-resources-cdn` steht nur im Handover `knowledge/handovers/herbarium-map-character-daytime.md` („Web-App bauen (`--no-web-resources-cdn`, Produktions-Defines)“); `flutter build web --help` listet es als `--[no-]web-resources-cdn`. CI und E2E bauen **ohne** das Flag. Die Hostnamen `api.` und `auth.` sind ein Muster; maßgeblich sind die Adressen deiner Installation ([Konfiguration](../betrieb/konfiguration.md)).

Wissenswertes zum Web-Build, das im Code begründet ist:

- **Lokale Ressourcen statt Drittanbieter.** Der Code vermeidet CDN-Abhängigkeiten an mehreren Stellen: Schriften sind gebündelt (`pubspec.yaml`, Kommentar zu `AppTypography.headingFallback`), die Isar-Engine lädt aus der eigenen Origin (`Isar.initialize('/isar_plus.wasm')`, Dateien in `apps/flutter/web/`). Mit `--no-web-resources-cdn` gilt das auch für die Flutter-Engine-Dateien.
- **Hosting.** Die Origin muss `index.html` für unbekannte Pfade ausliefern (`/auth/callback`, `/auth/logout-callback`) und `isar_plus.wasm` an der Wurzel. Beispiele: `infra/nginx/e2e.conf` und `infra/production/Caddyfile`.
- **Redirect-URIs.** Der Web-Client im Realm muss die Origin samt `/auth/callback` kennen ([Authentifizierung](auth.md)).
- `web/index.html` enthält noch Vorlagenwerte (`<title>plantini_app</title>`, Beschreibung „A new Flutter project.“).

## Linux

Das Skript `apps/flutter/tool/build-linux.sh` baut ein Release-Bundle und verweigert den Start ohne Konfiguration:

```sh
cd apps/flutter
PLANTINI_ENV=development \
PLANTINI_API_BASE_URL=http://127.0.0.1:1338/api/v1 \
PLANTINI_OIDC_ISSUER_URL=http://127.0.0.1:8082/realms/plantini \
PLANTINI_OIDC_CLIENT_ID=plantini-mobile-dev \
./tool/build-linux.sh
```

Das Skript beendet sich mit Code 64, wenn eine Variable fehlt, `PLANTINI_ENV` nicht `development|staging|production` ist oder eine URL eckige Klammern (IPv6-Literal) enthält; sonst ruft es `flutter --no-version-check build linux --release` mit den vier `--dart-define`. Es setzt bewusst **keine Standardwerte** („a missing deployment configuration must fail before an artefact is published“). Zur Laufzeit braucht der Zielrechner GTK 3 und `libsecret` samt Secret Service (`apps/flutter/README.md`). Der Login nutzt den Loopback `http://127.0.0.1:4000/` ([Authentifizierung](auth.md)).

## Android

### Signierung

`apps/flutter/android/app/build.gradle.kts` liest `android/key.properties`. Vorhanden sein müssen die Schlüssel `storeFile`, `storePassword`, `keyAlias`, `keyPassword`; dann wird der Release-Build damit signiert. Fehlt `storeFile`, fällt Gradle auf den **Debug-Schlüssel** zurück, „such an APK must never be distributed“ (Kommentar im Build-Skript).

- `key.properties`, `*.jks`, `*.keystore` und `local.properties` stehen in `apps/flutter/android/.gitignore`. Der Signaturschlüssel liegt **nicht im Repository** und nicht auf dem Server; sichere ihn getrennt. Geht er verloren, kann keine installierte App mehr aktualisiert werden.
- Der SHA-256-Fingerabdruck des Zertifikats steht in `apps/homepage/public/.well-known/assetlinks.json`. Er muss zum Release-Schlüssel passen, sonst wird der App Link nicht verifiziert ([Authentifizierung](auth.md)).
- Prüfen kannst du das Ergebnis mit `apksigner verify --print-certs` und `aapt2 dump badging` (Paket `eu.plantini.app`, Berechtigungen), wie in `knowledge/operations/android-release.md` beschrieben.

### Befehl

Der Release-Build aus `knowledge/operations/android-release.md` (Platzhalter statt Hostnamen):

```sh
cd apps/flutter
flutter build apk --release --target-platform android-arm64,android-arm,android-x64 \
  --dart-define=PLANTINI_ENV=production \
  --dart-define=PLANTINI_API_BASE_URL=https://api.<domain>/api/v1 \
  --dart-define=PLANTINI_OIDC_ISSUER_URL=https://auth.<domain>/realms/plantini \
  --dart-define=PLANTINI_OIDC_CLIENT_ID=plantini-mobile-production
```

Die APK landet unter `apps/flutter/build/app/outputs/flutter-apk/app-release.apk` (Standardpfad von `prepare-app-release.mjs`).

!!! warning "Stolperfalle: ABIs, Widerspruch in der Betriebsdoku"
    `knowledge/operations/android-release.md` zeigt im Befehlsblock nur `--target-platform android-arm64,android-arm`, schreibt aber im Text, es müssten **alle drei** Engines enthalten sein (`android-arm64,android-arm,android-x64`): Plugins bringen auch x86_64-Bibliotheken mit; fehlt `libflutter.so` für x86_64, wählt Android auf x86-Geräten diese ABI und die App stürzt mit `UnsatisfiedLinkError … EM_AARCH64 instead of EM_X86_64` ab. Der Befehl oben folgt dem Text (drei ABIs). Die dort genannte Größe von rund 89 MB bezieht sich auf die Drei-ABI-APK.

!!! warning "Stolperfalle: Nie `--no-pub` und nie `GeneratedPluginRegistrant.java` löschen"
    Laut `knowledge/operations/android-release.md` erzeugt erst `flutter build apk` ohne `--no-pub` die Plugin-Registrierung für Release neu (`flutter pub get` erzeugt sie mit Dev-Plugins wie `integration_test`). Mit `--no-pub` bricht der Build mit `package dev.flutter.plugins.integration_test does not exist` ab. Löschst du die Datei trotzdem, entsteht eine APK **ohne registrierte Plugins**, die beim Start „Plantini konnte nicht sicher gestartet werden“ zeigt (`ClassNotFoundException: io.flutter.plugins.GeneratedPluginRegistrant`, dann `PlatformException(channel-error … shared_preferences …)`). Das ist bei Version 0.4.0 passiert. Die Datei steht in `apps/flutter/android/.gitignore`.

Weitere Manifest-Punkte, die im Code stehen:

- Release erlaubt nur HTTPS: `android:usesCleartextTraffic="false"` im Haupt-Manifest; das Debug-Manifest (`android/app/src/debug/AndroidManifest.xml`) überschreibt das mit `true` für den lokalen HTTP-Stack.
- `<queries>` mit einem https-VIEW-Intent ist nötig, damit `canLaunchUrl` ab Android 11 Browser findet; sonst meldet die App „Kein Browser kann die Anmeldung öffnen.“
- Die Intent-Filter für Login-Rückweg und App Link stehen in [Authentifizierung](auth.md).
- Berechtigungen: Internet, Netzwerkstatus, Kamera, Standort (grob und fein), `READ_MEDIA_IMAGES` sowie `READ_EXTERNAL_STORAGE` bis API 32; Kamera und Standort sind optional (`uses-feature … required="false"`).

### Auslieferung an die Website

Die Homepage bietet die APK unter `/download/plantini.apk` an und liest Metadaten aus `/download/plantini.json` (`apps/homepage/src/main.js`, Funktion `initApk`): Versionsname, Größe, `minAndroid` und die ersten 16 Zeichen der Prüfsumme; die volle Summe liegt unter `/download/plantini.apk.sha256`. Wo die Dateien auf dem Server liegen und wie sie dort eingehängt sind, steht in [Android-Release (Betrieb)](../betrieb/android-release.md) und [Homepage](../betrieb/homepage.md); die Pfade sind installationsspezifisch.

### `tools/scripts/prepare-app-release.mjs`

Das Skript erzeugt die beiden Begleitdateien aus der gebauten APK:

```js title="tools/scripts/prepare-app-release.mjs"
const apk = resolve(process.argv[2] || 'apps/flutter/build/app/outputs/flutter-apk/app-release.apk');
const pubspec = await readFile(new URL('../../apps/flutter/pubspec.yaml', import.meta.url), 'utf8');
const match = /^version:\s*(\d+\.\d+\.\d+)\+(\d+)\s*$/m.exec(pubspec);
if (!match) throw new Error('A version name and increasing build number are required.');
const bytes = await readFile(apk);
const sha256 = createHash('sha256').update(bytes).digest('hex');
const metadata = { versionName: match[1], versionCode: Number(match[2]), bytes: bytes.length, sha256, minAndroid: 7 };
```

Aufruf (aus dem Repository-Wurzelverzeichnis):

```sh
node tools/scripts/prepare-app-release.mjs                      # Standard-APK
node tools/scripts/prepare-app-release.mjs path/to/app.apk      # anderer Pfad
```

Ergebnis, jeweils **neben der APK**: `plantini.json` mit `versionName`, `versionCode`, `bytes`, `sha256`, `minAndroid` und `plantini.apk.sha256` mit der Zeile `<sha256>  plantini.apk`. Die Konsole meldet `Android <name> (<code>): <bytes> bytes; public metadata prepared.`

Zu beachten:

- Version und Code kommen aus `pubspec.yaml`, **nicht** aus der APK. Das Skript prüft nicht, ob die APK wirklich diese Version enthält; baue vorher mit unverändertem `pubspec.yaml`.
- Das Muster verlangt `x.y.z+n`; ohne `+n` bricht das Skript ab.
- `minAndroid: 7` ist fest eingetragen und passt zu `minSdk 24` (Android 7) nur, solange `flutter.minSdkVersion` 24 bleibt.
- In `plantini.apk.sha256` steht der Dateiname `plantini.apk`, die gebaute Datei heißt aber `app-release.apk`. Für ein erfolgreiches `sha256sum -c` muss die APK bei der Auslieferung `plantini.apk` heißen.

### Stand der Prüfung

Belegt ist laut `knowledge/operations/android-release.md` (Stand 30.09.2026): Installation, Start bis zur Anmeldeseite und das Öffnen des Browsers auf einem x86_64-Emulator. **Nicht belegt** sind ein vollständiger Login bis zum Token, Lernen, Kamera, GPS und Offline-Sync auf Android; ebenso ARM-Geräte. Die neuere Anmeldung per App Link (siehe [Authentifizierung](auth.md)) ist in dieser Betriebsdoku noch nicht nachgetragen.

## iOS

Belegt ist nur, dass ein Xcode-Projekt existiert (`apps/flutter/ios/`): `IPHONEOS_DEPLOYMENT_TARGET = 15.0`, `Info.plist` mit Nutzungstexten für Kamera, Fotos und Standort sowie dem URL-Schema `eu.plantini.app`. Es fehlen eine `.entitlements`-Datei (Associated Domains), eine echte Bundle-ID (`com.example.plantiniApp` in `project.pbxproj`) und ein Eintrag für `apple-app-site-association` auf der Website. Ein iOS-Build, ein Login auf iOS oder eine Store-Einreichung sind in den Quellen **nicht belegt**; `todos.md` führt iOS als offen (`APP-09`, `INFRA-13`).

## Perf-Messlauf

Zwei Werkzeuge messen Frame-Zeiten, besonders für die 3D-Ansichten ([3D und Blender](../3d/index.md), [Performance](../3d/performance.md)).

**`PLANTINI_PERF_LOG`.** Mit `--dart-define=PLANTINI_PERF_LOG=true` schreibt `FrameStats` (`lib/core/diagnostics/frame_stats.dart`) jede Sekunde eine Zeile:

```text
PERF 59.8 fps ui avg=3.1ms max=9.4ms raster avg=2.2ms max=7.0ms slow(>20ms)=0/60 | <name> n=… avg=…ms max=…ms
```

(Format aus dem Quelltext; die Zahlen sind ein Beispiel.) `FrameStats.note(name, duration)` hängt benannte Spannen an, z. B. Cache-Fehlgriffe. Ohne Define ist die Klasse „free when off“.

**`integration_test/perf_walk_test.dart`.** Läuft den Weg Home → Lernen → Pfad (alle Tageszeiten) → Herbarium → Profil mit den Fakes aus `test/app_flow_widget_test.dart` ab und druckt je Schritt Perzentile für UI- und Raster-Thread. Aufruf laut Dateikopf:

```sh
DISPLAY=:0 flutter test integration_test/perf_walk_test.dart -d linux --profile
```

Zahlen sind nur im `--profile`-Modus aussagekräftig; der Test braucht weder Netz noch Login. Ein Define `ONLY_HOME` (`--dart-define=ONLY_HOME=1`, im Test mit `String.fromEnvironment` gelesen) beschränkt den Lauf auf die Startseite.

**`lib/dev/world_bench.dart`.** Eigenständiger Benchmark der 3D-Ansichten: `flutter run --release -d linux -t lib/dev/world_bench.dart --dart-define=PLANTINI_PERF_LOG=true` (Aufruf aus dem Dateikopf). Er durchläuft Lernpfad, Vitrinen und eine Ruhelinie und druckt `BENCH phase`-Marker zwischen den `PERF`-Zeilen.

!!! note "Grenzen der Messungen"
    Laut Handover `knowledge/handovers/herbarium-map-character-daytime.md` wurden keine echten Android-Geräte gemessen; die Zahlen stammen von einem Desktop-Rechner.

## CI

`.gitlab-ci.yml` (Flutter 3.47.1) führt für die App aus: `dart format --output=none --set-exit-if-changed lib test`, `flutter analyze`, `flutter test`, danach den Web-Build mit Entwicklungs-Defines (Artefakt `apps/flutter/build/web/`, eine Woche). `tools/scripts/ci-check.sh` bündelt lokal Backend, Flutter-Analyse, Tests, einen Web- und einen Linux-Build sowie Smoke-Tests gegen den lokalen Stack. Mehr in [Tests und CI](../mitmachen/tests-ci.md).

## Weiterführend

- [Überblick der App](index.md): Konfiguration und Dart-Defines
- [Authentifizierung](auth.md): Signatur, App Link, Redirect-URIs
- [Offline-Fähigkeit](offline.md): Mindestversion der Inhalte
- [Android-Release (Betrieb)](../betrieb/android-release.md), [Homepage](../betrieb/homepage.md), [Konfiguration](../betrieb/konfiguration.md)
- Quellpfade: `apps/flutter/pubspec.yaml`, `apps/flutter/tool/build-linux.sh`, `apps/flutter/android/app/build.gradle.kts`, `apps/flutter/android/gradle.properties`, `tools/scripts/prepare-app-release.mjs`, `apps/flutter/integration_test/perf_walk_test.dart`, `apps/flutter/lib/dev/world_bench.dart`, `knowledge/operations/android-release.md`

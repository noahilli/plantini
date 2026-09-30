# Android-Release (APK zum Direktdownload)

Stand 30.09.2026. Die App ist noch nicht im Play Store; es gibt eine signierte APK unter `https://plantini.eu/download/plantini.apk` (Metadaten und Prüfsumme daneben: `plantini.json`, `plantini.apk.sha256`).

## Signierschlüssel

- Keystore: `~/.plantini-signing/plantini-release.jks` (Alias `plantini`, RSA 4096, 10.000 Tage), Zugangsdaten in `apps/flutter/android/key.properties` (git-ignoriert, Modus 600). **Beides sichern.** Geht der Schlüssel verloren, kann keine installierte App mehr aktualisiert werden (Nutzer müssten deinstallieren). Der Schlüssel liegt nicht im Repository und nicht auf dem Server.
- Ohne `key.properties` signiert Gradle die Release-APK mit dem Debug-Schlüssel: nur für lokale Tests, **nie verteilen**.

## Bauen

Aus einem sauberen Checkout (keine fremden uncommitteten Änderungen in der APK); `android/key.properties` und `android/local.properties` dorthin kopieren:

```sh
cd apps/flutter
flutter build apk --release --target-platform android-arm64,android-arm \
  --dart-define=PLANTINI_ENV=production \
  --dart-define=PLANTINI_API_BASE_URL=https://api.plantini.eu/api/v1 \
  --dart-define=PLANTINI_OIDC_ISSUER_URL=https://auth.plantini.eu/realms/plantini \
  --dart-define=PLANTINI_OIDC_CLIENT_ID=plantini-mobile-production
```

Hinweise: `compileSdk` ist 37 (zwei Plugins verlangen es; AGP 9.1 empfiehlt 36, deshalb `android.suppressUnsupportedCompileSdk=37` in `gradle.properties`); `minSdk` 24 (Android 7), `targetSdk` 36. **Nie `--no-pub` und nie `GeneratedPluginRegistrant.java` löschen:** `flutter pub get` erzeugt die Registrierung mit Dev-Plugins (`integration_test`), erst `flutter build apk` ohne `--no-pub` erzeugt sie für Release neu. Mit `--no-pub` bricht der Build entweder mit `package dev.flutter.plugins.integration_test does not exist` ab, oder (nach Löschen der Datei) entsteht eine APK **ohne registrierte Plugins**, die beim Start „Plantini konnte nicht sicher gestartet werden“ zeigt (`ClassNotFoundException: io.flutter.plugins.GeneratedPluginRegistrant`, dann `PlatformException(channel-error … shared_preferences …)`). Genau das ist bei 0.4.0 passiert.

Enthalten sein müssen alle drei Engines (`--target-platform android-arm64,android-arm,android-x64`): Plugins bringen auch x86_64-Bibliotheken mit, fehlt dann `libflutter.so` für x86_64, wählt Android auf x86-Geräten diese ABI und die App stürzt mit `UnsatisfiedLinkError … EM_AARCH64 instead of EM_X86_64` ab.

Prüfen: `apksigner verify --print-certs`, `aapt2 dump badging` (Paket `eu.plantini.app`, Berechtigungen), Größe. Neue Releases brauchen einen höheren `versionCode` (Teil nach `+` in `pubspec.yaml`).

## Veröffentlichen

APK nach `/opt/plantini/downloads/plantini.apk` auf dem Server kopieren (Caddy hängt das Verzeichnis read-only als `/srv/downloads` ein). `plantini.json` (`versionName`, `versionCode`, `bytes`, `sha256`, `minAndroid`) und `plantini.apk.sha256` aus der APK erzeugen; die Homepage liest `plantini.json` und zeigt Version, Größe und Prüfsumme an.

## Anmeldung und Keycloak

Die App nutzt wie der Desktop den Loopback-Redirect `http://127.0.0.1:4000/` (`lib/auth/auth_platform_io.dart`) mit PKCE S256. Der Client `plantini-mobile-production` ist dafür freigeschaltet (Redirect genau diese Adresse, öffentlich, keine Direct-Access-Grants); `tools/scripts/build-production-realm.mjs` setzt das ebenfalls. Der Release-Build erlaubt nur HTTPS (`usesCleartextTraffic=false`; Debug-Builds dürfen HTTP für den lokalen Stack).

## Stand der ersten Veröffentlichung

Version 0.4.1 (Code 2), rund 89 MB (arm64, armeabi-v7a, x86_64), signiert mit dem Release-Schlüssel (SHA-256 des Zertifikats `03388f0f…a84ec`), Paket `eu.plantini.app`, Android ≥ 7, nur HTTPS. Veröffentlicht unter `https://plantini.eu/download/plantini.apk`, von dort heruntergeladen und gegen die veröffentlichte Prüfsumme und die Signatur geprüft.

## Test auf dem Emulator

`~/Android/Sdk` enthält ein AVD (`Medium_Phone_API_36.1`, x86_64, KVM). `emulator -avd Medium_Phone_API_36.1 -no-window -no-audio -gpu swiftshader_indirect`, dann `adb install -r plantini.apk`, `adb shell am start -W -n eu.plantini.app/.MainActivity`, `adb logcat -d -s flutter` (Startfehler stehen als „Plantini bootstrap failed: …“ im Log). Geprüft (30.09.2026): Installation, Start bis zur Anmeldeseite, Anmelde-Button öffnet Chrome mit der Keycloak-Seite (Redirect `http://127.0.0.1:4000/` wird akzeptiert), der Empfänger lauscht auf Port 4000 und die App lebt im Hintergrund weiter. Unter ARM-Übersetzung (`--abi arm64-v8a`) stürzt die Flutter-Engine auf x86-Emulatoren ab (SIGSEGV in der Übersetzung, kein App-Fehler); ARM-Geräte sind damit nicht getestet.

Android 11+: Damit `canLaunchUrl` Browser sieht, braucht das Manifest eine `<queries>`-Abfrage für https-VIEW-Intents; ohne sie meldet die App „Kein Browser kann die Anmeldung öffnen“.

Beobachtung: Der Loopback-Empfänger bindet auf `0.0.0.0:4000` (alle Schnittstellen) statt nur auf `127.0.0.1`. PKCE und `state` schützen den Ablauf, enger wäre besser (Bibliothek `openid_client`).

## Nicht geprüft

- Vollständige Anmeldung bis zum Token (kein freigeschaltetes Testkonto, E-Mail-Bestätigung war bis dahin nicht abgeschlossen) und alles danach (Lernen, Kamera, GPS, Offline-Sync) auf Android. Risiko des Loopback-Flows: Android darf die App im Hintergrund beenden, während der Browser die Anmeldung zeigt; dann kommt der Redirect nicht an.
- Kamera, GPS und Offline-Synchronisation auf Android.
- Kein Play-Store-Eintrag, keine Play-App-Signatur. Geräte können vor der Installation aus „unbekannten Quellen“ warnen (Play Protect).

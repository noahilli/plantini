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

Hinweise: `compileSdk` ist 37 (zwei Plugins verlangen es; AGP 9.1 empfiehlt 36, deshalb `android.suppressUnsupportedCompileSdk=37` in `gradle.properties`); `minSdk` 24 (Android 7), `targetSdk` 36. Bricht der Build mit `package dev.flutter.plugins.integration_test does not exist` ab, liegt eine veraltete, in Debug erzeugte `GeneratedPluginRegistrant.java` im Checkout: Datei löschen, der Build erzeugt sie neu.

Prüfen: `apksigner verify --print-certs`, `aapt2 dump badging` (Paket `eu.plantini.app`, Berechtigungen), Größe. Neue Releases brauchen einen höheren `versionCode` (Teil nach `+` in `pubspec.yaml`).

## Veröffentlichen

APK nach `/opt/plantini/downloads/plantini.apk` auf dem Server kopieren (Caddy hängt das Verzeichnis read-only als `/srv/downloads` ein). `plantini.json` (`versionName`, `versionCode`, `bytes`, `sha256`, `minAndroid`) und `plantini.apk.sha256` aus der APK erzeugen; die Homepage liest `plantini.json` und zeigt Version, Größe und Prüfsumme an.

## Anmeldung und Keycloak

Die App nutzt wie der Desktop den Loopback-Redirect `http://127.0.0.1:4000/` (`lib/auth/auth_platform_io.dart`) mit PKCE S256. Der Client `plantini-mobile-production` ist dafür freigeschaltet (Redirect genau diese Adresse, öffentlich, keine Direct-Access-Grants); `tools/scripts/build-production-realm.mjs` setzt das ebenfalls. Der Release-Build erlaubt nur HTTPS (`usesCleartextTraffic=false`; Debug-Builds dürfen HTTP für den lokalen Stack).

## Stand der ersten Veröffentlichung

Version 0.4.0 (Code 1), 67 MB (arm64 und armeabi-v7a), signiert mit dem Release-Schlüssel (SHA-256 des Zertifikats `03388f0f…a84ec`), Paket `eu.plantini.app`, Android ≥ 7, nur HTTPS. Veröffentlicht unter `https://plantini.eu/download/plantini.apk`, von dort heruntergeladen und gegen die veröffentlichte Prüfsumme und die Signatur geprüft.

## Nicht geprüft

- Installation und Anmeldung auf einem echten Gerät oder Emulator (auf dieser Maschine ist kein Emulator installiert). Risiko des Loopback-Flows: Android darf die App im Hintergrund beenden, während der Browser die Anmeldung zeigt; dann kommt der Redirect nicht an.
- Kamera, GPS und Offline-Synchronisation auf Android.
- Kein Play-Store-Eintrag, keine Play-App-Signatur. Geräte können vor der Installation aus „unbekannten Quellen“ warnen (Play Protect).

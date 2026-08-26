# Plantini Flutter app

Plantini requires explicit API and OIDC configuration at build time. Do not
publish a Linux bundle built with plain `flutter build linux`: its first screen
will correctly reject the missing configuration.

## Linux build

The target system needs GTK 3 and libsecret at runtime. On Debian/Ubuntu:

```bash
sudo apt-get install libgtk-3-0 libsecret-1-0
```

Build a development bundle against the IPv4-only local environment:

```bash
PLANTINI_ENV=development \
PLANTINI_API_BASE_URL=http://127.0.0.1:1338/api/v1 \
PLANTINI_OIDC_ISSUER_URL=http://127.0.0.1:8082/realms/plantini \
PLANTINI_OIDC_CLIENT_ID=plantini-mobile-dev \
./tool/build-linux.sh
```

For staging or production, provide HTTPS API and issuer URLs plus that
environment's enabled mobile/desktop client. The Keycloak client must allow
the exact PKCE loopback redirect `http://127.0.0.1:4000/`; IPv6 loopback is
intentionally not used.

## Local quality gates

```bash
flutter analyze
flutter test
```

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

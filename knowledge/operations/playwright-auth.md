# Playwright-Playbook: Keycloak/Auth

## Ziel

Der lokale Realm wird über Admin-UI aufgebaut und aus Nutzersicht geprüft. Anschließend wird ein bereinigter Realm-Export zur reproduzierbaren Source of Truth. Produktive Provider-Secrets bleiben außerhalb von Browserautomation und Repository.

## Reihenfolge

1. Mit lokalen Bootstrap-Credentials anmelden; Passwort nie loggen oder in Trace aufnehmen.
2. Realm `plantini` mit E-Mail-Verifikation, Locale und Session-/Tokenzeiten anlegen.
3. Clients anlegen:
   - `plantini-web`: public client, Authorization Code + PKCE, enge Web-Redirects
   - `plantini-mobile`: public native client, PKCE, freigegebene App-Links/Redirects
   - `plantini-admin`: Adminzugang, keine offene Registrierung
   - `plantini-api`: Audience/Scopes für Fach-API
4. Realm-/Clientrollen und minimale Mapper gemäß `architecture/auth-and-roles.md` anlegen.
5. Testnutzer je Rolle sowie gesperrten/unbestätigten Nutzer erzeugen.
6. lokalen Test-OIDC/SAML-Provider anbinden; Google/Apple nur in freigegebener Sandbox.
7. Login, Abbruch, falscher Redirect, Logout, globaler Logout, Sperre, Tokenrefresh und Admin-MFA prüfen.
8. bereinigten Realm exportieren; Secrets/temporäre Nutzer entfernen oder referenzieren.
9. frischen Container ausschließlich mit Export starten und komplette Smoke-Suite wiederholen.

## Account-Linking

Gleiche verifizierte E-Mail führt nie automatisch zu unsicherem Merge. Linking benötigt re-authentifizierte Besitzbestätigung und Testfälle für Konflikt/Provider ohne E-Mail.

## Artefakte

Commitbar: Realmstruktur, Clients ohne Secrets, Rollen, Scopes, Mapper, Themes, Test-IdP-Konfiguration mit Platzhaltern und automatisierte Tests. Nicht commitbar: Admin-/Providerpasswörter, Client Secrets, Cookies, Storage State, Refresh Tokens und echte E-Mail-Adressen.

# Authentifizierung und Rollen

## Identitätsfluss

- Flutter Native/Web: Authorization Code Flow mit PKCE gegen Keycloak.
- Keycloak vermittelt E-Mail/Passwort, Google, Apple und institutionelle OIDC-/SAML-Provider.
- Fach-API validiert Issuer, Audience, Signatur, Ablauf und erforderliche Claims.
- Fachprofil referenziert stabilen `sub`; E-Mail ist änderbares Attribut.
- Konten werden nicht allein aufgrund gleicher E-Mail automatisch zusammengeführt.

## Fachrollen

| Rolle | Kernrechte | Grenzen |
|---|---|---|
| Lernende | eigene Inhalte, Fortschritt, Funde, Export/Löschung | keine fremden Funde oder CMS-Drafts |
| Lehrende | freigegebene Lernpfade, ggf. aggregierte Gruppenansicht | keine exakten Fundorte/privaten Fotos ohne Zweck |
| Inhaltsredaktion | Content-Entwürfe und Medienmetadaten | keine fachliche Endfreigabe eigener Inhalte |
| Botanisches Review | Taxonomie, Fakten, Sicherheit, Freigabe | keine System-/Identity-Administration |
| Organisationsadmin | Einladungen, lokale Rollen/Reports im Scope | keine globale Systemverwaltung |
| Systemadmin | Betrieb und globale Konfiguration | kein pauschaler Zugriff auf private Inhalte |
| Forschende | genehmigte pseudonymisierte Exporte | nur Projekt, Zweck, Einwilligung und Felder |

Keycloak-Realmrollen, Clientrollen, CMS-Rollen und Fachrechte sind getrennte Ebenen. Der Backend-Policy-Layer bildet Claims auf Aktionen ab; UI-Verstecken ersetzt keine serverseitige Prüfung.

## Administrative Einladung

Backend-Selbstregistrierung ist deaktiviert. Adminzugang entsteht über einmalige, ablaufende Einladung oder freigegebenen institutionellen IdP. Einladung, Rollenänderung, Sperre und globale Abmeldung werden auditiert.

## Playwright

Der Auth Manager konfiguriert und prüft den lokalen Realm gemäß `operations/playwright-auth.md`. Echte Google-/Apple-Secrets werden nie automatisiert oder in Traces gespeichert; Entwicklung nutzt einen Test-IdP.

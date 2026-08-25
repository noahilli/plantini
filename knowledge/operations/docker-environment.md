# Docker-Entwicklungsumgebung

`compose.blueprint.yml` ist ein Integrationsentwurf, kein ungeprüfter Produktionsstack. Der DevOps-Agent pinnt vor dem ersten Lauf jede Image-/Toolversion und möglichst den Digest.

## Dienste

| Dienst | Zweck | Dev-URL/Port |
|---|---|---|
| `platform` | Strapi + Fach-API bzw. Startprozess | `http://localhost:1337` |
| `keycloak` | Realm, Login, SSO und Admin | `http://localhost:8081` |
| `postgres-platform` | CMS- und Fachdaten | nur internes Netzwerk |
| `postgres-keycloak` | Identity-Daten | nur internes Netzwerk |
| `redis` | persistente Jobqueue/Cache | nur intern |
| `minio` | S3-kompatibler Public/Private Storage | API 9000, Console 9001 |
| `mailpit` | lokale E-Mail-Verifikation/Einladung | UI 8025 |
| `plantnet-mock` | definierte Success/Low-score/429/Timeout-Fälle | 1080 |
| `playwright` | optionaler Container für E2E/Bootstrap | Profil `tools` |

## Bootstrap-Reihenfolge

1. `.env.example` nach `.env` kopieren und ausschließlich lokale Zufallswerte setzen.
2. Images/SDKs nach Kompatibilitätsprüfung pinnen; Entscheidung dokumentieren.
3. DB, Redis, MinIO, Mailpit und PlantNet-Mock starten; Healthchecks abwarten.
4. Keycloak starten/importieren; Auth Manager führt Playwright-Bootstrap aus und exportiert Realm.
5. Platform starten/migrieren; CMS Manager führt Playwright-Bootstrap aus und sichert Schema/Config.
6. Seeds laden und Backend-Smokes ausführen.
7. Flutter Web starten; QA führt Walking Skeleton aus.

## Reproduzierbarkeit

Ein Lauf gilt erst als reproduzierbar, wenn eine leere Umgebung ausschließlich aus Repository, `.env`-Vorlage, generierten lokalen Secrets und versionierten Exporten entsteht. Manuelle Klicks ohne Export sind kein Liefergegenstand.

## Umgebungen

- Dev: synthetische Daten, Test-IdP, Mailpit, PlantNet-Mock; lokale Secrets.
- Staging: produktionsnahe Domains/TLS, synthetische oder explizit freigegebene Testdaten, Provider-Sandbox.
- Produktion: keine Playwright-Konfiguration per Klick; Promotion geprüfter Artefakte, echte Secrets aus Secret Management, freigegebene Migration/Smoke/Rollback.

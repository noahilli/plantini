# Erster Entwicklungsmeilenstein · Walking Skeleton

Ziel ist ein kleiner Ende-zu-Ende-Pfad, nicht bereits das vollständige MVP.

## Ergebnis

Eine frische Docker-Umgebung startet reproduzierbar. Ein Testnutzer meldet sich in Flutter Web über Keycloak an, sieht ein in Strapi veröffentlichtes Ökosystem und Level über die Fach-API, lädt die Daten lokal, startet eine einfache Lerneinheit/Quizfrage und sieht sie nach Neustart offline. Playwright beweist den Pfad.

## Arbeitspakete und Reihenfolge

| Paket | Owner | Anforderungen | Abhängigkeit |
|---|---|---|---|
| M0-01 Repo/Versionen/ADR | Orchestrator | NFA001–004, NFA027 | keine |
| M0-02 Docker/CI-Basis | DevOps | NFA007–008, NFA023–026 | M0-01 |
| M0-03 Keycloak-Realm/Clients | Auth Manager | FA001, FA006, FA008, NFA009 | M0-02 |
| M0-04 Strapi-Kernmodell | CMS Manager | FA010–015, FA050–054 | M0-02 |
| M0-05 API `/me`/Manifest/Ecosystem | Backend | FA017, NFA004 | M0-03/04 Contract |
| M0-06 Flutter Shell/Read Path | Flutter | FA010, FA020, FA041, NFA003 | Contract-Seed |
| M0-07 Playwright Walking Skeleton | QA | NFA016, NFA019, NFA022 | M0-03–06 |
| M0-08 Web-Storage-Spike | Flutter + Orchestrator | NFA003, NFA020 | M0-06 |
| M0-09 Threat/Privacy Review | Security | NFA009–015 | M0-03–07 |

## Exit-Kriterien

- `compose up` aus leerem Zustand und alle Healthchecks grün
- Realm- und CMS-Konfiguration aus versionierten Artefakten wiederherstellbar
- kein direkter App→Strapi/PlantNet-Zugriff
- Login, Contentread, lokaler Cache, Neustart und Offlineanzeige automatisiert
- OpenAPI generiert Client/Mock und Contracttests laufen
- keine Secrets/realen Daten in Git oder Playwright-Artefakten
- Handoffs und Gate-A-Entscheidungen OQ-02/OQ-03 vorbereitet

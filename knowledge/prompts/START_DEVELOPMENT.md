# Kopierbarer Startprompt für die Entwicklung

```text
Du koordinierst die Entwicklung von Plantini als Multi-Agent-Projekt.

Lies zuerst vollständig:
1. knowledge/AGENT.md
2. knowledge/manifest.yaml
3. knowledge/product/vision-and-scope.md
4. knowledge/product/mvp-and-open-questions.md
5. knowledge/delivery/first-milestone.md
6. knowledge/agents/README.md und agents/ownership.csv
7. die jeweils betroffenen Zeilen aus knowledge/features/features.csv

Ziel des ersten Inkrements ist nur der Walking Skeleton:
Eine frische, gepinnte Docker-Entwicklungsumgebung startet reproduzierbar. Ein synthetischer Nutzer meldet sich in Flutter Web über Keycloak an, sieht ein in Strapi veröffentlichtes Ökosystem und Level über die versionierte Fach-API, lädt diese Daten lokal, startet eine einfache Lerneinheit/Quizfrage und sieht den Inhalt nach Neustart offline. Playwright weist den Pfad nach.

Erzeuge zunächst keine vollständige App. Beginne mit:
- Repository-/Toolchain-Inventur und Versions-Pinning
- ADR-/Contract-Baseline und OpenAPI-Seed
- Docker/CI-Health-Skeleton
- Keycloak-Realm und Clients durch den auth-manager; Konfiguration in Dev mit Playwright, anschließend bereinigter Realm-Export
- Strapi-Kernmodelle durch den cms-manager; Konfiguration in Dev mit Playwright, anschließend versionierte Schemas/Seeds
- Fach-API `/me`, `/content/manifest`, `/ecosystems` und `/levels/{id}`
- Flutter-Shell, Plantini-Designsystem, OIDC, Contentread und lokaler Cache
- Playwright-E2E für Login → Ökosystem → Level → Neustart/Offline
- frühen Web-Speicher-Spike und Threat/Privacy Review

Weise jede Aufgabe genau einer Rolle, einem Branch/Worktree und erlaubten Pfaden zu. Lasse parallele Agents niemals dieselben Engpassartefakte ungeprüft ändern. Nutze synthetische Daten, Test-IdP und PlantNet-Mock; keine Produktionszugänge oder echten Secrets.

API, Realm, CMS-Schema, Migrationen und Infrastruktur sind versionierte Verträge. Ein UI-Klick allein ist keine fertige Konfiguration. Jede Playwright-Konfiguration muss exportiert, aus einem frischen Container wieder importiert und getestet werden.

Für jede Aufgabe verlange:
- Requirement-ID und Nutzerwert
- klare Scopegrenze und Abhängigkeiten
- Implementierung plus Tests
- Security/Privacy/Accessibility-Auswirkung
- Handoff nach knowledge/delivery/handoff-template.md

Stoppe bei offenen Scopeentscheidungen, Breaking Contracts, echten Secrets, Produktionsdaten, irreversiblen Migrationen oder Cross-Owner-Konflikten. Berichte am Ende: integrierte Ergebnisse, Tests/Nachweise, offene Entscheidungen, Blocker und nächste fünf Tasks.
```

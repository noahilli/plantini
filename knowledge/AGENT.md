# Plantini · gemeinsame Einführung für AI-Agents

## Auftrag

Plantini ist eine offene Flutter-Lernplattform für Artenkenntnis. Lernende entdecken Ökosysteme, lernen Pflanzen in konfigurierbaren Leveln, üben mit mehreren Quizformen, fotografieren Pflanzen in der Natur, lassen sie serverseitig über PlantNet identifizieren und speichern bestätigte Funde in einem privaten Offline-Herbarium. Redaktion und fachliche Freigabe laufen im eigenen Studio (`apps/editor`) auf Strapi; Lehrende verwalten Klassen im Lehrendenportal (`apps/teacher`).

Dein Ziel ist nicht, möglichst viel Code zu erzeugen. Dein Ziel ist ein überprüfbares, integrierbares Inkrement, das einer zugeordneten Anforderung und ihrem Abnahmekriterium entspricht.

## Pflichtlektüre vor Änderungen

1. `manifest.yaml`
2. `product/vision-and-scope.md`
3. eigene Datei unter `agents/`
4. eigene Zeilen in `features/features.csv`
5. relevante Dateien unter `architecture/`
6. `delivery/coordination-protocol.md`
7. `delivery/definition-of-ready-done.md`

Bei Auth-, CMS- oder Docker-Aufgaben zusätzlich die passenden Playbooks unter `operations/` lesen. Das Originaldokument unter `references/` bleibt die normative Langfassung.

## Nicht verhandelbare Systemgrenzen

- Die Flutter-App spricht ausschließlich mit der Fach-API und Keycloak, niemals direkt mit Strapi-Admin-APIs oder PlantNet.
- PlantNet-Schlüssel, OIDC-Secrets, Datenbankpasswörter und Signierschlüssel gelangen nie in App, Repository, Image, Testtrace oder Screenshot.
- Strapi enthält redaktionelle Inhalte und Veröffentlichungsmetadaten, aber keine Passwörter, privaten Herbariumfotos oder exakten Fundorte.
- Keycloak enthält Identitäten, Providerverknüpfungen, Sitzungen und Realm-/Clientrollen, aber keine Lern- oder Herbariumdaten.
- Fach- und personenbezogene Daten werden über stabile interne IDs verbunden. E-Mail, wissenschaftlicher Name oder Provider-ID sind keine fachlichen Primärschlüssel.
- Exakte Fundorte sind optional, privat und standardmäßig aus Exporten und Analytik entfernt oder vergröbert.
- Veröffentlichtes Lernmaterial ist versioniert. Ein Client aktiviert ein Release erst nach vollständiger Prüfung von Manifest und Prüfsummen.
- Offline-Schreibvorgänge besitzen stabile Client-IDs und sind idempotent. Wiederholung darf keine doppelten Funde, Events oder Identifikationen erzeugen.
- Levelabschluss und PlantNet-Abgleich werden serverseitig validiert. Ein Clientergebnis allein ist nicht autoritativ.
- Domain- und Application-Code kennen weder Flutter, Isar, HTTP, Kamera, GPS, Strapi noch PlantNet. Adapter implementieren Ports.
- Produktionskonfiguration ist deklarativ reproduzierbar. Playwright darf Dev/Staging über die UI konfigurieren, muss das Ergebnis aber exportieren und versionieren.

## Zielstruktur des Produkt-Repositories

```text
apps/flutter/                 Flutter-App für Android, iOS und Web
services/platform/           Strapi-Erweiterungen und Fach-API
services/identity/           Keycloak-Realm, Clients, Themes und Export
contracts/                   OpenAPI 3.1, Schemas und Eventkatalog
infra/                       Compose/IaC, CI, Monitoring, Backup
tools/e2e/                   Playwright-Konfiguration und E2E-Tests
content/                     offene Seeds/Exporte, keine privaten Daten
docs/                        ADRs, Betrieb, Datenschutz und Contribution
knowledge/                   dieses Paket oder dessen gepflegte Nachfolge
```

Ein Monorepo ist die Ausgangsentscheidung. Große Medien können später in ein separates Content-Repository bzw. den Objektspeicher ausgelagert werden.

## Arbeitsprotokoll für jeden Agent

1. Aufgabe mit Feature-ID, Ziel, erlaubten Pfaden und Abnahme festhalten.
2. Bestehenden Stand und fremde Änderungen prüfen; keine fremden Arbeiten überschreiben.
3. Falls Vertrag, Schema oder Entscheidung fehlt: stoppen, einen Vorschlag erstellen und zuständige Rollen einbeziehen.
4. Kleinstes vertikales Inkrement implementieren. Keine spekulative Plattform bauen.
5. Tests auf der niedrigsten sinnvollen Ebene ergänzen; kritische Reise zusätzlich integriert/E2E prüfen.
6. Dokumentation, Migration, Telemetrie und Datenschutzfolgen im selben Inkrement aktualisieren.
7. Handoff nach `delivery/handoff-template.md` schreiben: Änderungen, Nachweise, bekannte Risiken, nächste Rolle.

## Multi-Agent-Koordination

- Ein Pfad hat zu einem Zeitpunkt genau einen schreibenden Owner. Siehe `agents/ownership.csv`.
- Verträge, Auth-Rollen, Datenmodelle und Infrastruktur sind gemeinsame Engpassartefakte. Änderungen brauchen die dort genannten Reviews.
- Jeder Agent arbeitet auf eigener Branch bzw. eigenem Worktree. Keine Agenten teilen einen nicht committed Zwischenstand.
- Der Product Manager priorisiert und pflegt Featurestatus; der Orchestrator entscheidet Architektur und Integrationsreihenfolge.
- Ein Agent darf keine Anforderungen als „done“ markieren, wenn Abnahmekriterium oder erforderlicher E2E-Nachweis fehlt.
- Konflikte werden nicht durch „last writer wins“ gelöst. Stoppen, diff/handoff bereitstellen, Owner entscheiden lassen.

## Test- und Qualitätsregeln

- Domainregeln: Unit-Tests, bei kritischer Logik mindestens 90 % Branch Coverage.
- Flutter: Unit-, Widget-, Golden-/Semantik- und Integrationsprüfungen; Zustände Loading, Empty, Offline, Error und große Schrift mitdenken.
- API: OpenAPI-Validierung, Contract- und Integrationsprüfungen gegen PostgreSQL/Keycloak/Storage.
- CMS/Auth: Playwright-Setup und UI-Smokes auf Dev/Staging; exportierte Konfiguration wird im frischen Container erneut importiert.
- Kernreise: Registrierung → Level → Quiz → Feldauftrag → Identifikation → Herbarium als E2E, zunächst mit PlantNet-Mock.
- Sicherheit: Secret-, Dependency-, Container-, SAST- und DAST-Prüfung; kritische oder hohe Befunde blockieren Releases.
- Betrieb: Migration, Backup/Restore, Queue-Wiederaufnahme, Provider-429 und Offline-/Netzwechsel werden aktiv getestet.

## Stop-Bedingungen

Stoppe und eskaliere, wenn eine Aufgabe Produktionszugang, echte Provider-Secrets, reale Nutzerdaten, eine irreversible Migration, ungeklärte Bildrechte, eine Änderung an Einwilligungslogik oder einen Breaking API Change benötigt. Dokumentiere den Blocker; erfinde keine Freigabe.

## Aktueller Architekturstand

- App: Flutter, Clean Architecture, vertikale Featuremodule
- Lokale Speicherung: `isar_plus` hinter Repository-Ports, im Web über denselben `LocalDatabase.open()`-Pfad (WASM)
- CMS/Admin: Strapi Community Edition mit projektseitigem Reviewstatus
- Identity: Keycloak mit OIDC/OAuth 2.0 (PKCE); externe Identity Provider sind noch nicht angebunden (`AUTH-09`)
- Daten: PostgreSQL, private Medien im Docker-Volume (S3/MinIO geplant, `CMS-07`), Redis-Queue
- Externe Identifikation: PlantNet ausschließlich über Backend-Worker
- Auslieferung: GitHub Actions und GitLab CI, Docker-basierte Dev-/E2E-Stacks, Single-Host-Produktion mit Caddy; signiert ist bisher nur die Android-APK

Noch offene Architekturpunkte stehen in `product/mvp-and-open-questions.md`; kein Agent darf sie stillschweigend als entschieden behandeln.

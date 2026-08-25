# Kurze Kickoff-Prompts pro Rolle

## Orchestrator / Technical Lead

> Übernimm die Rolle `orchestrator` für Plantini. Lies `AGENT.md`, `agents/00-orchestrator.md`, deine Zeilen in `features/features.csv` und die relevanten Architekturdateien. Repositorystruktur, Toolchain-Versionen und ADRs bestätigen; OQ-01 bis OQ-03 terminieren; erste fünf vertikale Tasks mit Feature-IDs vergeben. Arbeite nur in deinen erlaubten Pfaden, liefere Tests und einen Handoff; stoppe bei fehlender Freigabe, echten Secrets, Produktionsdaten oder Vertragskonflikten.

## Product & Delivery Manager

> Übernimm die Rolle `product-manager` für Plantini. Lies `AGENT.md`, `agents/01-product-manager.md`, deine Zeilen in `features/features.csv` und die relevanten Architekturdateien. Offene Entscheidungen priorisieren, Gate-A-Backlog freigeben und ein integriertes Alpha-Szenario als Abnahmegeschichte formulieren. Arbeite nur in deinen erlaubten Pfaden, liefere Tests und einen Handoff; stoppe bei fehlender Freigabe, echten Secrets, Produktionsdaten oder Vertragskonflikten.

## Flutter Frontend Developer

> Übernimm die Rolle `flutter-frontend` für Plantini. Lies `AGENT.md`, `agents/02-flutter-frontend.md`, deine Zeilen in `features/features.csv` und die relevanten Architekturdateien. Flutter-Shell, Router, Plantini-Tokens und ein vertikales Home→Ökosystem-Read-Modul gegen Mock/OpenAPI aufsetzen; parallel Web-Storage-Spike starten. Arbeite nur in deinen erlaubten Pfaden, liefere Tests und einen Handoff; stoppe bei fehlender Freigabe, echten Secrets, Produktionsdaten oder Vertragskonflikten.

## Backend / Platform API Developer

> Übernimm die Rolle `backend-api` für Plantini. Lies `AGENT.md`, `agents/03-backend-api.md`, deine Zeilen in `features/features.csv` und die relevanten Architekturdateien. Service-Skeleton, `/me`, `/content/manifest`, `/ecosystems` und Provider-Mock implementieren; Entscheidung Strapi-Erweiterung vs. separater Dienst vorbereiten. Arbeite nur in deinen erlaubten Pfaden, liefere Tests und einen Handoff; stoppe bei fehlender Freigabe, echten Secrets, Produktionsdaten oder Vertragskonflikten.

## CMS Configuration Manager (Strapi + Playwright)

> Übernimm die Rolle `cms-manager` für Plantini. Lies `AGENT.md`, `agents/04-cms-manager.md`, deine Zeilen in `features/features.csv` und die relevanten Architekturdateien. Docker-Health abwarten, Einmal-Admin sicher bootstrappen, Kern-Contenttypes erzeugen, Schema-Diff sichern und CMS-Smoke in frischem Container wiederholen. Arbeite nur in deinen erlaubten Pfaden, liefere Tests und einen Handoff; stoppe bei fehlender Freigabe, echten Secrets, Produktionsdaten oder Vertragskonflikten.

## Authentication & Identity Manager (Keycloak + Playwright)

> Übernimm die Rolle `auth-manager` für Plantini. Lies `AGENT.md`, `agents/05-auth-manager.md`, deine Zeilen in `features/features.csv` und die relevanten Architekturdateien. Lokalen Realm, Web-/Native-Clients, Testnutzer, Rollen und Test-IdP via Playwright anlegen; Export importieren und Login/Logout/Revocation nachweisen. Arbeite nur in deinen erlaubten Pfaden, liefere Tests und einen Handoff; stoppe bei fehlender Freigabe, echten Secrets, Produktionsdaten oder Vertragskonflikten.

## DevOps & Release Engineer

> Übernimm die Rolle `devops-release` für Plantini. Lies `AGENT.md`, `agents/06-devops-release.md`, deine Zeilen in `features/features.csv` und die relevanten Architekturdateien. `compose.blueprint.yml` in lauffähige, gepinnte Dev-Compose überführen; Healthcheck-Command und CI-Basis bereitstellen. Arbeite nur in deinen erlaubten Pfaden, liefere Tests und einen Handoff; stoppe bei fehlender Freigabe, echten Secrets, Produktionsdaten oder Vertragskonflikten.

## QA / Playwright Engineer

> Übernimm die Rolle `qa-playwright` für Plantini. Lies `AGENT.md`, `agents/07-qa-playwright.md`, deine Zeilen in `features/features.csv` und die relevanten Architekturdateien. Playwright-Harness, Healthcheck-Projekt und Walking-Skeleton `Login → Ökosystem → Level` gegen Dev-Compose aufsetzen. Arbeite nur in deinen erlaubten Pfaden, liefere Tests und einen Handoff; stoppe bei fehlender Freigabe, echten Secrets, Produktionsdaten oder Vertragskonflikten.

## Botanical Content & Data Manager

> Übernimm die Rolle `content-data` für Plantini. Lies `AGENT.md`, `agents/08-content-data.md`, deine Zeilen in `features/features.csv` und die relevanten Architekturdateien. Referenzdatensatz für ein Ökosystem, ein Level und fünf Arten inklusive Lizenz-/Alt-Text-Prüfung erstellen. Arbeite nur in deinen erlaubten Pfaden, liefere Tests und einen Handoff; stoppe bei fehlender Freigabe, echten Secrets, Produktionsdaten oder Vertragskonflikten.

## UX, Design System & Accessibility

> Übernimm die Rolle `ux-accessibility` für Plantini. Lies `AGENT.md`, `agents/09-ux-accessibility.md`, deine Zeilen in `features/features.csv` und die relevanten Architekturdateien. Tokens und Komponenteninventar aus dem Screenboard ableiten; Walking-Skeleton mit Loading/Offline/Error/200-%-Text freigeben. Arbeite nur in deinen erlaubten Pfaden, liefere Tests und einen Handoff; stoppe bei fehlender Freigabe, echten Secrets, Produktionsdaten oder Vertragskonflikten.

## Security & Privacy Engineer

> Übernimm die Rolle `security-privacy` für Plantini. Lies `AGENT.md`, `agents/10-security-privacy.md`, deine Zeilen in `features/features.csv` und die relevanten Architekturdateien. Threat Model für Walking Skeleton, initiale Rollenmatrix und Secret-/Trace-Policy freigeben. Arbeite nur in deinen erlaubten Pfaden, liefere Tests und einen Handoff; stoppe bei fehlender Freigabe, echten Secrets, Produktionsdaten oder Vertragskonflikten.

## Research & Analytics Manager

> Übernimm die Rolle `research-analytics` für Plantini. Lies `AGENT.md`, `agents/11-research-analytics.md`, deine Zeilen in `features/features.csv` und die relevanten Architekturdateien. Minimalen Eventkatalog für Registrierung, Contentdownload, Levelstart/-abschluss und Identifikationsjob entwerfen – ohne Foto, Freitext oder GPS. Arbeite nur in deinen erlaubten Pfaden, liefere Tests und einen Handoff; stoppe bei fehlender Freigabe, echten Secrets, Produktionsdaten oder Vertragskonflikten.

# ADR 001: Initiale Architektur, Toolchain und Walking Skeleton Entscheidungen

## Datum
2026-08-24

## Status
Akzeptiert (Gate A)

## Kontext
Plantini wird als Multi-Agent-Projekt entwickelt. Wir benötigen eine feste Repository-Struktur, festgelegte Toolchain-Versionen und müssen die initialen offenen Architekturfragen (OQ-01 bis OQ-03) für den Walking Skeleton klären. Gemäß NFA001 bis NFA004 und NFA027 muss die Architektur modular, dokumentiert und portabel sein.

## Entscheidungen

1. **Repository-Struktur:** Das Repository ist als Monorepo mit den Verzeichnissen `apps/flutter`, `services/platform`, `services/identity`, `contracts`, `infra`, `tools/e2e`, `content`, und `docs/adr` angelegt.
2. **Lizenzierung (NFA001):** Eigener Code wird unter Apache-2.0 veröffentlicht. *(Überholt am 11.11.2026: Code unter AGPL-3.0-or-later, Lerninhalte unter CC BY-SA 4.0, siehe `LICENSE` und `NOTICE`.)*
3. **Modulare Gesamtarchitektur (NFA002):** Backend, Auth, Frontend und DB sind strikt entkoppelt.
4. **OQ-01 (Artenanzahl):** Die Architektur unterstützt sowohl globale als auch ökosystemspezifische Arten. Für den Seed rechnen wir mit 75 eindeutigen Arten.
5. **OQ-02 (Isar auf Web - NFA003):** Für den Web-Spike testen wir Isar. Sollte dies in Zielbrowsern fehlschlagen, wird der Fallback IndexedDB/Drift-WASM genutzt. Entscheidung über finalen Adapter fällt nach Spike (Gate A).
6. **OQ-03 (Fach-API - NFA004):** Wir starten mit dünnen Strapi-Custom-Routes in `services/platform`.
7. **Versionen:** 
   - Docker/Compose (infra)
   - Strapi Community Edition
   - Keycloak
   - PostgreSQL
   - Flutter für Apps
   - Playwright für E2E

## Konsequenzen
Die Toolchain ist festgelegt. DevOps kann mit der `M0-02` Docker-Basis beginnen.

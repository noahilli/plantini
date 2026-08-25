# Architekturentscheidungen und ADR-Prozess

## Bereits entschieden

| ADR | Entscheidung | Status |
|---|---|---|
| ADR-001 | Flutter-Codebasis für Android, iOS und Web; Clean Architecture und vertikale Features | accepted |
| ADR-002 | Strapi CE + PostgreSQL für redaktionelle Inhalte/Admin | accepted |
| ADR-003 | Keycloak als zentraler IdP und Broker für OIDC/SAML/Social Login | accepted |
| ADR-004 | App spricht über Fach-API; kein direkter Strapi-/PlantNet-Zugriff | accepted |
| ADR-005 | S3-kompatibler Storage und asynchrone Worker/Queue | accepted |
| ADR-006 | Offline-Ereignisse idempotent; Content Releases atomar/versioniert | accepted |
| ADR-007 | Isar Mobile hinter Port; Webadapter erst nach Spike festlegen | provisional |
| ADR-008 | Monorepo für Produktcode; große offene Medien separat möglich | accepted |

## Neue ADR

Eine ADR enthält Kontext, Optionen, Entscheidung, Konsequenzen, Sicherheits-/Datenschutzwirkung, Migrations-/Rollbackweg, betroffene Requirements und beteiligte Rollen. Verwende `delivery/decision-template.md`.

Ein Agent darf eine accepted ADR nicht implizit brechen. Er erstellt einen Änderungsvorschlag und wartet auf Orchestrator-Entscheidung; bei Scopewirkung ist Product Manager accountable.

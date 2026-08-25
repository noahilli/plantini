# Koordinationsprotokoll für mehrere Agents

## Task-Lease

Jeder Task nennt: Ticket/Feature-ID, Agentenrolle, Branch/Worktree, erlaubte Pfade, erwartete Artefakte, Abnahmekriterien, Abhängigkeiten und Ablaufzeitpunkt. Ohne eindeutigen Owner keine Änderung.

## Engpassartefakte

`contracts/**`, Datenmigrationen, Keycloak-Realm, Strapi-Schemas, `infra/**` und `features.csv` werden niemals parallel ungeprüft überschrieben. Wer sie ändern will, kündigt die Änderung an und nennt Reviewer aus `agents/ownership.csv`.

## Branching

- `feat/FA033-plantnet-job`
- `fix/NFA020-sync-crash`
- `chore/NFA023-ci-sbom`
- `config/FA050-strapi-model`

Ein Agent committed nur eigene logisch zusammenhängende Änderungen. Keine fremden uncommitted Dateien formatieren oder löschen. Rebase/Integration übernimmt der Owner des Zielbereichs bzw. Orchestrator.

## Handoff

Abschluss enthält Requirement, Outcome, geänderte Pfade, Befehle/Tests, Migration/Config-Diff, Screenshots/Trace nur sanitisiert, offene Risiken und konkret nächste Rolle. Vorlage: `handoff-template.md`.

## Konflikt

Bei überlappenden Änderungen sofort stoppen. Diffs sichern, Owners informieren, keine automatische Last-writer-wins-Auflösung. Bei Vertrag/Architektur entscheidet Orchestrator; bei Scope/Akzeptanz Product Manager; bei Security/Privacy kann Security die Freigabe blockieren.

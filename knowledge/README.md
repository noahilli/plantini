# Plantini · Agent Knowledge Package

Dieses Paket ist die gemeinsame Arbeitsgrundlage für mehrere Entwicklungs- und Konfigurationsagents. Es übersetzt das 49-seitige Anforderungsdokument in kleine, maschinenlesbare und rollenbezogene Dateien.

## Einstieg

1. `AGENT.md` vollständig lesen.
2. Die eigene Rolle unter `agents/` öffnen.
3. In `features/features.csv` nur die der Rolle zugeordneten Anforderungen filtern.
4. Relevante Architektur-, Betriebs- und Delivery-Dateien lesen.
5. Eine klar abgegrenzte Aufgabe aus `delivery/first-milestone.md` übernehmen.

## Inhalt

- `features/`: alle 95 Anforderungen mit Priorität, Abnahme, Ownership und Testebenen
- `product/`: Vision, MVP, Screens, Spielablauf, Begriffe und offene Entscheidungen
- `architecture/`: Plattform, Flutter, Backend/CMS, Daten, API, Sync, Auth und Sicherheit
- `agents/`: Rollenbeschreibungen, Eigentumsgrenzen und Startaufträge
- `operations/`: Docker-Blueprint, Playwright-Playbooks, CI/CD, Betrieb und Backup
- `delivery/`: Koordination, Definition of Ready/Done, Meilensteine und Vorlagen
- `governance/`: Open-Source-Rollen, Beitragsfluss und Repository-Vorlagen
- `prompts/`: kopierbarer Gesamtstartprompt und kurze Rollenprompts
- `references/`: originales PDF/LaTeX sowie aktuelle Plantini-Screenquellen
- `scripts/validate_knowledge.py`: Konsistenzprüfung des Pakets

## Verbindlichkeit

Die Dateien sind keine Erlaubnis, Scope oder Sicherheitsregeln stillschweigend zu ändern. Normative Anforderungen stammen aus `references/plantini-anforderungen.pdf`. Abweichungen benötigen eine Entscheidung nach `architecture/decisions.md` und ein Update der Feature-Traceability.

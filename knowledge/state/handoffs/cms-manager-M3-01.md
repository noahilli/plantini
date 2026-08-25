# Handoff: M3-01 CMS Draft/Publish & Review Flow

- **Von / an Rolle:** cms-manager / orchestrator, qa-playwright
- **Ergebnis:** Draft & Publish ist für `Plant` und `Quiz` aktiviert. Ein `reviewStatus` Enum wurde hinzugefügt. Über Strapi Lifecycle-Hooks (`lifecycles.js`) wird nun hart blockiert, dass Inhalte ohne `approved`-Status publiziert werden können (Vier-Augen-Prinzip).
- **Requirement(s):** FA054
- **Geänderte Pfade:** `services/platform/src/api/plant/**`, `services/platform/src/api/quiz/**`
- **Bekannte Risiken/Blocker:** Keine. Community Edition Workflow-Limits elegant durch Lifecycles umgangen.
- **Nächster konkreter Schritt:** CMS Manager setzt mit Taxonomie & Media Rights (M3-02) fort.

# Handoff: M2-01 Strapi Models: Observation

- **Von / an Rolle:** cms-manager / backend-api
- **Ergebnis:** Contentmodell `Observation` als Strapi Schema in `services/platform/src/api/observation/content-types/` angelegt. Enthält Felder für Media-Relation, Geo-Koordinaten (opt-in), PlantNet-JSON-Scores, Notizen und die zugeordnete Pflanze.
- **Requirement(s):** FA036, FA063
- **Geänderte Pfade:** `services/platform/src/api/observation/**`
- **Bekannte Risiken/Blocker:** Keine.
- **Nächster konkreter Schritt:** Backend-API (M2-02) implementiert nun die Custom Routes für POST und GET Observations und schreibt die Datei-Upload Logik.

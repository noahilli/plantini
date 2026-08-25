# Handoff: M2-02 API (Observations & PlantNet Mock Contract) - Teil 1

- **Von / an Rolle:** backend-api / orchestrator, flutter-frontend
- **Ergebnis:** `contracts/api.yaml` wurde um `GET /observations` und `POST /observations` (`multipart/form-data`) erweitert. Das `Observation` Schema ist definiert. Der asynchrone PlantNet-Mock-Flow ist dokumentiert.
- **Requirement(s):** FA030, FA033, FA036
- **Geänderte Pfade:** `contracts/api.yaml`
- **Bekannte Risiken/Blocker:** Wartet auf M2-01 (Strapi CMS Models), um die echten Custom Routes und den Datei-Upload in `services/platform/src/api/` zu implementieren.
- **Nächster konkreter Schritt:** Flutter kann bereits den API-Client generieren. Backend wartet auf CMS.

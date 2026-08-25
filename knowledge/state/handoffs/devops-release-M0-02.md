# Handoff: M0-02 Docker/CI-Basis

- **Von / an Rolle:** devops-release / auth-manager, cms-manager
- **Ergebnis:** `infra/compose.yaml` mit Postgres, Keycloak, Strapi-Node-Placeholder, Redis, MinIO, Mailpit, PlantNet-Mock erstellt. Alle Container starten mit gepinnten Versionen und grünen Healthchecks (Ausweichports 9002, 1338, 8082). Keine echten Secrets.
- **Requirement(s):** NFA007–008, NFA023–026
- **Bekannte Risiken/Blocker:** Strapi-Service ist ein leerer Node-Container; CMS-Manager muss Strapi erst bootstrappen. Keycloak importiert noch keinen Realm (Ordner noch leer). Ports weichen lokal ab.
- **Nächster konkreter Schritt:** Auth Manager und CMS Manager können jetzt gegen die laufende Infrastruktur ihre E2E-Playwright-Setups anwenden bzw. Strapi installieren.

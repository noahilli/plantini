# Handoff: M0-03 Keycloak-Realm/Clients (Final)

- **Von / an Rolle:** auth-manager / devops, qa-playwright
- **Ergebnis:** Realm `plantini`, Client `plantini-flutter` und Testnutzer `learner1` wurden über Playwright in der laufenden Keycloak-Instanz angelegt.
- **Artefakte:** Konfiguration wurde in `services/identity/realm/plantini-realm.json` exportiert.
- **Nächster Schritt:** DevOps kann das Flag `--import-realm` wieder in die `compose.yaml` einfügen. QA-Playwright kann diese Testdaten für das E2E-Script nutzen.

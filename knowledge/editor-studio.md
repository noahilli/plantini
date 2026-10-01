# Plantini Studio: Anforderung und Umsetzungsstand

Stand: 2026-10-01. Das Studio ist eine separate Webanwendung. Es ersetzt **nicht** das interne Strapi-Admin.

## Seiten und Rechte

| Seite | Zweck | Rechte |
| --- | --- | --- |
| Übersicht | Nutzer, PlantNet-Tageszugriffe, privater Upload-Speicher, Ökosysteme, Level, Pflanzen, Quizze, Karten, offene Reviews | Redaktion und Review |
| Inhalte | Baum Ökosystem → Level → Pflanze/Quiz; Entwürfe erstellen und bearbeiten; Lernkarten und Relationen pflegen | Redaktion und Review |
| Review | Eingereichte Änderungen ansehen und begründet zurückweisen | Review; Redakteure sehen eigene Änderungen |
| Team | Redakteure per Keycloak-E-Mail einladen; Reviewer nur durch Systemadministration | Redaktion bzw. Systemadministration |

Die Keycloak-Realm-Rollen heißen `inhaltsredaktion`, `botanisches_review` und `systemadministration`. Rollenprüfung erfolgt serverseitig an jeder Editor-API. Browser-Login nutzt Authorization Code + PKCE S256 mit separatem Public Client. Die Keycloak-Admin-API wird nur vom Backend mit einem eigenen, eng berechtigten Service Account aufgerufen. Es gibt keine Admin-Zugangsdaten im Browser.

## Architektur und Deployment

`apps/editor` ist ein statischer Nginx-Container hinter `editor.<domain>`. Er spricht ausschließlich mit `api.<domain>/api/v1/editor/*` und `auth.<domain>`. Der API-Dienst hält Entwürfe und Review-Zustände in PostgreSQL (`editor_changes`); die veröffentlichten Strapi-Inhalte bleiben zunächst unverändert. In der Produktions-Compose-Datei hängt der Editor nur am Edge-Netz. Auf einem bestehenden Keycloak-Realm muss der neue OIDC-Client **live** angelegt werden: ein Realm-Import aktualisiert ihn nicht automatisch. Der Einladungsdienst benötigt einen separat konfigurierten Keycloak-Service-Account und funktionierenden SMTP-Versand. Seed-Inhalte müssen bei echter Redaktion deaktiviert sein (`PLATFORM_SEED_DEMO_CONTENT=false`). Vor Produktionsbetrieb sind Datenbank-Backups nötig.

## Aktueller Funktionsumfang und harte Grenze

Angelegt sind die Studio-Oberfläche, Keycloak-Clients im versionierten Realm, API für Dashboard/Katalog/Entwürfe/Einreichen/Zurückweisen/Einladen und der Container-Bau. Die Browseroberfläche zeigt vorhandene Bilder, kann sie aber noch nicht hochladen oder zuordnen. Einladungen sind nur mit konfiguriertem Service Account und SMTP nutzbar. Dashboard-Speicher zählt derzeit nur hochgeladene private Medien; Kartenanzahl ist aus drei Pflicht-Lernkarten je veröffentlichter Pflanze abgeleitet; PlantNet-Zugriffe sind nur der Tageszähler aus Redis, keine historische Analyse. Katalogabfragen sind noch auf 1000 Datensätze je Typ begrenzt.

**Freigabe ist absichtlich deaktiviert.** Der bestehende Live-Lesepfad und die Offline-Manifest/Paket-Linie sind noch nicht an ein atomar aktiviertes Release gekoppelt. Direktes Publizieren in Strapi könnte Clients inkonsistente Inhalte liefern. Deshalb dürfen Entwürfe noch keine veröffentlichten Datensätze ändern. Um Freigabe zu aktivieren, müssen nacheinander umgesetzt werden:

1. Release-übergreifende Validierung für Beziehungen, Quizlösungen, Quellen, Bildlizenz und Alt-Text.
2. Versionierten Release aus geprüften Datensätzen bauen; Pakete, SHA-256, Manifest und Cursor aus denselben Daten erzeugen.
3. Release atomar aktivieren und zurückrollen können; Online-Endpunkte strikt auf das aktive Release filtern.
4. Vier-Augen-Freigabe anbinden. Reviewer dürfen eigene Inhalte freigeben; Redakteure benötigen Reviewer-Freigabe.
5. Bildverwaltung, Teamübersicht, Dashboard-Paginierung und einen Frischumgebungs-Test vom Entwurf bis zum App-Sync ergänzen.

Bis dahin ist dies ein **Redaktions-MVP für Entwürfe und Review, kein produktionsfertiger Veröffentlichungsweg**.

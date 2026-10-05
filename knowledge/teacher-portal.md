# Lehrendenportal

Stand: 05.10.2026. Nutzerauftrag TEACH-01, FA006/FA056/FA057/FA059.

## Seiten und Funktionen

Das Portal unter `portal.plantini.eu` ist eine eigene responsive Webanwendung in
`apps/teacher`, ausgeliefert durch einen unprivilegierten Nginx-Container. Die
Übersicht zeigt Klassen, aktive Schülerkonten, absolvierte Level, mittleren
Fortschritt, Fortschritt je Ökosystem und die letzten Levelabschlüsse. Die
Klassenansicht erlaubt die Anlage einer Klasse; ihre Detailseite zeigt die
Lernenden mit individuellen Fortschrittsbalken und Ökosystemaufteilung.

Lehrende erstellen Schülerkonten mit eindeutigem Anmeldenamen und Anzeigenamen.
Eine E-Mail-Adresse ist optional. Ein generiertes Startpasswort wird genau
einmal angezeigt und muss beim ersten Login geändert werden. Eine angegebene
E-Mail-Adresse wird in Keycloak bestätigt. Das Portal kann Passwörter erneut
zurücksetzen und Konten sperren bzw. aktivieren; der Lernfortschritt bleibt dabei
erhalten. Die Selbstregistrierung im Realm ist deaktiviert. Bereits vorhandene
Konten bleiben erhalten.

## Rechte und Daten

Die Rollen `lehrende` und `systemadministration` dürfen das Portal öffnen. Jede
Klasse gehört dem anlegenden Keycloak-Subject. Auch Systemadmins arbeiten hier
mit ihren eigenen Klassen; es gibt keinen pauschalen Zugriff auf fremde
Lernende. Jede Schüleroperation prüft die Klassenbeziehung serverseitig und
prüft in Keycloak, dass das Ziel ein verwaltetes Lernendenkonto ohne erhöhte
Rollen ist. Fremde Klassen und Schüler-IDs liefern 404; Lernende erhalten 403.
Schulübergreifende Organisationen und das Teilen einer Klasse mit weiteren
Lehrenden gehören nicht zu diesem ersten Inkrement.

Passwörter liegen ausschließlich in Keycloak. Browser-Tokens bleiben im
Arbeitsspeicher; nur der kurzlebige PKCE-State liegt in sessionStorage. Der
Backend-Service-Account hat `manage-users`, `view-users`, `query-users` und
`view-realm`, keine Realm- oder Clientverwaltung. Bestehende Sitzungen werden bei
Reset und Sperre beendet. Zusätzlich sperrt `tokensValidAfter` zuvor ausgestellte
Access-Tokens unmittelbar in der Fach-API. Schülerkonten bleiben bei einer
unterbrochenen Anlage zunächst gesperrt und sichtbar verwaltbar.

Die neuen Tabellen `teaching_classes`, `teaching_students`, `teaching_audit`
enthalten stabile UUIDs, Beziehungen und minimale Verwaltungsdaten. Audit-Events
speichern nur Akteur-Subject, Ziel-ID, Aktion und Ergebnis, keine Passwörter oder
Token. Das Portal liefert weder Herbariumfotos noch Fundorte. Fortschritt zählt
eindeutige serverseitig bestandene Level aus dem aktiven Katalog; wiederholte
Versuche erzeugen keine zusätzlichen Abschlüsse. Der Durchschnitt ist die Summe
der bestandenen Level geteilt durch Schülerzahl × aktuelle Levelzahl. Konten
ohne Aktivität zählen mit null; gesperrte Konten bleiben Teil der Lerngruppe.

## Container und Einrichtung

Öffentliche Laufzeitkonfiguration: `PLANTINI_API_BASE_URL`,
`PLANTINI_OIDC_ISSUER_URL`, `PLANTINI_OIDC_CLIENT_ID`; keine Secrets im Image.
Der Produktionsclient ist `plantini-teacher-production`, mit PKCE S256 und
exaktem Redirect `https://portal.plantini.eu/`. Der Container ist read-only,
bindet nur `127.0.0.1:8085` und liegt hinter Caddy/TLS.

Bestehende Realms werden ausdrücklich aktualisiert, nicht neu importiert:

```sh
node tools/scripts/configure-managed-accounts.mjs <geschützte-env-Datei> https://portal.plantini.eu
```

Das Skript legt den Portalclient und einen vertraulichen Verwaltungsclient an,
setzt Rollenscopes, deaktiviert Selbstregistrierung und schreibt dessen Secret
nur in die geschützte Env-Datei (0600). Dieser Client aktiviert zugleich den
bisher unkonfigurierten Studio-Einladungsdienst. SMTP bleibt Voraussetzung für
E-Mail-Einladungen. Lehrendenrollen werden zunächst durch die bestehende
Systemadministration über Studio → Team → „Lehrende“ eingeladen; das Portal
selbst kann nur Lernende erzeugen. Lehrendeneinladungen kehren nach der
Passwort-/E-Mail-Einrichtung zum Portal zurück.

Lokal bleibt alles auf IPv4 und vorhandene Volumes werden weiterverwendet:

```sh
node tools/scripts/configure-managed-accounts.mjs tools/e2e/.runtime/e2e.env http://127.0.0.1:8085
docker compose --env-file tools/e2e/.runtime/e2e.env -p plantini-e2e \
  -f infra/compose.e2e.yaml -f infra/compose.teacher.local.yaml \
  up -d --build --wait platform teacher
```

Live-Abnahme und Deployment-Versionen werden im Produktions-Runbook ergänzt.

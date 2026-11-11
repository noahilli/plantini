# Sicherheit

## Unterstützte Versionen

Plantini ist ein früher Stand (App 0.7.x). Sicherheitskorrekturen gibt es nur für den aktuellen Stand von `main` und die auf plantini.eu ausgerollte Version. Ältere Stände werden nicht gepflegt.

## Schwachstelle melden

Bitte **kein öffentliches Issue** für Sicherheitslücken oder Datenschutzprobleme.

- Bevorzugt: über GitHub **„Report a vulnerability“** (Reiter *Security* des Repositorys, privates Advisory).
- Alternativ per E-Mail an **noah@illmann.net** mit dem Betreff „Plantini Security“.

Hilfreich sind:

- Art des Problems (z. B. Umgehung der Anmeldung, Zugriff auf fremde Funde oder Klassen, Offenlegung von Fundorten, Secret im Repository)
- betroffener Teil (App, Fach-API, Keycloak-Realm, Studio, Portal, Homepage, Infrastruktur)
- Schritte zum Nachstellen, möglichst gegen eine lokale Instanz (`tools/scripts/start-local-demo.sh`)

Plantini ist ein ehrenamtliches Projekt ohne Bereitschaftsdienst. Eingangsbestätigung in der Regel innerhalb von 7 Tagen; danach stimmen wir Behebung und Veröffentlichung gemeinsam ab.

Bitte teste **nicht** gegen die produktive Instanz mit fremden Konten, automatisierten Scans oder Last. Die offene Registrierung ist kein Freibrief dafür.

## Was das System heute absichert

Der genaue Stand mit Belegen steht im Handbuch unter `docs-site/docs/architektur/sicherheit-datenschutz.md`. Kurzfassung:

- **Rechte entscheidet der Server.** Jede Route der Fach-API prüft Token (Signatur, Aussteller, Zielgruppe `plantini-api`) und Rolle; die Oberflächen prüfen nur zur Anzeige.
- **Fundorte:** Die App rundet Fundorte vor dem Hochladen auf zwei Nachkommastellen (etwa 1 km); exakte Koordinaten bleiben auf dem Gerät. Der Server erzwingt die Rundung bisher nicht selbst (offener Punkt `OFFLINE-08`).
- **Pl@ntNet** wird nur vom Server angesprochen; der Schlüssel erreicht nie App oder Browser.
- **Secrets** stehen nie im Repository. Produktiv liegen sie in einer nur für root lesbaren Umgebungsdatei auf dem Server; Vorlagen ohne Werte: `infra/production.env.example`.
- **Administration** von Keycloak und Strapi ist nicht öffentlich erreichbar (nur über SSH-Tunnel); Konten mit Administrationsrolle brauchen einen zweiten Faktor (TOTP).

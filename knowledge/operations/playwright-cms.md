# Playwright-Playbook: Strapi/CMS

## Ziel

Das CMS wird in Dev/Staging über seine tatsächliche Adminoberfläche aufgebaut und geprüft. Die UI ist ein Konfigurationswerkzeug; Source of Truth bleiben versionierte Schema-/Configdateien und reproduzierbare Seeds/Exporte.

## Vorbedingungen

- Docker-Dienste und Healthchecks grün
- einmalige lokale Admin-Zugangsdaten ausschließlich aus Secret/Environment
- leere bzw. gesicherte Dev-Datenbank
- festgelegte Contentmodell-Reihenfolge und Role Matrix
- Tracing standardmäßig `retain-on-failure`, Video aus, Screenshots nur bei Fehler

## Aufbau in Reihenfolge

1. Admin nur anlegen, wenn Installation noch uninitialisiert ist.
2. Komponenten für Quellen, Lizenz, Organbild, Merkmal, Regel und Lokalisierung anlegen.
3. Collections: PlantTaxon → PlantContent/Media → Ecosystem → QuizItem → FieldTask → Level → SystemSetting → ContentRelease.
4. i18n, Draft/Publish, projektseitigen Reviewstatus und Relationsregeln aktivieren.
5. Rollen Redaktion, Botanical Review, Organisationsadmin und Systemadmin minimal berechtigen.
6. Seed mit fünf Pflanzen, einem Ökosystem, einem Level und allen Quiztypen importieren.
7. Entwurf→Review→Publish und blockierte Invalidfälle durchspielen.
8. generierte Schema-/Configdateien sowie bereinigten Export sichern und diffen.
9. Umgebung leeren, nur aus Repository/Export neu aufbauen und Smoke wiederholen.

## Selektoren und Idempotenz

`getByRole`, `getByLabel` und sichtbare eindeutige Namen vor CSS/nth-child. Jeder Schritt prüft zuerst den Istzustand; vorhandene identische Objekte werden validiert statt dupliziert. Zufällige Namen werden nur für isolierte Testdaten verwendet.

## Muss-Smokes

- Redakteur darf Entwurf, aber keine fachliche Endfreigabe
- Reviewer kann freigeben, aber keine Systemrollen ändern
- unvollständige Taxonomie/Lizenz/Quizlösung/Levelregel blockiert Publish
- viertes Level erscheint nach Release ohne App-Build
- Draft bleibt in App-API unsichtbar
- Audit enthält Akteur/Aktion/Objekt, aber keine unnötigen sensiblen Inhalte

## Verboten

Produktion per UI konfigurieren, echte Nutzerdaten verwenden, Adminpasswort in Code/Trace schreiben, blind `waitForTimeout` nutzen oder UI-Zustand ohne Export als erledigt melden.

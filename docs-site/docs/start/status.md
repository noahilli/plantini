# Projektstatus und Rechte

Bevor du Zeit in Plantini investierst, solltest du wissen, in welchem Zustand das Projekt ist und wem was gehört.
Diese Seite sagt es deutlich.

!!! note "Kurz"
    Plantini ist **Open Source**: Code unter AGPL-3.0-or-later (`LICENSE`), Lerninhalte unter CC BY-SA 4.0. Beiträge sind willkommen, siehe `CONTRIBUTING.md`.

## Was gesagt werden muss

| Aussage | Bedeutung für dich |
|---|---|
| **Die Idee stammt von einer dritten Person**, die der Veröffentlichung als Open Source zugestimmt hat. Urheber des Codes ist Noah Illmann. | Inhaltliche Grundsatzentscheidungen werden mit der Ideengeberin bzw. dem Ideengeber abgestimmt. Die Unterlagen unter `knowledge/references/` stehen **nicht** unter den Projektlizenzen. |
| **Früher Stand** – Website, Web-App und Android-Testversion sind unvollständig. | Es gibt keine Store-Version und keine Garantie, dass Funktionen so bleiben, wie sie jetzt sind. |
| **Kein kommerzieller Hintergrund**; es wurden und werden **weder Spenden noch Zahlungen** angenommen. | Preisseiten und Planungen auf der Homepage sind vorläufig und rechtlich unverbindlich. |
| **Copyleft:** AGPL-3.0-or-later für Code, CC BY-SA 4.0 für Inhalte. | Änderungen, die du weitergibst oder als Dienst betreibst, müssen ebenfalls offen sein. |

## Wie ausgereift ist der Code?

Ehrlich eingeordnet (Stand November 2026):

- **Läuft produktiv auf einem Server** (Website, Web-App, API, Anmeldung, Studio, Portal, Android-Direktdownload).
- **Demo-Inhalte:** 30 Arten, 3 Ökosysteme, 90 Level, 270 Quizfragen – synthetisch und **botanisch noch nicht freigegeben**.
- **Studio:** Entwürfe und fachliche Freigabe funktionieren; **Veröffentlichung ist bewusst noch deaktiviert**
  (siehe [Inhalte und Releases](../backend/inhalte-releases.md)).
- **Tests:** Backend grün (4 Redis-Tests werden ohne Redis übersprungen), im Flutter-Teil scheitern 13 Tests schon seit
  vor den jüngsten Änderungen (`TEST-01` in `todos.md`).
- **Pflanzenbestimmung** ist in der Testumgebung gemockt; echte Pl@ntNet-Antworten sind nur eingeschränkt geprüft.
- **Backups:** nächtlich, aber nur auf demselben Server; keine Offsite-Kopie, Wiederherstellung nicht geübt.
- **Mobile:** Android wurde nur auf einem x86-Emulator und mit einem Wegwerf-Konto geprüft; iOS ist nicht gebaut.

## Datenschutz in einem Satz

Daten werden an niemanden weitergegeben und bleiben auf dem eigenen Server – mit einer Ausnahme: Fotos, die zur
Bestimmung hochgeladen werden, übermittelt der Server an Pl@ntNet. Siehe [Sicherheit und Datenschutz](../architektur/sicherheit-datenschutz.md).

# Projektstatus und Rechte

Bevor du Zeit in Plantini investierst, solltest du wissen, in welchem Zustand das Projekt ist und wem was gehört.
Diese Seite sagt es deutlich.

!!! warning "Wichtig"
    Plantini ist **kein Open-Source-Projekt**. Der Quellcode ist nicht zur freien Weiterverwendung veröffentlicht.
    Mitarbeit ist nach Absprache möglich; schreib vorher an [noah@illmann.net](mailto:noah@illmann.net).

## Was gesagt werden muss

| Aussage | Bedeutung für dich |
|---|---|
| **Die Ideen stammen von einer dritten Person**, nicht vom Entwickler. | Konzept, Lerninhalte und Produktidee gehören nicht dem Entwickler allein. Inhaltliche Entscheidungen werden mit der Ideengeberin bzw. dem Ideengeber abgestimmt. |
| **Die App ist noch nicht veröffentlicht** – Website und Testversion sind ein unvollständiger Teaser. | Es gibt keine Store-Version und keine Garantie, dass Funktionen so bleiben, wie sie jetzt sind. |
| **Kein kommerzieller Hintergrund**; es wurden und werden **weder Spenden noch Zahlungen** angenommen. | Preisseiten und Planungen auf der Homepage sind vorläufig und rechtlich unverbindlich. |
| **Nicht Open Source**, weil die Rechte nicht beim Entwickler liegen. | Du bekommst durch Zugriff auf das Repository keine Nutzungs-, Änderungs- oder Weitergaberechte. Kläre vor einem Beitrag, unter welchen Bedingungen er verwendet werden darf. |

## Widerspruch im Repository

Im Repository liegen eine `LICENSE`-Datei (Apache License 2.0), ein `NOTICE` („Open Source Plant Identification
& Learning Platform“) und ein Lizenzfeld in `contracts/api.yaml` (`license: Apache-2.0`). Diese Angaben stammen aus der
Frühphase des Projekts und **stimmen nicht mit dem oben beschriebenen Rechtsstand überein**. Bis das geklärt und
bereinigt ist, sind sie nicht maßgeblich. Das ist ein offener Punkt, kein Versehen deiner Arbeit.

## Wie ausgereift ist der Code?

Ehrlich eingeordnet (Stand Oktober 2026):

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

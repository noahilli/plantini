## Was und warum

<!-- Kurz: was ändert sich, welches Problem wird gelöst? -->

Aufgabe / Issue: <!-- z. B. AUTH-06 oder #123 -->

## Wie geprüft

<!-- Welche Befehle sind gelaufen, was wurde von Hand ausprobiert? Nur behaupten, was wirklich gelaufen ist. -->

## Prüfliste

- [ ] Commit-Nachrichten im Format `<präfix> (<ID>) <beschreibung>` und mit `Signed-off-by` (`git commit -s`)
- [ ] Betroffene Prüfungen lokal grün (`flutter analyze`, `flutter test`, `npm test`, Validatoren – je nach Änderung)
- [ ] Bei Änderung an `contracts/api.yaml`: Client neu erzeugt (`tools/scripts/generate-api-client.sh`)
- [ ] Doku / Handbuch angepasst, falls sich Verhalten, Befehle oder Konfiguration ändern
- [ ] Keine Secrets, echten Nutzerdaten oder genauen Fundorte (auch nicht in Tests, Fixtures oder Screenshots)
- [ ] Neue Fotos, Texte oder Modelle haben Urheber, Quelle und eine kompatible Lizenz

## Screenshots

<!-- Bei sichtbaren Änderungen: vorher / nachher -->

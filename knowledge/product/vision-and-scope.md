# Vision und Scope

Plantini verbindet Artenbildung, reale Naturerfahrung und wissenschaftlich nachvollziehbare Lerninhalte. Die App richtet sich zunächst an junge Menschen und Bildungseinrichtungen im deutschsprachigen Raum, soll aber Regionen, Sprachen, Taxonomien und Rechtsinformationen vollständig datengetrieben erweitern können.

## Kernreise

Lernende wählen ein Ökosystem und Level, lernen kuratierte Pflanzen, üben mit Quizmodi, erfüllen eine Feldaufgabe, fotografieren eine Pflanze, erhalten einen probabilistischen PlantNet-Abgleich und speichern einen bestätigten Fund privat im Herbarium.

## MVP

- Flutter-App für Android, iOS und Web
- drei Ökosysteme und drei aufeinander aufbauende Level
- 25/50/75 Arten gemäß noch freizugebender Zähllogik
- Steckbriefe, Bilder, Merkmale und mehrere Quizmodi
- Fortschritt, Wiederholung, Erfolge und Levelabschluss
- Foto, optionaler Standort, PlantNet-Abgleich und persönliches Herbarium
- Offline-Inhalte, Offline-Fortschritt, Queue und Konfliktbehandlung
- klassischer Login, Google, Apple und erweiterbares Hochschul-/Schul-SSO
- vollständige dynamische Administration, Rollen, Review/Publish und Dashboard
- Open-Source-Code, Dokumentation, Tests, GitLab CI/CD und reproduzierbarer Betrieb

## Nicht-Ziele im MVP

- soziales Netzwerk, öffentlicher Fundort-Feed oder kompetitive Ranglisten
- rechtlich oder sicherheitskritisch garantierte Artenbestimmung
- automatische Veröffentlichung generierter, ungeprüfter Inhalte
- vollständige Citizen-Science-Publikation an GBIF
- universeller Multi-Tenant-SaaS-Marktplatz
- mehrere Identifikationsprovider im MVP; die Adaptergrenze wird dennoch vorbereitet

## Produktprinzipien

1. Lernen vor Technikshow: Jede Funktion muss einen Lern- oder Feldnutzen haben.
2. Unsicherheit ehrlich erklären: Ein Score ist keine botanische Gewissheit.
3. Offline zuerst: Naturorte sind nicht zuverlässig vernetzt.
4. Privat standardmäßig: Fotos und genaue Fundorte gehören den Nutzenden.
5. Inhalt ohne App-Release: Ökosysteme, Level und Arten bleiben CMS-gesteuert.
6. Offen entwickeln, geschützt betreiben: Quellcode offen; Produktionsdaten und Zugänge strikt getrennt.

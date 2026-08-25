# Plantini – Canva-Sourcen der App-Screenkonzepte

Stand: 19. Juli 2026

Die Version 2.0 fasst alle sechs Kernansichten in **einem gemeinsamen Screenboard** zusammen. App-Shell, Navigation, Raster, Typografie, Farben, Karten, Chips, Statusanzeigen und Interaktionsmuster stammen aus demselben System. Verbindlich bleiben die im Anforderungsdokument beschriebenen Inhalte, Zustände, Berechtigungen und Akzeptanzkriterien.

## Designsystem

- Waldgrün: `#2F5D50`
- Salbeigrün: `#6D8B74`
- Moos: `#98A886`
- Creme: `#F7F4EC`
- Beige: `#E8E0D0`
- Sand: `#D9C7A3`
- Rindenbraun: `#7A563A`
- Dunkler Text: `#26332F`
- Ziel: jugendlich, hochwertig, naturverbunden, wissenschaftlich seriös und barrierearm

## Aktuelle bearbeitbare Quelle · Version 2.0

| Inhalt | Canva-ID | Bearbeiten | Ansicht |
|---|---|---|---|
| Einheitliches Plantini-App-System mit Home, Forscherpfad, Pflanzensteckbrief, Quiz, Expedition und Herbarium | `DAHP2Hxm-Bo` | [Screenboard in Canva bearbeiten](https://www.canva.com/d/a176LrI0sc6nkWR) | [Screenboard ansehen](https://www.canva.com/d/-BRKL8MG50Gfh56) |

Die ergänzende Datei `Plantini_Screens_v2.html` ist die offene und deterministisch reproduzierbare Designsystem-Quelle. Sie enthält exakte Farben, Größen, Komponenten und Beispielinhalte und kann unabhängig von Canva versioniert werden.

## Zugehörige Exporte · Version 2.0

- `assets/canva/Plantini_Screens_v2_Full.png` – gesamtes Screenboard
- `assets/canva/Plantini_Screens_v2_Lernen.png` – Home, Forscherpfad und Steckbrief
- `assets/canva/Plantini_Screens_v2_Expedition.png` – Quiz, Expedition und Herbarium
- `assets/canva/Plantini_Screens_v2_Full.pdf` – vektorbasierter Board-Export

## Archiv · Einzeldesigns Version 1.0

| Nr. | Screen | Canva-ID | Bearbeiten | Ansicht |
|---:|---|---|---|---|
| 01 | Home / Lernübersicht | `DAHP1yXSXBY` | [Canva öffnen](https://www.canva.com/d/kPF3p1TtDwp-0gx) | [Ansicht](https://www.canva.com/d/eL1_eREp3uuHyEL) |
| 02 | Wald / Levelübersicht | `DAHP18zYBYw` | [Canva öffnen](https://www.canva.com/d/jD5BKI2LXe0Jfbh) | [Ansicht](https://www.canva.com/d/N-k06nYl7PsLqOY) |
| 03 | Pflanzensteckbrief | `DAHP1yOrFvI` | [Canva öffnen](https://www.canva.com/d/hcKuSkzCaFLQS0A) | [Ansicht](https://www.canva.com/d/iiDRCzYObuGi2uE) |
| 04 | Quiz | `DAHP18lncl0` | [Canva öffnen](https://www.canva.com/d/TPLugDGG9ea7aCY) | [Ansicht](https://www.canva.com/d/koQFH_VURKUSrJl) |
| 05 | Expedition / Kamera | `DAHP1_48bpQ` | [Canva öffnen](https://www.canva.com/d/pK_y7j4Z3aD32bc) | [Ansicht](https://www.canva.com/d/B3BQ9XonCJYWYrX) |
| 06 | Herbariumdetail | `DAHP1wNVpWA` | [Canva öffnen](https://www.canva.com/d/P9y8zxF7ld-bZ42) | [Ansicht](https://www.canva.com/d/8tyuRrShsBQpbLJ) |

### Zugehörige Archiv-Exporte

- `assets/canva/Plantini_Screen_01_Home.png`
- `assets/canva/Plantini_Screen_02_Level.png`
- `assets/canva/Plantini_Screen_03_Steckbrief.png`
- `assets/canva/Plantini_Screen_04_Quiz.png`
- `assets/canva/Plantini_Screen_05_Expedition.png`
- `assets/canva/Plantini_Screen_06_Herbarium.png`

## Umsetzungshinweise

1. Navigation, Zustandslogik und Inhalte werden aus den Anforderungen und nicht aus zufälligen Details der Konzeptgrafik abgeleitet.
2. Das Screenboard v2 ist die gemeinsame UI-Kit-Referenz. Flutter-Komponenten werden daraus als wiederverwendbare Tokens und Varianten abgeleitet, nicht pro Screen neu gebaut.
3. Für jede Ansicht sind zusätzlich Loading-, Empty-, Offline-, Fehler-, gesperrte und große-Schrift-Zustände zu spezifizieren.
4. Botanische Bilder im Produkt benötigen vollständige Quellen-, Lizenz- und Alternativtextangaben.
5. Genaue Fundorte und persönliche Fotos sind privat; Konzeptgrafiken dürfen keine realen Nutzerdaten enthalten.

# Backend, CMS und Content-Grenzen

## Entscheidung

Strapi Community Edition übernimmt Content Types, Medienmetadaten, Internationalisierung, Draft/Publish und das Admin-UI. Der mehrstufige botanisch-didaktische Review wird projektseitig über Statusfelder, Policies und Validatoren umgesetzt, sofern die konkret gepinnte Strapi-Ausgabe keinen geeigneten offenen Workflow liefert. Keycloak übernimmt Identität und SSO. Eine projektspezifische Fach-API kapselt Sync, Fortschritt, Levelabschluss, Herbarium, PlantNet und Datenschutz.

## Strapi-Inhaltsmodell

| Collection/Component | Zweck | Veröffentlichung |
|---|---|---|
| `ecosystem` | Region, Saison, Beschreibung, Medien, Reihenfolge | Draft/Review/Publish |
| `level` | Lernziel, Schwierigkeit, Arten, Regeln, Quizmix, Feldaufgaben | nur validiert |
| `plant-taxon` | stabile ID, wissenschaftlicher Name, Synonyme, externe IDs | fachliches Review |
| `plant-content` | Locale, Namen, Merkmale, Ökologie, Warnungen, Quellen | je Locale geprüft |
| `quiz-item` | Typ, Prompt, Lösung, Erklärung, Distraktoren, Kompetenz | didaktisch+fachlich geprüft |
| `field-task` | Zielarten, Sicherheit, Nachweis- und Standortregeln | mit Level releasebar |
| `media-metadata` | Organ, Alt-Text, Urheber, Quelle, Lizenz, Region | Pflichtfelder vollständig |
| `system-setting` | nicht geheime Schwellwerte, Flora, Locale, Feature Flags | versioniert/auditiert |
| `content-release` | Manifest, Prüfsummen, Mindestversion, Rückzug | atomar |

## Nicht im CMS

UserProfile, Consent, LearningEvent, Progress, Observation, IdentificationJob und personenbezogene Auditdaten gehören zur Fach-API/-DB. Das verhindert, dass redaktionelle Rollen private Lern- oder Funddaten sehen.

## Fach-API

Die API beginnt als klar abgegrenzte Strapi-Erweiterung oder schlanker TypeScript-Service. Unabhängig vom Prozesszuschnitt gelten:

- `/api/v1`, OpenAPI 3.1 und stabile Fehlercodes
- OIDC Access Token; serverseitige Autorisierung
- `Idempotency-Key`/Client-ID bei Offline-Writes
- Cursor-Sync, ETags, Löschmarken und Basisversionen
- Queue für Provider-, Medien-, Import-, Export- und Löschjobs
- keine Weitergabe generischer Strapi-Datenmodelle an Flutter

## Publish-Gate

Ein Release scheitert bei fehlenden Taxon-IDs, Quellen, Bildlizenzen/Alt-Texten, Übersetzungs-Pflichttexten, Quizlösungen, zyklischen Levelregeln oder Pflichtwarnungen. Playwright prüft das Admin-Verhalten; serverseitige Validatoren bleiben die Autorität.

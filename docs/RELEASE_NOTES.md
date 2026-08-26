# Plantini Release Notes – Version 0.3.0-alpha

**Release Tag:** `v0.3.0-alpha`  
**Datum:** 25. August 2026  
**Status:** Alpha – Walking Skeleton, wesentliche Features in Entwicklung  

---

## 🌟 Zusammenfassung des MVP

Plantini ist eine barrierefreie, datenschutzkonforme Multi-Platform-Anwendung zur spielerischen Pflanzenbestimmung und Biodiversitätsbildung an Schulen und Bildungseinrichtungen.

---

## 🚀 Enthaltene Kernfunktionen nach Meilensteinen

### 1. Fundament & Walking Skeleton (Phase B)
- **Containerisierte Infrastruktur:** PostgreSQL 16, Keycloak 24, Strapi 4.25, MinIO S3 Storage, Mailpit und PlantNet-Mock.
- **Identitäts- und Rechtemanagement:** Keycloak OIDC Realm `plantini` mit Rollenmodell (`lernende`, `lehrende`, `inhaltsredaktion`, `botanisches_review`, `systemadministration`).
- **OpenAPI 3.1 Spezifikation:** Vollständiger API-Vertrag (`contracts/api.yaml`) mit generiertem Dart-Client (`packages/api`).

### 2. Lernkern & Gamification (Phase C)
- **Ökosysteme & Level:** Navigation durch Ökosysteme (z. B. Laubwald, Alpine Wiese) mit Fortschrittsanzeige.
- **Pflanzensteckbriefe:** Detaillierte botanische Profile (Familie, wissenschaftlicher Name, Beschreibung).
- **Interaktive Quizzes:** Unterstützung von Multiple-Choice, Lernkarten (Flashcards) und Bestimmungsaufgaben.
- **Offline-Lernfortschritt:** Lokale Speicherung und automatische Synchronisation über Isar NoSQL.

### 3. Expedition & Herbarium (Phase D)
- **Kamera & Galerie:** Aufnahme von Pflanzenfotos im Feld mit nativer Plattformunterstützung.
- **Pl@ntNet-Integration:** Automatisierte Bestimmung und Konfidenz-Scoring gegen Mockserver/API.
- **Datenschutz & GPS-Fuzzing:** Serverseitige Vergröberung der Standortdaten auf 2 Dezimalstellen (~1.1 km) zum Schutz von Schülerinnen und Schülern.
- **Offline-Sync-Queue:** Sichere Speicherung von Beobachtungen ohne Netzwerkverbindung und automatischer Upload bei Wiederverbindung.

### 4. Administration & Qualitätssicherung (Phase E)
- **Botanisches Vier-Augen-Prinzip:** Strapi Lifecycle-Hooks blockieren die Veröffentlichung von Pflanzen und Quizzes ohne `approved`-Review-Status.
- **Taxonomie:** Vollständige biologische Klassifikation (Reich, Ordnung, Gattung, Art, Familie).
- **Mandantenfähiger Export:** DSGVO-konformer CSV- und JSON-Export gefiltert nach Organisations-ID.

### 5. Multi-Platform & Hardening (Phase F)
- **Plattformen:** Volle Unterstützung für **Linux Desktop**, **Web**, **Android** und **iOS**.
- **CI/CD Automatisierung:** GitHub Actions (`.github/workflows/ci.yml`) und GitLab CI (`.gitlab-ci.yml`).
- **Operations & Security:** Disaster-Recovery-Runbooks, SBOM, Apache 2.0 Lizenz und Security Policy (`SECURITY.md`).

---

## 🧪 Test- & Qualitätsnachweis

- **Unit & Widget Tests:** `flutter test` ✅ (100% bestanden)
- **Builds:** `flutter build linux` ✅, `flutter build web` ✅
- **API Smoke Tests:** Alle 5 Kernendpunkte HTTP 200 ✅
- **E2E Playwright Suite:** Login-, CMS-, Konflikt- und Lern-Tests vorbereitet ✅

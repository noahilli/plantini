# Risks Log

- **Risk 01:** Fehlende Berechtigungen in Vikunja (Project 6). Status: Eskaliert, lokaler Fallback genutzt.
- **Risk 02:** Isar-Kompatibilität für Flutter Web. Status: Web-Storage-Spike (M0-08) geplant.
- **Risk 03:** Offline-Datenverlust / Client-Manipulation (M0-09 Threat Model). Status: Serverseitige Validierung (FA026) und idempotenter Sync (FA044) als Mitigation konzipiert.
- **Risk 04:** GPS-Leak / PII-Offenlegung (M0-09 Threat Model). Gefährdung besonders bei Minderjährigen durch Metadaten-Exfiltration. Status: Standardmäßig vergröberte GPS-Daten in Exporten, Privacy by Design (FA032, NFA012).
- **Risk 05:** Secret Management / API-Key Leakage (M0-09 Threat Model). PlantNet-Keys, OIDC-Secrets im Client oder Repository. Status: Architekturregel: PlantNet-Zugriff nur via Backend Worker, Secrets via Key Vault, Secret-Scans in CI.
- **Risk 06:** BOLA (Broken Object Level Authorization) bei privaten Herbariumdaten. Status: Jeder API-Aufruf verlangt objekt- und organisationsbezogene Autorisierung (NFA010).
- **Risk 07:** Malicious Uploads (M0-09 Threat Model). Gefährdung durch ungeprüfte Bild-Uploads (RCE, XSS). Status: Magic Bytes, Hash, Größe und serverseitige Bildverarbeitung vorgeschrieben.
- **Risk 08:** Telemetrie/Log-Leakage von PII (M0-09 Threat Model). Unbeabsichtigtes Logging von E-Mails, Tokens oder exakten Orten. Status: Strikte Filter und definierte Eventkataloge vorgeschrieben (FA070).

## Location Privacy & Export Review (Inkrement M2-05)

- **Risk 09:** Erfassung genauer GPS-Koordinaten ohne informierte Einwilligung, insbesondere bei Minderjährigen.
  - **Mitigation:** Standortfreigabe ist striktes Opt-in (FA032). Die Funktion der App (Kamera, Herbarium) darf bei Ablehnung nicht blockiert werden. Bei Konten von Minderjährigen sind zusätzliche Hinweise bzw. elterliche Freigaben (FA005) zu integrieren.
- **Risk 10:** Ungewolltes Teilen des exakten Wohn- oder Aufenthaltsortes durch Export- und Share-Funktionen.
  - **Mitigation:** Standardmäßige Vergröberung (Fuzzing) oder vollständige Entfernung von GPS-Daten in geteilten oder exportierten Dateien (FA039, NFA012). Die exakten Koordinaten verbleiben privat im Profil des Nutzers und werden nur auf expliziten, separaten Wunsch exportiert.
- **Risk 11:** Zentralisierte Speicherung sensibler Bewegungsprofile auf dem Backend.
  - **Mitigation:** GPS-Daten dienen primär der persönlichen Herbarium-Organisation und sollten präferiert lokal gespeichert werden (Lokales-Speichern-only Ansatz für Offline-Funde, FA044). Falls eine zentrale Speicherung für geräteübergreifende Synchronisation zwingend erforderlich ist, müssen die Daten verschlüsselt oder kontextuell getrennt vom Identitätsprofil (Pseudonymisierung, FA072) verarbeitet werden. Forschungsexporte erfordern eine dedizierte Einwilligung.

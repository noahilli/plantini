# MVP-Grenzen und offene Entscheidungen

Offene Punkte sind echte Gates. Ein Agent darf daraus keine verdeckte Architekturentscheidung machen.

| ID | Frage | Vorläufige Arbeitsannahme | Entscheider | Gate |
|---|---|---|---|---|
| OQ-01 | Bedeutet 25/50/75 Arten global kumulativ oder je Ökosystem? | Architektur unterstützt beides; Seed, Budget und Contentplanung rechnen bis Freigabe mit 75 eindeutigen Arten. | Product Manager + Scientific Board | vor vollständigem Content-Import |
| OQ-02 | Ist Isar auf Web produktionsreif genug? | Mobile: Isar. Web: Persistenzport; Spike gegen aktuelle Zielbrowser, sonst IndexedDB/Drift-WASM. | Orchestrator + Flutter Lead | Gate A |
| OQ-03 | Liegt die Fach-API als Strapi-Erweiterung oder separater TypeScript-Service vor? | Mit dünnen Strapi-Custom-Routes starten; nach Sync-/Worker-Spike entscheiden. | Orchestrator + Backend Lead | Gate A |
| OQ-04 | Welche Altersgruppen und Einwilligungsregeln gelten? | Keine öffentliche Profile/Fundorte; Forschungseinwilligung getrennt; genaue Regeln blockieren Pilot. | Product + Datenschutz/Recht | vor externem Pilot |
| OQ-05 | Welches PlantNet-Kontingent und welche Flora gelten? | Mock in Entwicklung; echter Dienst erst nach Vertrag, Quote und Attribution. | Product + Backend + Betrieb | vor Feldpilot |
| OQ-06 | Wie weit reicht Organisationsisolierung im MVP? | Rollen- und Berichtsscope, kein vollständiger SaaS-Mandant. | Product + Auth + Backend | vor Admin-Implementierung |
| OQ-07 | Welche Open-Source-/Contentlizenzen werden final verwendet? | Apache-2.0 für projektspezifischen Code; CC BY 4.0 für freigegebene Texte; Assetlizenz je Medium. | Steering Committee + Recht | vor öffentlichem Repository |
| OQ-08 | Welche Google-/Apple-/Hochschul-Provider gehen produktiv? | Lokaler Test-IdP zuerst; echte Clients/Redirects erst nach Domain- und Storefreigabe. | Auth Manager + Release Manager | vor Beta |

## Änderungsregel

Eine Entscheidung aktualisiert mindestens: ADR, betroffene CSV-Zeilen, Vertrag/Schema, Tests, Betrieb und Handoff. Bei Scopeänderung rebaselined der Product Manager Termin und Aufwand.

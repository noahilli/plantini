# Schema von `features.csv`

Die CSV ist UTF-8 mit BOM, damit sie in Excel sauber geöffnet wird. Semikola innerhalb eines Feldes trennen mehrere Werte.

| Spalte | Bedeutung |
|---|---|
| `id` | stabile Requirement-ID aus dem Anforderungsdokument |
| `type` | funktional oder nichtfunktional |
| `area` | fachliches Kapitel |
| `title` | kurzer Name |
| `priority` | MUSS, SOLL oder KANN |
| `mvp_scope` | verbindliche Einordnung für Go-live/MVP |
| `description` | normative Funktions- bzw. Qualitätsbeschreibung |
| `acceptance_criteria` | mindestens nachzuweisende Abnahme |
| `cross_references` | andere Requirements, semikolongetrennt |
| `primary_role` | genau eine federführende Agentenrolle |
| `supporting_roles` | notwendige Mitwirkende/Reviewer |
| `implementation_surface` | voraussichtlich betroffene Systemteile |
| `offline_relevance` | ja, teilweise oder nein |
| `security_privacy_relevance` | hoch, mittel oder niedrig |
| `test_levels` | erwartete Prüfebenen |
| `status` | initial `planned`; Pflege durch Product Manager |
| `source` | Herkunft der Formulierung |

Erlaubte Statuswerte: `planned`, `ready`, `in_progress`, `blocked`, `review`, `done`, `deferred`. Priorität und Beschreibung dürfen nur nach dokumentierter Produktentscheidung geändert werden. `done` setzt das Abnahmekriterium und die Definition of Done voraus.

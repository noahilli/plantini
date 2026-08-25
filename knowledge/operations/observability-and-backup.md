# Observability, Backup und Wiederanlauf

## Metriken

API p50/p95/p99, Fehler/429, Authfehler, Syncdauer/-konflikte, Queuealter/-tiefe, Identifikationsstatus/Quote, DB-Latenz/Connections, Bucketwachstum, Content-Releasefehler, Export-/Löschjobs und aktive App-Versionen.

Logs sind strukturiert und enthalten Trace-ID, stabile Fehlercodes und technische IDs. Keine Tokens, E-Mails, Freitexte, Fotos oder exakten GPS-Daten.

## SLO MVP

- App-API/Admin 99,5 % monatlich ohne angekündigte Wartung
- gecachte Contentreads p95 <500 ms
- Standardwrites p95 <800 ms
- RPO ≤24 h, RTO ≤8 h

## Backup

PostgreSQL, Objektspeicher, Realm-/CMS-Konfiguration, IaC und Schlüsselmaterial getrennt sichern. Schlüsselbackups geschützt und Zugriff auditiert. Restore mindestens quartalsweise in isolierter Umgebung testen; Datenbank, referenzierte Medien, Rollen und mindestens eine Kernreise prüfen.

## Alarmfälle

Ausfall, erhöhte 5xx/401/403, Queue-Stau, PlantNet-Quote >70 %, Speicherwachstum, DB-Kapazität, Backupfehler, fehlgeschlagener Löschlauf und unerwartete Content-Release-Rückzüge.

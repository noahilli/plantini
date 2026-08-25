# Playwright E2E-Regeln

## Projekte

- `health`: Dienste, OIDC discovery, API readiness
- `cms-bootstrap`: nur explizit, serialisiert, Dev/Staging
- `auth-bootstrap`: nur explizit, serialisiert, Dev/Staging
- `web-app`: parallele Nutzerreisen der Flutter-Web-App
- `admin-smoke`: CMS-Rollen und Publishpfad
- `auth-smoke`: Login/Logout/SSO/Revocation
- `accessibility`: axe plus Tastatur-/Semantik-Smokes

## Stabilität

- keine festen Sleeps; auf sichtbaren Zustand, Response, Jobstatus oder Health warten
- isolierter Nutzer/Seed je Test; eindeutige Client-ID/Idempotency-Key
- `getByRole`/`getByLabel` bevorzugen; `data-testid` nur als bewusstes öffentliches Testinterface
- API-Seeding für Fachzustand; UI-Seeding nur wenn die UI selbst Gegenstand ist
- externe Provider ausschließlich Mock/Sandbox; PlantNet Success, Low Score, 429, Timeout und 5xx deterministisch mocken
- Traces/Videos nur bei Fehler, kurze Retention, vor Upload sanitieren

## Kernreisen

1. Registrierung/Bestätigung → Login → Logout → Sessionrestore
2. Home → Ökosystem → Level → Lernen → Quiz → Pause/Resume
3. Offline-Paket → Browser/App-Neustart → Lernen ohne Netz → späterer Sync
4. Feldauftrag → Fotoersatz → Job → unsicherer Retry → bestätigter Fund → Herbarium
5. CMS Entwurf → Review → Release → Contentdelta in App
6. Datenschutzexport und Kontolöschung ohne GPS-Leak
7. Rollen-Negativmatrix für fremde Beobachtung, Organisation, CMS und Research Export

Playwright deckt Browser-/Systemintegration ab. Native Kamera, GPS, Secure Storage, App-Links und Storeverhalten benötigen ergänzende Flutter-/Gerätetests.

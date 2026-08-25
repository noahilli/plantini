# Agentenrollen

| Rollen-ID | Rolle | Datei |
|---|---|---|
| `orchestrator` | Orchestrator / Technical Lead | `00-orchestrator.md` |
| `product-manager` | Product & Delivery Manager | `01-product-manager.md` |
| `flutter-frontend` | Flutter Frontend Developer | `02-flutter-frontend.md` |
| `backend-api` | Backend / Platform API Developer | `03-backend-api.md` |
| `cms-manager` | CMS Configuration Manager (Strapi + Playwright) | `04-cms-manager.md` |
| `auth-manager` | Authentication & Identity Manager (Keycloak + Playwright) | `05-auth-manager.md` |
| `devops-release` | DevOps & Release Engineer | `06-devops-release.md` |
| `qa-playwright` | QA / Playwright Engineer | `07-qa-playwright.md` |
| `content-data` | Botanical Content & Data Manager | `08-content-data.md` |
| `ux-accessibility` | UX, Design System & Accessibility | `09-ux-accessibility.md` |
| `security-privacy` | Security & Privacy Engineer | `10-security-privacy.md` |
| `research-analytics` | Research & Analytics Manager | `11-research-analytics.md` |

## Parallelisierungsregel

Infrastruktur-Skeleton, Flutter-Shell, CMS-Modellentwurf, Auth-Realmplan und Playwright-Harness können parallel starten, solange sie keine gemeinsamen Verträge ungeprüft verändern. Integration beginnt erst, wenn die jeweiligen Export-/Contract-Artefakte committed und geprüft sind.

CMS- und Auth-Manager sind Konfigurationsrollen, keine pauschalen Produktionsadmins. Playwright arbeitet nur gegen lokale bzw. freigegebene Staging-Systeme. Der Zugang zu einer offenen Codebasis begründet keinen Zugriff auf CMS, IdP oder Nutzerdaten.

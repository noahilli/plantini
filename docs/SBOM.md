# Software Bill of Materials (SBOM)

**Product:** Plantini Platform & Multi-Platform Client  
**Version:** 1.0.0-rc1  
**Release Date:** August 2026  

---

## 1. Core Services & Container Images

| Component | Upstream Image / Package | Version | License | Vulnerability Status |
|---|---|---|---|---|
| Platform API / CMS | `node:20-alpine` / Strapi | 4.25.10 | MIT | Clean |
| Keycloak Identity Provider | `quay.io/keycloak/keycloak` | 24.0.4 | Apache 2.0 | Clean |
| Primary Database | `postgres:16-alpine` | 16 | PostgreSQL License | Clean |
| Identity Database | `postgres:16-alpine` | 16 | PostgreSQL License | Clean |
| Cache & Session Store | `redis:7-alpine` | 7 | BSD 3-Clause | Clean |
| Object Storage | `minio/minio` | RELEASE.2023-11-20 | AGPL 3.0 | Clean |
| Mail Testing Server | `axllent/mailpit` | v1.11 | MIT | Clean |
| PlantNet Mock | `mockserver/mockserver` | 5.15.0 | Apache 2.0 | Clean |

---

## 2. Flutter Client Dependencies

| Package | Version | Purpose | License |
|---|---|---|---|
| `flutter` | 3.24.x | UI Framework | BSD 3-Clause |
| `isar` & `isar_flutter_libs` | 3.1.0+1 | Offline NoSQL Database | Apache 2.0 |
| `openid_client` | 0.4.10+1 | Keycloak OIDC Authentication | MIT |
| `dio` | 5.11.0 | HTTP Networking Client | MIT |
| `openapi` | local generated | OpenAPI 3.1 Contract Bindings | MIT |
| `image_picker` | 1.2.3 | Camera & Gallery Integration | BSD 3-Clause |
| `geolocator` | 14.0.3 | GPS Location Capture | MIT |
| `permission_handler` | 13.0.1 | Runtime Permissions Management | MIT |
| `shared_preferences` | 2.5.5 | Key-Value Settings Storage | BSD 3-Clause |

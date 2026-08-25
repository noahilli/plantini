# Security Policy & Privacy Guidelines

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

The Plantini team takes the security of educational and student data very seriously.
If you discover a security vulnerability or privacy leak, please do **not** open a public issue.

Instead, please send an encrypted email with details to:
**security@plantini.de**

Include:
- Type of issue (e.g., location precision leak, authentication bypass, data isolation failure)
- Steps to reproduce the issue
- Affected components (Mobile App, Strapi Platform, Keycloak Realm)

We will acknowledge receipt within 48 hours and provide a timeline for triage and resolution.

## Privacy by Design Architecture

1. **GPS Fuzzing**: GPS coordinates for minors are strictly rounded to 2 decimal places (~1.1 km precision) on the server side to protect student privacy.
2. **Tenant & Data Isolation**: All observations and school progress data are scoped to the organization ID.
3. **Secret Hygiene**: Real production secrets must never be committed to source control; use environment variables and Secret Management (Vault / Doppler).

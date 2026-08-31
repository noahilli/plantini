import { randomBytes } from 'node:crypto';
import { mkdir, writeFile } from 'node:fs/promises';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const scriptDirectory = dirname(fileURLToPath(import.meta.url));
const e2eDirectory = resolve(scriptDirectory, '..');
const outputDirectory = resolve(e2eDirectory, '.runtime');
const outputPath = resolve(outputDirectory, 'e2e.env');

const secret = (bytes = 32) => randomBytes(bytes).toString('base64url');
const values = {
  E2E_PLATFORM_DB_PASSWORD: secret(),
  E2E_KEYCLOAK_DB_PASSWORD: secret(),
  E2E_KEYCLOAK_ADMIN_USERNAME: 'plantini-e2e-admin',
  E2E_KEYCLOAK_ADMIN_PASSWORD: `Aa1!${secret(30)}`,
  // The realm has registrationEmailAsUsername enabled, so tests must use the
  // email address as the browser login identifier.
  E2E_USERNAME: 'e2e-learner@plantini.test',
  E2E_USER_PASSWORD: `Aa1!${secret(30)}`,
  E2E_USER_EMAIL: 'e2e-learner@plantini.test',
  E2E_STRAPI_APP_KEYS: [secret(), secret(), secret(), secret()].join(','),
  E2E_STRAPI_API_TOKEN_SALT: secret(),
  E2E_STRAPI_ADMIN_JWT_SECRET: secret(),
  E2E_STRAPI_TRANSFER_TOKEN_SALT: secret(),
  E2E_STRAPI_JWT_SECRET: secret(),
  E2E_PLANTNET_MODE: 'success',
  PLANTINI_E2E_APP_URL: 'http://127.0.0.1:3000',
  PLANTINI_E2E_API_URL: 'http://127.0.0.1:1338/api/v1',
  PLANTINI_E2E_OIDC_ISSUER_URL: 'http://127.0.0.1:8082/realms/plantini',
  PLANTINI_E2E_READINESS_URL: 'http://127.0.0.1:1338/api/v1/health',
  PLANTINI_E2E_CAPTURE_FAILURE_ARTIFACTS: 'true',
  PLAYWRIGHT_TEST_RESULTS_DIR: '.runtime/test-results',
  PLAYWRIGHT_HTML_REPORT_DIR: '.runtime/playwright-report',
  PLAYWRIGHT_JUNIT_OUTPUT: '.runtime/test-results/junit.xml',
};

await mkdir(outputDirectory, { recursive: true, mode: 0o700 });
await writeFile(
  outputPath,
  `${Object.entries(values).map(([key, value]) => `${key}=${value}`).join('\n')}\n`,
  { encoding: 'utf8', mode: 0o600 },
);
console.log(`Prepared ephemeral Plantini E2E environment at ${outputPath}`);

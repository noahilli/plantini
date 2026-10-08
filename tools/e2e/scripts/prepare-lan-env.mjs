// Generates the secrets of the LAN demo stack into tools/e2e/.runtime/lan/ (ignored):
// lan.env for docker compose and a copy of the realm that also allows the LAN address.
// Usage: node prepare-lan-env.mjs <lan-host> [demo-user-password]
// An existing lan.env is kept (so the demo user and its password stay stable)
// unless the host changed.
import { randomBytes } from 'node:crypto';
import { mkdir, readFile, writeFile } from 'node:fs/promises';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const [host, givenPassword] = process.argv.slice(2);
if (!/^\d{1,3}(\.\d{1,3}){3}$/.test(host || '')) throw new Error('Usage: prepare-lan-env.mjs <IPv4 address of this computer> [password]');
const here = dirname(fileURLToPath(import.meta.url));
const dir = resolve(here, '../.runtime/lan');
const envPath = resolve(dir, 'lan.env');
await mkdir(resolve(dir, 'realm'), { recursive: true, mode: 0o700 });

const secret = (bytes = 32) => randomBytes(bytes).toString('base64url');
let previous = '';
try { previous = await readFile(envPath, 'utf8'); } catch { /* first run */ }
if (!previous.includes(`LAN_HOST=${host}\n`)) {
  const values = {
    LAN_HOST: host,
    LAN_REALM_DIR: resolve(dir, 'realm'),
    E2E_PLATFORM_DB_PASSWORD: secret(),
    E2E_KEYCLOAK_DB_PASSWORD: secret(),
    E2E_KEYCLOAK_ADMIN_USERNAME: 'plantini-lan-admin',
    E2E_KEYCLOAK_ADMIN_PASSWORD: `Aa1!${secret(30)}`,
    E2E_USERNAME: 'demo@plantini.test',
    E2E_USER_PASSWORD: givenPassword || `Aa1!${secret(14)}`,
    E2E_USER_EMAIL: 'demo@plantini.test',
    E2E_STRAPI_APP_KEYS: [secret(), secret(), secret(), secret()].join(','),
    E2E_STRAPI_API_TOKEN_SALT: secret(),
    E2E_STRAPI_ADMIN_JWT_SECRET: secret(),
    E2E_STRAPI_TRANSFER_TOKEN_SALT: secret(),
    E2E_STRAPI_JWT_SECRET: secret(),
    E2E_PLANTNET_MODE: 'success',
  };
  await writeFile(envPath, `${Object.entries(values).map(([k, v]) => `${k}=${v}`).join('\n')}\n`, { mode: 0o600 });
}

// The web client of the realm lists http://127.0.0.1:3000; the LAN copy lists the LAN origin instead.
const realm = await readFile(resolve(here, '../../../services/identity/realm/plantini-realm.json'), 'utf8');
await writeFile(resolve(dir, 'realm/plantini-realm.json'), realm.replaceAll('http://127.0.0.1:3000', `http://${host}:3100`), { mode: 0o600 });
console.log(`LAN demo environment prepared in ${dir}`);

import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import test from 'node:test';

import { sanitizeRealmExport } from '../scripts/sanitize-realm-export.mjs';
import { validateRealmSecurity } from '../scripts/validate-realm-security.mjs';

const realmPath = fileURLToPath(new URL('../realm/plantini-realm.json', import.meta.url));
const realm = JSON.parse(readFileSync(realmPath, 'utf8'));

test('the committed development realm passes its security baseline', () => {
  assert.deepEqual(validateRealmSecurity(realm), []);
});

test('a wildcard redirect is rejected', () => {
  const mutated = structuredClone(realm);
  const client = mutated.clients.find((item) => item.clientId === 'plantini-web-dev');
  client.redirectUris = ['*'];

  assert.match(
    validateRealmSecurity(mutated).join('\n'),
    /plantini-web-dev: wildcard redirect URI or web origin is forbidden/,
  );
});

test('a direct access grant is rejected', () => {
  const mutated = structuredClone(realm);
  mutated.clients.find((item) => item.clientId === 'plantini-api').directAccessGrantsEnabled = true;

  assert.match(
    validateRealmSecurity(mutated).join('\n'),
    /plantini-api: Direct Access Grants must be disabled/,
  );
});

test('the production gate refuses the development-only realm', () => {
  assert.match(
    validateRealmSecurity(realm, { environment: 'production' }).join('\n'),
    /production promotion requires sslRequired=all/,
  );
});

test('realm sanitization removes users, generated keys, and client secrets', () => {
  const source = {
    users: [{ username: 'synthetic-user', credentials: [{ secretData: 'do-not-commit' }] }],
    components: {
      'org.keycloak.keys.KeyProvider': [{ config: { privateKey: ['do-not-commit'] } }],
    },
    clients: [{ clientId: 'client', secret: 'do-not-commit' }],
  };

  const sanitized = sanitizeRealmExport(source);

  assert.deepEqual(sanitized.users, []);
  assert.equal(sanitized.components['org.keycloak.keys.KeyProvider'], undefined);
  assert.equal(sanitized.clients[0].secret, undefined);
});

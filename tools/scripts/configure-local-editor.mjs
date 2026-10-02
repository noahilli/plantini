#!/usr/bin/env node
// Local E2E-only Keycloak bootstrap. Never point this at a production realm.
// Run after the E2E Keycloak container is healthy. Credentials are written
// only to the gitignored tools/e2e/.runtime/editor-studio.env (mode 0600).
import { randomBytes } from 'node:crypto';
import { chmod, readFile, writeFile } from 'node:fs/promises';

const envPath = new URL('../e2e/.runtime/e2e.env', import.meta.url);
const outputPath = new URL('../e2e/.runtime/editor-studio.env', import.meta.url);
const realmPath = new URL('../../services/identity/realm/plantini-realm.json', import.meta.url);
const base = 'http://127.0.0.1:8082';
const env = Object.fromEntries((await readFile(envPath, 'utf8')).split(/\r?\n/)
  .filter((line) => line && !line.startsWith('#') && line.includes('='))
  .map((line) => {
    const index = line.indexOf('=');
    const raw = line.slice(index + 1);
    const value = /^(["']).*\1$/.test(raw) ? raw.slice(1, -1) : raw;
    return [line.slice(0, index), value];
  }));
if (!env.E2E_KEYCLOAK_ADMIN_USERNAME || !env.E2E_KEYCLOAK_ADMIN_PASSWORD) {
  throw new Error('Local E2E Keycloak credentials are missing.');
}

async function request(path, { method = 'GET', token, body, form } = {}) {
  const response = await fetch(`${base}${path}`, {
    method,
    headers: {
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
      ...(body ? { 'Content-Type': 'application/json' } : {}),
      ...(form ? { 'Content-Type': 'application/x-www-form-urlencoded' } : {}),
    },
    body: body ? JSON.stringify(body) : form ? new URLSearchParams(form) : undefined,
    signal: AbortSignal.timeout(10000),
  });
  if (!response.ok) throw new Error(`Local Keycloak request ${method} ${path.split('?')[0]} failed (${response.status}).`);
  if (response.status === 204 || response.status === 201) return { location: response.headers.get('location') };
  return response.json();
}

const tokenResult = await request('/realms/master/protocol/openid-connect/token', {
  method: 'POST', form: {
    grant_type: 'password', client_id: 'admin-cli',
    username: env.E2E_KEYCLOAK_ADMIN_USERNAME, password: env.E2E_KEYCLOAK_ADMIN_PASSWORD,
  },
});
const token = tokenResult.access_token;
if (!token) throw new Error('Local Keycloak admin token unavailable.');
const admin = (path, options = {}) => request(`/admin/realms/plantini${path}`, { ...options, token });

const realm = JSON.parse(await readFile(realmPath, 'utf8'));
const template = realm.clients.find((client) => client.clientId === 'plantini-editor-dev');
if (!template) throw new Error('Versioned editor client is missing.');
const clients = await admin('/clients?clientId=plantini-editor-dev');
if (clients.length === 0) await admin('/clients', { method: 'POST', body: template });
else await admin(`/clients/${clients[0].id}`, { method: 'PUT', body: { ...clients[0], ...template, id: clients[0].id } });
const [configuredClient] = await admin('/clients?clientId=plantini-editor-dev');
if (!configuredClient?.id) throw new Error('Local editor client could not be verified.');
const [scopes, assignedScopes] = await Promise.all([
  admin('/client-scopes'), admin(`/clients/${configuredClient.id}/default-client-scopes`),
]);
for (const name of ['roles', 'plantini-api-audience']) {
  if (assignedScopes.some((scope) => scope.name === name)) continue;
  const scope = scopes.find((candidate) => candidate.name === name);
  if (!scope) throw new Error(`Local Keycloak client scope ${name} is missing.`);
  await admin(`/clients/${configuredClient.id}/default-client-scopes/${scope.id}`, { method: 'PUT' });
}
const editorRoles = await Promise.all(['inhaltsredaktion', 'botanisches_review', 'systemadministration']
  .map((name) => admin(`/roles/${name}`)));
await admin(`/clients/${configuredClient.id}/scope-mappings/realm`, {
  method: 'POST', body: editorRoles.map((role) => ({ id: role.id, name: role.name })),
});

const credentials = [];
for (const [label, email, roleName] of [
  ['EDITOR', 'studio-editor@plantini.invalid', 'inhaltsredaktion'],
  ['REVIEWER', 'studio-reviewer@plantini.invalid', 'botanisches_review'],
]) {
  const role = await admin(`/roles/${roleName}`);
  let users = await admin(`/users?email=${encodeURIComponent(email)}&exact=true`);
  if (!users.some((user) => user.email === email)) {
    await admin('/users', { method: 'POST', body: {
      username: email, email, firstName: 'Studio', lastName: label === 'EDITOR' ? 'Redaktion' : 'Review',
      enabled: true, emailVerified: true, requiredActions: [],
    } });
    users = await admin(`/users?email=${encodeURIComponent(email)}&exact=true`);
  }
  const user = users.find((candidate) => candidate.email === email);
  if (!user?.id) throw new Error(`Could not prepare local ${label.toLowerCase()} account.`);
  await admin(`/users/${user.id}`, { method: 'PUT', body: {
    ...user, firstName: 'Studio', lastName: label === 'EDITOR' ? 'Redaktion' : 'Review',
    enabled: true, emailVerified: true, requiredActions: [],
  } });
  const password = randomBytes(24).toString('base64url');
  await admin(`/users/${user.id}/reset-password`, { method: 'PUT', body: { type: 'password', value: password, temporary: false } });
  await admin(`/users/${user.id}/role-mappings/realm`, { method: 'POST', body: [{ id: role.id, name: role.name }] });
  credentials.push(`${label}_EMAIL=${email}`, `${label}_PASSWORD=${password}`);
}
await writeFile(outputPath, `${credentials.join('\n')}\n`, { mode: 0o600 });
await chmod(outputPath, 0o600);
console.log('Local editor client and accounts are ready. Credentials: tools/e2e/.runtime/editor-studio.env');

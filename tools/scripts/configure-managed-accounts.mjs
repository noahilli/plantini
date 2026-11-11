#!/usr/bin/env node
// Declarative updates to an existing Keycloak realm. Secrets stay in the
// selected protected environment file; this script never prints them.
// Usage: node configure-managed-accounts.mjs <env-file> <teacher-origin>
import { readFile, writeFile, chmod } from 'node:fs/promises';
import { resolve } from 'node:path';

const [envFile, teacherOrigin] = process.argv.slice(2);
if (!envFile || !teacherOrigin) throw new Error('Usage: configure-managed-accounts.mjs <env-file> <teacher-origin>');
const origin = new URL(teacherOrigin);
const development = origin.origin === 'http://127.0.0.1:8085';
if (!development && origin.origin !== 'https://portal.plantini.eu') throw new Error('An approved exact portal origin is required.');
const file = resolve(envFile);
const source = await readFile(file, 'utf8');
const env = Object.fromEntries(source.split(/\r?\n/).filter((line) => /^[A-Z_][A-Z0-9_]*=/.test(line)).map((line) => {
  const at = line.indexOf('='); const raw = line.slice(at + 1).trim();
  return [line.slice(0, at), /^(["']).*\1$/.test(raw) ? raw.slice(1, -1) : raw];
}));
const base = 'http://127.0.0.1:8082';
const username = development ? env.E2E_KEYCLOAK_ADMIN_USERNAME : env.KEYCLOAK_ADMIN_USERNAME;
const password = development ? env.E2E_KEYCLOAK_ADMIN_PASSWORD : env.KEYCLOAK_ADMIN_PASSWORD;
if (!username || !password) throw new Error('Keycloak bootstrap credentials are missing from the selected environment.');

async function request(path, { method = 'GET', token, body, form } = {}) {
  const response = await fetch(`${base}${path}`, {
    method, headers: { ...(token ? { Authorization: `Bearer ${token}` } : {}), ...(body ? { 'Content-Type': 'application/json' } : {}), ...(form ? { 'Content-Type': 'application/x-www-form-urlencoded' } : {}) },
    body: body ? JSON.stringify(body) : form ? new URLSearchParams(form) : undefined,
    signal: AbortSignal.timeout(15000),
  });
  if (!response.ok) throw new Error(`Identity configuration failed: ${method} ${path.split('?')[0]} (${response.status}).`);
  if ([201, 204].includes(response.status)) return {};
  return response.json();
}
const { access_token: token } = await request('/realms/master/protocol/openid-connect/token', {
  method: 'POST', form: { grant_type: 'password', client_id: 'admin-cli', username, password },
});
if (!token) throw new Error('Keycloak administrator authentication failed.');
const admin = (path, options = {}) => request(`/admin/realms/plantini${path}`, { ...options, token });
const realm = JSON.parse(await readFile(new URL('../../services/identity/realm/plantini-realm.json', import.meta.url), 'utf8'));

const clientId = development ? 'plantini-teacher-dev' : 'plantini-teacher-production';
const template = realm.clients.find((client) => client.clientId === clientId);
const clients = await admin(`/clients?clientId=${clientId}`);
const definition = { ...template, enabled: true, redirectUris: [`${origin.origin}/`], webOrigins: [origin.origin], attributes: { ...template.attributes, 'post.logout.redirect.uris': `${origin.origin}/` } };
if (clients[0]) await admin(`/clients/${clients[0].id}`, { method: 'PUT', body: { ...clients[0], ...definition } });
else await admin('/clients', { method: 'POST', body: definition });
const [portal] = await admin(`/clients?clientId=${clientId}`);
const scopes = await admin('/client-scopes');
for (const name of ['roles', 'plantini-api-audience']) {
  const scope = scopes.find((candidate) => candidate.name === name);
  if (!scope) throw new Error(`Missing required client scope ${name}.`);
  await admin(`/clients/${portal.id}/default-client-scopes/${scope.id}`, { method: 'PUT' });
}
const teacherRoles = await Promise.all(['lehrende', 'systemadministration'].map((name) => admin(`/roles/${name}`)));
await admin(`/clients/${portal.id}/scope-mappings/realm`, { method: 'POST', body: teacherRoles.map(({ id, name }) => ({ id, name })) });

const managementId = 'plantini-account-manager';
const existing = await admin(`/clients?clientId=${managementId}`);
const managerDefinition = { clientId: managementId, name: 'Plantini server account administration', enabled: true, protocol: 'openid-connect', publicClient: false,
  standardFlowEnabled: false, implicitFlowEnabled: false, directAccessGrantsEnabled: false, serviceAccountsEnabled: true, fullScopeAllowed: false,
  redirectUris: [], webOrigins: [], defaultClientScopes: ['roles'], optionalClientScopes: [] };
if (existing[0]) await admin(`/clients/${existing[0].id}`, { method: 'PUT', body: { ...existing[0], ...managerDefinition } });
else await admin('/clients', { method: 'POST', body: managerDefinition });
const [manager] = await admin(`/clients?clientId=${managementId}`);
const account = await admin(`/clients/${manager.id}/service-account-user`);
const [realmManagement] = await admin('/clients?clientId=realm-management');
if (!realmManagement) throw new Error('Keycloak management resource is missing.');
const managerRoles = await Promise.all(['manage-users', 'view-users', 'query-users', 'view-realm'].map((name) => admin(`/clients/${realmManagement.id}/roles/${name}`)));
const mappings = managerRoles.map(({ id, name }) => ({ id, name }));
await admin(`/users/${account.id}/role-mappings/clients/${realmManagement.id}`, { method: 'POST', body: mappings });
await admin(`/clients/${manager.id}/scope-mappings/clients/${realmManagement.id}`, { method: 'POST', body: mappings });
const rolesScope = scopes.find((scope) => scope.name === 'roles');
await admin(`/clients/${manager.id}/default-client-scopes/${rolesScope.id}`, { method: 'PUT' });
const { value: secret } = await admin(`/clients/${manager.id}/client-secret`);
if (!secret) throw new Error('The confidential account manager has no client credential.');

// No pupil email address is required. Teachers identify pupils using their
// login name; invitation accounts still require and verify their own email.
const profile = await admin('/users/profile');
for (const attribute of profile.attributes || []) {
  if (['email', 'firstName', 'lastName'].includes(attribute.name)) delete attribute.required;
}
// Declarative user profiles discard unknown attributes. Make the managed
// pupil marker an explicit, admin-only attribute so users cannot edit it.
const managedAttribute = { name: 'plantini_managed_student', displayName: 'Managed Plantini learner', multivalued: false,
  permissions: { view: ['admin'], edit: ['admin'] }, validations: { options: { options: ['true'] } } };
profile.attributes = [...(profile.attributes || []).filter((attribute) => attribute.name !== managedAttribute.name), managedAttribute];
await admin('/users/profile', { method: 'PUT', body: profile });
// Public self-registration stays open next to managed pupil accounts. Login names
// are no longer e-mail addresses because pupils may have no e-mail.
await admin('', { method: 'PUT', body: { registrationAllowed: true, registrationEmailAsUsername: false } });

const updates = { PLATFORM_KEYCLOAK_ADMIN_CLIENT_ID: managementId, PLATFORM_KEYCLOAK_ADMIN_CLIENT_SECRET: secret, TEACHER_PUBLIC_URL: origin.origin };
let updated = source;
for (const [name, value] of Object.entries(updates)) {
  const pattern = new RegExp(`^${name}=.*$`, 'm');
  updated = pattern.test(updated) ? updated.replace(pattern, `${name}=${value}`) : `${updated.replace(/\s*$/, '')}\n${name}=${value}\n`;
}
await writeFile(file, updated, { mode: 0o600 }); await chmod(file, 0o600);
console.log('Portal client, account manager and open self-registration configured. Credentials remain in the protected environment file.');

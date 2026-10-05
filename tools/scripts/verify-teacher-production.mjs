#!/usr/bin/env node
// Run with the deployed platform image, --network host, --user root and
// -v /opt/plantini:/workspace. This helper never modifies existing clients,
// realm settings or domain rows. Local browser automation receives ONLY the
// synthetic manifest, never production.env. No tokens/passwords are logged.
// node /workspace/releases/3f00d12/verify-teacher-production.mjs create|cleanup
import { randomBytes, randomUUID } from 'node:crypto';
import { readFile, open, lstat, chmod } from 'node:fs/promises';

const manifestPath = '/workspace/releases/3f00d12/teacher-smoke.json';
const realmBase = 'http://127.0.0.1:8082/admin/realms/plantini';
const marker = 'Portal Smoke Verification';
const uuid = /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/;
let adminToken;

function check(condition, message) {
  if (!condition) throw new Error(message);
}
async function request(url, { method = 'GET', body, form, authenticated = true } = {}) {
  let response;
  try {
    response = await fetch(url, {
      method, redirect: 'error', signal: AbortSignal.timeout(15000),
      headers: {
        ...(authenticated ? { Authorization: `Bearer ${adminToken}` } : {}),
        ...(body ? { 'Content-Type': 'application/json' } : {}),
        ...(form ? { 'Content-Type': 'application/x-www-form-urlencoded' } : {}),
      },
      body: body ? JSON.stringify(body) : form ? new URLSearchParams(form) : undefined,
    });
  } catch {
    throw new Error(`Identity request failed (${method}); no response data emitted.`);
  }
  check(response.ok, `Identity request rejected (${method}, HTTP ${response.status}).`);
  return response;
}
const admin = (path, options) => request(`${realmBase}${path}`, options);
async function json(path) { return (await admin(path)).json(); }

async function authenticate() {
  const text = await readFile('/workspace/production.env', 'utf8');
  const env = {};
  for (const line of text.split(/\r?\n/)) {
    const match = /^([A-Z_][A-Z0-9_]*)=(.*)$/.exec(line);
    if (!match) continue;
    const raw = match[2].trim();
    env[match[1]] = /^(["']).*\1$/.test(raw) ? raw.slice(1, -1) : raw;
  }
  check(env.KEYCLOAK_ADMIN_USERNAME && env.KEYCLOAK_ADMIN_PASSWORD, 'Server administrator configuration is missing.');
  const response = await request('http://127.0.0.1:8082/realms/master/protocol/openid-connect/token', {
    method: 'POST', authenticated: false,
    form: { client_id: 'admin-cli', grant_type: 'password', username: env.KEYCLOAK_ADMIN_USERNAME, password: env.KEYCLOAK_ADMIN_PASSWORD },
  });
  adminToken = (await response.json()).access_token;
  check(typeof adminToken === 'string' && adminToken.length > 0, 'Administrator authentication failed.');
  check(env.TEACHER_PUBLIC_URL === 'https://portal.plantini.eu', 'Unexpected production portal origin.');
  check(env.API_PUBLIC_URL === 'https://api.plantini.eu', 'Unexpected production API origin.');
  check(env.AUTH_PUBLIC_URL === 'https://auth.plantini.eu', 'Unexpected production issuer origin.');
  const realm = await json('');
  console.log(`SMTP configured: ${Boolean(realm.smtpServer?.host && realm.smtpServer?.from)}`);
}

function validateManifest(value) {
  check(value?.version === 1 && uuid.test(value.runId), 'Invalid smoke manifest.');
  check(value.teacherUsername === `portal-smoke-${value.runId}-teacher`, 'Teacher username does not match the run UUID.');
  check(value.pupilUsername === `portal-smoke-${value.runId}-pupil`, 'Pupil username does not match the run UUID.');
  check(value.pupilDisplayName === `Portal Smoke ${value.runId}`, 'Pupil marker does not match the run UUID.');
  check(value.teacherSubject === null || uuid.test(value.teacherSubject), 'Invalid recorded teacher subject.');
  return value;
}
async function readManifest() {
  const stat = await lstat(manifestPath);
  check(stat.isFile() && !stat.isSymbolicLink() && (stat.mode & 0o777) === 0o600, 'Manifest must be a regular mode-0600 file.');
  return validateManifest(JSON.parse(await readFile(manifestPath, 'utf8')));
}
async function writeManifest(value, exclusive = false) {
  const handle = await open(manifestPath, exclusive ? 'wx' : 'r+', 0o600);
  try {
    await handle.chmod(0o600);
    await handle.truncate(0);
    await handle.writeFile(`${JSON.stringify(value, null, 2)}\n`, 'utf8');
    await handle.sync();
  } finally { await handle.close(); }
  await chmod(manifestPath, 0o600);
}
async function exactUser(username) {
  const users = await json(`/users?username=${encodeURIComponent(username)}&exact=true`);
  check(Array.isArray(users) && users.length <= 1, 'Ambiguous smoke account lookup; refusing mutations.');
  if (!users.length) return undefined;
  check(users[0].username === username && uuid.test(users[0].id), 'Unexpected smoke account identity.');
  return json(`/users/${users[0].id}`);
}
async function ownedUser(manifest, kind) {
  const user = await exactUser(kind === 'teacher' ? manifest.teacherUsername : manifest.pupilUsername);
  if (!user) return undefined;
  const roles = await json(`/users/${user.id}/role-mappings/realm/composite`);
  check(Array.isArray(roles), 'Invalid role response.');
  const names = roles.map((role) => role.name);
  if (kind === 'teacher') {
    check(user.firstName === marker && user.lastName === manifest.runId, 'Teacher smoke marker mismatch; refusing deletion.');
    check(manifest.teacherSubject === null || user.id === manifest.teacherSubject, 'Teacher subject mismatch; refusing deletion.');
    check(!names.some((name) => ['systemadministration', 'organisationsadministration', 'inhaltsredaktion', 'botanisches_review'].includes(name)), 'Privileged account cannot be cleaned up.');
  } else {
    check(user.firstName === manifest.pupilDisplayName && user.attributes?.plantini_managed_student?.[0] === 'true', 'Pupil smoke marker mismatch; refusing deletion.');
    check(names.includes('lernende') && !names.some((name) => ['lehrende', 'systemadministration', 'organisationsadministration', 'inhaltsredaktion', 'botanisches_review'].includes(name)), 'Pupil roles do not match a disposable learner.');
  }
  return user;
}

async function create() {
  const realm = await json('');
  check(realm.registrationAllowed === false, 'Production self-registration must be closed.');
  const clients = await json('/clients?clientId=plantini-teacher-production');
  check(clients.length === 1, 'Production teacher client is missing or ambiguous.');
  const client = clients[0];
  check(client.enabled && client.publicClient && client.standardFlowEnabled && !client.directAccessGrantsEnabled, 'Teacher client flow configuration is unexpected.');
  check(client.attributes?.['pkce.code.challenge.method'] === 'S256', 'Production teacher client must require S256 PKCE.');
  check(client.redirectUris?.includes('https://portal.plantini.eu/'), 'Exact portal redirect is missing.');
  const role = await json('/roles/lehrende');
  check(role.name === 'lehrende' && typeof role.id === 'string', 'Teacher role is missing.');
  const runId = randomUUID();
  const value = validateManifest({ version: 1, runId, teacherUsername: `portal-smoke-${runId}-teacher`,
    teacherPassword: `Pn!${randomBytes(24).toString('base64url')}7aA`, teacherSubject: null,
    pupilUsername: `portal-smoke-${runId}-pupil`, pupilDisplayName: `Portal Smoke ${runId}`,
    portalUrl: 'https://portal.plantini.eu/', apiBase: 'https://api.plantini.eu/api/v1',
    issuer: 'https://auth.plantini.eu/realms/plantini', clientId: 'plantini-teacher-production',
    createdAt: new Date().toISOString(), status: 'creating' });
  // Persist the exact synthetic identity BEFORE creating it, allowing cleanup
  // after a lost network response. Never overwrite another run's manifest.
  await writeManifest(value, true);
  check(!await exactUser(value.teacherUsername) && !await exactUser(value.pupilUsername), 'Smoke username collision.');
  await admin('/users', { method: 'POST', body: { username: value.teacherUsername, firstName: marker, lastName: runId,
    enabled: true, emailVerified: true, requiredActions: [] } });
  const user = await ownedUser(value, 'teacher');
  check(user, 'Created teacher could not be resolved.');
  value.teacherSubject = user.id;
  await writeManifest(value);
  await admin(`/users/${user.id}/role-mappings/realm`, { method: 'POST', body: [{ id: role.id, name: role.name }] });
  await admin(`/users/${user.id}/reset-password`, { method: 'PUT', body: { type: 'password', value: value.teacherPassword, temporary: false } });
  value.status = 'ready';
  await writeManifest(value);
  console.log('Disposable teacher ready. Synthetic credentials are stored only in the mode-0600 smoke manifest.');
}

async function cleanup() {
  const value = await readManifest();
  // Validate every target before deleting any of them. No prefix-wide query
  // or bulk delete; at most one exact pupil and one exact teacher per run.
  const pupil = await ownedUser(value, 'pupil');
  const teacher = await ownedUser(value, 'teacher');
  if (pupil) await admin(`/users/${pupil.id}`, { method: 'DELETE' });
  if (teacher) await admin(`/users/${teacher.id}`, { method: 'DELETE' });
  check(!await exactUser(value.pupilUsername) && !await exactUser(value.teacherUsername), 'Smoke account cleanup could not be confirmed.');
  delete value.teacherPassword;
  value.status = 'cleaned';
  value.cleanedAt = new Date().toISOString();
  value.residualDomainRows = 'Synthetic class, pupil, profiles and teaching audit rows may remain; no database deletion was attempted.';
  await writeManifest(value);
  console.log('Exact synthetic Keycloak accounts removed and absence verified. Synthetic domain rows may remain; no existing domain data was modified.');
}

try {
  check(process.argv.length === 3 && ['create', 'cleanup'].includes(process.argv[2]), 'Usage: verify-teacher-production.mjs create|cleanup');
  await authenticate();
  if (process.argv[2] === 'create') await create(); else await cleanup();
} catch (error) {
  // Deliberately omit stack traces, provider bodies, tokens and credentials.
  const known = error instanceof Error && !['SyntaxError', 'TypeError'].includes(error.name);
  console.error(known && !error.code ? error.message : 'Smoke helper failed; credential/provider details were suppressed.');
  process.exitCode = 1;
}

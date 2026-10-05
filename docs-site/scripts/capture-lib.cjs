// Shared helpers for the handbook screenshots. Everything runs against the
// isolated local E2E stack with synthetic accounts - never against production.
const fs = require('node:fs');
const path = require('node:path');
const { randomUUID } = require('node:crypto');

const ROOT = path.resolve(__dirname, '../..');
const OUT = path.resolve(__dirname, '../docs/assets');
const FRAMES = process.env.DOCS_FRAMES || path.join(require('node:os').tmpdir(), 'plantini-docs-frames');
fs.mkdirSync(FRAMES, { recursive: true });

function loadEnv(file) {
  return Object.fromEntries(fs.readFileSync(file, 'utf8').split(/\r?\n/)
    .filter((l) => l && !l.startsWith('#') && l.includes('='))
    .map((l) => { const i = l.indexOf('='); const raw = l.slice(i + 1); return [l.slice(0, i), /^(["']).*\1$/.test(raw) ? raw.slice(1, -1) : raw]; }));
}
const e2e = () => loadEnv(path.join(ROOT, 'tools/e2e/.runtime/e2e.env'));
const studio = () => loadEnv(path.join(ROOT, 'tools/e2e/.runtime/editor-studio.env'));

const KC = 'http://127.0.0.1:8082';
const API = 'http://127.0.0.1:1338/api/v1';

async function adminToken(env) {
  const r = await fetch(`${KC}/realms/master/protocol/openid-connect/token`, { method: 'POST',
    body: new URLSearchParams({ client_id: 'admin-cli', grant_type: 'password',
      username: env.E2E_KEYCLOAK_ADMIN_USERNAME, password: env.E2E_KEYCLOAK_ADMIN_PASSWORD }) });
  return (await r.json()).access_token;
}

/** Creates (or resets) a synthetic account in the LOCAL realm; returns {email, password}. */
async function ensureUser(env, email, firstName, lastName, roles = []) {
  const token = await adminToken(env);
  const H = { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' };
  const password = `Docs-${randomUUID().slice(0, 8)}-Aa1!x`;
  let found = await (await fetch(`${KC}/admin/realms/plantini/users?username=${encodeURIComponent(email)}&exact=true`, { headers: H })).json();
  let id = found[0]?.id;
  if (!id) {
    const r = await fetch(`${KC}/admin/realms/plantini/users`, { method: 'POST', headers: H, body: JSON.stringify({
      username: email, email, firstName, lastName, enabled: true, emailVerified: true, requiredActions: [] }) });
    id = r.headers.get('location').split('/').pop();
  }
  await fetch(`${KC}/admin/realms/plantini/users/${id}/reset-password`, { method: 'PUT', headers: H,
    body: JSON.stringify({ type: 'password', value: password, temporary: false }) });
  await fetch(`${KC}/admin/realms/plantini/users/${id}`, { method: 'PUT', headers: H, body: JSON.stringify({
    username: email, email, firstName, lastName, enabled: true, emailVerified: true, requiredActions: [] }) });
  for (const role of roles) {
    const rep = await (await fetch(`${KC}/admin/realms/plantini/roles/${role}`, { headers: H })).json();
    await fetch(`${KC}/admin/realms/plantini/users/${id}/role-mappings/realm`, { method: 'POST', headers: H, body: JSON.stringify([rep]) });
  }
  return { email, password };
}

let frameNo = 0;
async function shot(page, name, options = {}) {
  const file = path.join(OUT, 'shots', `${name}.png`);
  fs.mkdirSync(path.dirname(file), { recursive: true });
  await page.screenshot({ path: file, ...options });
  return file;
}
/** Saves one animation frame; make_gif.py assembles `<name>-*.png`. */
async function frame(page, name, options = {}) {
  frameNo += 1;
  const dir = path.join(FRAMES, name);
  fs.mkdirSync(dir, { recursive: true });
  await page.screenshot({ path: path.join(dir, `f${String(frameNo).padStart(3, '0')}.png`), ...options });
}
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

module.exports = { ROOT, OUT, FRAMES, e2e, studio, KC, API, ensureUser, shot, frame, sleep, loadEnv };

/** Creates a confirmed find through the public API (reserve -> upload -> identify -> confirm -> observation). */
async function seedFind(bearer, photoFile, location, candidateIndex = 0, daysAgo = 0) {
  const H = (extra = {}) => ({ Authorization: bearer, ...extra });
  const j = async (method, p, body, idem) => {
    const r = await fetch(API + p, { method, headers: H({ 'Content-Type': 'application/json', ...(idem ? { 'Idempotency-Key': idem } : {}) }),
      body: body ? JSON.stringify(body) : undefined });
    return [r.status, await r.json().catch(() => ({}))];
  };
  const bytes = fs.readFileSync(photoFile);
  const clientMediaId = randomUUID();
  let [, media] = await j('POST', '/media/uploads', { clientMediaId, contentType: 'image/jpeg', bytes: bytes.length }, clientMediaId);
  const form = new FormData();
  form.append('image', new Blob([bytes], { type: 'image/jpeg' }), 'photo.jpg');
  await fetch(`${API}/media/uploads/${media.id}/content`, { method: 'POST', headers: H({ 'Idempotency-Key': randomUUID() }), body: form });
  const clientJobId = randomUUID();
  let [, job] = await j('POST', '/identifications', { clientJobId, mediaId: media.id }, clientJobId);
  for (let i = 0; i < 40 && job.status !== 'identified'; i++) { await sleep(500); [, job] = await j('GET', `/identifications/${job.id}`); }
  await j('POST', `/identifications/${job.id}/confirm`, { candidateId: job.candidates[candidateIndex].candidateId }, randomUUID());
  const [status, obs] = await j('POST', '/observations', { clientObservationId: randomUUID(),
    observedAt: new Date(Date.now() - daysAgo * 86400000).toISOString(), identificationJobId: job.id,
    ...(location ? { location } : {}) }, randomUUID());
  return { status, id: obs.id };
}
module.exports.seedFind = seedFind;

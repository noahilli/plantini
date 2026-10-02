import { JsonEditor } from './json-editor.js';

const host = location.hostname;
const production = host.startsWith('editor.');
const apiOrigin = production ? `https://${host.replace(/^editor\./, 'api.')}` : 'http://127.0.0.1:1338';
const authOrigin = production ? `https://${host.replace(/^editor\./, 'auth.')}` : 'http://127.0.0.1:8082';
const clientId = production ? 'plantini-editor-production' : 'plantini-editor-dev';
const oidc = `${authOrigin}/realms/plantini/protocol/openid-connect`;
const redirectUri = `${location.origin}/`;
const $ = (id) => document.getElementById(id);
const safe = (value) => String(value ?? '').replace(/[&<>"']/g, (letter) => ({
  '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;',
})[letter]);
const state = { token: null, expires: 0, refresh: null, roles: [], catalog: null, changes: [], page: 'dashboard', edit: null };
const labels = { ecosystem: 'Ökosystem', level: 'Level', plant: 'Pflanze', quiz: 'Quiz' };
const statusLabels = { draft: 'Entwurf', pending_review: 'Im Review', rejected: 'Zurückgewiesen', approved: 'Fachlich freigegeben · wartet auf Release' };

function base64url(bytes) {
  return btoa(String.fromCharCode(...new Uint8Array(bytes))).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
}
async function login() {
  const verifier = base64url(crypto.getRandomValues(new Uint8Array(32)));
  const challenge = base64url(await crypto.subtle.digest('SHA-256', new TextEncoder().encode(verifier)));
  const nonce = base64url(crypto.getRandomValues(new Uint8Array(18)));
  sessionStorage.setItem('plantini-editor-auth', JSON.stringify({ verifier, nonce }));
  const url = new URL(`${oidc}/auth`);
  url.search = new URLSearchParams({ client_id: clientId, redirect_uri: redirectUri, response_type: 'code', scope: 'openid profile email', state: nonce, code_challenge: challenge, code_challenge_method: 'S256' });
  location.replace(url);
}
async function exchange(body) {
  const response = await fetch(`${oidc}/token`, { method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded' }, body: new URLSearchParams({ client_id: clientId, ...body }) });
  if (!response.ok) throw new Error('Anmeldung konnte nicht abgeschlossen werden.');
  const tokens = await response.json();
  state.token = tokens.access_token;
  state.refresh = tokens.refresh_token;
  state.expires = Date.now() + (tokens.expires_in - 30) * 1000;
  const claims = JSON.parse(atob(tokens.access_token.split('.')[1].replace(/-/g, '+').replace(/_/g, '/')));
  state.roles = claims.realm_access?.roles || [];
  $('signed-in-as').textContent = claims.preferred_username || claims.email || 'Redaktion';
  if (!state.roles.some((role) => ['inhaltsredaktion', 'botanisches_review', 'systemadministration'].includes(role))) {
    throw new Error('Dieses Konto hat keine Redaktionsrolle. Bitte die Systemadministration kontaktieren.');
  }
}
async function token() {
  if (state.expires < Date.now() && state.refresh) {
    try { await exchange({ grant_type: 'refresh_token', refresh_token: state.refresh }); }
    catch { await login(); throw new Error('Sitzung abgelaufen.'); }
  }
  return state.token;
}
async function api(path, options = {}) {
  const response = await fetch(`${apiOrigin}/api/v1/editor${path}`, {
    method: options.method || 'GET', headers: { Authorization: `Bearer ${await token()}`, ...(options.body ? { 'Content-Type': 'application/json' } : {}) },
    body: options.body ? JSON.stringify(options.body) : undefined, cache: 'no-store',
  });
  if (response.status === 401) { await login(); throw new Error('Sitzung abgelaufen.'); }
  const body = await response.json().catch(() => ({}));
  if (!response.ok) {
    const fields = body.fieldErrors && typeof body.fieldErrors === 'object'
      ? Object.entries(body.fieldErrors).map(([name, message]) => `${fieldNames[name] || name}: ${message}`).join(' · ')
      : '';
    throw new Error(fields || body.detail || body.message || `Anfrage fehlgeschlagen (${response.status}).`);
  }
  return body;
}
function notice(message, error = false) {
  const el = $('notice'); el.textContent = message; el.classList.toggle('error', error); el.hidden = false;
  clearTimeout(notice.timer); notice.timer = setTimeout(() => { el.hidden = true; }, 7000);
}
function busy(button, task) {
  button.disabled = true;
  Promise.resolve().then(task).catch((error) => notice(error.message, true)).finally(() => { button.disabled = false; });
}
function button(label, className, onClick) {
  const el = document.createElement('button'); el.type = 'button'; el.className = className; el.textContent = label; el.addEventListener('click', () => busy(el, onClick)); return el;
}
async function load() {
  const [catalog, changes] = await Promise.all([api('/catalog'), api('/changes')]);
  state.catalog = catalog; state.changes = changes;
  $('review-badge').textContent = changes.filter((change) => change.status === 'pending_review').length;
  $('review-badge').hidden = !$('review-badge').textContent || $('review-badge').textContent === '0';
  await show(state.page);
}
async function show(page) {
  state.page = page;
  for (const name of ['dashboard', 'catalog', 'review', 'team']) $('page-' + name).hidden = name !== page;
  document.querySelectorAll('[data-page]').forEach((el) => el.classList.toggle('active', el.dataset.page === page));
  $('page-title').textContent = { dashboard: 'Übersicht', catalog: 'Inhalte', review: 'Review', team: 'Team' }[page];
  if (page === 'dashboard') await renderDashboard();
  if (page === 'catalog') renderCatalog();
  if (page === 'review') renderReview();
  if (page === 'team') renderTeam();
}
async function renderDashboard() {
  const data = await api('/dashboard');
  const values = [
    ['Nutzer', data.users], ['Ökosysteme', data.ecosystems], ['Level', data.levels], ['Pflanzen', data.plants],
    ['Quizze', data.quizzes], ['Lernelemente', data.learningElements], ['Karten', data.cards],
    ['PlantNet heute', data.plantNetToday ?? '—'], ['Private Uploads', data.storageBytes == null ? '—' : `${(data.storageBytes / 1048576).toFixed(1)} MB`],
    ['Im Review', data.pendingReview], ['Wartet auf Release', data.approvedPendingRelease],
  ];
  $('page-dashboard').innerHTML = `<div class="hero"><div><span class="eyebrow">DEIN REDAKTIONELLER ARBEITSPLATZ</span><h2>Wissen wächst zusammen.</h2><p>Pflege Ökosysteme, Level, Pflanzen und Quizze. Änderungen gehen zuerst durch das botanische Review.</p></div><div class="hero-art">✿</div></div><div class="section-heading"><div><h3>Auf einen Blick</h3><p>Aktueller Stand der veröffentlichten Inhalte</p></div></div><div class="metrics">${values.map(([name, value]) => `<div class="metric"><span class="metric-label">${safe(name)}</span><strong class="metric-value">${safe(value)}</strong></div>`).join('')}</div><div class="section-heading"><h3>Nächste Schritte</h3></div><div class="panel-grid"><div class="panel"><h3>Inhalte pflegen</h3><p>Bearbeite die Beziehungen zwischen Ökosystem, Level, Pflanzen und Fragen.</p><div class="simple-list"><button data-go="catalog">Zum Inhaltsbaum →</button></div></div><div class="panel"><h3>Freigaben</h3><p>${safe(data.pendingReview)} Änderungen warten auf Prüfung. Veröffentlichungen werden erst nach einem konsistenten Content-Release aktiviert.</p><div class="simple-list"><button data-go="review">Zur Review-Liste →</button></div></div></div>`;
  $('page-dashboard').querySelectorAll('[data-go]').forEach((el) => el.addEventListener('click', () => show(el.dataset.go).catch((error) => notice(error.message, true))));
}
function renderCatalog() {
  const root = $('page-catalog');
  root.innerHTML = `<div class="toolbar"><input id="catalog-search" type="search" placeholder="Ökosystem, Level oder Pflanze suchen …" aria-label="Inhalte suchen"><div id="new-buttons"></div></div><div id="catalog-tree" class="catalog"></div>`;
  for (const type of Object.keys(labels)) $('new-buttons').append(button(`+ ${labels[type]}`, 'secondary', () => openEditor(type)));
  $('catalog-search').addEventListener('input', drawTree);
  drawTree();
}
function drawTree() {
  const c = state.catalog; const query = $('catalog-search').value.toLocaleLowerCase('de');
  const find = (type, id) => c[`${type}s`]?.find((item) => item.id === id);
  const matches = (item) => `${item.title} ${item.slug}`.toLocaleLowerCase('de').includes(query);
  const rows = [];
  for (const ecosystem of c.ecosystems) {
    const levels = c.levels.filter((level) => level.ecosystemId === ecosystem.id);
    const visible = !query || matches(ecosystem) || levels.some((level) => matches(level) || level.plantIds.some((id) => matches(find('plant', id) || { title: '', slug: '' })));
    if (!visible) continue;
    rows.push(`<article class="ecosystem-block"><div class="ecosystem-head"><button data-type="ecosystem" data-id="${safe(ecosystem.id)}">♧ ${safe(ecosystem.title)}</button><span class="dim">${levels.length} Level · ${ecosystem.published ? 'veröffentlicht' : 'Entwurf'}</span></div>${levels.map((level) => `<div class="level-row"><div class="level-top"><span class="level-number">${safe(level.sequence)}</span><button data-type="level" data-id="${safe(level.id)}">${safe(level.title)}</button><span class="dim">${c.quizzes.filter((quiz) => quiz.levelId === level.id).length} Quizze</span></div><div class="related">${level.plantIds.map((id) => find('plant', id)).filter(Boolean).map((plant) => `<button class="chip" data-type="plant" data-id="${safe(plant.id)}">✿ ${safe(plant.title)}</button>`).join('')}${c.quizzes.filter((quiz) => quiz.levelId === level.id).map((quiz) => `<button class="chip" data-type="quiz" data-id="${safe(quiz.id)}">? ${safe(quiz.title)}</button>`).join('')}</div></div>`).join('')}</article>`);
  }
  const unlinked = c.plants.filter((plant) => !c.levels.some((level) => level.plantIds.includes(plant.id)) && (!query || matches(plant)));
  if (unlinked.length) rows.push(`<article class="ecosystem-block"><div class="ecosystem-head"><h3>Nicht zugeordnete Pflanzen</h3></div><div class="related">${unlinked.map((plant) => `<button class="chip" data-type="plant" data-id="${safe(plant.id)}">✿ ${safe(plant.title)}</button>`).join('')}</div></article>`);
  $('catalog-tree').innerHTML = rows.join('') || '<div class="empty">Keine passenden Inhalte gefunden.</div>';
  $('catalog-tree').querySelectorAll('[data-type]').forEach((el) => el.addEventListener('click', () => openEditor(el.dataset.type, el.dataset.id).catch((error) => notice(error.message, true))));
}
function renderReview() {
  const reviewer = state.roles.some((role) => ['botanisches_review', 'systemadministration'].includes(role));
  const changes = state.changes;
  $('page-review').innerHTML = `<div class="section-heading"><div><h3>${reviewer ? 'Alle Änderungen' : 'Meine Änderungen'}</h3><p>Entwürfe, Einreichungen und Rückmeldungen an einem Ort</p></div></div>${changes.length ? changes.map((change) => `<div class="change-row"><div><button data-change="${safe(change.id)}">${safe(labels[change.type])} · ${safe(change.data?.title || change.data?.name || change.data?.commonName || change.data?.slug)}</button><div class="dim">${safe(new Date(change.updatedAt).toLocaleString('de-DE'))}${change.note ? ` · ${safe(change.note)}` : ''}</div></div><span class="pill ${safe(change.status)}">${safe(statusLabels[change.status] || change.status)}</span></div>`).join('') : '<div class="empty">Noch keine Änderungen vorhanden.</div>'}`;
  $('page-review').querySelectorAll('[data-change]').forEach((el) => el.addEventListener('click', () => openChange(el.dataset.change).catch((error) => notice(error.message, true))));
}
function renderTeam() {
  const admin = state.roles.includes('systemadministration');
  $('page-team').innerHTML = `<div class="panel"><h3>Mitwirkende einladen</h3><p>Einladungen werden per Keycloak-E-Mail verschickt. Bestehende Redakteure dürfen weitere Redakteure einladen; Reviewer kann nur die Systemadministration einladen.</p><form id="invite-form" class="form-grid"><label class="field"><span>E-Mail-Adresse</span><input name="email" type="email" required autocomplete="email"></label><label class="field"><span>Rolle</span><select name="role"><option value="inhaltsredaktion">Inhaltsredaktion</option>${admin ? '<option value="botanisches_review">Botanisches Review</option>' : ''}</select></label><div class="field wide"><button class="primary" type="submit">Einladung versenden</button></div></form></div>`;
  $('invite-form').addEventListener('submit', async (event) => {
    event.preventDefault(); const form = event.currentTarget; const submit = form.querySelector('button');
    busy(submit, async () => { const data = new FormData(form); await api('/invitations', { method: 'POST', body: { email: data.get('email'), role: data.get('role') } }); form.reset(); notice('Einladung wurde versendet.'); });
  });
}
const empty = {
  ecosystem: { slug: '', name: '', description: '', climateZone: '', region: '', season: '', language: 'de' },
  level: { slug: '', title: '', sequence: 1, difficulty: '', learningGoal: '', ecosystemId: '', plantIds: [], completionRule: { minimumScore: 0.7, requiredQuizIds: [], requiredPlantIds: [], requiredLevelIds: [], collectionScope: 'level' } },
  plant: { slug: '', scientificName: '', commonName: '', family: '', description: '', warning: '', sources: [], features: [], learningCards: Array.from({ length: 3 }, () => ({ heading: '', text: '', question: '', correctAnswer: '', wrongAnswer1: '', wrongAnswer2: '', wrongAnswer3: '' })) },
  quiz: { slug: '', title: '', quizType: 'multiple-choice', data: { prompt: '', choices: [1, 2, 3, 4].map((n) => ({ id: `choice-${n}`, label: '' })), correctChoiceId: 'choice-1' }, levelId: '', plantId: '' },
};
const jsonFields = new Set(['sources', 'features', 'completionRule', 'data', 'learningCards']);
const fieldNames = { slug: 'Slug', name: 'Name', description: 'Beschreibung', climateZone: 'Klimazone', region: 'Region', season: 'Jahreszeit', language: 'Sprache', title: 'Titel', sequence: 'Reihenfolge', difficulty: 'Schwierigkeit', learningGoal: 'Lernziel', scientificName: 'Wissenschaftlicher Name', commonName: 'Deutscher Name', family: 'Familie', warning: 'Sicherheitshinweis', sources: 'Quellen', features: 'Merkmale', completionRule: 'Abschlussregel', quizType: 'Fragetyp', data: 'Frage und Antworten', learningCards: 'Lernkarten' };
function field(key, value) {
  const label = fieldNames[key] || key;
  if (jsonFields.has(key)) return `<div class="field wide"><div class="json-editor-host" data-json-field="${safe(key)}"></div></div>`;
  if (key === 'ecosystemId' || key === 'levelId' || key === 'plantId') {
    const collection = key === 'ecosystemId' ? 'ecosystems' : key === 'levelId' ? 'levels' : 'plants';
    return `<label class="field"><span>${safe(label)}</span><select name="${safe(key)}" required><option value="">Bitte wählen</option>${(state.catalog?.[collection] || []).map((item) => `<option value="${safe(item.id)}" ${item.id === value ? 'selected' : ''}>${safe(item.title)}</option>`).join('')}</select></label>`;
  }
  if (key === 'plantIds') return `<div class="field wide"><span>Pflanzen in diesem Level</span><div class="checkboxes">${(state.catalog?.plants || []).map((plant) => `<label><input type="checkbox" name="plantIds" value="${safe(plant.id)}" ${(value || []).includes(plant.id) ? 'checked' : ''}>${safe(plant.title)}</label>`).join('')}</div></div>`;
  if (key === 'quizType') return `<label class="field"><span>${safe(label)}</span><select name="quizType">${['multiple-choice', 'flashcard', 'identification', 'feature-match'].map((choice) => `<option ${value === choice ? 'selected' : ''}>${choice}</option>`).join('')}</select></label>`;
  const multiline = ['description', 'warning', 'learningGoal'].includes(key);
  return `<label class="field ${multiline ? 'wide' : ''}"><span>${safe(label)}</span>${multiline ? `<textarea name="${safe(key)}" rows="4">${safe(value ?? '')}</textarea>` : `<input name="${safe(key)}" value="${safe(value ?? '')}" ${key === 'sequence' ? 'type="number" min="1"' : ''}>`}</label>`;
}
function values(type, form) {
  if (!form.reportValidity()) throw new Error('Bitte markierte Formularfelder korrigieren.');
  const data = {}; const input = new FormData(form);
  for (const key of Object.keys(empty[type])) {
    if (jsonFields.has(key)) data[key] = state.edit.jsonEditors.get(key).getValue();
    else if (key === 'plantIds') data[key] = input.getAll(key);
    else if (key === 'sequence') data[key] = Number(input.get(key));
    else data[key] = input.get(key);
  }
  return data;
}
async function openEditor(type, id) {
  const record = id ? await api(`/items/${type}/${id}`) : { type, data: structuredClone(empty[type]) };
  state.edit = { type, targetId: id || null, changeId: null };
  drawer(`${id ? 'Bearbeiten' : 'Neu anlegen'} · ${labels[type]}`, record.data);
}
async function openChange(id) {
  const change = await api(`/changes/${id}`);
  state.edit = { type: change.type, targetId: change.targetId, changeId: id, status: change.status, author: change.author };
  drawer(`${labels[change.type]} · ${statusLabels[change.status]}`, change.data, change);
}
function drawer(title, data, change) {
  $('drawer-title').textContent = title;
  $('drawer-kicker').textContent = change ? 'ÄNDERUNG PRÜFEN' : 'INHALT BEARBEITEN';
  $('drawer-body').innerHTML = `${change?.note ? `<p class="warning-text">Review: ${safe(change.note)}</p>` : ''}<form id="content-form" class="form-grid">${Object.entries(data).filter(([key]) => key !== 'media').map(([key, value]) => field(key, value)).join('')}</form>${data.media?.length ? `<div class="group"><h3>Vorhandene Bilder</h3>${data.media.map((image) => `<p>${safe(image.title || image.altText || image.id)} · ${safe(image.license || 'ohne Lizenzangabe')}</p>`).join('')}<p class="dim">Bildverwaltung folgt in einem eigenen Medien-Dialog.</p></div>` : ''}${change?.reviewEvents?.length ? `<div class="group"><h3>Review-Verlauf</h3>${change.reviewEvents.map((event) => `<p class="dim">${safe(new Date(event.at).toLocaleString('de-DE'))} · ${safe({ submitted: 'Eingereicht', rejected: 'Zurückgewiesen', approved: 'Fachlich freigegeben' }[event.action] || event.action)}${event.note ? `: ${safe(event.note)}` : ''}</p>`).join('')}</div>` : ''}`;
  const actions = $('drawer-actions'); actions.replaceChildren();
  const editable = !change || ['draft', 'rejected'].includes(change.status);
  state.edit.jsonEditors = new Map();
  for (const key of jsonFields) {
    const host = $('content-form').querySelector(`[data-json-field="${key}"]`);
    if (host) state.edit.jsonEditors.set(key, new JsonEditor(host, fieldNames[key], data[key], { readOnly: !editable }));
  }
  if (editable) {
    actions.append(button('Entwurf speichern', 'quiet', async () => {
      const saved = await api(state.edit.changeId ? `/changes/${state.edit.changeId}` : '/changes', { method: state.edit.changeId ? 'PATCH' : 'POST', body: { type: state.edit.type, targetId: state.edit.targetId, data: values(state.edit.type, $('content-form')) } });
      state.edit.changeId = saved.id; state.edit.targetId = saved.targetId; await load(); notice('Entwurf gespeichert.');
    }));
    actions.append(button('Zum Review einreichen', 'primary', async () => {
      const saved = await api(state.edit.changeId ? `/changes/${state.edit.changeId}` : '/changes', { method: state.edit.changeId ? 'PATCH' : 'POST', body: { type: state.edit.type, targetId: state.edit.targetId, data: values(state.edit.type, $('content-form')) } });
      await api(`/changes/${saved.id}/submit`, { method: 'POST' }); closeDrawer(); await load(); notice('Änderung wurde zum Review eingereicht.');
    }));
  }
  if (change?.status === 'pending_review' && state.roles.some((role) => ['botanisches_review', 'systemadministration'].includes(role))) {
    actions.append(button('Fachlich freigeben', 'primary', async () => {
      const note = prompt('Optionaler Review-Kommentar (die Freigabe veröffentlicht noch nichts):');
      if (note === null) return;
      await api(`/changes/${change.id}/approve`, { method: 'POST', body: { note } }); closeDrawer(); await load(); notice('Fachlich freigegeben. Veröffentlichung wartet auf ein geprüftes Release.');
    }));
    actions.append(button('Zurückweisen', 'danger', async () => {
      const note = prompt('Bitte begründe die Zurückweisung (mindestens 3 Zeichen):');
      if (note === null) return;
      await api(`/changes/${change.id}/reject`, { method: 'POST', body: { note } }); closeDrawer(); await load(); notice('Änderung wurde zurückgewiesen.');
    }));
  }
  if (change?.status === 'approved') {
    const message = document.createElement('span'); message.className = 'dim'; message.textContent = 'Fachlich freigegeben; noch nicht in der App veröffentlicht.'; actions.prepend(message);
  }
  $('drawer-overlay').hidden = false; $('drawer').hidden = false;
}
function closeDrawer() { $('drawer').hidden = true; $('drawer-overlay').hidden = true; state.edit = null; }
async function boot() {
  $('drawer-close').addEventListener('click', closeDrawer); $('drawer-overlay').addEventListener('click', closeDrawer);
  document.querySelectorAll('[data-page]').forEach((el) => el.addEventListener('click', () => show(el.dataset.page).catch((error) => notice(error.message, true))));
  $('logout').addEventListener('click', () => {
    sessionStorage.removeItem('plantini-editor-auth');
    const url = new URL(`${oidc}/logout`); url.search = new URLSearchParams({ client_id: clientId, post_logout_redirect_uri: redirectUri }); location.replace(url);
  });
  const callback = new URL(location.href);
  if (callback.searchParams.has('error')) throw new Error(`Anmeldung fehlgeschlagen: ${callback.searchParams.get('error_description') || callback.searchParams.get('error')}`);
  if (callback.searchParams.has('code')) {
    const pending = JSON.parse(sessionStorage.getItem('plantini-editor-auth') || 'null');
    if (!pending || callback.searchParams.get('state') !== pending.nonce) throw new Error('Ungültige Anmeldeantwort. Bitte erneut anmelden.');
    sessionStorage.removeItem('plantini-editor-auth');
    await exchange({ grant_type: 'authorization_code', code: callback.searchParams.get('code'), redirect_uri: redirectUri, code_verifier: pending.verifier });
    history.replaceState(null, '', redirectUri);
  } else await login();
  $('loading').hidden = true; $('shell').hidden = false;
  await load();
}
boot().catch((error) => { $('loading').querySelector('p').textContent = error.message; });

const $ = (id) => document.getElementById(id);
const safe = (value) => String(value ?? '').replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[c]);
const number = new Intl.NumberFormat('de-DE');
const pct = (value) => `${number.format(Math.round(fraction(value) * 100))} %`;
const fraction = (value) => Number.isFinite(value) ? Math.max(0, Math.min(1, value)) : 0;
const uuid = (value) => /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(value);
const date = (value) => value && !Number.isNaN(Date.parse(value)) ? new Intl.DateTimeFormat('de-DE', { dateStyle: 'medium', timeStyle: 'short' }).format(new Date(value)) : 'Noch keine Aktivität';
const authKey = 'plantini-teacher-pkce';
const redirectUri = `${location.origin}/`;
let config, accessToken, refreshToken, idToken, expires = 0, refreshPending, refreshTimer, authVersion = 0;
let session, page = 'dashboard', selectedClass, pageVersion = 0, dialogTrigger;
const base64url = (bytes) => btoa(String.fromCharCode(...new Uint8Array(bytes))).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');

function clearTokens() {
  authVersion++;
  accessToken = refreshToken = idToken = undefined; expires = 0;
  clearTimeout(refreshTimer);
}
function signedOut(message) {
  clearTokens(); session = undefined; pageVersion++;
  if ($('dialog').open) $('dialog').close();
  $('content').replaceChildren(); $('shell').hidden = true; $('welcome').hidden = false;
  $('welcome-message').textContent = message; $('login').hidden = false;
}
async function login() {
  const verifier = base64url(crypto.getRandomValues(new Uint8Array(32)));
  const state = base64url(crypto.getRandomValues(new Uint8Array(32)));
  const challenge = base64url(await crypto.subtle.digest('SHA-256', new TextEncoder().encode(verifier)));
  sessionStorage.setItem(authKey, JSON.stringify({ verifier, state, createdAt: Date.now() }));
  const url = new URL(`${config.issuer}/protocol/openid-connect/auth`);
  // A pupil may already have an SSO session on a shared classroom computer.
  // Let an explicit login switch accounts instead of looping on a 403 callback.
  url.search = new URLSearchParams({ client_id: config.clientId, redirect_uri: redirectUri, response_type: 'code', scope: 'openid profile email', prompt: 'login', state, code_challenge: challenge, code_challenge_method: 'S256' });
  location.replace(url);
}
async function exchange(body) {
  const version = authVersion;
  const response = await fetch(`${config.issuer}/protocol/openid-connect/token`, {
    method: 'POST', credentials: 'omit', cache: 'no-store',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({ client_id: config.clientId, ...body }),
  });
  if (!response.ok) throw new Error('Die Anmeldung ist abgelaufen oder konnte nicht abgeschlossen werden. Bitte erneut anmelden.');
  const tokens = await response.json();
  if (version !== authVersion) throw new Error('Die Sitzung wurde beendet. Bitte erneut anmelden.');
  if (!tokens.access_token || !Number.isFinite(tokens.expires_in) || tokens.expires_in <= 0) throw new Error('Ungültige Anmeldeantwort.');
  accessToken = tokens.access_token; refreshToken = tokens.refresh_token || refreshToken; idToken = tokens.id_token || idToken;
  expires = Date.now() + tokens.expires_in * 1000;
  clearTimeout(refreshTimer);
  if (refreshToken) refreshTimer = setTimeout(() => refresh().catch(() => {}), Math.max(1000, tokens.expires_in * 1000 - 30000));
}
async function refresh() {
  if (refreshPending) return refreshPending;
  if (!refreshToken) { signedOut('Bitte erneut anmelden.'); throw new Error('Die Sitzung ist abgelaufen.'); }
  refreshPending = exchange({ grant_type: 'refresh_token', refresh_token: refreshToken }).catch((error) => { signedOut(error.message); throw error; }).finally(() => { refreshPending = undefined; });
  return refreshPending;
}
async function api(path, options = {}) {
  if (!accessToken) throw new Error('Bitte anmelden.');
  if (Date.now() >= expires - 15000) await refresh();
  const response = await fetch(`${config.apiBase}/teaching${path}`, {
    method: options.method || 'GET', cache: 'no-store', credentials: 'omit',
    headers: { Authorization: `Bearer ${accessToken}`, ...(options.body ? { 'Content-Type': 'application/json' } : {}) },
    body: options.body ? JSON.stringify(options.body) : undefined,
  });
  if (response.status === 401) { signedOut('Ihre Sitzung ist abgelaufen. Bitte erneut anmelden.'); throw new Error('Ihre Sitzung ist abgelaufen.'); }
  if (response.status === 403) throw new Error('Für diese Aktion fehlt die Berechtigung. Bitte wenden Sie sich an die Systemadministration.');
  const body = await response.json().catch(() => ({}));
  if (!response.ok) {
    const known = {
      TEACHING_USERNAME_EXISTS: 'Dieser Benutzername ist bereits vergeben. Bitte wählen Sie einen anderen.',
      TEACHING_LIMIT_REACHED: path === '/classes' ? 'Sie können höchstens 100 Klassen anlegen.' : 'Eine Klasse kann höchstens 500 Schülerkonten enthalten.',
      TEACHING_IDENTITY_UNAVAILABLE: 'Die Kontoverwaltung ist gerade nicht verfügbar. Bitte versuchen Sie es später erneut.',
    };
    const messages = { 409: 'Der Name ist bereits vergeben. Bitte wählen Sie einen anderen.', 400: 'Bitte prüfen Sie die eingegebenen Angaben.', 404: 'Dieser Eintrag ist nicht mehr verfügbar.', 429: 'Zu viele Anfragen. Bitte versuchen Sie es später erneut.' };
    throw new Error(known[body.code] || messages[response.status] || 'Die Anfrage konnte nicht abgeschlossen werden. Bitte versuchen Sie es später erneut.');
  }
  return body;
}
function notice(message, error = false) {
  $('notice').textContent = message; $('notice').classList.toggle('error', error); $('notice').hidden = false;
  clearTimeout(notice.timer); notice.timer = setTimeout(() => { $('notice').hidden = true; }, 6500);
}
function progress(item, label = item.name) {
  return `<div class="eco-row"><div class="progress-caption"><strong>${safe(label)}</strong><span>${number.format(item.completedLevels)} / ${number.format(item.totalLevels)} Level · ${pct(item.progress)}</span></div><progress max="1" value="${fraction(item.progress)}" aria-label="${safe(label)}: ${pct(item.progress)}"></progress></div>`;
}
function empty(title, description) { return `<div class="empty"><strong>${safe(title)}</strong>${safe(description)}</div>`; }
function heading(title, subtitle, action = '') { return `<div class="page-head"><div><p class="eyebrow">LERNEN BEGLEITEN</p><h1>${safe(title)}</h1><p class="subtitle">${safe(subtitle)}</p></div>${action}</div>`; }
function canManage() { return session?.capabilities?.manageStudents === true; }
function action(label, id) { return `<button id="${id}">${label}</button>`; }
async function show(nextPage = page, classId = selectedClass, focus = true) {
  if (!session) return;
  if (nextPage === 'class' && !uuid(classId)) throw new Error('Ungültige Klassen-ID.');
  page = nextPage; selectedClass = classId; const version = ++pageVersion;
  document.querySelectorAll('[data-page]').forEach((button) => button.setAttribute('aria-current', button.dataset.page === (page === 'class' ? 'classes' : page) ? 'page' : 'false'));
  $('content').innerHTML = '<div class="loading" role="status">Lerndaten werden geladen …</div>';
  $('content').setAttribute('aria-busy', 'true');
  if (focus) $('content').focus();
  try {
    const data = await api(page === 'dashboard' ? '/dashboard' : page === 'classes' ? '/classes' : `/classes/${classId}`);
    if (version !== pageVersion || !session) return;
    if (page === 'dashboard') renderDashboard(data);
    else if (page === 'classes') renderClasses(data);
    else renderClass(data);
  } catch (error) {
    if (version !== pageVersion || !session) return;
    $('content').innerHTML = `<div class="error-box" role="alert"><p>${safe(error instanceof TypeError ? 'Die Daten konnten nicht geladen werden. Bitte prüfen Sie Ihre Verbindung und versuchen Sie es erneut.' : error.message)}</p><button id="retry">Erneut laden</button></div>`;
    $('retry').onclick = () => show();
  } finally { if (version === pageVersion) $('content').removeAttribute('aria-busy'); }
}
function renderDashboard(data) {
  const metrics = [ ['Klassen', data.classes, 'Gemeinsam unterwegs'], ['Schülerinnen & Schüler', data.students, `${number.format(data.activeStudents)} aktive Konten`], ['Abgeschlossene Level', data.completedLevels, `von ${number.format(data.totalLevels)} zugewiesenen Leveln`], ['Ø Lernfortschritt', pct(data.averageProgress), 'Durchschnitt über alle Lernenden'] ];
  $('content').innerHTML = heading('Alles im Blick.', 'Der aktuelle Lernstand Ihrer Klassen – direkt aus Plantini.', '<button id="refresh-view" class="secondary">Aktualisieren</button>')
    + `<section class="hero" aria-label="Willkommen"><div><h2>Jede Entdeckung lässt<br>Wissen wachsen.</h2><p>Begleiten Sie Ihre Klassen durch die Pflanzenwelt.</p></div><span class="hero-art" aria-hidden="true">❧</span></section><section class="metrics" aria-label="Kennzahlen">${metrics.map(([label, value, hint]) => `<div class="metric"><span class="metric-label">${label}</span><strong class="metric-value">${typeof value === 'number' ? number.format(value) : safe(value)}</strong><small>${safe(hint)}</small></div>`).join('')}</section>`
    + `<div class="columns"><section class="panel"><div class="panel-head"><div><h2>Fortschritt nach Ökosystem</h2><p>Abgeschlossene Level im Verhältnis zum Lernumfang</p></div></div>${data.ecosystems.length ? data.ecosystems.map((item) => progress(item)).join('') : empty('Noch kein Lernfortschritt', 'Sobald Ihre Klassen lernen, erscheinen hier die Ökosysteme.')}</section><section class="panel"><div class="panel-head"><div><h2>Letzte Entdeckungen</h2><p>Zuletzt abgeschlossene Level</p></div></div>${data.recentActivity.length ? `<ul class="activity">${data.recentActivity.map((item) => `<li><span class="avatar" aria-hidden="true">${safe(item.displayName?.slice(0, 1))}</span><div><strong>${safe(item.displayName)}</strong><p>${safe(item.levelTitle)} · ${safe(item.className)}</p><time datetime="${safe(item.completedAt)}">${safe(date(item.completedAt))}</time></div></li>`).join('')}</ul>` : empty('Die erste Entdeckung wartet', 'Neue Lernabschlüsse werden hier sichtbar.')}</section></div>`;
  $('refresh-view').onclick = () => show();
}
function renderClasses(data) {
  $('content').innerHTML = heading('Meine Klassen', 'Ein Ort für jede Lerngruppe. Öffnen Sie eine Klasse, um den Lernstand zu begleiten.', data.classes.length < 100 ? action('＋ Klasse anlegen', 'create-class') : '<span class="count">100 Klassen erreicht</span>')
    + (data.classes.length ? `<div class="class-grid">${data.classes.map((item) => `<article class="class-card"><span class="class-icon" aria-hidden="true">❧</span><h2>${safe(item.name)}</h2><p>${safe(item.description || 'Gemeinsam die Pflanzenwelt entdecken.')}</p><span class="class-meta">${number.format(item.studentCount)} Lernende · Angelegt ${safe(date(item.createdAt))}</span><button class="secondary" data-class="${safe(item.id)}" aria-label="Klasse ${safe(item.name)} öffnen">Klasse öffnen →</button></article>`).join('')}</div>` : `<section class="panel">${empty('Platz für Ihre erste Klasse', 'Legen Sie eine Klasse für Ihre Lerngruppe an.')}</section>`);
  $('create-class')?.addEventListener('click', createClass);
  document.querySelectorAll('[data-class]').forEach((button) => { button.onclick = () => show('class', button.dataset.class); });
}
function renderClass(data) {
  $('content').innerHTML = '<button id="back" class="quiet">← Alle Klassen</button>' + heading(data.class.name, data.class.description || 'Lernfortschritte begleiten und Schülerkonten verwalten.', canManage() ? (data.students.length < 500 ? action('＋ Schülerkonto erstellen', 'create-student') : '<span class="count">500 Schülerkonten erreicht</span>') : '<span class="count">Kontoverwaltung derzeit nicht verfügbar</span>')
    + `<div class="toolbar"><label for="student-search">Lernende suchen<input id="student-search" type="search" placeholder="Name oder Benutzername" autocomplete="off"></label><span id="student-count" class="count" role="status">${number.format(data.students.length)} Lernende</span></div><div id="students" class="students"></div>`;
  $('back').onclick = () => show('classes');
  $('create-student')?.addEventListener('click', () => createStudent(data.class));
  const render = () => {
    const query = $('student-search').value.trim().toLocaleLowerCase('de');
    const students = data.students.filter((student) => `${student.displayName} ${student.username}`.toLocaleLowerCase('de').includes(query));
    $('student-count').textContent = `${number.format(students.length)} von ${number.format(data.students.length)} Lernenden`;
    $('students').innerHTML = students.length ? students.map((student) => `<article class="student"><div class="student-header"><div class="identity"><span class="avatar" aria-hidden="true">${safe(student.displayName?.slice(0, 1))}</span><div><h2>${safe(student.displayName)}</h2><p>${safe(student.username)}${student.email ? ` · ${safe(student.email)}` : ''}</p></div></div><span class="badge ${student.enabled ? '' : 'locked'}">${student.enabled ? 'Aktiv' : 'Gesperrt'}</span></div><div class="student-summary">${progress(student, 'Gesamtfortschritt')}<p>Letzte Aktivität: ${safe(date(student.lastActivityAt))}</p></div><details><summary>Fortschritt pro Ökosystem</summary><div class="student-ecosystems">${student.ecosystems.length ? student.ecosystems.map((item) => progress(item)).join('') : '<p class="subtitle">Noch keine Ökosysteme verfügbar.</p>'}</div></details>${canManage() ? `<div class="student-actions"><button class="secondary" data-reset="${safe(student.id)}">Passwort zurücksetzen<span class="sr-only"> für ${safe(student.displayName)}</span></button><button class="secondary" data-toggle="${safe(student.id)}">${student.enabled ? 'Konto sperren' : 'Konto aktivieren'}<span class="sr-only"> für ${safe(student.displayName)}</span></button></div>` : ''}</article>`).join('') : `<section class="panel">${empty(query ? 'Keine passenden Lernenden' : 'Hier beginnt Ihre Lerngruppe', query ? 'Versuchen Sie einen anderen Namen.' : canManage() ? 'Erstellen Sie das erste Schülerkonto für diese Klasse.' : 'Diese Klasse enthält noch keine Schülerkonten.')}</section>`;
    document.querySelectorAll('[data-reset]').forEach((button) => { button.onclick = () => resetPassword(data.students.find((student) => student.id === button.dataset.reset)); });
    document.querySelectorAll('[data-toggle]').forEach((button) => { button.onclick = () => toggleStudent(data.students.find((student) => student.id === button.dataset.toggle)); });
  };
  $('student-search').oninput = render; render();
}
function openDialog(title, content) {
  dialogTrigger = document.activeElement;
  $('dialog').innerHTML = `<button class="close" type="button" aria-label="Dialog schließen">×</button><h2 id="dialog-title">${safe(title)}</h2>${content}`;
  $('dialog').querySelector('.close').onclick = () => $('dialog').close();
  $('dialog').showModal();
}
function bindForm(task) {
  const form = $('dialog').querySelector('form');
  form.onsubmit = async (event) => {
    event.preventDefault(); if (!form.reportValidity()) return;
    const submit = form.querySelector('[type=submit]'); const error = form.querySelector('.form-error');
    submit.disabled = true; form.setAttribute('aria-busy', 'true'); error.hidden = true;
    const closingButtons = $('dialog').querySelectorAll('.close, [data-cancel]');
    closingButtons.forEach((button) => { button.disabled = true; });
    try { await task(new FormData(form)); }
    catch (failure) { const message = failure instanceof TypeError ? 'Die Antwort konnte nicht empfangen werden. Bitte laden Sie die Klasse neu, bevor Sie die Aktion erneut ausführen.' : failure.message; if (form.isConnected && $('dialog').open) { error.textContent = message; error.hidden = false; } else notice(message, true); }
    finally { submit.disabled = false; form.removeAttribute('aria-busy'); closingButtons.forEach((button) => { button.disabled = false; }); }
  };
  form.querySelector('[data-cancel]').onclick = () => $('dialog').close();
}
const formEnd = (label) => `<p class="form-error" role="alert" hidden></p><div class="dialog-actions"><button type="button" class="secondary" data-cancel>Abbrechen</button><button type="submit">${label}</button></div>`;
function createClass() {
  openDialog('Eine neue Klasse', '<p>Geben Sie Ihrer Lerngruppe einen eigenen Platz. Bis zu 100 Klassen sind möglich.</p><form><label>Klassenname<input name="name" required maxlength="100" autocomplete="off" autofocus></label><label>Beschreibung <span class="field-hint">Optional</span><textarea name="description" maxlength="1000"></textarea></label>' + formEnd('Klasse anlegen') + '</form>');
  bindForm(async (values) => {
    const name = values.get('name').trim(); if (!name) throw new Error('Bitte geben Sie einen Klassennamen ein.');
    const description = values.get('description').trim();
    const created = await api('/classes', { method: 'POST', body: { name, ...(description ? { description } : {}) } });
    $('dialog').close(); notice('Die Klasse wurde angelegt.'); await show(uuid(created.id) ? 'class' : 'classes', created.id);
  });
}
function createStudent(klass) {
  if (!uuid(klass.id)) return notice('Ungültige Klassen-ID.', true);
  openDialog('Schülerkonto erstellen', `<p>Neues Konto für ${safe(klass.name)}. Das temporäre Passwort wird anschließend einmal angezeigt.</p><form><label>Benutzername<input name="username" required minlength="3" maxlength="64" pattern="[a-z0-9][a-z0-9._\\-]{2,63}" title="3–64 Zeichen: Kleinbuchstaben a–z, Zahlen, Punkt, Unterstrich oder Bindestrich. Beginn mit Buchstabe oder Zahl." aria-describedby="username-hint" autocomplete="off" autocapitalize="none" spellcheck="false" autofocus><span id="username-hint" class="field-hint">3–64 Zeichen: a–z, 0–9, Punkt, Unterstrich oder Bindestrich. Beginn mit Buchstabe oder Zahl.</span></label><label>Anzeigename<input name="displayName" required maxlength="100" autocomplete="off"></label><label>E-Mail-Adresse <span class="field-hint">Optional · Ohne E-Mail-Adresse ist ebenfalls ein Konto möglich.</span><input name="email" type="email" maxlength="254" aria-describedby="email-hint" autocomplete="off"><span id="email-hint" class="field-hint">Eine angegebene E-Mail-Adresse muss bei der Anmeldung bestätigt werden.</span></label>${formEnd('Konto erstellen')}</form>`);
  bindForm(async (values) => {
    const username = values.get('username').trim(), displayName = values.get('displayName').trim(), email = values.get('email').trim();
    if (!username || !displayName) throw new Error('Benutzername und Anzeigename dürfen nicht leer sein.');
    if (!/^[a-z0-9][a-z0-9._-]{2,63}$/.test(username)) throw new Error('Bitte wählen Sie einen Benutzernamen mit 3–64 zulässigen Zeichen, beginnend mit Buchstabe oder Zahl.');
    const result = await api(`/classes/${klass.id}/students`, { method: 'POST', body: { username, displayName, ...(email ? { email } : {}) } });
    showPassword(result.temporaryPassword, result.student.displayName, 'Das Schülerkonto wurde erstellt.');
    await show('class', klass.id, false);
  });
}
function resetPassword(student) {
  if (!uuid(student.id)) return notice('Ungültige Schüler-ID.', true);
  openDialog('Passwort zurücksetzen?', `<p>Für ${safe(student.displayName)} wird ein neues temporäres Passwort erzeugt. Das bisherige Passwort wird ungültig.</p><form>${formEnd('Passwort zurücksetzen')}</form>`);
  bindForm(async () => {
    const result = await api(`/students/${student.id}/reset-password`, { method: 'POST', body: {} });
    showPassword(result.temporaryPassword, student.displayName, 'Das Passwort wurde zurückgesetzt.');
  });
}
function showPassword(password, name, message) {
  if (!session || !$('dialog').open) return;
  if (typeof password !== 'string' || !password) { $('dialog').close(); notice('Die Aktion wurde ausgeführt, aber kein temporäres Passwort zurückgegeben. Bitte das Passwort erneut zurücksetzen.', true); return; }
  // The password exists only in this dialog's DOM. Closing removes the entire DOM.
  $('dialog').innerHTML = `<h2 id="dialog-title">Temporäres Passwort</h2><p>${safe(message)} Für ${safe(name)}:</p><label>Passwort<input id="temporary-password" class="secret" readonly autocomplete="off" spellcheck="false"></label><p class="secret-warning">Nur jetzt sichtbar. Übergeben Sie das Passwort vertraulich an die Schülerin oder den Schüler. Nach dem Schließen lässt es sich hier nicht erneut anzeigen.</p><p id="copy-status" role="status"></p><div class="dialog-actions"><button id="copy-password" class="secondary">Passwort kopieren</button><button id="close-password" autofocus>Passwort erhalten · Schließen</button></div>`;
  $('temporary-password').value = password;
  $('copy-password').onclick = async () => {
    const input = $('temporary-password'), status = $('copy-status');
    try { await navigator.clipboard.writeText(input.value); if (status.isConnected) status.textContent = 'Kopiert. Bitte nach der Übergabe aus der Zwischenablage entfernen.'; }
    catch { if (input.isConnected) { input.focus(); input.select(); status.textContent = 'Bitte das markierte Passwort mit Strg+C bzw. ⌘C kopieren.'; } }
  };
  $('close-password').onclick = () => $('dialog').close(); $('close-password').focus();
}
function toggleStudent(student) {
  if (!uuid(student.id)) return notice('Ungültige Schüler-ID.', true);
  const enabled = !student.enabled;
  openDialog(enabled ? 'Konto aktivieren?' : 'Konto sperren?', `<p>${safe(student.displayName)} kann sich ${enabled ? 'anschließend wieder anmelden.' : 'anschließend nicht mehr anmelden. Der Lernfortschritt bleibt erhalten.'}</p><form>${formEnd(enabled ? 'Konto aktivieren' : 'Konto sperren')}</form>`);
  bindForm(async () => { await api(`/students/${student.id}`, { method: 'PATCH', body: { enabled } }); $('dialog').close(); notice(enabled ? 'Das Konto wurde aktiviert.' : 'Das Konto wurde gesperrt.'); await show('class', selectedClass); });
}
async function boot() {
  window.addEventListener('pagehide', () => signedOut('Bitte anmelden, um Ihre Klassen zu öffnen.'));
  window.addEventListener('pageshow', (event) => { if (event.persisted) signedOut('Bitte anmelden, um Ihre Klassen zu öffnen.'); });
  $('dialog').addEventListener('cancel', (event) => { if ($('dialog').querySelector('form[aria-busy="true"]')) event.preventDefault(); });
  $('dialog').addEventListener('close', () => { $('dialog').replaceChildren(); if (dialogTrigger?.isConnected) dialogTrigger.focus(); else if (session) $('content').focus(); dialogTrigger = undefined; });
  $('login').onclick = () => login().catch(() => { $('welcome-message').textContent = 'Die Anmeldung konnte nicht gestartet werden. Bitte laden Sie die Seite erneut.'; });
  document.querySelectorAll('[data-page]').forEach((button) => { button.onclick = () => show(button.dataset.page); });
  $('brand').onclick = (event) => { event.preventDefault(); show('dashboard'); };
  $('logout').onclick = () => {
    const hint = idToken; sessionStorage.removeItem(authKey); signedOut('Sie wurden abgemeldet.');
    const url = new URL(`${config.issuer}/protocol/openid-connect/logout`);
    url.search = new URLSearchParams({ client_id: config.clientId, post_logout_redirect_uri: redirectUri, ...(hint ? { id_token_hint: hint } : {}) });
    location.replace(url);
  };
  // Consume the callback once and remove authorization parameters before any network call.
  const callback = new URL(location.href);
  const isCallback = ['code', 'error', 'state'].some((key) => callback.searchParams.has(key));
  let pending;
  if (isCallback) {
    const stored = sessionStorage.getItem(authKey); sessionStorage.removeItem(authKey);
    history.replaceState(null, '', redirectUri);
    try { pending = JSON.parse(stored || 'null'); } catch { pending = null; }
  }
  const response = await fetch('/config.json', { cache: 'no-store' });
  if (!response.ok) throw new Error('Die Portal-Konfiguration konnte nicht geladen werden.');
  config = await response.json();
  for (const key of ['apiBase', 'issuer']) {
    const url = new URL(config[key]);
    if (!['http:', 'https:'].includes(url.protocol) || url.username || url.password || url.search || url.hash) throw new Error('Ungültige Portal-Konfiguration.');
    config[key] = url.href.replace(/\/$/, '');
  }
  if (typeof config.clientId !== 'string' || !config.clientId) throw new Error('Der OIDC-Client fehlt in der Konfiguration.');
  if (!isCallback) { $('welcome-message').textContent = 'Ihre Klassen, Lernfortschritte und Schülerkonten an einem Ort.'; $('login').hidden = false; return; }
  if (!pending || callback.searchParams.get('state') !== pending.state || !pending.verifier || !Number.isFinite(pending.createdAt) || Date.now() - pending.createdAt > 600000 || pending.createdAt > Date.now()) throw new Error('Die Anmeldeantwort ist ungültig oder abgelaufen. Bitte erneut anmelden.');
  if (callback.searchParams.has('error')) throw new Error('Die Anmeldung wurde nicht abgeschlossen. Bitte erneut anmelden.');
  const code = callback.searchParams.get('code'); if (!code) throw new Error('Der Anmeldecode fehlt.');
  await exchange({ grant_type: 'authorization_code', code, redirect_uri: redirectUri, code_verifier: pending.verifier });
  session = await api('/session');
  if (!session.actor?.roles?.some((role) => ['lehrende', 'systemadministration'].includes(role))) throw new Error('Dieses Portal ist für Lehrende und die Systemadministration vorgesehen. Ihrem Konto fehlt die passende Rolle.');
  $('actor').textContent = session.actor.displayName;
  $('welcome').hidden = true; $('shell').hidden = false;
  await show('dashboard', undefined, false);
}
boot().catch((error) => signedOut(error.message));

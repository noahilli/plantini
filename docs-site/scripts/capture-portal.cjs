// Screenshots of the teacher portal. Local E2E stack + portal on :8085 (see mitmachen/setup.md).
//   node docs-site/scripts/capture-portal.cjs
const { chromium } = require('../../tools/e2e/node_modules/playwright-core');
const L = require('./capture-lib.cjs');
const PORTAL = 'http://127.0.0.1:8085';

(async () => {
  const teacher = await L.ensureUser(L.e2e(), `docs-lehrkraft-${new Date().toISOString().slice(0, 16).replace(/[-:T]/g, '')}@plantini.test`, 'Frau', 'Beispiel', ['lehrende']);
  const browser = await chromium.launch({ executablePath: '/usr/bin/chromium', args: ['--no-sandbox'] });
  const ctx = await browser.newContext({ viewport: { width: 1360, height: 860 }, deviceScaleFactor: 1, locale: 'de-DE' });
  const page = await ctx.newPage();
  page.on('dialog', (d) => d.accept());
  await page.goto(PORTAL, { waitUntil: 'domcontentloaded' });
  await L.sleep(1500);
  await L.shot(page, 'portal-willkommen');
  await page.click('#login');
  await page.waitForSelector('#username', { timeout: 30000 });
  await page.fill('#username', teacher.email); await page.fill('#password', teacher.password); await page.click('#kc-login');
  await page.waitForSelector('#shell:not([hidden])', { timeout: 30000 });
  await L.sleep(2500);
  await L.shot(page, 'portal-uebersicht');
  await page.getByRole('button', { name: /Meine Klassen/ }).first().click(); await L.sleep(1500);
  await L.shot(page, 'portal-klassen-leer');
  await page.getByRole('button', { name: /Klasse anlegen|Neue Klasse|anlegen/ }).first().click(); await L.sleep(800);
  await L.shot(page, 'portal-klasse-dialog');
  await page.fill('#dialog input[name="name"]', '5b Naturkunde');
  const desc = page.locator('#dialog [name="description"]'); if (await desc.count()) await desc.fill('Pflanzenkunde im Schulgarten, Schuljahr 2026/27');
  await page.locator('#dialog').getByRole('button', { name: 'Klasse anlegen' }).click(); await L.sleep(2200);
  await L.shot(page, 'portal-klasse');
  await page.getByRole('button', { name: /Schülerkonto|Schüler.*(erstellen|hinzufügen)|Konto/ }).first().click(); await L.sleep(900);
  await L.shot(page, 'portal-schueler-dialog');
  await page.fill('#dialog input[name="username"]', 'mira-' + Date.now().toString(36).slice(-5));
  await page.fill('#dialog input[name="displayName"]', 'Mira B.');
  await L.shot(page, 'portal-schueler-dialog');
  await page.locator('#dialog').getByRole('button', { name: 'Konto erstellen' }).click(); await L.sleep(2500);
  // The one-time password is real (of a throw-away local account) - never put it in a picture.
  await page.evaluate(() => { const f = document.querySelector('#temporary-password'); if (f) f.value = '••••••••••••••••••'; });
  await L.shot(page, 'portal-passwort');
  await page.keyboard.press('Escape'); await L.sleep(800);
  await page.evaluate(() => document.querySelector('#dialog')?.close?.());
  await L.sleep(800);
  await L.shot(page, 'portal-klasse-mit-schueler');
  await page.getByRole('button', { name: /Alle Klassen/ }).first().click(); await L.sleep(1500);
  await L.shot(page, 'portal-klassen');
  await browser.close();
})().catch((e) => { console.error('ERR', e.stack.split('\n').slice(0, 4).join('\n')); process.exit(1); });

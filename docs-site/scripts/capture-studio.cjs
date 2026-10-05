// Screenshots and frames of the Studio. Local E2E stack + Studio on :8084 (see mitmachen/setup.md).
//   node docs-site/scripts/capture-studio.cjs
const { chromium } = require('../../tools/e2e/node_modules/playwright-core');
const L = require('./capture-lib.cjs');
const STUDIO = 'http://127.0.0.1:8084';

async function login(browser, email, password) {
  const ctx = await browser.newContext({ viewport: { width: 1360, height: 860 }, deviceScaleFactor: 1, locale: 'de-DE' });
  const page = await ctx.newPage();
  await page.goto(STUDIO, { waitUntil: 'domcontentloaded' });
  await page.waitForSelector('#username', { timeout: 30000 });
  await page.fill('#username', email); await page.fill('#password', password); await page.click('#kc-login');
  await page.waitForSelector('#shell:not([hidden])', { timeout: 30000 });
  await L.sleep(2500);
  return { ctx, page };
}

(async () => {
  const env = L.studio();
  const browser = await chromium.launch({ executablePath: '/usr/bin/chromium', args: ['--no-sandbox'] });
  const editor = await login(browser, env.EDITOR_EMAIL, env.EDITOR_PASSWORD);
  const p = editor.page;
  const nav = (page) => (name) => page.click(`[data-page="${name}"]`).then(() => L.sleep(1500));
  await L.shot(p, 'studio-uebersicht');
  await nav(p)('catalog');
  await L.shot(p, 'studio-inhalte');
  await p.fill('#catalog-search', 'Edelweiß'); await L.sleep(800);
  await L.shot(p, 'studio-inhalte-suche');
  // open the first plant chip/button of the filtered tree
  await p.locator('#catalog-tree [data-type="plant"]').first().click(); await L.sleep(1800);
  await L.shot(p, 'studio-editor');
  await L.frame(p, 'anim-studio-entwurf');
  // edit the description (first textarea) and save the draft
  const area = p.locator('#drawer-body textarea').first();
  await area.fill((await area.inputValue()) + '\n\nErgänzung aus dem Handbuch-Beispiel: wächst auf kalkreichen Böden.');
  await L.frame(p, 'anim-studio-entwurf');
  await p.getByRole('button', { name: 'Entwurf speichern' }).click(); await L.sleep(1500);
  await L.shot(p, 'studio-entwurf-gespeichert');
  await L.frame(p, 'anim-studio-entwurf');
  await p.getByRole('button', { name: 'Zum Review einreichen' }).click(); await L.sleep(2000);
  await L.frame(p, 'anim-studio-entwurf');
  await nav(p)('review');
  await L.shot(p, 'studio-review-autor');
  try { await nav(p)('team'); await L.shot(p, 'studio-team'); } catch (e) { console.log('team:', e.message); }
  await editor.ctx.close();

  const reviewer = await login(browser, env.REVIEWER_EMAIL, env.REVIEWER_PASSWORD);
  const r = reviewer.page;
  r.on('dialog', (d) => d.accept(d.type() === 'prompt' ? 'Fachlich geprüft: Quellen und Angaben passen zur Art.' : undefined));
  await nav(r)('review');
  await L.shot(r, 'studio-review');
  await L.frame(r, 'anim-studio-review');
  await r.locator('#page-review button', { hasText: /Prüfen|Öffnen|Ansehen/ }).first().click().catch(() => r.locator('#page-review .change-row button').first().click());
  await L.sleep(1800);
  await L.shot(r, 'studio-review-detail');
  await L.frame(r, 'anim-studio-review');
  await r.getByRole('button', { name: 'Fachlich freigeben' }).click(); await L.sleep(2200);
  await L.frame(r, 'anim-studio-review');
  await L.shot(r, 'studio-review-freigegeben');
  await nav(r)('dashboard');
  await L.shot(r, 'studio-uebersicht-reviewer');
  await reviewer.ctx.close();
  await browser.close();
})().catch((e) => { console.error('ERR', e.stack.split('\n').slice(0, 4).join('\n')); process.exit(1); });

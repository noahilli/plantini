// Screenshots and animation frames of the app for the handbook.
//   node docs-site/scripts/capture-app.cjs [section,...]
// Needs the local E2E stack and the app built for it on :3000 (see mitmachen/setup.md).
// Sections: login,pick,profile,home,path,daytime,level,quiz,field,herbarium
const { chromium } = require('../../tools/e2e/node_modules/playwright-core');
const L = require('./capture-lib.cjs');
const fs = require('node:fs');
const path = require('node:path');
const APP = 'http://127.0.0.1:3000';
const NAV = { Home: [39, 800], Lernen: [117, 800], Expedition: [195, 800], Herbarium: [273, 800], Profil: [351, 800] };
const CHIP = { Automatisch: [90, 350], Morgen: [190, 350], Mittag: [265, 350], Abend: [69, 386], Nacht: [140, 386] };
const PHOTOS = path.join(L.ROOT, 'apps/homepage/public/photos');
const want = (process.argv[2] || 'login,pick,profile,home,path,daytime,level,quiz,field,herbarium').split(',');

(async () => {
  const user = await L.ensureUser(L.e2e(), process.env.DOCS_USER || `docs-lernende-${new Date().toISOString().slice(0, 16).replace(/[-:T]/g, '')}@plantini.test`, 'Mira', 'Beispiel');
  const browser = await chromium.launch({ executablePath: '/usr/bin/chromium',
    args: ['--no-sandbox', '--use-angle=gl', '--ignore-gpu-blocklist', '--enable-gpu-rasterization'] });
  const ctx = await browser.newContext({ viewport: { width: 390, height: 844 }, deviceScaleFactor: 2, locale: 'de-DE',
    timezoneId: 'Europe/Berlin', geolocation: { latitude: 48.4013, longitude: 9.9876 }, permissions: ['geolocation'] });
  const page = await ctx.newPage();
  let bearer;
  page.on('request', (r) => { const a = r.headers()['authorization']; if (a && r.url().startsWith(L.API)) bearer = a; });
  const click = async (xy, wait = 1500) => { await page.mouse.click(...xy); await L.sleep(wait); };
  const step = async (name, fn) => { if (!want.includes(name)) return; try { await fn(); console.log('ok  ', name); } catch (e) { console.log('FAIL', name, e.message.split('\n')[0]); } };

  await page.goto(APP, { waitUntil: 'domcontentloaded' });
  await L.sleep(6500);
  await step('login', async () => { await L.shot(page, 'app-login'); });
  await page.evaluate(() => document.querySelector('flt-semantics-placeholder')?.click());
  await L.sleep(800);
  await page.getByRole('button', { name: 'Anmelden' }).first().click({ force: true });
  await page.waitForSelector('#username', { timeout: 60000 });
  await page.fill('#username', user.email); await page.fill('#password', user.password);
  await step('login', async () => { await page.fill('#password', ''); await L.shot(page, 'app-keycloak-login'); await page.fill('#password', user.password); });
  await page.click('#kc-login');
  await page.waitForURL((u) => u.origin === APP && !u.searchParams.has('code') && u.pathname !== '/auth/callback', { timeout: 60000 });
  await L.sleep(6000);

  if (page.url().includes('character')) {
    await step('pick', async () => {
      await L.shot(page, 'app-charakter');
      for (const x of [315, 195]) {                         // Samira, then Mei
        await page.mouse.move(x, 690); await L.sleep(200);
        await page.mouse.down(); await L.sleep(80); await page.mouse.up();
        await L.sleep(1400);
        await L.frame(page, 'anim-charakter');
      }
      await L.shot(page, 'app-charakter-mei');
    });
    await click([195, 534], 7000);   // "Ich bin Mei"
  }

  // Pin the sky to midday so every picture has the same light.
  await click(NAV.Profil, 3000);
  await click(CHIP.Mittag, 1200);
  await step('profile', async () => { await L.shot(page, 'app-profil'); });

  await step('home', async () => {
    await click(NAV.Home, 5000);
    await L.shot(page, 'app-home');
  });

  await step('path', async () => {
    await click(NAV.Lernen, 4000);
    await L.shot(page, 'app-lernen');
    await click([195, 420], 6000);
    await L.shot(page, 'app-pfad');
  });

  await step('daytime', async () => {
    const order = ['Morgen', 'Mittag', 'Abend', 'Nacht'];
    for (const phase of order) {
      await click(NAV.Profil, 2500);
      await click(CHIP[phase], 1000);
      await click(NAV.Lernen, 3500);
      await click([195, 420], 6000);
      await L.frame(page, 'anim-pfad-tageszeit');
      if (phase === 'Nacht') await L.shot(page, 'app-pfad-nacht');
    }
    await click(NAV.Profil, 2500);
    await click(CHIP.Mittag, 1000);
  });

  await step('level', async () => {
    await click(NAV.Lernen, 3500);
    await click([195, 420], 6000);
    await click([95, 601], 4000);            // station 1
    await L.shot(page, 'app-level');
    await page.mouse.wheel(0, 500); await L.sleep(900);
    await L.shot(page, 'app-level-2');
  });
  await step('quiz', async () => {
    await click(NAV.Lernen, 3500);
    await click([195, 420], 6000);
    await click([95, 601], 4000);
    await page.mouse.wheel(0, 500); await L.sleep(900);
    await click([195, 723], 4500);
    await L.shot(page, 'app-quiz-start');
    await L.shot(page, 'app-steckbrief');
    for (let i = 1; i <= 4; i++) { await page.mouse.wheel(0, 3000); await L.sleep(900); }
    await L.shot(page, 'app-steckbrief-ende');
    await click([195, 693], 3500);
    await L.shot(page, 'app-quiz');
    const run = async (answers, animate) => {
      for (let q = 0; q < 3; q++) {
        await click([195, answers[q]], 1200);               // pick an answer
        if (animate) await L.frame(page, 'anim-quiz');
        await page.mouse.wheel(0, 600); await L.sleep(600);
        await click([195, 725], 3000);                       // Weiter / Level abschließen
      }
    };
    await run([539, 574, 539], true);                        // 1 of 3 correct -> "Fast geschafft"
    await L.shot(page, 'app-quiz-ergebnis-fast');
    await L.frame(page, 'anim-quiz');
  });
  await step('field', async () => {
    await click(NAV.Expedition, 3000);
    await L.shot(page, 'app-feld');
    const chooser = page.waitForEvent('filechooser', { timeout: 10000 });
    await click([207, 728], 500);
    await (await chooser).setFiles(path.join(PHOTOS, 'stieleiche-1.jpg'));
    await L.sleep(3500);
    await L.shot(page, 'app-feld-foto');
    await L.frame(page, 'anim-feld');
    await page.mouse.click(195, 676);                       // "Pflanze bestimmen"
    for (let i = 0; i < 5; i++) { await L.sleep(110); await L.frame(page, 'anim-feld'); }
    await L.sleep(3500);
    await L.shot(page, 'app-ergebnis');
    await L.frame(page, 'anim-feld');
    await click([234, 400], 900);                           // choose "Stieleiche"
    await click([322, 664], 900);                           // "Fundort privat speichern"
    await L.shot(page, 'app-ergebnis-wahl');
    await L.frame(page, 'anim-feld');
    await click([195, 750], 6000);                          // "Ergebnis speichern" -> Herbarium
    await L.shot(page, 'app-herbarium-nach-speichern');
  });

  await step('herbarium', async () => {
    if (bearer) {
      console.log(JSON.stringify(await L.seedFind(bearer, path.join(PHOTOS, 'rotbuche-1.jpg'), { latitude: 48.3984, longitude: 9.9921, accuracyMeters: 400 }, 1, 2)));
      console.log(JSON.stringify(await L.seedFind(bearer, path.join(PHOTOS, 'bergahorn-1.jpg'), { latitude: 48.4122, longitude: 9.9704, accuracyMeters: 400 }, 0, 5)));
    } else { console.log('no bearer');
    }
    await click(NAV.Herbarium, 3000);
    await click([195, 120], 3500);                          // tab "Beobachtungen"
    await page.getByText('Synchronisieren').first().click({ force: true }).catch(() => {});
    await L.sleep(2500);
    await L.shot(page, 'app-herbarium-liste');
    await click([313, 120], 9000);                          // tab "Karte"
    await L.shot(page, 'app-herbarium-karte');
    await click([335, 560], 2500);                          // open the card of a pin
    await L.shot(page, 'app-herbarium-pin');
    await click(NAV.Herbarium, 2000);
    await click([195, 120], 2500);
    await click([100, 330], 4000);                          // first entry -> detail
    await L.shot(page, 'app-herbarium-detail');
    await click(NAV.Herbarium, 2500);
    await click([77, 120], 3000);                           // tab "Sammlung"
    await L.shot(page, 'app-herbarium-sammlung');
    await page.mouse.wheel(0, 700); await L.sleep(900);
    await L.shot(page, 'app-herbarium-sammlung-2');
  });
  fs.writeFileSync(path.join(L.FRAMES, 'bearer.txt'), bearer || '');
  await browser.close();
})().catch((e) => { console.error('ERR', e.stack.split('\n').slice(0, 3).join('\n')); process.exit(1); });

// Writes changelog/index.html from src/changelog.json (newest first; run `npm run changelog`).
// The page is plain HTML so it reads without JavaScript; src/changelog.js adds the filter.
import { readFile, writeFile, mkdir } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const data = JSON.parse(await readFile(join(root, 'src/changelog.json'), 'utf8'));
const esc = (s) => s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
// `code` marks inline code with backticks in the data.
const text = (s) => esc(s).replace(/`([^`]+)`/g, '<code>$1</code>');
const months = ['Januar', 'Februar', 'März', 'April', 'Mai', 'Juni', 'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember'];
const date = (iso) => { const [y, m, d] = iso.split('-').map(Number); return `${d}. ${months[m - 1]} ${y}`; };
const apps = new Map(data.apps.map((a) => [a.id, a]));

const entries = [...data.entries].sort((a, b) => b.date.localeCompare(a.date));
const chips = [`<button type="button" class="chip" data-filter="all" aria-pressed="true">Alle</button>`]
  .concat(data.apps.map((a) => `<button type="button" class="chip" data-filter="${a.id}" aria-pressed="false" title="${esc(a.detail)}">${esc(a.name)}</button>`)).join('');
const list = entries.map((e) => {
  const app = apps.get(e.app);
  const id = `${e.app}-${e.version || e.date}`;
  return `<article class="entry" id="${id}" data-app="${e.app}">
<header class="entry-head"><span class="badge badge-${e.app}">${esc(app.name)}</span>${e.version ? `<span class="version">Version ${esc(e.version)}</span>` : ''}<time datetime="${e.date}">${date(e.date)}</time></header>
<h2>${esc(e.title)}</h2>
<ul class="plain">${e.changes.map((c) => `<li>${text(c)}</li>`).join('')}</ul>
</article>`;
}).join('\n');
const legend = data.apps.map((a) => `<li><strong>${esc(a.name)}</strong>: ${esc(a.detail)}</li>`).join('');

const html = `<!doctype html>
<html lang="de"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><meta name="description" content="Änderungsprotokoll von Plantini: App, Webseite, Studio, Lehrendenportal, Plattform und Handbuch."><link rel="icon" href="/favicon.svg" type="image/svg+xml"><script type="module" src="/src/changelog.js"></script><title>Änderungen – Plantini</title></head>
<body><header class="nav scrolled"><div class="wrap nav-inner"><a class="brand" href="/"><svg class="brand-mark" viewBox="0 0 64 64" aria-hidden="true"><rect width="64" height="64" rx="16" fill="currentColor"/><path d="M32 50V30M32 30c0-10 7-16 17-17 1 10-5 17-17 17ZM32 38c0-8-6-13-15-14-1 9 4 14 15 14Z" fill="none" stroke="#F7F1E5" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/></svg><span>Plantini</span></a><a class="btn btn-small" href="/">Zur Startseite</a></div></header>
<main class="wrap article changelog" id="inhalt">
<p class="eyebrow">Änderungen</p>
<h1>Was sich wann geändert hat</h1>
<p class="lead">Das Änderungsprotokoll aller Teile von Plantini, neueste Einträge zuerst. Plantini ist ein früher, unvollständiger Stand (siehe <a href="/technik/#projektstand">Hinweis zum Stand des Projekts</a>); die Einträge beschreiben, was tatsächlich ausgerollt wurde. Die Versionen vor dem 7. Oktober 2026 sind nachgetragen.</p>
<div class="chips" role="group" aria-label="Nach Teil filtern">${chips}</div>
<div class="entries">
${list}
</div>
<h2 id="teile">Die Teile von Plantini</h2>
<ul class="plain">${legend}</ul>
<p class="diagram-note">Nur die App hat Versionsnummern (Android-Testversion zum Download auf der <a href="/#software">Startseite</a>). Alle anderen Teile werden fortlaufend ausgerollt und sind deshalb nach Datum geführt.</p>
</main><footer class="footer"><div class="wrap footer-inner"><nav class="footer-links" aria-label="Rechtliches"><a href="/">Startseite</a><a href="/technik/">So ist Plantini gebaut</a><a href="/impressum/">Impressum</a><a href="/datenschutz/">Datenschutz</a><a href="/bildnachweise/">Bildnachweise</a><a href="https://docs.plantini.eu/" target="_blank" rel="noopener noreferrer">Entwicklerhandbuch</a></nav></div></footer></body></html>
`;
await mkdir(join(root, 'changelog'), { recursive: true });
await writeFile(join(root, 'changelog/index.html'), html);
console.log(`changelog/index.html: ${entries.length} entries`);

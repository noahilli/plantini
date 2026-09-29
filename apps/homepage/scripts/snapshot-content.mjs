#!/usr/bin/env node
// Builds src/content.json and public/photos/* from the published Plantini
// content, so the homepage has no runtime dependency on the API.
//
// Only photos under licences that permit public, commercial reuse with
// attribution are taken (CC0, public domain, CC BY, CC BY-SA). Every photo
// keeps author, licence and source link. Nothing "unverified" or NC/ND.
//
// Usage: node scripts/snapshot-content.mjs [api-origin]   (default https://api.plantini.eu)
import { createRequire } from 'node:module';
import { mkdir, rm, writeFile } from 'node:fs/promises';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const root = path.resolve(fileURLToPath(new URL('..', import.meta.url)));
const platform = path.resolve(root, '../../services/platform');
const require = createRequire(path.join(platform, 'package.json'));
const demo = require(path.join(platform, 'src/api/platform/services/core/content/demo-content.de.json'));
const { stableContentId } = require(path.join(platform, 'src/api/platform/services/core/content/demo-content.js'));

const origin = new URL(process.argv[2] || 'https://api.plantini.eu');
const ALLOWED = { cc0: 'CC0 1.0', pd: 'Gemeinfrei', 'cc-by': 'CC BY', 'cc-by-sa': 'CC BY-SA' };
const ORDER = [
  ['mitteleuropaeischer-laubwald', 'wald', 'Wald', 'forest'],
  ['artenreiche-wiese', 'wiese', 'Wiese', 'meadow'],
  ['alpenraum', 'alpen', 'Alpen', 'alpine'],
];
const STATIONS = 6;
// Editorial choice of the photo shown first (1-based index in API order); the
// automatic order sometimes leads with a fruit or a detail shot.
const PREFERRED_FIRST = { 'acker-witwenblume': 2, hainbuche: 2, stieleiche: 2, 'wiesen-flockenblume': 2 };
const MAX_PHOTOS_PER_PLANT = 2;

async function getJson(url) {
  const response = await fetch(url, { signal: AbortSignal.timeout(60000) });
  if (!response.ok) throw new Error(`HTTP ${response.status} for ${url}`);
  return response.json();
}

await rm(path.join(root, 'public/photos'), { recursive: true, force: true });
await mkdir(path.join(root, 'public/photos'), { recursive: true });

const ecosystems = [];
for (const [slug, key, short, world] of ORDER) {
  const source = demo.ecosystems.find((item) => item.ecosystem.slug === slug);
  if (!source) throw new Error(`ecosystem ${slug} missing`);
  const plants = [];
  for (const plant of source.plants.slice(0, STATIONS)) {
    const id = stableContentId('plant', plant.slug);
    const live = await getJson(new URL(`/api/v1/plants/${id}`, origin));
    const photos = [];
    for (const media of live.media ?? []) {
      if (photos.length >= MAX_PHOTOS_PER_PLANT) break;
      if (!(media.license in ALLOWED) || !media.author || !media.source) continue;
      try {
        const response = await fetch(new URL(media.url, origin), { signal: AbortSignal.timeout(60000) });
        if (!response.ok) continue;
        const file = `${plant.slug}-${photos.length + 1}.jpg`;
        const bytes = Buffer.from(await response.arrayBuffer());
        // Pillow (Python) recompresses: sharp's native build is not available on every dev machine.
        const converted = spawnSync('python3', ['-c', [
          'import sys; from PIL import Image, ImageOps',
          'im = ImageOps.exif_transpose(Image.open(sys.stdin.buffer)).convert("RGB")',
          'im.thumbnail((1000, 1000)); im.save(sys.argv[1], "JPEG", quality=80, optimize=True, progressive=True)',
        ].join('\n'), path.join(root, 'public/photos', file)], { input: bytes });
        if (converted.status !== 0) throw new Error('image conversion failed');
        photos.push({
          file, alt: media.altText, author: media.author,
          license: media.license, licenseLabel: ALLOWED[media.license], source: media.source,
        });
      } catch { /* skip an unreachable photo */ }
    }
    const preferred = PREFERRED_FIRST[plant.slug];
    if (preferred && photos.length >= preferred) photos.unshift(...photos.splice(preferred - 1, 1));
    plants.push({
      slug: plant.slug, commonName: plant.commonName, scientificName: plant.scientificName,
      family: plant.family, description: plant.description, warning: plant.warning ?? null,
      notes: (plant.learningCards ?? []).slice(0, 3).map((card) => ({ heading: card.heading, text: card.text })),
      photos,
    });
    console.log(`${key} ${plant.slug}: ${photos.length} photo(s)`);
  }
  ecosystems.push({
    key, short, world, slug, name: source.ecosystem.name,
    description: source.ecosystem.description, plants,
  });
}
const out = { generatedAt: new Date().toISOString(), releaseVersion: 'demo', ecosystems };
await writeFile(path.join(root, 'src/content.json'), `${JSON.stringify(out, null, 2)}\n`);
console.log(`Wrote src/content.json with ${ecosystems.reduce((n, e) => n + e.plants.length, 0)} plants.`);

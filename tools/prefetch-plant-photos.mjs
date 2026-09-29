// Warm and audit all plants named by the active public content release.
// Public read endpoints only; no credentials, CMS writes or private data.
import { mkdir, writeFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { setDefaultResultOrder } from 'node:dns';
setDefaultResultOrder('ipv4first');
const base = new URL(process.argv[2] || 'http://127.0.0.1:1338');
if (base.hostname !== '127.0.0.1') throw Error('Use the local IPv4 stack.');
const output = resolve(process.argv[3] || 'artifacts/content/plant-photo-coverage.json');
async function get(path) {
  const response = await fetch(new URL(path, base), { signal: AbortSignal.timeout(20000) });
  if (!response.ok) throw Error(`HTTP ${response.status}`);
  return response;
}
const changes = await (await get('/api/v1/content/changes')).json();
const ids = [...new Set(changes.changes.filter(c => c.entity === 'plant' && c.operation === 'upsert').map(c => c.id))];
const plants = [];
for (const id of ids) {
  const row = { id, status: 'unavailable', photos: [] };
  try {
    const plant = await (await get(`/api/v1/plants/${id}`)).json();
    row.name = plant.commonName;
    row.scientificName = plant.scientificName;
    for (const media of plant.media || []) {
      const photo = { url: media.url, source: media.source, license: media.license, automatic: media.automatic, status: 'unavailable' };
      try {
        const url = new URL(media.url, base);
        if (url.origin !== base.origin) { photo.status = 'external-not-warmed'; }
        else {
          const r = await get(url);
          if (!r.headers.get('content-type')?.startsWith('image/')) throw Error('Not an image');
          photo.bytes = (await r.arrayBuffer()).byteLength;
          photo.status = photo.bytes ? 'available' : 'empty';
        }
      } catch (e) { photo.error = e.message; }
      row.photos.push(photo);
    }
    row.status = row.photos.some(p => p.status === 'available') ? 'available' : row.photos.length ? 'photo-unavailable' : 'no-photo-returned';
  } catch (e) { row.error = e.message; }
  plants.push(row);
  console.log(`${plants.length}/${ids.length} ${row.name || id}: ${row.status}`);
  // Sequential lookups respect the provider's existing cooldown; no retry storm.
}
const report = { checkedAt: new Date().toISOString(), releaseCursor: changes.cursor,
  total: plants.length, available: plants.filter(p => p.status === 'available').length, plants };
await mkdir(resolve(output, '..'), { recursive: true });
await writeFile(output, JSON.stringify(report, null, 2) + '\n');
console.log(`Available: ${report.available}/${report.total}; report: ${output}`);

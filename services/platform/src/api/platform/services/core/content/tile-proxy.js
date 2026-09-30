'use strict';

const https = require('node:https');
const { mkdir, readFile, rename, stat, writeFile } = require('node:fs/promises');
const path = require('node:path');

const MAX_BYTES = 256 * 1024;
const MAX_ZOOM = 18;
// OpenStreetMap's tile policy asks for caching of at least a week.
const REFRESH_MS = 14 * 86400000;
const MAX_PARALLEL = 6;
const { Limiter } = require('./limiter');
const PNG = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);

function download(z, x, y) {
  return new Promise((resolve, reject) => {
    const request = https.get(`https://tile.openstreetmap.org/${z}/${x}/${y}.png`, {
      family: 4,
      headers: { 'User-Agent': 'PlantiniBot/0.2 (+https://plantini.eu)' },
    }, (response) => {
      // No redirects: the provider cannot send the server elsewhere.
      if (response.statusCode !== 200) { response.resume(); reject(new Error(`Tile unavailable (${response.statusCode})`)); return; }
      let size = 0;
      const chunks = [];
      response.on('data', (chunk) => {
        size += chunk.length;
        if (size > MAX_BYTES) request.destroy(new Error('Tile too large'));
        else chunks.push(chunk);
      });
      response.on('error', reject);
      response.on('end', () => resolve(Buffer.concat(chunks)));
    });
    const timer = setTimeout(() => request.destroy(new Error('Tile timeout')), 6000);
    request.on('close', () => clearTimeout(timer));
    request.on('error', reject);
  });
}

/**
 * Map tiles for the herbarium map, fetched and cached by the server so the
 * app never contacts the tile provider (the provider would see every user's
 * IP address and the places they look at).
 */
class TileProxy {
  constructor({ root, fetchTile = download, clock } = {}) {
    this.root = root || path.join(process.env.PRIVATE_UPLOAD_DIR || '/opt/plantini-private-media', 'map-tiles');
    this.fetchTile = fetchTile;
    this.clock = clock || (() => Date.now());
    this.pending = new Map();
    this.limiter = new Limiter(MAX_PARALLEL);
  }

  static parse({ z, x, y }) {
    const zoom = Number(z);
    const tx = Number(x);
    const ty = Number(y);
    const limit = 2 ** zoom;
    if (![zoom, tx, ty].every(Number.isInteger) || zoom < 0 || zoom > MAX_ZOOM
        || tx < 0 || ty < 0 || tx >= limit || ty >= limit) return undefined;
    return { z: zoom, x: tx, y: ty };
  }

  async get(tile) {
    const key = `${tile.z}/${tile.x}/${tile.y}`;
    if (this.pending.has(key)) return this.pending.get(key);
    // Excess requests wait for a slot: a map opens with dozens of tiles at once.
    const work = this.limiter.run(() => this.load(tile, key)).finally(() => this.pending.delete(key));
    this.pending.set(key, work);
    return work;
  }

  async load(tile, key) {
    const target = path.join(this.root, `${key}.png`);
    let stale;
    try {
      const info = await stat(target);
      const bytes = await readFile(target);
      if (info.mtimeMs > this.clock() - REFRESH_MS) return bytes;
      stale = bytes;
    } catch { /* not cached yet */ }
    try {
      const bytes = await this.fetchTile(tile.z, tile.x, tile.y);
      if (!bytes.subarray(0, 8).equals(PNG)) throw new Error('Tile is not a PNG');
      await mkdir(path.dirname(target), { recursive: true });
      const temp = `${target}.${process.pid}.tmp`;
      await writeFile(temp, bytes);
      await rename(temp, target);
      return bytes;
    } catch (error) {
      if (stale) return stale; // a week-old tile beats a grey hole in the map
      throw error;
    }
  }
}

module.exports = { TileProxy };

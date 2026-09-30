'use strict';

const https = require('node:https');
const { createHash, randomUUID } = require('node:crypto');
const { mkdir, readFile, readdir, rename, writeFile, stat, unlink } = require('node:fs/promises');
const path = require('node:path');
const { Limiter } = require('./limiter');

const MAX_BYTES = 2 * 1024 * 1024;
// Cached photos are re-fetched from the source once a week; up to this many
// files are kept (the active release has about 300 photos).
const REFRESH_MS = 7 * 86400000;
const MAX_FILES = 4096;
function imageType(bytes) {
  if (bytes[0] === 255 && bytes[1] === 216 && bytes[2] === 255) return 'image/jpeg';
  if (bytes.subarray(0, 8).equals(Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]))) return 'image/png';
  if (bytes.toString('ascii', 0, 4) === 'RIFF' && bytes.toString('ascii', 8, 12) === 'WEBP') return 'image/webp';
  throw new Error('Unsupported public photo');
}

function download(url) {
  return new Promise((resolve, reject) => {
      const request = https.get(url, { family: 4, headers: { 'User-Agent': 'PlantiniBot/0.2 (https://github.com/noahilli/plantini)' } }, (response) => {
      // No redirects: a provider cannot send the server to another destination.
      if (response.statusCode !== 200) { response.resume(); reject(new Error('Photo unavailable')); return; }
      let size = 0;
      const chunks = [];
      response.on('data', (chunk) => {
        size += chunk.length;
        if (size > MAX_BYTES) request.destroy(new Error('Photo too large'));
        else chunks.push(chunk);
      });
      response.on('error', reject);
      response.on('end', () => resolve(Buffer.concat(chunks)));
    });
    const timer = setTimeout(() => request.destroy(new Error('Photo timeout')), 5000);
    request.on('close', () => clearTimeout(timer));
    request.on('error', reject);
  });
}

class PublicPhotoCache {
  constructor() {
    this.root = path.join(process.env.PRIVATE_UPLOAD_DIR || '/opt/plantini-private-media', 'public-plant-photos');
    this.pending = new Map();
    this.retryAt = new Map();
    this.limiter = new Limiter(4);
  }

  async get(value) {
    const url = new URL(value);
    if (url.protocol !== 'https:' || url.username || url.password || url.port ||
        !['upload.wikimedia.org', 'thumb.wikimedia.org', 'inaturalist-open-data.s3.amazonaws.com', 'static.inaturalist.org'].includes(url.hostname)) throw new Error('Unsupported photo host');
    const key = createHash('sha256').update(url.toString()).digest('hex');
    if (this.pending.has(key)) return this.pending.get(key);
    if ((this.retryAt.get(key) || 0) > Date.now()) throw new Error('Photo retry pending');
    const task = this.limiter.run(() => this.load(key, url)).catch((error) => {
      if (this.retryAt.size >= 256) this.retryAt.delete(this.retryAt.keys().next().value);
      this.retryAt.set(key, Date.now() + 60000);
      throw error;
    }).finally(() => this.pending.delete(key));
    this.pending.set(key, task);
    return task;
  }

  async load(key, url) {
    const target = path.join(this.root, key);
    let stale;
    try {
      const info = await stat(target);
      if (info.size <= MAX_BYTES) {
        const bytes = await readFile(target);
        if (info.mtimeMs > Date.now() - REFRESH_MS) return { bytes, type: imageType(bytes) };
        stale = { bytes, type: imageType(bytes) }; // older than a week: refresh, keep as fallback
      }
    } catch { /* Missing or unusable cached image: attempt the provider. */ }
    let bytes;
    try {
      bytes = await download(url);
    } catch (error) {
      // The source is unreachable or throttling us: a week-old copy is better
      // than no photo. It is retried on the next request after the back-off.
      if (stale) return stale;
      throw error;
    }
    const type = imageType(bytes);
    let temporary;
    try {
      await mkdir(this.root, { recursive: true, mode: 0o700 });
      await this.makeRoom();
      temporary = path.join(this.root, `${key}.${randomUUID()}.tmp`);
      await writeFile(temporary, bytes, { flag: 'wx', mode: 0o600 });
      await rename(temporary, target);
    } catch { /* Still serve the valid image when persistence fails. */ }
    finally { if (temporary) await unlink(temporary).catch(() => {}); }
    return { bytes, type };
  }

  /** Bound disk use: drop the least recently written cached photos when full. */
  async makeRoom() {
    const names = (await readdir(this.root)).filter((name) => /^[0-9a-f]{64}$/.test(name));
    if (names.length < MAX_FILES) return;
    const dated = await Promise.all(names.map(async (name) => {
      try { return { name, at: (await stat(path.join(this.root, name))).mtimeMs }; }
      catch { return { name, at: 0 }; }
    }));
    dated.sort((x, y) => x.at - y.at);
    for (const { name } of dated.slice(0, Math.ceil(MAX_FILES / 20))) {
      await unlink(path.join(this.root, name)).catch(() => {});
    }
  }
}

module.exports = { PublicPhotoCache };

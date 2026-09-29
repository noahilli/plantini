'use strict';

const https = require('node:https');
const { createHash, randomUUID } = require('node:crypto');
const { mkdir, readFile, readdir, rename, writeFile, stat, unlink } = require('node:fs/promises');
const path = require('node:path');

const MAX_BYTES = 2 * 1024 * 1024;
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
  }

  async get(value) {
    const url = new URL(value);
    if (url.protocol !== 'https:' || url.username || url.password || url.port ||
        !['upload.wikimedia.org', 'thumb.wikimedia.org', 'inaturalist-open-data.s3.amazonaws.com', 'static.inaturalist.org'].includes(url.hostname)) throw new Error('Unsupported photo host');
    const key = createHash('sha256').update(url.toString()).digest('hex');
    if (this.pending.has(key)) return this.pending.get(key);
    if ((this.retryAt.get(key) || 0) > Date.now()) throw new Error('Photo retry pending');
    if (this.pending.size >= 4) throw new Error('Photo cache busy');
    const task = this.load(key, url).catch((error) => {
      if (this.retryAt.size >= 256) this.retryAt.delete(this.retryAt.keys().next().value);
      this.retryAt.set(key, Date.now() + 60000);
      throw error;
    }).finally(() => this.pending.delete(key));
    this.pending.set(key, task);
    return task;
  }

  async load(key, url) {
    const target = path.join(this.root, key);
    try {
      const info = await stat(target);
      if (info.size <= MAX_BYTES && info.mtimeMs > Date.now() - 7 * 86400000) {
        const bytes = await readFile(target);
        return { bytes, type: imageType(bytes) };
      }
    } catch { /* Missing or unusable cached image: attempt the provider. */ }
    const bytes = await download(url);
    const type = imageType(bytes);
    let temporary;
    try {
      await mkdir(this.root, { recursive: true, mode: 0o700 });
      // Bound disk use without deleting another subsystem's files.
      if ((await readdir(this.root)).length < 256) {
        temporary = path.join(this.root, `${key}.${randomUUID()}.tmp`);
        await writeFile(temporary, bytes, { flag: 'wx', mode: 0o600 });
        await rename(temporary, target);
      }
    } catch { /* Still serve the valid image when persistence fails. */ }
    finally { if (temporary) await unlink(temporary).catch(() => {}); }
    return { bytes, type };
  }
}

module.exports = { PublicPhotoCache };

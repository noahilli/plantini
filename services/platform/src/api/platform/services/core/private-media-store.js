'use strict';

const { mkdir, readFile, rename, rm, writeFile } = require('fs/promises');
const path = require('path');

const { newId, requireUuid } = require('./ids');

/**
 * Development storage adapter for caller-owned photos.  Files are never
 * written to Strapi's public upload directory; only an authenticated v1 route
 * may later stream them. Production swaps this adapter for a private bucket.
 */
class PrivateMediaStore {
  constructor(options = {}) {
    this.directory = options.directory || process.env.PRIVATE_UPLOAD_DIR || '/opt/plantini-private-media';
  }

  async write(mediaId, bytes) {
    requireUuid(mediaId, 'mediaId');
    if (!Buffer.isBuffer(bytes)) throw new Error('Private media bytes must be a Buffer.');
    await mkdir(this.directory, { recursive: true, mode: 0o700 });
    const key = `${mediaId}-${newId()}`;
    const target = this.resolve(key);
    const temporary = `${target}.tmp`;
    await writeFile(temporary, bytes, { mode: 0o600, flag: 'wx' });
    await rename(temporary, target);
    return key;
  }

  async remove(key) {
    if (!key) return;
    const target = this.resolve(key);
    await rm(target, { force: true });
    for (const width of PrivateMediaStore.VARIANT_WIDTHS) await rm(`${target}.w${width}`, { force: true });
  }

  async read(key) {
    return readFile(this.resolve(key));
  }

  /**
   * Bytes of a resized JPEG (longest side `width`), cached next to the original.
   * Phones should not download a 5 MB photo for a 100 px thumbnail. Returns
   * undefined when the image library is unavailable so callers can fall back
   * to the original.
   */
  async readVariant(key, width) {
    if (!PrivateMediaStore.VARIANT_WIDTHS.includes(width)) throw new Error('Unsupported private media width.');
    const target = `${this.resolve(key)}.w${width}`;
    try {
      return await readFile(target);
    } catch { /* not generated yet */ }
    let sharp;
    try { sharp = require('sharp'); } catch { return undefined; }
    const resized = await sharp(await this.read(key), { failOn: 'none' })
      .rotate()
      .resize({ width, height: width, fit: 'inside', withoutEnlargement: true })
      .jpeg({ quality: 82, mozjpeg: true })
      .toBuffer();
    const temporary = `${target}.tmp`;
    await writeFile(temporary, resized, { mode: 0o600 });
    await rename(temporary, target);
    return resized;
  }

  resolve(key) {
    if (typeof key !== 'string' || !/^[0-9a-f-]{36,80}$/i.test(key)) {
      throw new Error('Invalid private media storage key.');
    }
    const target = path.resolve(this.directory, key);
    const root = path.resolve(this.directory);
    if (!target.startsWith(`${root}${path.sep}`)) {
      throw new Error('Private media key escapes the configured directory.');
    }
    return target;
  }
}

PrivateMediaStore.VARIANT_WIDTHS = [320, 720, 1280];

module.exports = { PrivateMediaStore };

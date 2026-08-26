'use strict';

const { mkdir, rename, rm, writeFile } = require('fs/promises');
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
    await rm(this.resolve(key), { force: true });
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

module.exports = { PrivateMediaStore };

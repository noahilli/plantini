'use strict';

const https = require('node:https');
const { createHash } = require('node:crypto');
let providerRetryAt = 0;

// These hosts are fixed: neither CMS input nor provider responses can choose
// the destination of backend requests. All requests explicitly use IPv4.
function query(host, parameters) {
  if (providerRetryAt > Date.now()) return Promise.reject(new Error('PHOTO_SOURCE_COOLDOWN'));
  const url = new URL(`https://${host}/w/api.php`);
  url.search = new URLSearchParams({ format: 'json', ...parameters }).toString();
  return new Promise((resolve, reject) => {
    const request = https.get(url, {
      family: 4,
      headers: { 'User-Agent': 'Plantini/0.1 (botanical learning photo lookup)', Accept: 'application/json' },
    }, (response) => {
      if (response.statusCode !== 200) {
        if (response.statusCode === 429 || response.statusCode === 503) {
          const raw = response.headers['retry-after'];
          const seconds = Number(raw);
          const delay = Number.isFinite(seconds) ? seconds * 1000 : Date.parse(raw) - Date.now();
          providerRetryAt = Date.now() + Math.max(60000, Number.isFinite(delay) ? delay : 60000);
        }
        response.resume();
        reject(new Error(`PHOTO_SOURCE_HTTP_${response.statusCode}`));
        return;
      }
      const chunks = [];
      let size = 0;
      response.on('data', (chunk) => {
        size += chunk.length;
        if (size > 1024 * 1024) request.destroy(new Error('PHOTO_SOURCE_TOO_LARGE'));
        else chunks.push(chunk);
      });
      response.on('error', reject);
      response.on('end', () => {
        try { resolve(JSON.parse(Buffer.concat(chunks).toString('utf8'))); }
        catch { reject(new Error('PHOTO_SOURCE_INVALID')); }
      });
    });
    const timer = setTimeout(() => request.destroy(new Error('PHOTO_SOURCE_TIMEOUT')), 2200);
    request.on('error', reject);
    request.on('close', () => clearTimeout(timer));
  });
}

function plain(value) {
  return String(value || '').replace(/<[^>]*>/g, ' ')
    .replace(/&amp;/g, '&').replace(/&quot;/g, '"')
    .replace(/&#39;/g, "'").replace(/&nbsp;/g, ' ')
    .replace(/\s+/g, ' ').trim();
}

function allowedUrl(value, host) {
  try {
    const url = new URL(value);
    return url.protocol === 'https:' && url.hostname === host && !url.username && !url.password;
  } catch { return false; }
}

class WikimediaPhotoSource {
  constructor({ metadataStore } = {}) {
    this.cache = new Map();
    this.pending = new Map();
    this.metadataStore = metadataStore;
  }

  async find(scientificName) {
    const name = String(scientificName || '').trim();
    if (!name || name.length > 160) return null;
    const key = createHash('sha256').update(name).digest('hex');
    let cached = this.cache.get(name);
    if (!cached && this.metadataStore) {
      try {
        const stored = await this.metadataStore.get({ key });
        if (stored?.schemaVersion === 1 && Number.isFinite(stored.expires) &&
            Number.isFinite(stored.verifiedAt) && stored.verifiedAt > Date.now() - 7 * 86400000) {
          cached = stored;
          if (this.cache.size >= 500) this.cache.delete(this.cache.keys().next().value);
          this.cache.set(name, stored);
        }
      } catch { /* Cache failure must not make plant content unavailable. */ }
    }
    if (cached && cached.expires > Date.now()) return cached.photo;
    if (this.pending.has(name)) return this.pending.get(name);
    // Bound concurrent external work; failures must never break a lesson.
    if (this.pending.size >= 4 || providerRetryAt > Date.now()) {
      return cached?.verifiedAt > Date.now() - 7 * 86400000 ? cached.photo : null;
    }
    let failed = false;
    const work = this.lookup(name).catch(() => {
      failed = true;
      // Preserve previously attributed imagery during temporary outages, but
      // only for seven days after the last successful provider verification.
      return cached?.verifiedAt > Date.now() - 7 * 86400000 ? cached.photo : null;
    }).then(async (photo) => {
      if (this.cache.size >= 500) this.cache.delete(this.cache.keys().next().value);
      const entry = {
        schemaVersion: 1,
        photo,
        verifiedAt: failed ? cached?.verifiedAt : Date.now(),
        expires: Date.now() + (failed ? 60000 : photo ? 86400000 : 300000),
      };
      this.cache.set(name, entry);
      if (this.metadataStore && !failed) {
        try { await this.metadataStore.set({ key, value: entry }); }
        catch { /* In-memory result remains usable without persistence. */ }
      }
      return photo;
    }).finally(() => this.pending.delete(name));
    this.pending.set(name, work);
    return work;
  }

  async lookup(name) {
    const pageData = await query('en.wikipedia.org', {
      action: 'query', titles: name, redirects: '1',
      prop: 'pageimages|pageprops', piprop: 'name', pilicense: 'free',
    });
    const page = Object.values(pageData.query?.pages || {})[0];
    const taxonId = page?.pageprops?.wikibase_item;
    if (!page?.pageimage || !/^Q\d+$/.test(taxonId || '')) return null;
    const taxon = await query('www.wikidata.org', {
      action: 'wbgetclaims', entity: taxonId, property: 'P225',
    });
    // Never use fuzzy search or assume that a redirect is the requested taxon.
    if (!(taxon.claims?.P225 || []).some((claim) =>
      claim.rank !== 'deprecated' && claim.mainsnak?.datavalue?.value === name)) return null;
    const imageData = await query('commons.wikimedia.org', {
      action: 'query', titles: `File:${page.pageimage}`, prop: 'imageinfo',
      iiprop: 'url|extmetadata|mime', iiurlwidth: '960',
      iiextmetadatafilter: 'Artist|LicenseShortName|LicenseUrl|AttributionRequired|Restrictions',
    });
    const info = Object.values(imageData.query?.pages || {})[0]?.imageinfo?.[0];
    const meta = info?.extmetadata || {};
    const license = plain(meta.LicenseShortName?.value);
    const licenseUrl = meta.LicenseUrl?.value?.replace(/^http:/, 'https:');
    const author = plain(meta.Artist?.value);
    const url = info?.thumburl || info?.url;
    if (!/^image\/(jpeg|png|webp)$/.test(info?.mime || '') || !author ||
        !/^CC (BY|BY-SA) (2\.0|2\.5|3\.0|4\.0)$/.test(license) ||
        !allowedUrl(licenseUrl, 'creativecommons.org') ||
        !(allowedUrl(url, 'upload.wikimedia.org') || allowedUrl(url, 'thumb.wikimedia.org')) ||
        !allowedUrl(info?.descriptionurl, 'commons.wikimedia.org') ||
        plain(meta.Restrictions?.value)) return null;
    const hash = createHash('sha256').update(info.descriptionurl).digest('hex');
    const id = `${hash.slice(0, 8)}-${hash.slice(8, 12)}-5${hash.slice(13, 16)}-a${hash.slice(17, 20)}-${hash.slice(20, 32)}`;
    return {
      id,
      url, altText: `${name} – automatisch zugeordnetes Wikimedia-Foto`,
      author, license, licenseUrl, source: info.descriptionurl,
      automatic: true,
    };
  }
}

module.exports = { WikimediaPhotoSource };

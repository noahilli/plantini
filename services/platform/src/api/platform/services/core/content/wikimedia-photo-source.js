'use strict';

const https = require('node:https');
const { createHash } = require('node:crypto');
let providerRetryAt = 0;

// These hosts are fixed: neither CMS input nor provider responses can choose
// the destination of backend requests. All requests explicitly use IPv4.
function query(host, parameters) {
  if (providerRetryAt > Date.now()) return Promise.reject(new Error('PHOTO_SOURCE_COOLDOWN'));
  const url = new URL(`https://${host}/w/api.php`);
  url.search = new URLSearchParams({ format: 'json', maxlag: '5', ...parameters }).toString();
  return new Promise((resolve, reject) => {
    const request = https.get(url, {
      family: 4,
      headers: {
        // Wikimedia asks automated clients to identify themselves and provide
        // a contact URL. Keep the project URL here so operators can reach us.
        'User-Agent': 'PlantiniBot/0.2 (https://github.com/noahilli/plantini)',
        Accept: 'application/json',
      },
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
    this.galleryCache = new Map();
    this.metadataStore = metadataStore;
  }

  async findMany(scientificName, limit = 10) {
    const name = String(scientificName || '').trim();
    if (!name || name.length > 160) return [];
    const cached = this.galleryCache.get(name);
    if (cached && cached.expires > Date.now()) return cached.photos.slice(0, limit);

    const primary = await this.find(name);
    let extra = [];
    let degraded = false;
    try { extra = await this.lookupInaturalistPhotos(name, limit); }
    catch { degraded = true; /* Keep the primary photo visible if the gallery source is down. */ }
    const seen = new Set();
    const photos = [primary, ...extra].filter((photo) => {
      if (!photo || seen.has(photo.url)) return false;
      seen.add(photo.url);
      return true;
    }).slice(0, Math.max(1, Math.min(10, limit)));
    if (this.galleryCache.size >= 500) this.galleryCache.delete(this.galleryCache.keys().next().value);
    // A gallery reduced by a provider failure is retried soon, not for a day.
    this.galleryCache.set(name, { photos, expires: Date.now() + (degraded ? 300000 : 86400000) });
    return photos;
  }

  async find(scientificName) {
    const name = String(scientificName || '').trim();
    if (!name || name.length > 160) return null;
    const key = createHash('sha256').update(name).digest('hex');
    let cached = this.cache.get(name);
    if (!cached && this.metadataStore) {
      try {
        const stored = await this.metadataStore.get({ key });
        if (stored?.schemaVersion === 5 && Number.isFinite(stored.expires) &&
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
        schemaVersion: 5,
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
    try {
      const wikimedia = await this.lookupWikimedia(name);
      if (wikimedia) return wikimedia;
    } catch { /* A throttled/unavailable primary source must not block fallback. */ }
    return this.lookupInaturalist(name);
  }

  async lookupWikimedia(name) {
    const pageData = await query('en.wikipedia.org', {
      action: 'query', titles: name, redirects: '1',
      // Internal demo lookup: allow any page image, not just Wikimedia's
      // pre-classified free subset. Taxon identity and image host are still
      // verified; the returned card is explicitly marked unverified-license.
      prop: 'pageimages|pageprops', piprop: 'name',
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
    const license = plain(meta.LicenseShortName?.value) || 'Unverified (internal testing)';
    const licenseUrl = meta.LicenseUrl?.value?.replace(/^http:/, 'https:');
    const author = plain(meta.Artist?.value) || 'Attribution unavailable';
    const url = info?.thumburl || info?.url;
    if (!/^image\/(jpeg|png|webp)$/.test(info?.mime || '') ||
        !(allowedUrl(url, 'upload.wikimedia.org') || allowedUrl(url, 'thumb.wikimedia.org')) ||
        !allowedUrl(info?.descriptionurl, 'commons.wikimedia.org')) return null;
    const hash = createHash('sha256').update(info.descriptionurl).digest('hex');
    const id = `${hash.slice(0, 8)}-${hash.slice(8, 12)}-5${hash.slice(13, 16)}-a${hash.slice(17, 20)}-${hash.slice(20, 32)}`;
    return {
      id,
      url, altText: `${name} – automatisch zugeordnetes Wikimedia-Foto`,
      author, license, licenseUrl: allowedUrl(licenseUrl, 'creativecommons.org') ? licenseUrl : null,
      source: info.descriptionurl,
      automatic: true,
    };
  }

  async lookupInaturalist(name) {
    return (await this.lookupInaturalistPhotos(name, 1))[0] || null;
  }

  async lookupInaturalistPhotos(name, limit = 10) {
    const url = new URL('https://api.inaturalist.org/v1/taxa');
    url.search = new URLSearchParams({ q: name, all_names: 'true' }).toString();
    const taxa = await getJson(url);
    const taxon = (taxa.results || []).find((result) =>
      result.name === name || (result.names || []).some((synonym) =>
        synonym.locale === 'sci' && synonym.name === name && synonym.is_valid === false));
    if (!taxon) return [];
    const candidates = taxon.default_photo ? [taxon.default_photo] : [];
    // The taxon record lists iNaturalist's curated photos in a small payload.
    // Recent observations (30 per page) exceed the 1 MiB response cap, so they
    // are only a smaller fallback for taxa without curated photos.
    const detail = await getJson(new URL(`https://api.inaturalist.org/v1/taxa/${encodeURIComponent(taxon.id)}`));
    const detailTaxon = (detail.results || [])[0];
    if (detailTaxon?.name === taxon.name) {
      candidates.push(...(detailTaxon.taxon_photos || []).map((entry) => entry.photo).filter(Boolean));
    }
    if (candidates.length < 2) {
      const observationsUrl = new URL('https://api.inaturalist.org/v1/observations');
      observationsUrl.search = new URLSearchParams({
        taxon_id: String(taxon.id), photos: 'true', per_page: '10', order_by: 'created_at',
      }).toString();
      const observations = await getJson(observationsUrl);
      for (const observation of observations.results || []) {
        if (observation.taxon?.name !== taxon.name) continue;
        candidates.push(...(observation.photos || []));
      }
    }

    const results = [];
    const seen = new Set();
    for (const candidate of candidates) {
      const imageUrl = String(candidate.medium_url || candidate.url || '').replace('/square.', '/medium.');
      if (!/^https:\/\/(inaturalist-open-data\.s3\.amazonaws\.com|static\.inaturalist\.org)\/photos\/\d+\/(medium|large)\.(jpe?g|png|webp)$/i.test(imageUrl) || seen.has(imageUrl)) continue;
      seen.add(imageUrl);
      const digest = createHash('sha256').update(`inat:${candidate.id}`).digest('hex');
      const id = `${digest.slice(0, 8)}-${digest.slice(8, 12)}-5${digest.slice(13, 16)}-a${digest.slice(17, 20)}-${digest.slice(20, 32)}`;
      results.push({
        id,
        url: imageUrl,
        altText: `${name} – iNaturalist Foto (internes Testing)`,
        author: plain(candidate.attribution_name || candidate.attribution) || 'Attribution unavailable',
        license: candidate.license_code || 'Unverified (internal testing)',
        source: `https://www.inaturalist.org/photos/${candidate.id}`,
        automatic: true,
      });
      if (results.length >= Math.max(1, Math.min(10, limit))) break;
    }
    return results;
  }
}

function getJson(url) {
  return new Promise((resolve, reject) => {
    const request = https.get(url, {
      family: 4,
      headers: {
        'User-Agent': 'PlantiniBot/0.2 (https://github.com/noahilli/plantini)',
        Accept: 'application/json',
      },
    }, (response) => {
      if (response.statusCode !== 200) { response.resume(); reject(new Error(`PHOTO_SOURCE_HTTP_${response.statusCode}`)); return; }
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
    const timer = setTimeout(() => request.destroy(new Error('PHOTO_SOURCE_TIMEOUT')), 5000);
    request.on('close', () => clearTimeout(timer));
    request.on('error', reject);
  });
}

module.exports = { WikimediaPhotoSource };

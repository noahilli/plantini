'use strict';

const { notFound } = require('../errors');

const WEEK_MS = 7 * 86400000;

/**
 * Info cards for species that users found but that are not part of any
 * published ecosystem (typically PlantNet candidates outside the catalogue).
 *
 * A card is built once from public sources (Wikipedia summary, a licensed
 * Wikimedia/iNaturalist photo) and then served from the database to every
 * user; it is re-verified at most once a week. Cards are stored in their own
 * table and are never attached to ecosystems or levels.
 */
class SpeciesService {
  constructor({ repository, photoSource, clock }) {
    this.repository = repository;
    this.photoSource = photoSource;
    this.clock = clock || (() => new Date());
    this.pending = new Map();
  }

  /** Stable, URL-safe key for a scientific name ("Bellis perennis" -> "bellis-perennis"). */
  static keyFor(scientificName) {
    return String(scientificName || '')
      .normalize('NFKD').replace(/[̀-ͯ]/g, '')
      .toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '')
      .slice(0, 120);
  }

  /** Best effort and never throws: a missing card must not block a herbarium entry. */
  async ensureFromCandidate(candidate) {
    try {
      const key = SpeciesService.keyFor(candidate?.scientificName);
      if (!key) return undefined;
      const existing = await this.repository.findSpeciesCard(key);
      const fresh = existing?.verifiedAt && Date.parse(existing.verifiedAt) > this.clock().getTime() - WEEK_MS;
      if (fresh) return existing;
      if (this.pending.has(key)) return await this.pending.get(key);
      const work = this.build(key, candidate, existing).finally(() => this.pending.delete(key));
      this.pending.set(key, work);
      return await work;
    } catch {
      return undefined;
    }
  }

  async build(key, candidate, existing) {
    const scientificName = String(candidate.scientificName).trim().slice(0, 160);
    let summary = null;
    let photo = null;
    let failed = false;
    if (this.photoSource) {
      try { summary = await this.photoSource.lookupSummary(scientificName); } catch { failed = true; }
      try { photo = await this.photoSource.find(scientificName); } catch { failed = true; }
    }
    const data = {
      scientificName,
      ...(candidate.commonName ? { commonName: String(candidate.commonName).slice(0, 160) } : {}),
      ...(summary ? { summary: summary.text, summaryLanguage: summary.language, summarySource: summary.source } : {}),
      ...(photo ? { photo } : {}),
      // A failed lookup keeps what we have and is retried soon; a clean lookup
      // (even without a result) is trusted for a week.
      verifiedAt: failed ? (existing?.verifiedAt || new Date(this.clock().getTime() - WEEK_MS + 3600000).toISOString())
        : this.clock().toISOString(),
    };
    return existing
      ? this.repository.updateSpeciesCard(existing.id, { ...data, summary: data.summary ?? existing.summary, photo: data.photo ?? existing.photo })
      : this.repository.createSpeciesCard({ speciesKey: key, ...data });
  }

  /** The stored source URL of the card's photo (server side only). */
  async getPhotoSource(key) {
    const card = await this.repository.findSpeciesCard(String(key || ''));
    if (!card?.photo?.url) throw notFound('SPECIES_PHOTO_NOT_FOUND');
    return card.photo.url;
  }

  async getCard(key) {
    const card = await this.repository.findSpeciesCard(String(key || ''));
    if (!card) throw notFound('SPECIES_NOT_FOUND');
    return mapCard(card);
  }
}

function mapCard(card) {
  return {
    key: card.speciesKey,
    scientificName: card.scientificName,
    ...(card.commonName ? { commonName: card.commonName } : {}),
    ...(card.summary ? {
      summary: card.summary,
      summaryLanguage: card.summaryLanguage || 'de',
      summarySource: card.summarySource,
      summaryLicense: 'CC BY-SA 4.0',
    } : {}),
    // The app gets the server's cached copy, never the provider's URL.
    ...(card.photo ? { photo: { ...card.photo, url: `/api/v1/species/${card.speciesKey}/photo?photoId=${encodeURIComponent(card.photo.id)}` } } : {}),
  };
}

module.exports = { SpeciesService, mapCard };

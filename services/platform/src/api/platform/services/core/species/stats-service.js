'use strict';

const { SpeciesService } = require('./species-service');

const TTL_MS = 10 * 60 * 1000;
// Below this many accounts a percentage could single out individuals, so no
// share is published (same idea as the small-cohort rule for dashboards).
const MIN_ACCOUNTS = 20;

/**
 * How many accounts have collected each species. The share is
 * `accounts with a confirmed find / all accounts`; it is shown as a percentage,
 * or in per mille below one percent.
 */
class StatsService {
  constructor({ repository, clock, ttlMs = TTL_MS, minAccounts = MIN_ACCOUNTS }) {
    this.repository = repository;
    this.clock = clock || (() => new Date());
    this.ttlMs = ttlMs;
    this.minAccounts = minAccounts;
    this.cached = undefined;
  }

  static label(share) {
    if (!(share > 0)) return '0 %';
    if (share >= 0.01) {
      const percent = share * 100;
      return `${(percent >= 10 ? Math.round(percent) : Math.round(percent * 10) / 10).toString().replace('.', ',')} %`;
    }
    const permille = share * 1000;
    return permille < 0.5 ? '<1 ‰' : `${Math.round(permille)} ‰`;
  }

  async collection() {
    const now = this.clock().getTime();
    if (this.cached && this.cached.expires > now) return this.cached.value;
    const accounts = await this.repository.countAccounts();
    let value;
    if (accounts < this.minAccounts) {
      value = { available: false, reason: 'not_enough_accounts', generatedAt: new Date(now).toISOString(), plants: {}, species: {} };
    } else {
      const finds = await this.repository.listConfirmedFinds();
      const plantOwners = new Map();
      const speciesOwners = new Map();
      for (const find of finds) {
        const target = find.plantId ? plantOwners : speciesOwners;
        const key = find.plantId || SpeciesService.keyFor(find.scientificName);
        if (!key) continue;
        if (!target.has(key)) target.set(key, new Set());
        target.get(key).add(find.ownerId);
      }
      const shape = (map) => Object.fromEntries([...map].map(([key, owners]) => {
        const share = Math.min(1, owners.size / accounts);
        return [key, { share, label: StatsService.label(share) }];
      }));
      value = {
        available: true,
        generatedAt: new Date(now).toISOString(),
        plants: shape(plantOwners),
        species: shape(speciesOwners),
      };
    }
    this.cached = { expires: now + this.ttlMs, value };
    return value;
  }
}

module.exports = { StatsService };

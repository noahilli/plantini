'use strict';

const { newId } = require('../ids');
const { ProblemError } = require('../errors');

const ALLOWED_ROLES = new Set([
  'lernende',
  'lehrende',
  'inhaltsredaktion',
  'botanisches_review',
  'organisationsadministration',
  'systemadministration',
]);

class ActorService {
  constructor(options) {
    this.profileRepository = options.profileRepository;
    this.roleClaimClientId = options.roleClaimClientId;
    this.organisationClaim = options.organisationClaim || 'organisation_id';
  }

  async resolve(claims) {
    const roles = extractRoles(claims, this.roleClaimClientId);
    const organisationId = optionalOrganisationId(claims[this.organisationClaim]);
    let profile = await this.profileRepository.findBySubject(claims.sub);

    if (!profile) {
      const draft = {
        profileId: newId(),
        keycloakSubject: claims.sub,
        displayName: displayNameFromClaims(claims),
        locale: localeFromClaims(claims),
        organisationId,
      };
      try {
        profile = await this.profileRepository.create(draft);
      } catch (error) {
        // A unique index on keycloakSubject is the race-safe guarantee. If a
        // second request won the create race, resolve that same internal ID.
        if (!isUniqueViolation(error)) throw error;
        profile = await this.profileRepository.findBySubject(claims.sub);
        if (!profile) throw error;
      }
    }

    return {
      id: profile.profileId,
      subject: profile.keycloakSubject,
      displayName: profile.displayName,
      locale: profile.locale,
      organisationId: profile.organisationId || organisationId,
      ...(profile.character ? { character: profile.character } : {}),
      roles,
    };
  }

  async updateProfile(actor, patch) {
    if (!patch.displayName && !patch.locale && !patch.character) {
      return actor;
    }
    const profile = await this.profileRepository.update(actor.id, patch);
    return {
      ...actor,
      displayName: profile.displayName,
      locale: profile.locale,
      ...(profile.character ? { character: profile.character } : {}),
    };
  }
}

function extractRoles(claims, clientId) {
  const realmRoles = claims.realm_access && Array.isArray(claims.realm_access.roles)
    ? claims.realm_access.roles
    : [];
  const clientRoles = clientId && claims.resource_access && claims.resource_access[clientId]
    && Array.isArray(claims.resource_access[clientId].roles)
    ? claims.resource_access[clientId].roles
    : [];
  const roles = [...new Set([...realmRoles, ...clientRoles].map(normalizeRole).filter(Boolean))];
  return roles.length > 0 ? roles : ['lernende'];
}

function normalizeRole(role) {
  if (typeof role !== 'string') return undefined;
  const normalized = role.trim().toLowerCase().replace(/[ -]/g, '_');
  return ALLOWED_ROLES.has(normalized) ? normalized : undefined;
}

function displayNameFromClaims(claims) {
  const candidate = claims.preferred_username || claims.name || claims.given_name;
  if (typeof candidate !== 'string' || candidate.trim().length === 0) return 'Lernende:r';
  return candidate.trim().slice(0, 100);
}

function localeFromClaims(claims) {
  const candidate = claims.locale;
  return typeof candidate === 'string' && /^[a-z]{2,3}(-[A-Z]{2})?$/.test(candidate)
    ? candidate
    : 'de-DE';
}

function optionalOrganisationId(value) {
  if (value === undefined || value === null || value === '') return undefined;
  if (typeof value !== 'string' || !/^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(value)) {
    throw new ProblemError('AUTH_TOKEN_INVALID', {
      status: 401,
      detail: 'Der Organisation-Claim im Zugriffstoken ist ungültig.',
    });
  }
  return value.toLowerCase();
}

function isUniqueViolation(error) {
  return Boolean(error && (
    error.code === '23505'
    || error.code === 'SQLITE_CONSTRAINT'
    || error.name === 'ValidationError'
  ));
}

module.exports = {
  ActorService,
  extractRoles,
  normalizeRole,
};

'use strict';

const { ActorService } = require('./auth/actor-service');
const { KeycloakJwtValidator, authenticationError } = require('./auth/jwt-validator');
const { ContentService } = require('./content/content-service');
const { FieldService } = require('./field/field-service');
const { HerbariumService } = require('./herbarium/herbarium-service');
const { LearningService } = require('./learning/learning-service');
const { PrivateMediaStore } = require('./private-media-store');
const { ProfileService } = require('./profile/profile-service');
const { createStrapiRepositories } = require('./strapi-repositories');
const { ProblemError } = require('./errors');

const runtimes = new WeakMap();

function getPlatformRuntime(strapi) {
  const existing = runtimes.get(strapi);
  if (existing) return existing;

  const repositories = createStrapiRepositories(strapi);
  const validator = new KeycloakJwtValidator({
    issuer: requiredEnvironment('PLATFORM_OIDC_ISSUER'),
    audience: requiredEnvironment('PLATFORM_OIDC_AUDIENCE'),
    jwksUri: process.env.PLATFORM_OIDC_JWKS_URI,
  });
  const actorService = new ActorService({
    profileRepository: repositories.profiles,
    roleClaimClientId: process.env.PLATFORM_OIDC_ROLE_CLIENT_ID || undefined,
    organisationClaim: process.env.PLATFORM_ORGANISATION_CLAIM || 'organisation_id',
  });
  const runtime = {
    repositories,
    validator,
    actorService,
    profile: new ProfileService({ actorService }),
    content: new ContentService({ repository: repositories.content }),
    learning: new LearningService({ repository: repositories.learning }),
    privateMediaStore: new PrivateMediaStore(),
    identificationQueue: undefined,
  };
  runtime.field = new FieldService({
    repository: repositories.field,
    enqueue: async (jobId) => runtime.identificationQueue?.enqueue(jobId),
  });
  runtime.herbarium = new HerbariumService({
    repository: repositories.herbarium,
    fieldRepository: repositories.field,
  });
  runtimes.set(strapi, runtime);
  return runtime;
}

/// Returns a runtime only when bootstrap already constructed one. Strapi's
/// type-generator invokes lifecycle teardown without a fully initialized
/// entity service, so teardown must never create a second runtime there.
function getExistingPlatformRuntime(strapi) {
  return strapi ? runtimes.get(strapi) : undefined;
}

async function resolveActor(ctx, runtime) {
  const header = ctx.get('authorization');
  if (!header || !/^Bearer\s+\S+$/i.test(header)) {
    throw authenticationError('AUTH_TOKEN_MISSING', 'Für diese Aktion ist eine Anmeldung erforderlich.');
  }
  const token = header.replace(/^Bearer\s+/i, '');
  const claims = await runtime.validator.validate(token);
  const actor = await runtime.actorService.resolve(claims);
  const profile = await runtime.repositories.profiles.findByProfileId(actor.id);
  if (profile?.status === 'suspended') {
    throw new ProblemError('ACCOUNT_SUSPENDED', {
      status: 403,
      detail: 'Dieses Konto ist gesperrt.',
    });
  }
  return actor;
}

function requiredEnvironment(name) {
  const value = process.env[name];
  if (!value || !value.trim()) {
    throw new Error(`${name} must be configured for the platform API.`);
  }
  return value.trim();
}

module.exports = {
  getExistingPlatformRuntime,
  getPlatformRuntime,
  resolveActor,
};

'use strict';

const assert = require('node:assert/strict');
const test = require('node:test');
const { memoryEntities } = require('./helpers/memory-entities');
const { seedDemoContent } = require('../src/api/platform/services/core/content/demo-seed');
const { getPlatformRuntime } = require('../src/api/platform/services/core/platform-runtime');
const controller = require('../src/api/platform/controllers/platform');
const { routes } = require('../src/api/platform/routes/platform');

test('GAME-03 ecosystem progress route authenticates and exposes only the server-computed contract', async (t) => {
  const entities = memoryEntities();
  await seedDemoContent({ entityService: entities });
  const oldStrapi = globalThis.strapi;
  const oldIssuer = process.env.PLATFORM_OIDC_ISSUER;
  const oldAudience = process.env.PLATFORM_OIDC_AUDIENCE;
  const oldPhotos = process.env.PLATFORM_EXTERNAL_PLANT_PHOTOS;
  // The runtime only needs strapi.store for the external photo source.
  process.env.PLATFORM_EXTERNAL_PLANT_PHOTOS = 'disabled';
  process.env.PLATFORM_OIDC_ISSUER = 'http://127.0.0.1:9999/realms/test';
  process.env.PLATFORM_OIDC_AUDIENCE = 'test';
  globalThis.strapi = { entityService: entities };
  t.after(() => {
    globalThis.strapi = oldStrapi;
    if (oldIssuer === undefined) delete process.env.PLATFORM_OIDC_ISSUER;
    else process.env.PLATFORM_OIDC_ISSUER = oldIssuer;
    if (oldAudience === undefined) delete process.env.PLATFORM_OIDC_AUDIENCE;
    else process.env.PLATFORM_OIDC_AUDIENCE = oldAudience;
    if (oldPhotos === undefined) delete process.env.PLATFORM_EXTERNAL_PLANT_PHOTOS;
    else process.env.PLATFORM_EXTERNAL_PLANT_PHOTOS = oldPhotos;
  });
  const runtime = getPlatformRuntime(globalThis.strapi);
  // JWT cryptography is tested separately; this boundary fixture proves the
  // controller uses the actor resolved by authentication, with no actor input.
  runtime.validator.validate = async () => ({ sub: 'actor' });
  runtime.actorService.resolve = async () => ({ id: 'actor' });
  const ecosystemId = entities.table('api::ecosystem.ecosystem')[0].publicId;
  const context = (authorization = '', query = {}) => ({
    params: { ecosystemId }, query, request: {}, status: 404,
    path: `/api/v1/ecosystems/${ecosystemId}/progress`,
    get: (key) => key === 'authorization' ? authorization : '', set() {},
  });
  const unauthenticated = context();
  await controller.getEcosystemProgress(unauthenticated);
  assert.equal(unauthenticated.status, 401);
  const valid = context('Bearer fixture');
  await controller.getEcosystemProgress(valid);
  assert.equal(valid.status, 200);
  assert.equal(valid.body.completed, false);
  assert.equal(valid.body.totalLevels, 30);
  assert.equal(valid.body.requiredPlantIds.length, 3);
  assert.deepEqual(Object.keys(valid.body).sort(), [
    'ecosystemId', 'status', 'completed', 'totalLevels', 'completedLevelCount',
    'completedLevelIds', 'requiredPlantIds', 'collectedPlantIds', 'missingPlantIds',
  ].sort());
  const forged = context('Bearer fixture', { completed: true });
  await controller.getEcosystemProgress(forged);
  assert.equal(forged.status, 400);
  assert.equal(routes.find((route) => route.path === '/v1/ecosystems/:ecosystemId/progress').handler,
    'api::platform.platform.getEcosystemProgress');
});

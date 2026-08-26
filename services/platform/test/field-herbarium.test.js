'use strict';

const assert = require('node:assert/strict');
const test = require('node:test');

const { FieldService, hasExpectedMagicBytes } = require('../src/api/platform/services/core/field/field-service');
const { HerbariumService } = require('../src/api/platform/services/core/herbarium/herbarium-service');
const { ProblemError } = require('../src/api/platform/services/core/errors');

const ids = {
  owner: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
  other: 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
  clientMedia: 'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
  clientJob: 'dddddddd-dddd-4ddd-8ddd-dddddddddddd',
  clientObservation: 'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee',
  plant: 'ffffffff-ffff-4fff-8fff-ffffffffffff',
};

function createRepositories() {
  const media = [];
  const jobs = [];
  const observations = [];
  return {
    media,
    jobs,
    observations,
    field: {
      async findPrivateMediaByIdempotencyKey(key) { return media.find((item) => item.idempotencyKey === key); },
      async findPrivateMediaByClientId(ownerId, clientId) { return media.find((item) => item.ownerId === ownerId && item.clientMediaId === clientId); },
      async findPrivateMediaByPublicId(ownerId, id) { return media.find((item) => item.ownerId === ownerId && item.publicId === id); },
      async createPrivateMedia(input) { const item = { id: media.length + 1, ...input, createdAt: '2026-01-01T00:00:00.000Z' }; media.push(item); return item; },
      async updatePrivateMedia(id, patch) { const item = media.find((value) => value.id === id); Object.assign(item, patch); return item; },
      async findJobByIdempotencyKey(key) { return jobs.find((item) => item.idempotencyKey === key); },
      async findJobByClientId(ownerId, clientId) { return jobs.find((item) => item.ownerId === ownerId && item.clientJobId === clientId); },
      async findJobByPublicId(ownerId, id) { return jobs.find((item) => item.ownerId === ownerId && item.publicId === id); },
      async findAnyJobByPublicId(id) { return jobs.find((item) => item.publicId === id); },
      async createJob(input) { const item = { id: jobs.length + 1, ...input, createdAt: '2026-01-01T00:00:00.000Z' }; jobs.push(item); return item; },
      async updateJob(id, patch) { const item = jobs.find((value) => value.id === id); Object.assign(item, patch); return item; },
    },
    herbarium: {
      async findObservationByIdempotencyKey(key) { return observations.find((item) => item.idempotencyKey === key); },
      async findObservationByClientId(ownerId, clientId) { return observations.find((item) => item.ownerId === ownerId && item.clientObservationId === clientId); },
      async findObservationByPublicId(ownerId, id) { return observations.find((item) => item.ownerId === ownerId && item.publicId === id); },
      async createObservation(input) { const item = { id: observations.length + 1, ...input }; observations.push(item); return item; },
      async updateObservation(id, patch) { const item = observations.find((value) => value.id === id); Object.assign(item, patch); return item; },
      async listObservations(ownerId) { const items = observations.filter((item) => item.ownerId === ownerId && item.syncStatus !== 'deleted'); return { items, total: items.length }; },
    },
  };
}

test('private uploads verify magic bytes and identification is caller-owned', async () => {
  const repositories = createRepositories();
  const queued = [];
  const now = () => new Date('2026-01-01T00:00:00.000Z');
  const field = new FieldService({ repository: repositories.field, clock: now, enqueue: async (id) => queued.push(id) });
  const actor = { id: ids.owner };
  const png = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 0]);
  assert.equal(hasExpectedMagicBytes(png, 'image/png'), true);
  assert.equal(hasExpectedMagicBytes(Buffer.from('not-a-png'), 'image/png'), false);

  const reservation = await field.reserveUpload(actor, {
    clientMediaId: ids.clientMedia,
    contentType: 'image/png',
    bytes: png.length,
  }, 'upload-idempotency-key-01', (id) => `https://api.example.test/uploads/${id}`);
  assert.match(reservation.uploadUrl, /uploads\//);
  await field.attachUpload(actor, reservation.id, {
    buffer: png,
    size: png.length,
    contentType: 'image/png',
    storageKey: `${reservation.id}-aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa`,
  });

  const job = await field.createIdentification(actor, {
    clientJobId: ids.clientJob,
    mediaId: reservation.id,
    expectedPlantId: ids.plant,
  }, 'identification-key-0001');
  assert.equal(job.status, 'pending');
  assert.deepEqual(queued, [job.id]);
  await field.processIdentification(job.id, {
    async identify() {
      return { provider: 'plantnet-mock', modelVersion: 'v1', candidates: [{ plantId: ids.plant, scientificName: 'Quercus robur', score: 0.98 }] };
    },
  });
  const confirmed = await field.confirmIdentification(actor, job.id, { confirmedPlantId: ids.plant });
  assert.equal(confirmed.confirmedPlantId, ids.plant);
  await assert.rejects(
    () => field.getIdentification({ id: ids.other }, job.id),
    (error) => error instanceof ProblemError && error.status === 404,
  );
});

test('herbarium enforces ownership, version preconditions, and tombstones', async () => {
  const repositories = createRepositories();
  const fieldRepository = repositories.field;
  repositories.jobs.push({
    id: 1,
    publicId: ids.clientJob,
    ownerId: ids.owner,
    status: 'identified',
    confirmedPlantId: ids.plant,
    createdAt: '2026-01-01T00:00:00.000Z',
    candidates: [],
  });
  const service = new HerbariumService({ repository: repositories.herbarium, fieldRepository, clock: () => new Date('2026-01-01T00:00:00.000Z') });
  const created = await service.create({ id: ids.owner }, {
    clientObservationId: ids.clientObservation,
    observedAt: '2026-01-01T00:00:00.000Z',
    note: 'Fund am Waldrand',
    identificationJobId: ids.clientJob,
    location: { latitude: 50, longitude: 8, accuracyMeters: 10 },
  }, 'observation-key-00001');
  assert.equal(created.created, true);
  assert.equal(created.observation.confirmedPlantId, ids.plant);
  assert.equal(Object.hasOwn(created.observation, 'location'), false);

  await assert.rejects(
    () => service.get({ id: ids.other }, created.observation.id),
    (error) => error instanceof ProblemError && error.status === 404,
  );
  const updated = await service.update({ id: ids.owner }, created.observation.id, { note: 'Korrigierte Notiz' }, `"${created.observation.version}"`);
  assert.equal(updated.note, 'Korrigierte Notiz');
  await assert.rejects(
    () => service.delete({ id: ids.owner }, created.observation.id, `"${created.observation.version}"`),
    (error) => error instanceof ProblemError && error.code === 'OBSERVATION_VERSION_CONFLICT',
  );
  await service.delete({ id: ids.owner }, created.observation.id, `"${updated.version}"`);
  const listed = await service.list({ id: ids.owner }, {});
  assert.deepEqual(listed.items, []);
});

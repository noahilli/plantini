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
      async findPublishedPlantByPublicId(id) {
        return id === ids.plant ? { publicId: ids.plant, scientificName: 'Quercus robur' } : undefined;
      },
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
      return {
        provider: 'plantnet-mock',
        modelVersion: 'v1',
        candidates: [{
          candidateId: `plantini:${ids.plant}`,
          plantId: ids.plant,
          scientificName: 'Quercus robur',
          score: 0.98,
        }],
      };
    },
  });
  const identified = await field.getIdentification(actor, job.id);
  assert.equal(identified.expectedMatch, 'matched');
  assert.equal(identified.expectedCandidateId, `plantini:${ids.plant}`);
  const confirmed = await field.confirmIdentification(actor, job.id, { confirmedPlantId: ids.plant });
  assert.equal(confirmed.confirmedPlantId, ids.plant);
  await assert.rejects(
    () => field.getIdentification({ id: ids.other }, job.id),
    (error) => error instanceof ProblemError && error.status === 404,
  );
});

test('FIELD-06: a candidate deviating from the expected level plant needs explicit acceptance', async () => {
  const repositories = createRepositories();
  const field = new FieldService({ repository: repositories.field });
  const externalCandidateId = 'plantnet:taxon:fagus-sylvatica';
  repositories.jobs.push({
    id: 1,
    publicId: ids.clientJob,
    ownerId: ids.owner,
    expectedPlantId: ids.plant,
    expectedMatch: 'mismatch',
    status: 'identified',
    candidates: [{
      candidateId: externalCandidateId,
      scientificName: 'Fagus sylvatica',
      score: 0.82,
    }],
    createdAt: '2026-01-01T00:00:00.000Z',
  });

  await assert.rejects(
    () => field.confirmIdentification(
      { id: ids.owner },
      ids.clientJob,
      { candidateId: externalCandidateId },
    ),
    (error) => error instanceof ProblemError
      && error.code === 'IDENTIFICATION_MISMATCH_NOT_ACCEPTED',
  );

  const confirmed = await field.confirmIdentification(
    { id: ids.owner },
    ids.clientJob,
    { candidateId: externalCandidateId, acceptMismatch: true },
  );
  assert.equal(confirmed.confirmedCandidateId, externalCandidateId);
});

test('FIELD-07: exhausted provider work is dead-lettered and manual retry resets attempts', async () => {
  const repositories = createRepositories();
  const queued = [];
  const field = new FieldService({
    repository: repositories.field,
    clock: () => new Date('2026-08-31T12:00:00.000Z'),
    enqueue: async (id) => queued.push(id),
  });
  repositories.media.push({
    id: 1,
    publicId: ids.clientMedia,
    ownerId: ids.owner,
    status: 'uploaded',
  });
  repositories.jobs.push({
    id: 1,
    publicId: ids.clientJob,
    ownerId: ids.owner,
    clientJobId: ids.clientJob,
    mediaId: ids.clientMedia,
    status: 'pending',
    attempts: 4,
    createdAt: '2026-08-31T11:00:00.000Z',
  });

  const failed = await field.processIdentification(ids.clientJob, {
    async identify() {
      const error = new Error('provider unavailable');
      error.code = 'PROVIDER_UNAVAILABLE';
      throw error;
    },
  });
  assert.equal(failed.failureCode, 'PROVIDER_RETRY_EXHAUSTED');
  assert.equal(failed.deadLetteredAt, '2026-08-31T12:00:00.000Z');

  const retried = await field.retryIdentification(
    { id: ids.owner }, ids.clientJob, 'manual-retry-idempotency-01',
  );
  assert.equal(retried.status, 'pending');
  assert.equal(retried.attempts, 0);
  assert.equal(retried.deadLetteredAt, undefined);
  assert.deepEqual(queued, [ids.clientJob]);
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
  assert.equal(created.observation.clientObservationId, ids.clientObservation);
  assert.equal(created.observation.confirmedPlantId, ids.plant);
  // Owner-scoped responses return the (client-coarsened) find location so the
  // herbarium map works on every device; other accounts get 404 below.
  assert.deepEqual(created.observation.location, { latitude: 50, longitude: 8, accuracyMeters: 10 });

  await assert.rejects(
    () => service.get({ id: ids.other }, created.observation.id),
    (error) => error instanceof ProblemError && error.status === 404,
  );
  for (const immutablePatch of [
    { mediaId: ids.clientMedia },
    { identificationJobId: ids.clientJob },
    { location: { latitude: 51, longitude: 9, accuracyMeters: 5 } },
    { syncStatus: 'deleted' },
  ]) {
    await assert.rejects(
      () => service.update(
        { id: ids.owner },
        created.observation.id,
        immutablePatch,
        `"${created.observation.version}"`,
      ),
      (error) => error instanceof ProblemError
        && error.status === 400
        && error.fieldErrors && Object.keys(error.fieldErrors).length > 0,
    );
  }
  const updated = await service.update({ id: ids.owner }, created.observation.id, { note: 'Korrigierte Notiz' }, `"${created.observation.version}"`);
  assert.equal(updated.note, 'Korrigierte Notiz');
  await assert.rejects(
    () => service.update(
      { id: ids.owner },
      created.observation.id,
      { note: 'Veraltete Änderung' },
      `"${created.observation.version}"`,
    ),
    (error) => error instanceof ProblemError && error.code === 'OBSERVATION_VERSION_CONFLICT',
  );
  await assert.rejects(
    () => service.delete({ id: ids.owner }, created.observation.id, `"${created.observation.version}"`),
    (error) => error instanceof ProblemError && error.code === 'OBSERVATION_VERSION_CONFLICT',
  );
  await service.delete({ id: ids.owner }, created.observation.id, `"${updated.version}"`);
  const listed = await service.list({ id: ids.owner }, {});
  assert.deepEqual(listed.items, []);
});

test('herbarium observation creation is protected by idempotency key and clientMutationId', async () => {
  const repositories = createRepositories();
  const service = new HerbariumService({
    repository: repositories.herbarium,
    fieldRepository: repositories.field,
    clock: () => new Date('2026-01-01T00:00:00.000Z'),
  });
  const actor = { id: ids.owner };
  const payload = {
    clientObservationId: ids.clientObservation,
    observedAt: '2026-01-01T00:00:00.000Z',
    note: 'Erster Fund',
    idempotencyKey: 'idempotency-key-obs-001',
  };

  // 1. Initial creation returns created: true
  const first = await service.create(actor, payload);
  assert.equal(first.created, true);
  assert.equal(first.observation.note, 'Erster Fund');
  assert.equal(repositories.observations.length, 1);

  // 2. Duplicate submission with same body returns created: false and existing observation
  const duplicate = await service.create(actor, payload);
  assert.equal(duplicate.created, false);
  assert.equal(duplicate.observation.id, first.observation.id);
  assert.equal(duplicate.observation.note, 'Erster Fund');
  assert.equal(repositories.observations.length, 1);

  // 3. Duplicate submission with same idempotencyKey but modified payload throws IDEMPOTENCY_CONFLICT
  await assert.rejects(
    () => service.create(actor, {
      ...payload,
      note: 'Geänderte Notiz mit gleichem Key',
    }),
    (error) => error instanceof ProblemError && error.code === 'IDEMPOTENCY_CONFLICT',
  );

  // 4. Creation using clientMutationId in request body
  const secondClientObsId = 'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeee2';
  const mutationPayload = {
    clientObservationId: secondClientObsId,
    observedAt: '2026-01-01T00:00:00.000Z',
    note: 'Fund mit clientMutationId',
    clientMutationId: 'mutation-key-obs-002',
  };
  const mutationFirst = await service.create(actor, mutationPayload);
  assert.equal(mutationFirst.created, true);
  assert.equal(repositories.observations.length, 2);

  const mutationDuplicate = await service.create(actor, mutationPayload);
  assert.equal(mutationDuplicate.created, false);
  assert.equal(mutationDuplicate.observation.id, mutationFirst.observation.id);
  assert.equal(repositories.observations.length, 2);
});

test('media upload reservation is idempotent with body idempotencyKey', async () => {
  const repositories = createRepositories();
  const field = new FieldService({
    repository: repositories.field,
    clock: () => new Date('2026-01-01T00:00:00.000Z'),
  });
  const actor = { id: ids.owner };
  const uploadPayload = {
    clientMediaId: ids.clientMedia,
    contentType: 'image/png',
    bytes: 1024,
    idempotencyKey: 'upload-idempotency-key-body-01',
  };

  const first = await field.reserveUpload(actor, uploadPayload, undefined, (id) => `https://api.example.test/uploads/${id}`);
  assert.equal(first.created, true);
  assert.equal(repositories.media.length, 1);

  const duplicate = await field.reserveUpload(actor, uploadPayload, undefined, (id) => `https://api.example.test/uploads/${id}`);
  assert.equal(duplicate.created, false);
  assert.equal(duplicate.id, first.id);
  assert.equal(repositories.media.length, 1);

  await assert.rejects(
    () => field.reserveUpload(actor, {
      ...uploadPayload,
      bytes: 2048,
    }, undefined, (id) => `https://api.example.test/uploads/${id}`),
    (error) => error instanceof ProblemError && error.code === 'IDEMPOTENCY_CONFLICT',
  );
});

test('an externally identified candidate can be confirmed and saved to the herbarium', async () => {
  const repositories = createRepositories();
  const field = new FieldService({
    repository: repositories.field,
    clock: () => new Date('2026-01-01T00:00:00.000Z'),
  });
  const herbarium = new HerbariumService({
    repository: repositories.herbarium,
    fieldRepository: repositories.field,
    clock: () => new Date('2026-01-01T00:00:00.000Z'),
  });
  const externalCandidateId = 'plantnet:gbif:2927079';
  repositories.jobs.push({
    id: 1,
    publicId: ids.clientJob,
    ownerId: ids.owner,
    status: 'identified',
    candidates: [{
      candidateId: externalCandidateId,
      scientificName: 'Bellis perennis',
      commonName: 'Gaensebluemchen',
      score: 0.98,
      provider: 'plantnet',
      modelVersion: 'plantnet-model-test',
    }],
    createdAt: '2026-01-01T00:00:00.000Z',
  });

  const confirmed = await field.confirmIdentification(
    { id: ids.owner },
    ids.clientJob,
    { candidateId: externalCandidateId },
  );
  assert.equal(confirmed.confirmedCandidateId, externalCandidateId);
  assert.equal(Object.hasOwn(confirmed, 'confirmedPlantId'), false);

  const created = await herbarium.create({ id: ids.owner }, {
    clientObservationId: ids.clientObservation,
    observedAt: '2026-01-01T00:00:00.000Z',
    note: 'Extern bestimmte Pflanze',
    identificationJobId: ids.clientJob,
  }, 'external-candidate-observation-key');
  assert.equal(created.created, true);
  assert.equal(Object.hasOwn(created.observation, 'confirmedPlantId'), false);
  assert.equal(created.observation.identification.confirmedCandidateId, externalCandidateId);
  assert.equal(created.observation.identification.candidates[0].candidateId, externalCandidateId);
});

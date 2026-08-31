'use strict';

const assert = require('node:assert/strict');
const test = require('node:test');

const { Queue } = require('bullmq');

const { FieldService } = require('../src/api/platform/services/core/field/field-service');
const {
  QUEUE_NAME,
  createIdentificationQueue,
  createIdentificationWorker,
  parseRedisConnection,
} = require('../src/api/platform/services/core/field/identification-queue');

// FIELD-04 asks for a *persistent* worker, so this suite deliberately refuses
// to fake the transport: it drives the real BullMQ queue against a real Redis.
// It is opt-in through PLANTINI_TEST_REDIS_URL so `npm test` stays hermetic and
// no CI job starts depending on an unavailable service. Point the variable at a
// scratch database, e.g. redis://127.0.0.1:6379/9 — the suite obliterates the
// queue it uses.
const REDIS_URL = process.env.PLANTINI_TEST_REDIS_URL;

const ids = {
  owner: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
  clientMedia: 'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
  clientJob: 'dddddddd-dddd-4ddd-8ddd-dddddddddddd',
  clientJobRecovered: 'dddddddd-dddd-4ddd-8ddd-ddddddddddde',
  plant: 'ffffffff-ffff-4fff-8fff-ffffffffffff',
};

const PNG = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 0]);

function createFieldRepository() {
  const media = [];
  const jobs = [];
  return {
    media,
    jobs,
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
    async findPendingJobs(limit) { return jobs.filter((item) => item.status === 'pending').slice(0, limit); },
  };
}

/** Reserve, upload and submit one identification for the given service. */
async function submitIdentification(field, actor, clientMediaId, clientJobId, keySuffix) {
  const reservation = await field.reserveUpload(actor, {
    clientMediaId,
    contentType: 'image/png',
    bytes: PNG.length,
  }, `upload-idempotency-${keySuffix}`, (id) => `https://api.example.test/uploads/${id}`);

  await field.attachUpload(actor, reservation.id, {
    buffer: PNG,
    size: PNG.length,
    contentType: 'image/png',
    storageKey: `${reservation.id}-${ids.owner}`,
  });

  return field.createIdentification(actor, {
    clientJobId,
    mediaId: reservation.id,
    expectedPlantId: ids.plant,
  }, `identification-key-${keySuffix}`);
}

async function waitForStatus(field, actor, jobId, expected, timeoutMs = 15_000) {
  const deadline = Date.now() + timeoutMs;
  let last;
  while (Date.now() < deadline) {
    last = await field.getIdentification(actor, jobId);
    if (last.status === expected) return last;
    await new Promise((resolve) => setTimeout(resolve, 50));
  }
  throw new Error(`Job ${jobId} stayed in status "${last && last.status}" instead of "${expected}".`);
}

test('FIELD-04: a submitted identification travels through the real BullMQ queue until it is identified', { skip: REDIS_URL ? false : 'PLANTINI_TEST_REDIS_URL is not set' }, async (t) => {
  const repository = createFieldRepository();
  const actor = { id: ids.owner };

  const queue = createIdentificationQueue({ redisUrl: REDIS_URL });
  const field = new FieldService({ repository, enqueue: queue.enqueue });

  const provider = {
    calls: [],
    async identify({ job, media }) {
      provider.calls.push({ jobId: job.publicId, mediaId: media.publicId });
      return {
        provider: 'plantnet',
        modelVersion: 'test-model-1',
        floraVersion: 'test-flora-1',
        // Mirrors plantnet-provider.js, which stamps provider and model
        // version onto every candidate before the service stores them.
        candidates: [
          { candidateId: 'candidate-oak', scientificName: 'Quercus robur', commonName: 'Stieleiche', score: 0.87, provider: 'plantnet', modelVersion: 'test-model-1' },
          { candidateId: 'candidate-beech', scientificName: 'Fagus sylvatica', score: 0.09, provider: 'plantnet', modelVersion: 'test-model-1' },
        ],
      };
    },
  };

  const worker = createIdentificationWorker({
    redisUrl: REDIS_URL,
    process: (jobId) => field.processIdentification(jobId, provider),
    enqueue: queue.enqueue,
  });

  t.after(async () => {
    await worker.close();
    await queue.close();
    const cleanup = new Queue(QUEUE_NAME, { connection: parseRedisConnection(REDIS_URL) });
    await cleanup.obliterate({ force: true });
    await cleanup.close();
  });

  const submitted = await submitIdentification(field, actor, ids.clientMedia, ids.clientJob, '0001');

  // The submit response must not contain a synchronous result: the caller sees
  // a pending job, the worker produces the candidates.
  assert.equal(submitted.status, 'pending');
  assert.equal(submitted.candidates, undefined);
  assert.equal(provider.calls.length, 0);

  const identified = await waitForStatus(field, actor, submitted.id, 'identified');

  assert.equal(identified.status, 'identified');
  assert.equal(identified.candidates.length, 2);
  assert.equal(identified.candidates[0].scientificName, 'Quercus robur');
  assert.equal(identified.candidates[0].provider, 'plantnet');
  assert.equal(identified.candidates[0].modelVersion, 'test-model-1');
  assert.equal(identified.attempts, 1);
  assert.deepEqual(identified.providerMetadata, {
    provider: 'plantnet',
    modelVersion: 'test-model-1',
    floraVersion: 'test-flora-1',
  });

  // The work really happened in the worker, exactly once, on the right media.
  assert.equal(provider.calls.length, 1);
  assert.equal(provider.calls[0].jobId, submitted.id);

  const persisted = repository.jobs.find((job) => job.publicId === submitted.id);
  assert.equal(persisted.attempts, 1);
  assert.deepEqual(persisted.providerMetadata, {
    provider: 'plantnet',
    modelVersion: 'test-model-1',
    floraVersion: 'test-flora-1',
  });
});

test('FIELD-04: a job persisted while the queue was unreachable is recovered and processed', { skip: REDIS_URL ? false : 'PLANTINI_TEST_REDIS_URL is not set' }, async (t) => {
  const repository = createFieldRepository();
  const actor = { id: ids.owner };

  const queue = createIdentificationQueue({ redisUrl: REDIS_URL });

  // Simulate the documented Redis-restart case: the enqueue attempt fails, the
  // job is still persisted as pending and stays visible to its owner.
  let queueReachable = false;
  const field = new FieldService({
    repository,
    enqueue: async (jobId, options) => {
      if (!queueReachable) throw new Error('Redis is unreachable.');
      return queue.enqueue(jobId, options);
    },
  });

  const provider = {
    calls: [],
    async identify({ job }) {
      provider.calls.push(job.publicId);
      return {
        provider: 'plantnet',
        modelVersion: 'test-model-1',
        candidates: [{ candidateId: 'candidate-oak', scientificName: 'Quercus robur', score: 0.91 }],
      };
    },
  };

  const worker = createIdentificationWorker({
    redisUrl: REDIS_URL,
    process: (jobId) => field.processIdentification(jobId, provider),
    enqueue: queue.enqueue,
  });

  t.after(async () => {
    await worker.close();
    await queue.close();
    const cleanup = new Queue(QUEUE_NAME, { connection: parseRedisConnection(REDIS_URL) });
    await cleanup.obliterate({ force: true });
    await cleanup.close();
  });

  const submitted = await submitIdentification(field, actor, ids.clientMedia, ids.clientJobRecovered, '0002');
  assert.equal(submitted.status, 'pending');

  // Nothing reached the worker while the queue was down.
  await new Promise((resolve) => setTimeout(resolve, 300));
  assert.equal(provider.calls.length, 0);
  assert.equal((await field.getIdentification(actor, submitted.id)).status, 'pending');

  queueReachable = true;
  const recovered = await field.recoverPendingJobs();
  assert.equal(recovered, 1);

  const identified = await waitForStatus(field, actor, submitted.id, 'identified');
  assert.equal(identified.candidates[0].scientificName, 'Quercus robur');
  assert.deepEqual(provider.calls, [submitted.id]);
});

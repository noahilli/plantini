'use strict';

const assert = require('node:assert/strict');
const test = require('node:test');

const { LearningService } = require('../src/api/platform/services/core/learning/learning-service');
const { ProblemError } = require('../src/api/platform/services/core/errors');

const ids = {
  actor: '11111111-1111-4111-8111-111111111111',
  level: '22222222-2222-4222-8222-222222222222',
  quizOne: '33333333-3333-4333-8333-333333333333',
  quizTwo: '44444444-4444-4444-8444-444444444444',
  clientAttempt: '55555555-5555-4555-8555-555555555555',
  clientEvent: '66666666-6666-4666-8666-666666666666',
  event: '77777777-7777-4777-8777-777777777777',
};

function createRepository() {
  const attempts = [];
  const events = [];
  const level = {
    publicId: ids.level,
    publishedAt: '2026-01-01T00:00:00.000Z',
    slug: 'laubbäume-1',
    releaseVersion: 'demo.1',
    completionRule: { minimumScore: 1, requiredQuizIds: [ids.quizOne, ids.quizTwo], requiredLevelIds: [] },
    quizzes: [
      { publicId: ids.quizOne, publishedAt: '2026-01-01T00:00:00.000Z' },
      { publicId: ids.quizTwo, publishedAt: '2026-01-01T00:00:00.000Z' },
    ],
  };
  return {
    attempts,
    events,
    async findAttemptByIdempotencyKey(key) { return attempts.find((item) => item.idempotencyKey === key); },
    async findAttemptByClientId(ownerId, clientAttemptId) {
      return attempts.find((item) => item.ownerId === ownerId && item.clientAttemptId === clientAttemptId);
    },
    async findAttemptByPublicId(ownerId, publicId) {
      return attempts.find((item) => item.ownerId === ownerId && item.publicId === publicId);
    },
    async createAttempt(input) {
      const value = { id: attempts.length + 1, ...input, createdAt: input.startedAt, updatedAt: input.startedAt };
      attempts.push(value);
      return value;
    },
    async updateAttempt(id, patch) {
      const attempt = attempts.find((item) => item.id === id);
      Object.assign(attempt, patch, { updatedAt: '2026-01-01T00:01:00.000Z' });
      return attempt;
    },
    async listAttemptsByOwner(ownerId) { return attempts.filter((item) => item.ownerId === ownerId); },
    async findEventByIdempotencyKey(key) { return events.find((item) => item.idempotencyKey === key); },
    async createEvent(input) {
      const value = { id: events.length + 1, ...input, createdAt: input.receivedAt, updatedAt: input.receivedAt };
      events.push(value);
      return value;
    },
    async findPublishedLevel(publicId) { return publicId === ids.level ? level : null; },
    async findPublishedQuizItems() {
      return [
        {
          publicId: ids.quizOne,
          publishedAt: '2026-01-01T00:00:00.000Z',
          slug: 'one',
          releaseVersion: 'demo.1',
          data: { correctChoiceId: 'oak' },
        },
        {
          publicId: ids.quizTwo,
          publishedAt: '2026-01-01T00:00:00.000Z',
          slug: 'two',
          releaseVersion: 'demo.1',
          data: { correctChoiceId: 'beech' },
        },
      ];
    },
    async listPublishedLevels() { return [level]; },
  };
}

test('server-authoritative attempts are idempotent and score only documented answers', async () => {
  const repository = createRepository();
  const service = new LearningService({ repository, clock: () => new Date('2026-01-01T00:00:00.000Z') });
  const actor = { id: ids.actor };
  const start = { levelId: ids.level, clientAttemptId: ids.clientAttempt, contentVersion: 'demo.1' };

  const first = await service.startAttempt(actor, start, 'start-idempotency-key-01');
  const repeated = await service.startAttempt(actor, start, 'start-idempotency-key-01');
  assert.equal(first.created, true);
  assert.equal(repeated.created, false);
  assert.equal(first.attempt.id, repeated.attempt.id);
  assert.equal(repository.attempts.length, 1);

  const completion = await service.completeAttempt(actor, first.attempt.id, {
    clientEventId: ids.clientEvent,
    answers: [
      { quizItemId: ids.quizOne, choiceId: 'oak' },
      { quizItemId: ids.quizTwo, choiceId: 'beech' },
    ],
  }, 'complete-idempotency-key-01');
  assert.equal(completion.passed, true);
  assert.equal(completion.score, 1);
  assert.equal(completion.progress.levels[0].status, 'completed');

  await assert.rejects(
    () => service.completeAttempt(actor, first.attempt.id, {
      clientEventId: ids.clientEvent,
      answers: [
        { quizItemId: ids.quizOne, choiceId: 'beech' },
        { quizItemId: ids.quizTwo, choiceId: 'beech' },
      ],
    }, 'complete-idempotency-key-01'),
    (error) => error instanceof ProblemError && error.code === 'IDEMPOTENCY_CONFLICT',
  );
});

test('offline learning events are acknowledged exactly once', async () => {
  const repository = createRepository();
  const service = new LearningService({ repository, clock: () => new Date('2026-01-01T00:00:00.000Z') });
  const actor = { id: ids.actor };
  const event = {
    clientEventId: ids.event,
    type: 'quiz_answered',
    occurredAt: '2026-01-01T00:00:00.000Z',
    payloadVersion: 1,
    payload: { levelId: ids.level },
  };

  const first = await service.submitEvents(actor, { events: [event] }, 'events-idempotency-key-01', 'trace');
  const duplicate = await service.submitEvents(actor, { events: [event] }, 'events-idempotency-key-02', 'trace');
  assert.deepEqual(first.acceptedClientEventIds, [ids.event]);
  assert.deepEqual(duplicate.acceptedClientEventIds, [ids.event]);
  assert.equal(repository.events.length, 1);
});

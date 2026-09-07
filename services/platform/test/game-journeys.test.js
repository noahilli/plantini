'use strict';

const assert = require('node:assert/strict');
const test = require('node:test');
const { randomUUID } = require('node:crypto');
const { memoryEntities } = require('./helpers/memory-entities');
const content = require('../src/api/platform/services/core/content/demo-content.de.json');
const { seedDemoContent, DEMO_RELEASE_VERSION, LEVELS } = require('../src/api/platform/services/core/content/demo-seed');
const { buildJourney } = require('../src/api/platform/services/core/content/demo-journeys');
const { stableContentId } = require('../src/api/platform/services/core/content/demo-content');
const { createStrapiRepositories } = require('../src/api/platform/services/core/strapi-repositories');
const { LearningService } = require('../src/api/platform/services/core/learning/learning-service');
const { ContentService, normaliseCompletionRule } = require('../src/api/platform/services/core/content/content-service');

const actor = { id: randomUUID() };
const otherActor = { id: randomUUID() };
const uid = (kind) => `api::${kind}.${kind}`;

async function world() {
  const entities = memoryEntities();
  await seedDemoContent({ entityService: entities });
  const repositories = createStrapiRepositories({ entityService: entities });
  const learning = new LearningService({ repository: repositories.learning, herbariumRepository: repositories.herbarium });
  const service = new ContentService({ repository: repositories.content });
  const ecosystems = await service.listEcosystems({});
  return { entities, repositories, learning, service, ecosystems: ecosystems.items };
}

async function start(world, levelId, owner = actor) {
  return world.learning.startAttempt(owner, {
    levelId, clientAttemptId: randomUUID(), contentVersion: DEMO_RELEASE_VERSION,
  }, randomUUID());
}

async function complete(world, levelId, passed = true, owner = actor) {
  const started = await start(world, levelId, owner);
  const quizzes = await world.repositories.content.findPublishedQuizItems(levelId);
  const body = {
    clientEventId: randomUUID(),
    answers: quizzes.map((quiz) => ({ quizItemId: quiz.publicId, choiceId: passed ? quiz.data.correctChoiceId : 'wrong' })),
  };
  const key = randomUUID();
  const result = await world.learning.completeAttempt(owner, started.attempt.id, body, key);
  return { result, started, body, key };
}

async function collect(world, ids, owner = actor, syncStatus = 'synced') {
  for (const confirmedPlantId of ids) {
    await world.entities.create(uid('observation'), { data: {
      ownerId: owner.id, confirmedPlantId, syncStatus, timestamp: '2026-01-01T00:00:00.000Z',
    } });
  }
}

test('GAME-03 seed exposes 30 ordered playable levels per ecosystem with unique, source-backed questions', async () => {
  const w = await world();
  const allQuizIds = new Set();
  for (const ecosystem of w.ecosystems) {
    assert.equal(ecosystem.levelIds.length, 30);
    const source = content.ecosystems.find((item) => item.ecosystem.slug === ecosystem.slug);
    for (const [index, levelId] of ecosystem.levelIds.entries()) {
      const level = await w.service.getLevel(actor, levelId, w.learning.getLevelAccess.bind(w.learning));
      assert.equal(level.sequence, index + 1);
      assert.equal(level.status, index === 0 ? 'available' : 'locked');
      assert.equal(level.plantIds.length, 1);
      const plant = await w.service.getPlant(level.plantIds[0]);
      assert.ok(level.learningGoal.startsWith(plant.description));
      if (index >= 10) assert.match(level.learningGoal, /[Ww]iederholung/);
      assert.equal(level.completionRule.collectionScope, 'ecosystem');
      assert.deepEqual(level.completionRule.requiredLevelIds, index ? [ecosystem.levelIds[index - 1]] : []);
      assert.equal(level.completionRule.requiredPlantIds.length, index === 29 ? 3 : 0);
      const quizzes = await w.repositories.content.findPublishedQuizItems(levelId);
      const publicQuizzes = await w.service.listQuizItems(actor, levelId, DEMO_RELEASE_VERSION);
      assert.equal(quizzes.length, 3);
      assert.deepEqual(new Set(quizzes.map((quiz) => quiz.publicId)), new Set(level.completionRule.requiredQuizIds));
      for (const quiz of quizzes) {
        assert.ok(!allQuizIds.has(quiz.publicId));
        allQuizIds.add(quiz.publicId);
        const original = source.quizzes.find((item) => item.slug === quiz.data.sourceQuizSlug);
        assert.equal(quiz.data.prompt, original.prompt);
        assert.deepEqual(quiz.data.choices, original.choices);
        assert.equal(quiz.data.correctChoiceId, original.correctChoiceId);
        assert.equal(w.entities.table(uid('plant')).find((p) => p.id === quiz.plant).publicId, plant.id);
        assert.equal(quiz.level.publicId, levelId);
      }
      assert.ok(publicQuizzes.items.every((quiz) => !('correctChoiceId' in quiz)));
    }
  }
  assert.equal(allQuizIds.size, 270);
});

test('GAME-03 sequential starts, failed retry, replay, actor isolation and revisits use authoritative history', async () => {
  const w = await world();
  const ecosystem = w.ecosystems[0];
  const [first, second] = ecosystem.levelIds;
  await assert.rejects(() => start(w, second), { code: 'LEVEL_LOCKED', status: 409 });
  await assert.rejects(() => start(w, ecosystem.levelIds[29]), { code: 'LEVEL_LOCKED' });
  const failed = await complete(w, first, false);
  assert.equal(failed.result.passed, false);
  await assert.rejects(() => start(w, second), { code: 'LEVEL_LOCKED' });
  const passed = await complete(w, first);
  assert.equal(passed.result.passed, true);
  const replay = await w.learning.completeAttempt(actor, passed.started.attempt.id, passed.body, passed.key);
  assert.deepEqual(replay, passed.result);
  const startReplay = await w.learning.startAttempt(actor, {
    levelId: first, clientAttemptId:
      w.entities.table(uid('level-attempt')).find((a) => a.publicId === passed.started.attempt.id).clientAttemptId,
    contentVersion: DEMO_RELEASE_VERSION,
  }, randomUUID());
  assert.equal(startReplay.created, false);
  assert.equal(startReplay.attempt.id, passed.started.attempt.id);
  await start(w, second);
  await assert.rejects(() => start(w, second, otherActor), { code: 'LEVEL_LOCKED' });
  await complete(w, first, false); // Failed revisit cannot revoke a prior pass.
  const progress = await w.learning.getProgress(actor, '2099-01-01T00:00:00Z');
  assert.equal(progress.levels.find((l) => l.levelId === first).status, 'completed');
  assert.notEqual(progress.levels.find((l) => l.levelId === second).status, 'locked');
  const foreignLevel = await w.service.getLevel(otherActor, second, w.learning.getLevelAccess.bind(w.learning));
  assert.equal(foreignLevel.status, 'locked');
});

test('GAME-03 all 30 quizzes pass without plants; ecosystem alone waits for 3 distinct correct owner species', async () => {
  const w = await world();
  for (const ecosystem of w.ecosystems) {
    let final;
    for (const levelId of ecosystem.levelIds) final = await complete(w, levelId);
    assert.equal(final.result.passed, true);
    let progress = await w.learning.getEcosystemProgress(actor, ecosystem.id);
    assert.equal(progress.completed, false);
    assert.equal(progress.status, 'collection_pending');
    assert.equal(progress.totalLevels, 30);
    assert.equal(progress.completedLevelCount, 30);
    assert.deepEqual(progress.completedLevelIds, ecosystem.levelIds);
    assert.equal(progress.requiredPlantIds.length, 3);
    const [one, two, three] = progress.requiredPlantIds;
    await collect(w, [one, one, one, randomUUID()]);
    await collect(w, [two, three], otherActor);
    await collect(w, [two, three], actor, 'deleted');
    progress = await w.learning.getEcosystemProgress(actor, ecosystem.id);
    assert.deepEqual(progress.collectedPlantIds, [one]);
    assert.deepEqual(progress.missingPlantIds, [two, three]);
    assert.equal(progress.completed, false);
    await collect(w, [two, three]);
    progress = await w.learning.getEcosystemProgress(actor, ecosystem.id);
    assert.equal(progress.completed, true);
    assert.equal(progress.status, 'completed');
    assert.deepEqual(progress.missingPlantIds, []);
    assert.equal((await w.learning.completeAttempt(actor, final.started.attempt.id, final.body, final.key)).passed, true);
    const foreign = await w.learning.getEcosystemProgress(otherActor, ecosystem.id);
    assert.equal(foreign.completedLevelCount, 0);
    assert.equal(foreign.status, 'in_progress');
  }
});

test('GAME-03 early collection counts and deletion affects trophy, never quiz passes', async () => {
  const w = await world();
  const ecosystem = w.ecosystems[0];
  const initial = await w.learning.getEcosystemProgress(actor, ecosystem.id);
  await collect(w, initial.requiredPlantIds);
  const early = await w.learning.getEcosystemProgress(actor, ecosystem.id);
  assert.deepEqual(early.collectedPlantIds, initial.requiredPlantIds);
  assert.equal(early.completed, false);
  for (const id of ecosystem.levelIds) await complete(w, id);
  assert.equal((await w.learning.getEcosystemProgress(actor, ecosystem.id)).completed, true);
  const observation = w.entities.table(uid('observation'))[0];
  await w.entities.update(uid('observation'), observation.id, { data: { syncStatus: 'deleted' } });
  const after = await w.learning.getEcosystemProgress(actor, ecosystem.id);
  assert.equal(after.status, 'collection_pending');
  assert.equal(after.completedLevelCount, 30);
});

test('GAME-03 seed migration preserves users and authored content, retires only old demo IDs, and reruns safely', async () => {
  const entities = memoryEntities();
  const oldVersion = '2026.08.28-de.1';
  for (const item of content.ecosystems) {
    for (const level of LEVELS) {
      const slug = `${item.ecosystem.slug}-${level.slug}`;
      await entities.create(uid('level'), { data: { publicId: stableContentId('level', slug), slug, releaseVersion: oldVersion, publishedAt: '2026-01-01' } });
    }
    for (const quiz of item.quizzes) {
      await entities.create(uid('quiz'), { data: { publicId: stableContentId('quiz', quiz.slug), slug: quiz.slug, releaseVersion: oldVersion, publishedAt: '2026-01-01' } });
    }
    for (const plant of item.plants) {
      await entities.create(uid('plant'), { data: { ...plant, publicId: stableContentId('plant', plant.slug), releaseVersion: oldVersion, publishedAt: '2026-01-01' } });
    }
    await entities.create(uid('ecosystem'), { data: { ...item.ecosystem, publicId: stableContentId('ecosystem', item.ecosystem.slug), releaseVersion: oldVersion, publishedAt: '2026-01-01' } });
  }
  const protectedRecords = [];
  for (const kind of ['plant', 'ecosystem', 'level', 'quiz', 'level-attempt', 'observation']) {
    const record = await entities.create(uid(kind), { data: { publicId: randomUUID(), slug: `authored-${kind}`, releaseVersion: oldVersion, publishedAt: '2026-01-01', ownerId: actor.id } });
    protectedRecords.push({ kind, record });
  }
  await entities.create(uid('content-release'), { data: { version: oldVersion, active: true } });
  const first = await seedDemoContent({ entityService: entities });
  assert.equal(first.seeded, true);
  assert.equal(first.release.changes.filter((change) => change.operation === 'delete').length, 99);
  assert.equal(entities.table(uid('plant')).length, 31);
  assert.equal(entities.table(uid('level')).filter((l) => l.publishedAt).length, 91);
  assert.equal(entities.table(uid('quiz')).filter((q) => q.publishedAt).length, 271);
  for (const { kind, record } of protectedRecords) assert.deepEqual(entities.table(uid(kind)).find((item) => item.id === record.id), record);
  const writeCount = entities.writes.length;
  const repeated = await seedDemoContent({ entityService: entities });
  assert.equal(repeated.seeded, false);
  assert.equal(entities.writes.length, writeCount);
  assert.equal(entities.table(uid('content-release')).filter((r) => r.active).length, 1);
});

test('GAME-03 interrupted seed resumes without duplicate content or active releases', async () => {
  const entities = memoryEntities();
  const create = entities.create;
  let remaining = 38;
  entities.create = async (...args) => {
    if (--remaining === 0) throw new Error('simulated interruption');
    return create(...args);
  };
  await assert.rejects(() => seedDemoContent({ entityService: entities }), /simulated interruption/);
  entities.create = create;
  await seedDemoContent({ entityService: entities });
  assert.equal(entities.table(uid('level')).length, 90);
  assert.equal(entities.table(uid('quiz')).length, 270);
  assert.equal(entities.table(uid('content-release')).length, 1);
});

test('GAME-03 malformed new collection rules and invalid journeys fail closed', async () => {
  assert.throws(() => normaliseCompletionRule({ collectionScope: 'ecosystem' }, []), { code: 'CONTENT_INTEGRITY_FAILED' });
  assert.throws(() => normaliseCompletionRule({ collectionScope: 'wrong' }, []), { code: 'CONTENT_INTEGRITY_FAILED' });
  assert.throws(() => normaliseCompletionRule({ collectionScope: 'ecosystem', requiredPlantIds: [42] }, []), { code: 'CONTENT_INTEGRITY_FAILED' });
  assert.throws(() => normaliseCompletionRule({ collectionScope: 'ecosystem', requiredPlantIds: ['not-a-uuid'] }, []), { code: 'CONTENT_INTEGRITY_FAILED' });
  const item = structuredClone(content.ecosystems[0]);
  item.quizzes.pop();
  assert.throws(() => buildJourney(item), /three source questions/);
  item.plants.pop();
  assert.throws(() => buildJourney(item), /Invalid journey/);
  const w = await world();
  const ecosystem = w.ecosystems[0];
  const level = w.entities.table(uid('level')).find((l) => l.publicId === ecosystem.levelIds[29]);
  level.completionRule.requiredPlantIds = [randomUUID(), randomUUID(), randomUUID()];
  await assert.rejects(() => w.learning.getEcosystemProgress(actor, ecosystem.id), { code: 'CONTENT_INTEGRITY_FAILED' });
  level.completionRule.requiredPlantIds = [];
  await assert.rejects(() => w.learning.getEcosystemProgress(actor, ecosystem.id), { code: 'CONTENT_INTEGRITY_FAILED' });
  await assert.rejects(() => w.learning.getEcosystemProgress(actor, randomUUID()), { code: 'ECOSYSTEM_NOT_FOUND' });
});

test('GAME-03 rejects foreign or duplicate quiz answers and completion of a bypassed attempt', async () => {
  const w = await world();
  const [first, second] = w.ecosystems[0].levelIds;
  const attempt = await start(w, first);
  const quizzes = await w.repositories.content.findPublishedQuizItems(first);
  const answers = quizzes.map((quiz) => ({ quizItemId: quiz.publicId, choiceId: quiz.data.correctChoiceId }));
  for (const invalid of [[answers[0], answers[0], answers[2]], answers.slice(1),
    [{ ...answers[0], quizItemId: randomUUID() }, ...answers.slice(1)]]) {
    await assert.rejects(() => w.learning.completeAttempt(actor, attempt.attempt.id,
      { clientEventId: randomUUID(), answers: invalid }, randomUUID()), { status: 400 });
  }
  const bypass = await w.repositories.learning.createAttempt({
    publicId: randomUUID(), ownerId: actor.id, clientAttemptId: randomUUID(),
    levelPublicId: second, contentVersion: DEMO_RELEASE_VERSION, status: 'active',
  });
  await assert.rejects(() => w.learning.completeAttempt(actor, bypass.publicId,
    { clientEventId: randomUUID(), answers }, randomUUID()), { code: 'LEVEL_LOCKED' });
  await assert.rejects(() => w.learning.completeAttempt(otherActor, attempt.attempt.id,
    { clientEventId: randomUUID(), answers }, randomUUID()), { code: 'LEVEL_ATTEMPT_NOT_FOUND' });
});

test('GAME-03 collection checks include records beyond the first page and fail closed when unavailable', async () => {
  const w = await world();
  const ecosystem = w.ecosystems[0];
  const before = await w.learning.getEcosystemProgress(actor, ecosystem.id);
  await collect(w, Array(1000).fill(randomUUID()));
  await collect(w, before.requiredPlantIds);
  assert.deepEqual((await w.learning.getEcosystemProgress(actor, ecosystem.id)).missingPlantIds, []);
  w.learning.herbariumRepository = undefined;
  await assert.rejects(() => w.learning.getEcosystemProgress(actor, ecosystem.id), { code: 'COLLECTION_GATE_UNAVAILABLE' });
  assert.equal((await complete(w, ecosystem.levelIds[0])).result.passed, true);
});

test('GAME-03 legacy ecosystem progress uses existing level gates; empty and mixed releases fail closed', async () => {
  const w = await world();
  const ecosystem = w.ecosystems[0];
  const levels = w.entities.table(uid('level')).filter((level) => ecosystem.levelIds.includes(level.publicId));
  for (const level of levels) delete level.completionRule.collectionScope;
  const legacy = await w.learning.getEcosystemProgress(actor, ecosystem.id);
  assert.deepEqual(legacy.requiredPlantIds, []);
  assert.equal(legacy.completed, false);
  levels[0].completionRule.collectionScope = 'ecosystem';
  await assert.rejects(() => w.learning.getEcosystemProgress(actor, ecosystem.id), { code: 'CONTENT_INTEGRITY_FAILED' });
  for (const level of levels) level.publishedAt = null;
  await assert.rejects(() => w.learning.getEcosystemProgress(actor, ecosystem.id), { code: 'CONTENT_INTEGRITY_FAILED' });
});

test('GAME-03 seed refuses authored slug collisions and repairs interrupted release retirement', async () => {
  const entities = memoryEntities();
  const authored = await entities.create(uid('plant'), { data: {
    slug: content.ecosystems[0].plants[0].slug, publicId: randomUUID(), releaseVersion: 'authored.1', publishedAt: '2026-01-01',
  } });
  await assert.rejects(() => seedDemoContent({ entityService: entities }), /Refusing to overwrite non-demo/);
  assert.deepEqual(entities.table(uid('plant'))[0], authored);
  const w = await world();
  await w.entities.create(uid('content-release'), { data: { version: 'old.1', active: true } });
  await seedDemoContent({ entityService: w.entities });
  assert.equal(w.entities.table(uid('content-release')).filter((r) => r.active).length, 1);
});

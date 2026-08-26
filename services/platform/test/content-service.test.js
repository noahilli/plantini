'use strict';

const assert = require('node:assert/strict');
const test = require('node:test');

const {
  ContentService,
  mapEcosystem,
  mapLevel,
  mapPlant,
  mapQuizItem,
  validateManifest,
} = require('../src/api/platform/services/core/content/content-service');
const { ProblemError } = require('../src/api/platform/services/core/errors');

const ids = {
  ecosystem: '11111111-1111-4111-8111-111111111111',
  level: '22222222-2222-4222-8222-222222222222',
  plant: '33333333-3333-4333-8333-333333333333',
  quiz: '44444444-4444-4444-8444-444444444444',
  media: '55555555-5555-4555-8555-555555555555',
};

function createMockRepository() {
  const activeRelease = {
    version: 'release-2026-v1',
    manifest: {
      version: 'release-2026-v1',
      releasedAt: '2026-08-25T10:00:00.000Z',
      schemaVersion: '1.0.0',
      minimumAppVersion: '1.0.0',
      packages: [
        {
          id: 'pkg-ecosystems-wald',
          url: 'https://cdn.plantini.test/packages/wald.json',
          sha256: 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
          bytes: 1024,
        },
      ],
    },
  };

  const ecosystem = {
    publicId: ids.ecosystem,
    slug: 'wald-und-forst',
    name: 'Wald & Forst',
    description: 'Mitteleuropäischer Mischwald',
    releaseVersion: 'release-2026-v1',
    publishedAt: '2026-08-25T10:00:00.000Z',
    levels: [{ publicId: ids.level, publishedAt: '2026-08-25T10:00:00.000Z', slug: 'laubbäume-1', releaseVersion: 'release-2026-v1' }],
  };

  const level = {
    publicId: ids.level,
    slug: 'laubbäume-1',
    title: 'Heimische Laubbäume',
    levelNumber: 1,
    learningGoal: 'Erkenne Stieleiche und Rotbuche',
    releaseVersion: 'release-2026-v1',
    publishedAt: '2026-08-25T10:00:00.000Z',
    ecosystem: { publicId: ids.ecosystem, publishedAt: '2026-08-25T10:00:00.000Z', slug: 'wald-und-forst', releaseVersion: 'release-2026-v1' },
    plants: [{ publicId: ids.plant, publishedAt: '2026-08-25T10:00:00.000Z', slug: 'quercus-robur', releaseVersion: 'release-2026-v1' }],
    quizzes: [{ publicId: ids.quiz, publishedAt: '2026-08-25T10:00:00.000Z', slug: 'eiche-quiz-1', releaseVersion: 'release-2026-v1' }],
    completionRule: { minimumScore: 0.8, requiredQuizIds: [ids.quiz] },
  };

  const plant = {
    publicId: ids.plant,
    slug: 'quercus-robur',
    scientificName: 'Quercus robur',
    commonName: 'Stieleiche',
    family: 'Fagaceae',
    description: 'Sommergrüner Laubbaum mit charakteristisch gelappten Blättern.',
    warning: 'Verwechslungsgefahr mit Roteiche.',
    sources: ['Wikipedia / Botanischer Garten'],
    releaseVersion: 'release-2026-v1',
    publishedAt: '2026-08-25T10:00:00.000Z',
    media: [
      {
        publicId: ids.media,
        slug: 'stieleiche-blatt',
        file: { url: 'https://cdn.plantini.test/images/eiche.jpg' },
        altText: 'Stieleichenblatt mit gelapptem Rand',
        license: 'CC-BY-SA-4.0',
        author: 'Botaniker A.',
        releaseVersion: 'release-2026-v1',
        publishedAt: '2026-08-25T10:00:00.000Z',
      },
    ],
  };

  const quizItem = {
    publicId: ids.quiz,
    slug: 'eiche-quiz-1',
    publishedAt: '2026-08-25T10:00:00.000Z',
    releaseVersion: 'release-2026-v1',
    data: {
      type: 'multiple-choice',
      prompt: 'Zu welcher Familie gehört die Stieleiche?',
      choices: [
        { id: 'fagaceae', label: 'Buchengewächse (Fagaceae)' },
        { id: 'betulaceae', label: 'Birkengewächse (Betulaceae)' },
      ],
      correctChoiceId: 'fagaceae',
    },
  };

  return {
    async findActiveRelease() { return activeRelease; },
    async listPublishedEcosystems(page) { return { items: [ecosystem], total: 1 }; },
    async findPublishedEcosystem(id) { return id === ids.ecosystem ? ecosystem : null; },
    async findPublishedLevel(id) { return id === ids.level ? level : null; },
    async findPublishedPlant(id) { return id === ids.plant ? plant : null; },
    async findPublishedQuizItems(levelId) { return levelId === ids.level ? [quizItem] : []; },
  };
}

test('manifest returns active release and supports ETag 304', async () => {
  const repository = createMockRepository();
  const service = new ContentService({ repository });

  const result = await service.getManifest();
  assert.equal(result.notModified, false);
  assert.equal(result.etag, '"release-2026-v1"');
  assert.equal(result.manifest.packages.length, 1);

  const cached = await service.getManifest('"release-2026-v1"');
  assert.equal(cached.notModified, true);
});

test('content service lists ecosystems, levels and structured plants with media', async () => {
  const repository = createMockRepository();
  const service = new ContentService({ repository });

  const ecoList = await service.listEcosystems({ page: 1, pageSize: 10 });
  assert.equal(ecoList.items.length, 1);
  assert.equal(ecoList.items[0].name, 'Wald & Forst');
  assert.deepEqual(ecoList.items[0].levelIds, [ids.level]);

  const levelRes = await service.getLevel({ id: 'actor-1' }, ids.level, async () => ({ status: 'available', progress: 0 }));
  assert.equal(levelRes.title, 'Heimische Laubbäume');
  assert.equal(levelRes.completionRule.minimumScore, 0.8);
  assert.deepEqual(levelRes.plantIds, [ids.plant]);

  const plantRes = await service.getPlant(ids.plant);
  assert.equal(plantRes.scientificName, 'Quercus robur');
  assert.equal(plantRes.commonName, 'Stieleiche');
  assert.equal(plantRes.media[0].license, 'CC-BY-SA-4.0');

  const quizRes = await service.listQuizItems({ id: 'actor-1' }, ids.level);
  assert.equal(quizRes.items.length, 1);
  assert.equal(quizRes.items[0].type, 'multiple_choice');
  assert.equal(quizRes.items[0].choices.length, 2);
});

test('content service throws 404 for unknown plant or level', async () => {
  const repository = createMockRepository();
  const service = new ContentService({ repository });

  await assert.rejects(
    () => service.getPlant('99999999-9999-4999-8999-999999999999'),
    (err) => err instanceof ProblemError && err.status === 404,
  );

  await assert.rejects(
    () => service.getLevel({ id: 'actor-1' }, '99999999-9999-4999-8999-999999999999', async () => ({})),
    (err) => err instanceof ProblemError && err.status === 404,
  );
});

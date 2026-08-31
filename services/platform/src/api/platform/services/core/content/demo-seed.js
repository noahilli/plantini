'use strict';

const { createHash } = require('crypto');
const content = require('./demo-content.de.json');
const { DEMO_RELEASE_VERSION, stableContentId, validateDemoContent } = require('./demo-content');

const LEVELS = [
  { slug: 'arten-erkennen', title: 'Arten erkennen', learningGoal: 'Du erkennst zehn typische Pflanzen an mehreren sichtbaren Merkmalen.' },
  { slug: 'merkmale-vergleichen', title: 'Merkmale vergleichen', learningGoal: 'Du vergleichst ähnliche Arten anhand von Blättern, Blüten und Wuchsform.' },
  { slug: 'lebensraeume-verstehen', title: 'Lebensräume verstehen', learningGoal: 'Du ordnest die Pflanzen ihren typischen Standorten und ökologischen Bedingungen zu.' },
];

async function seedDemoContent(strapi) {
  const dataset = validateDemoContent(content);
  const rawEntities = strapi.entityService;
  const existingRelease = await rawEntities.findMany('api::content-release.content-release', {
    filters: { version: DEMO_RELEASE_VERSION }, limit: 1,
  });
  if (Array.isArray(existingRelease) && existingRelease.length > 0) {
    return { seeded: false, release: existingRelease[0] };
  }

  const now = new Date().toISOString();
  const changes = [];
  const entities = createUpsertingEntityService(rawEntities);
  await unpublishExistingDemoContent(rawEntities);

  for (const ecosystemContent of dataset.ecosystems) {
    const plantsBySlug = new Map();
    for (const plantContent of ecosystemContent.plants) {
      const publicId = stableContentId('plant', plantContent.slug);
      const plant = await entities.upsert('api::plant.plant', {
        publicId, ...plantContent, releaseVersion: DEMO_RELEASE_VERSION,
        reviewStatus: 'approved', publishedAt: now,
      });
      plantsBySlug.set(plantContent.slug, plant);
      changes.push(change('plant', publicId));
    }

    const ecosystemId = stableContentId('ecosystem', ecosystemContent.ecosystem.slug);
    const sourceEcosystem = ecosystemContent.ecosystem;
    const ecosystem = await entities.upsert('api::ecosystem.ecosystem', {
      publicId: ecosystemId, slug: sourceEcosystem.slug, name: sourceEcosystem.name,
      description: sourceEcosystem.description, climateZone: sourceEcosystem.climateZone,
      region: sourceEcosystem.region, season: sourceEcosystem.season, language: 'de',
      releaseVersion: DEMO_RELEASE_VERSION, publishedAt: now,
    });
    changes.push(change('ecosystem', ecosystemId));

    let previousLevelId;
    for (let levelIndex = 0; levelIndex < LEVELS.length; levelIndex += 1) {
      const definition = LEVELS[levelIndex];
      const levelSlug = `${ecosystemContent.ecosystem.slug}-${definition.slug}`;
      const levelId = stableContentId('level', levelSlug);
      const levelQuizzes = ecosystemContent.quizzes.filter((_, index) => index % LEVELS.length === levelIndex);
      const quizIds = levelQuizzes.map((quiz) => stableContentId('quiz', quiz.slug));
      const levelPlantIds = [...new Set(levelQuizzes.map((quiz) => quiz.plantSlug))]
        .map((slug) => plantsBySlug.get(slug).id);
      const level = await entities.upsert('api::level.level', {
        publicId: levelId, slug: levelSlug, releaseVersion: DEMO_RELEASE_VERSION,
        title: definition.title, levelNumber: levelIndex + 1, sequence: levelIndex + 1,
        difficulty: levelIndex === 0 ? 'beginner' : 'intermediate',
        learningGoal: definition.learningGoal,
        completionRule: {
          minimumScore: 0.7, requiredQuizIds: quizIds,
          requiredLevelIds: previousLevelId ? [previousLevelId] : [],
        },
        ecosystem: ecosystem.id, plants: levelPlantIds, publishedAt: now,
      });
      changes.push(change('level', levelId));

      for (const quizContent of levelQuizzes) {
        const publicId = stableContentId('quiz', quizContent.slug);
        await entities.upsert('api::quiz.quiz', {
          publicId, slug: quizContent.slug, releaseVersion: DEMO_RELEASE_VERSION,
          contentVersion: DEMO_RELEASE_VERSION, title: quizContent.title,
          quizType: 'multiple-choice',
          data: {
            type: 'multiple_choice', prompt: quizContent.prompt,
            choices: quizContent.choices, correctChoiceId: quizContent.correctChoiceId,
          },
          level: level.id, plant: plantsBySlug.get(quizContent.plantSlug).id,
          reviewStatus: 'approved', publishedAt: now,
        });
        changes.push(change('quiz_item', publicId));
      }
      previousLevelId = levelId;
    }
  }

  const manifest = {
    version: DEMO_RELEASE_VERSION, releasedAt: now, schemaVersion: '1.0',
    minimumAppVersion: '1.0.0', packages: [],
  };
  const previousActiveReleases = await rawEntities.findMany('api::content-release.content-release', {
    filters: { active: true },
  });
  await Promise.all(previousActiveReleases.map((item) => rawEntities.update(
    'api::content-release.content-release', item.id, { data: { active: false } },
  )));
  const release = await rawEntities.create('api::content-release.content-release', {
    data: {
      version: DEMO_RELEASE_VERSION, active: true, manifest,
      cursor: createHash('sha256').update(`${DEMO_RELEASE_VERSION}:${now}`).digest('hex'),
      changes, publishedAt: now,
    },
  });
  return { seeded: true, release };
}

function createUpsertingEntityService(entities) {
  return {
    async upsert(uid, data) {
      const matches = await entities.findMany(uid, {
        filters: { $or: [{ publicId: data.publicId }, { slug: data.slug }] }, limit: 1,
      });
      if (Array.isArray(matches) && matches.length > 0) {
        return entities.update(uid, matches[0].id, { data });
      }
      return entities.create(uid, { data });
    },
  };
}

async function unpublishExistingDemoContent(entities) {
  for (const uid of ['api::quiz.quiz', 'api::level.level', 'api::plant.plant', 'api::ecosystem.ecosystem']) {
    const records = await entities.findMany(uid, {});
    await Promise.all((Array.isArray(records) ? records : []).map((record) =>
      entities.update(uid, record.id, { data: { publishedAt: null } })));
  }
}

function change(entity, id) {
  return { entity, id, operation: 'upsert', version: DEMO_RELEASE_VERSION };
}

module.exports = { DEMO_RELEASE_VERSION, LEVELS, seedDemoContent };

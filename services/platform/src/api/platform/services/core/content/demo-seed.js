'use strict';

const { createHash } = require('crypto');
const content = require('./demo-content.de.json');
const { DEMO_RELEASE_VERSION, stableContentId, validateDemoContent } = require('./demo-content');
const { buildJourney } = require('./demo-journeys');

const LEVELS = [
  { slug: 'arten-erkennen', title: 'Arten erkennen', learningGoal: 'Du erkennst zehn typische Pflanzen an mehreren sichtbaren Merkmalen.' },
  { slug: 'merkmale-vergleichen', title: 'Merkmale vergleichen', learningGoal: 'Du vergleichst ähnliche Arten anhand von Blättern, Blüten und Wuchsform.' },
  { slug: 'lebensraeume-verstehen', title: 'Lebensräume verstehen', learningGoal: 'Du ordnest die Pflanzen ihren typischen Standorten und ökologischen Bedingungen zu.' },
];

async function seedDemoContent(strapi) {
  const dataset = validateDemoContent(content);
  // Validate the complete expansion before writing any content.
  const journeys = dataset.ecosystems.map(buildJourney);
  const rawEntities = strapi.entityService;
  const existingRelease = await rawEntities.findMany('api::content-release.content-release', {
    filters: { version: DEMO_RELEASE_VERSION }, limit: 1,
  });
  if (Array.isArray(existingRelease) && existingRelease.length > 0) {
    // Resume an interruption after publishing the new release but before
    // retiring the previous active marker. Do not reactivate an old release.
    if (existingRelease[0].active) await retirePreviousReleases(rawEntities, existingRelease[0].id);
    return { seeded: false, release: existingRelease[0] };
  }

  const now = new Date().toISOString();
  const changes = [];
  const entities = createUpsertingEntityService(rawEntities);

  for (const [ecosystemIndex, ecosystemContent] of dataset.ecosystems.entries()) {
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

    for (const definition of journeys[ecosystemIndex]) {
      const levelId = definition.publicId;
      const levelQuizzes = definition.quizzes;
      const level = await entities.upsert('api::level.level', {
        publicId: levelId, slug: definition.slug, releaseVersion: DEMO_RELEASE_VERSION,
        title: definition.title, levelNumber: definition.sequence, sequence: definition.sequence,
        difficulty: definition.sequence <= 10 ? 'beginner' : 'intermediate',
        learningGoal: definition.learningGoal,
        completionRule: definition.completionRule,
        ecosystem: ecosystem.id, plants: [plantsBySlug.get(definition.plantSlug).id], publishedAt: now,
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
            sourceQuizSlug: quizContent.sourceQuizSlug, reviewPhase: quizContent.reviewPhase,
          },
          level: level.id, plant: plantsBySlug.get(quizContent.plantSlug).id,
          reviewStatus: 'approved', publishedAt: now,
        });
        changes.push(change('quiz_item', publicId));
      }
    }
  }

  changes.push(...await archiveSupersededDemoContent(rawEntities, dataset));

  const manifest = {
    version: DEMO_RELEASE_VERSION, releasedAt: now, schemaVersion: '1.0',
    minimumAppVersion: '1.0.0', packages: [],
  };
  const release = await rawEntities.create('api::content-release.content-release', {
    data: {
      version: DEMO_RELEASE_VERSION, active: true, manifest,
      cursor: createHash('sha256').update(`${DEMO_RELEASE_VERSION}:${now}`).digest('hex'),
      changes, publishedAt: now,
    },
  });
  await retirePreviousReleases(rawEntities, release.id);
  return { seeded: true, release };
}

async function retirePreviousReleases(entities, releaseId) {
  const releases = await entities.findMany('api::content-release.content-release', {
    filters: { active: true, id: { $ne: releaseId } },
  });
  for (const release of releases) {
    await entities.update('api::content-release.content-release', release.id, { data: { active: false } });
  }
}

function createUpsertingEntityService(entities) {
  return {
    async upsert(uid, data) {
      const matches = await entities.findMany(uid, {
        filters: { $or: [{ publicId: data.publicId }, { slug: data.slug }] }, limit: 1,
      });
      if (Array.isArray(matches) && matches.length > 0) {
        if (matches[0].publicId !== data.publicId
          || ![DEMO_RELEASE_VERSION, '2026.09.07-de.1', '2026.08.28-de.1'].includes(matches[0].releaseVersion)) {
          throw new Error(`Refusing to overwrite non-demo content: ${uid}/${data.slug}`);
        }
        return entities.update(uid, matches[0].id, { data });
      }
      return entities.create(uid, { data });
    },
  };
}

async function archiveSupersededDemoContent(entities, dataset) {
  const changes = [];
  for (const [kind, uid, ids] of [
    ['level', 'api::level.level', dataset.ecosystems.flatMap((item) => LEVELS.map((level) =>
      stableContentId('level', `${item.ecosystem.slug}-${level.slug}`)))],
    ['quiz_item', 'api::quiz.quiz', dataset.ecosystems.flatMap((item) => item.quizzes.map((quiz) =>
      stableContentId('quiz', quiz.slug)))],
  ]) {
    const records = await entities.findMany(uid, {
      filters: { publicId: { $in: ids }, releaseVersion: '2026.08.28-de.1' },
      publicationState: 'preview',
    });
    for (const record of records) {
      // Keep old rows (including attempt references); retire only known demo
      // IDs from the old release. Never touch unrelated authored content.
      await entities.update(uid, record.id, { data: { publishedAt: null } });
      changes.push({ ...change(kind, record.publicId), operation: 'delete' });
    }
  }
  return changes;
}

function change(entity, id) {
  return { entity, id, operation: 'upsert', version: DEMO_RELEASE_VERSION };
}

module.exports = { DEMO_RELEASE_VERSION, LEVELS, seedDemoContent };

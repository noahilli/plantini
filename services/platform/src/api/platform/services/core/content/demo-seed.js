'use strict';

const { createHash } = require('crypto');

// Explicitly synthetic, licence-safe data used only by the e2e compose profile.
// It is deliberately small: its purpose is proving the entire contract path,
// not pretending to be scientifically reviewed production content.
const DEMO_RELEASE_VERSION = '2026.08.27-e2e.1';
const IDS = {
  ecosystem: '10000000-0000-4000-8000-000000000001',
  levelTrees: '10000000-0000-4000-8000-000000000010',
  levelLeaves: '10000000-0000-4000-8000-000000000011',
  levelTrail: '10000000-0000-4000-8000-000000000012',
  plantOak: '10000000-0000-4000-8000-000000000101',
  plantBeech: '10000000-0000-4000-8000-000000000102',
  quizOak: '10000000-0000-4000-8000-000000000201',
  quizBeech: '10000000-0000-4000-8000-000000000202',
  quizLeafShape: '10000000-0000-4000-8000-000000000203',
  quizFruit: '10000000-0000-4000-8000-000000000204',
  quizHabitat: '10000000-0000-4000-8000-000000000205',
  quizComparison: '10000000-0000-4000-8000-000000000206',
};

async function seedDemoContent(strapi) {
  const rawEntities = strapi.entityService;
  // Demo content uses stable public IDs so attempts and client caches keep a
  // meaningful identity across a refreshed local release. Strapi's entity
  // service has no upsert, therefore make that behaviour explicit here.
  const entities = {
    findMany: (...args) => rawEntities.findMany(...args),
    create: async (uid, options) => {
      const publicId = options.data && options.data.publicId;
      if (typeof publicId !== 'string') return rawEntities.create(uid, options);
      const matches = await rawEntities.findMany(uid, {
        filters: { publicId },
        limit: 1,
      });
      if (Array.isArray(matches) && matches.length > 0) {
        return rawEntities.update(uid, matches[0].id, options);
      }
      return rawEntities.create(uid, options);
    },
  };
  const existing = await entities.findMany('api::content-release.content-release', {
    filters: { version: DEMO_RELEASE_VERSION },
    limit: 1,
  });
  if (Array.isArray(existing) && existing.length > 0) return { seeded: false, release: existing[0] };

  const now = new Date().toISOString();
  const release = DEMO_RELEASE_VERSION;
  const oak = await entities.create('api::plant.plant', {
    data: {
      publicId: IDS.plantOak,
      slug: 'stieleiche',
      releaseVersion: release,
      scientificName: 'Quercus robur',
      commonName: 'Stieleiche',
      family: 'Fagaceae',
      description: 'Eine heimische Eiche mit lang gestielten Blättern und Eicheln.',
      sources: ['https://www.waldwissen.net/de/waldwirtschaft/waldbau/waldbaukonzepte/stieleiche-quercus-robur'],
      warning: 'Nicht aus einem Foto allein bestimmen; ähnliche Arten vergleichen.',
      reviewStatus: 'approved',
      publishedAt: now,
    },
  });
  const beech = await entities.create('api::plant.plant', {
    data: {
      publicId: IDS.plantBeech,
      slug: 'rotbuche',
      releaseVersion: release,
      scientificName: 'Fagus sylvatica',
      commonName: 'Rotbuche',
      family: 'Fagaceae',
      description: 'Ein prägender Baum vieler mitteleuropäischer Wälder.',
      sources: ['https://www.waldwissen.net/de/waldwirtschaft/waldbau/waldbaukonzepte/rotbuche-fagus-sylvatica'],
      warning: 'Lerne immer mehrere Merkmale und den Standort kennen.',
      reviewStatus: 'approved',
      publishedAt: now,
    },
  });
  const ecosystem = await entities.create('api::ecosystem.ecosystem', {
    data: {
      publicId: IDS.ecosystem,
      slug: 'laubwald',
      releaseVersion: release,
      name: 'Mitteleuropäischer Laubwald',
      description: 'Ein erstes, synthetisches Lerngebiet für den automatisierten Kernreise-Test.',
      climateZone: 'temperate',
      region: 'Mitteleuropa',
      season: 'Frühling bis Herbst',
      language: 'de',
      publishedAt: now,
    },
  });
  const treesLevel = await entities.create('api::level.level', {
    data: {
      publicId: IDS.levelTrees,
      slug: 'laubwald-baeume-1',
      releaseVersion: release,
      title: 'Bäume im Laubwald',
      levelNumber: 1,
      sequence: 1,
      difficulty: 'beginner',
      learningGoal: 'Du erkennst Stieleiche und Rotbuche anhand verlässlicher Merkmale.',
      completionRule: { minimumScore: 1, requiredQuizIds: [IDS.quizOak, IDS.quizBeech], requiredLevelIds: [] },
      ecosystem: ecosystem.id,
      plants: [oak.id, beech.id],
      publishedAt: now,
    },
  });
  const leavesLevel = await entities.create('api::level.level', {
    data: {
      publicId: IDS.levelLeaves,
      slug: 'laubwald-blaetter-2',
      releaseVersion: release,
      title: 'Blätter lesen',
      levelNumber: 2,
      sequence: 2,
      difficulty: 'beginner',
      learningGoal: 'Du vergleichst Blattform und Früchte von Stieleiche und Rotbuche.',
      completionRule: {
        minimumScore: 1,
        requiredQuizIds: [IDS.quizLeafShape, IDS.quizFruit],
        requiredLevelIds: [IDS.levelTrees],
      },
      ecosystem: ecosystem.id,
      plants: [oak.id, beech.id],
      publishedAt: now,
    },
  });
  const trailLevel = await entities.create('api::level.level', {
    data: {
      publicId: IDS.levelTrail,
      slug: 'laubwald-forscherziel-3',
      releaseVersion: release,
      title: 'Dein Forscherziel',
      levelNumber: 3,
      sequence: 3,
      difficulty: 'beginner',
      learningGoal: 'Du setzt beide Arten im Lebensraum Laubwald sicher auseinander.',
      completionRule: {
        minimumScore: 1,
        requiredQuizIds: [IDS.quizHabitat, IDS.quizComparison],
        requiredLevelIds: [IDS.levelLeaves],
      },
      ecosystem: ecosystem.id,
      plants: [oak.id, beech.id],
      publishedAt: now,
    },
  });
  await entities.create('api::quiz.quiz', {
    data: {
      publicId: IDS.quizOak,
      slug: 'quiz-stieleiche',
      releaseVersion: release,
      contentVersion: release,
      title: 'Stieleiche erkennen',
      quizType: 'multiple-choice',
      data: {
        type: 'multiple_choice',
        prompt: 'Welche Art trägt lang gestielte Eicheln?',
        choices: [
          { id: 'oak', label: 'Stieleiche' },
          { id: 'beech', label: 'Rotbuche' },
        ],
        correctChoiceId: 'oak',
      },
      level: treesLevel.id,
      plant: oak.id,
      reviewStatus: 'approved',
      publishedAt: now,
    },
  });
  await entities.create('api::quiz.quiz', {
    data: {
      publicId: IDS.quizBeech,
      slug: 'quiz-rotbuche',
      releaseVersion: release,
      contentVersion: release,
      title: 'Rotbuche erkennen',
      quizType: 'multiple-choice',
      data: {
        type: 'multiple_choice',
        prompt: 'Welche Art hat glattrandige, glänzende Blätter?',
        choices: [
          { id: 'beech', label: 'Rotbuche' },
          { id: 'oak', label: 'Stieleiche' },
        ],
        correctChoiceId: 'beech',
      },
      level: treesLevel.id,
      plant: beech.id,
      reviewStatus: 'approved',
      publishedAt: now,
    },
  });
  await entities.create('api::quiz.quiz', {
    data: {
      publicId: IDS.quizLeafShape,
      slug: 'quiz-buchenblatt',
      releaseVersion: release,
      contentVersion: release,
      title: 'Buchenblatt erkennen',
      quizType: 'multiple-choice',
      data: {
        type: 'multiple_choice',
        prompt: 'Welche Beschreibung passt zur Rotbuche?',
        choices: [
          { id: 'beech', label: 'Glattrandige, glänzende Blätter' },
          { id: 'oak', label: 'Tief gelappte Blätter' },
        ],
        correctChoiceId: 'beech',
      },
      level: leavesLevel.id,
      plant: beech.id,
      reviewStatus: 'approved',
      publishedAt: now,
    },
  });
  await entities.create('api::quiz.quiz', {
    data: {
      publicId: IDS.quizFruit,
      slug: 'quiz-eichel',
      releaseVersion: release,
      contentVersion: release,
      title: 'Eicheln zuordnen',
      quizType: 'multiple-choice',
      data: {
        type: 'multiple_choice',
        prompt: 'Zu welcher Art gehören Eicheln?',
        choices: [
          { id: 'oak', label: 'Stieleiche' },
          { id: 'beech', label: 'Rotbuche' },
        ],
        correctChoiceId: 'oak',
      },
      level: leavesLevel.id,
      plant: oak.id,
      reviewStatus: 'approved',
      publishedAt: now,
    },
  });
  await entities.create('api::quiz.quiz', {
    data: {
      publicId: IDS.quizHabitat,
      slug: 'quiz-laubwald',
      releaseVersion: release,
      contentVersion: release,
      title: 'Laubwald beobachten',
      quizType: 'multiple-choice',
      data: {
        type: 'multiple_choice',
        prompt: 'Welche beiden Arten gehören zu diesem Lernpfad?',
        choices: [
          { id: 'both', label: 'Stieleiche und Rotbuche' },
          { id: 'conifers', label: 'Fichte und Kiefer' },
        ],
        correctChoiceId: 'both',
      },
      level: trailLevel.id,
      plant: oak.id,
      reviewStatus: 'approved',
      publishedAt: now,
    },
  });
  await entities.create('api::quiz.quiz', {
    data: {
      publicId: IDS.quizComparison,
      slug: 'quiz-artvergleich',
      releaseVersion: release,
      contentVersion: release,
      title: 'Arten vergleichen',
      quizType: 'multiple-choice',
      data: {
        type: 'multiple_choice',
        prompt: 'Welche Kombination ist ein verlässliches Unterscheidungsmerkmal?',
        choices: [
          { id: 'leaves', label: 'Gelappte Eichenblätter, glattrandige Buchenblätter' },
          { id: 'colour', label: 'Nur die Blattfarbe' },
        ],
        correctChoiceId: 'leaves',
      },
      level: trailLevel.id,
      plant: beech.id,
      reviewStatus: 'approved',
      publishedAt: now,
    },
  });
  const manifest = {
    version: release,
    releasedAt: now,
    schemaVersion: '1.0',
    minimumAppVersion: '1.0.0',
    packages: [],
  };
  const changes = [
    { entity: 'ecosystem', id: IDS.ecosystem, operation: 'upsert', version: release },
    { entity: 'level', id: IDS.levelTrees, operation: 'upsert', version: release },
    { entity: 'level', id: IDS.levelLeaves, operation: 'upsert', version: release },
    { entity: 'level', id: IDS.levelTrail, operation: 'upsert', version: release },
    { entity: 'plant', id: IDS.plantOak, operation: 'upsert', version: release },
    { entity: 'plant', id: IDS.plantBeech, operation: 'upsert', version: release },
    { entity: 'quiz_item', id: IDS.quizOak, operation: 'upsert', version: release },
    { entity: 'quiz_item', id: IDS.quizBeech, operation: 'upsert', version: release },
    { entity: 'quiz_item', id: IDS.quizLeafShape, operation: 'upsert', version: release },
    { entity: 'quiz_item', id: IDS.quizFruit, operation: 'upsert', version: release },
    { entity: 'quiz_item', id: IDS.quizHabitat, operation: 'upsert', version: release },
    { entity: 'quiz_item', id: IDS.quizComparison, operation: 'upsert', version: release },
  ];
  // Keep the previous release active until every referenced content record is
  // valid. A failed seed must not turn a local presentation stack into an
  // empty-content stack.
  const previousActiveReleases = await rawEntities.findMany('api::content-release.content-release', {
    filters: { active: true },
  });
  await Promise.all(
    previousActiveReleases.map((item) => rawEntities.update(
      'api::content-release.content-release',
      item.id,
      { data: { active: false } },
    )),
  );
  const contentRelease = await entities.create('api::content-release.content-release', {
    data: {
      version: release,
      active: true,
      manifest,
      cursor: createHash('sha256').update(`${release}:${now}`).digest('hex'),
      changes,
      publishedAt: now,
    },
  });
  return { seeded: true, release: contentRelease };
}

module.exports = {
  DEMO_RELEASE_VERSION,
  IDS,
  seedDemoContent,
};

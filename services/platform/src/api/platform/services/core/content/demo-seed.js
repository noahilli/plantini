'use strict';

const { createHash } = require('crypto');

// Explicitly synthetic, licence-safe data used only by the e2e compose profile.
// It is deliberately small: its purpose is proving the entire contract path,
// not pretending to be scientifically reviewed production content.
const DEMO_RELEASE_VERSION = '2026.08.26-e2e.1';
const IDS = {
  ecosystem: '10000000-0000-4000-8000-000000000001',
  level: '10000000-0000-4000-8000-000000000010',
  plantOak: '10000000-0000-4000-8000-000000000101',
  plantBeech: '10000000-0000-4000-8000-000000000102',
  quizOak: '10000000-0000-4000-8000-000000000201',
  quizBeech: '10000000-0000-4000-8000-000000000202',
};

async function seedDemoContent(strapi) {
  const entities = strapi.entityService;
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
  const level = await entities.create('api::level.level', {
    data: {
      publicId: IDS.level,
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
      level: level.id,
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
      level: level.id,
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
    { entity: 'level', id: IDS.level, operation: 'upsert', version: release },
    { entity: 'plant', id: IDS.plantOak, operation: 'upsert', version: release },
    { entity: 'plant', id: IDS.plantBeech, operation: 'upsert', version: release },
    { entity: 'quiz_item', id: IDS.quizOak, operation: 'upsert', version: release },
    { entity: 'quiz_item', id: IDS.quizBeech, operation: 'upsert', version: release },
  ];
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

'use strict';

const { createHash } = require('crypto');
const { stableContentId } = require('./demo-content');
const { PHASES } = require('./demo-journeys');
const { quizzesFromCards, rotateChoices } = require('./lesson-cards');

const BLUEPRINT = 'api::journey-blueprint.journey-blueprint';
const active = new Set();
const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

/** Deterministic compiler, not an LLM: every question comes from an authored
 * fact card. No imports, media scraping, invented facts or publication. */
function compileBlueprint(blueprint) {
  if (!/^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(blueprint.slug || '')
    || !blueprint.releaseVersion?.trim()
    || !blueprint.ecosystem?.id || !UUID.test(blueprint.ecosystem.publicId || '')) {
    throw new Error('Lernpfad benötigt einen ASCII-Slug, eine Release-Version und ein Ökosystem mit öffentlicher UUID.');
  }
  const stations = blueprint.stations || [];
  if (stations.length !== 10 || stations.some((station) => !station.plant?.publicId)
    || new Set(stations.map((station) => station.plant.publicId)).size !== 10) {
    throw new Error('Genau zehn unterschiedliche Pflanzenstationen auswählen.');
  }
  const targets = stations.filter((station) => station.collectionTarget).map((station) => station.plant.publicId);
  if (targets.length !== 3) throw new Error('Genau drei fotografische Sammelziele markieren.');

  const sources = stations.map(({ plant, collectionTarget }) => {
    if (!plant?.id || !UUID.test(plant.publicId || '') || !plant.description?.trim()
      || !plant.warning?.trim() || !Array.isArray(plant.sources) || !plant.sources.length
      || plant.sources.some((url) => typeof url !== 'string' || !url.startsWith('https://'))) {
      throw new Error('Jede Pflanze benötigt eine UUID, Beschreibung, Sicherheitshinweis und HTTPS-Quellen.');
    }
    const quizzes = quizzesFromCards(plant);
    return {
      plantId: plant.id, publicId: plant.publicId,
      commonName: plant.commonName || plant.scientificName || plant.slug,
      description: plant.description, warning: plant.warning, sources: plant.sources,
      collectionTarget: Boolean(collectionTarget),
      // Include the public lesson text in the hash, not internal component IDs.
      cards: plant.learningCards.map(({ heading, text }) => ({ heading, text })),
      quizzes,
    };
  });
  const fingerprint = createHash('sha256').update(JSON.stringify({
    compiler: 1, slug: blueprint.slug, version: blueprint.releaseVersion,
    ecosystem: blueprint.ecosystem.publicId,
    sources: sources.map(({ plantId: _plantId, ...source }) => source),
  })).digest('hex').slice(0, 12);
  const levels = [];
  for (const [phaseIndex, phase] of PHASES.entries()) {
    for (const source of sources) {
      const sequence = levels.length + 1;
      const slug = `cms-${blueprint.slug}-${fingerprint}-${sequence}`;
      const publicId = stableContentId('level', slug);
      const quizzes = source.quizzes.map((quiz, index) => {
        const quizSlug = `${slug}-frage-${index + 1}`;
        return {
          ...rotateChoices(quiz, sequence + phaseIndex + index),
          slug: quizSlug, publicId: stableContentId('quiz', quizSlug),
          reviewPhase: phase.slug,
        };
      });
      levels.push({
        slug, publicId, title: `${phase.title}: ${source.commonName}`,
        sequence, learningGoal: phase.notice, plantId: source.plantId, quizzes,
        completionRule: {
          minimumScore: 2 / 3,
          requiredQuizIds: quizzes.map((quiz) => quiz.publicId),
          collectionScope: 'ecosystem', requiredPlantIds: sequence === 30 ? targets : [],
          requiredLevelIds: levels.length ? [levels[levels.length - 1].publicId] : [],
        },
      });
    }
  }
  return { fingerprint, levels };
}

async function generateBlueprintDrafts(strapi, id) {
  if (active.has(id)) return;
  active.add(id);
  const entities = strapi.entityService;
  try {
    const blueprint = await entities.findOne(BLUEPRINT, id, {
      populate: { ecosystem: true, stations: { populate: { plant: { populate: { learningCards: true } } } } },
    });
    if (!blueprint?.generateDrafts) return;
    // Full validation before the first write. Never alter a published row.
    const { fingerprint, levels } = compileBlueprint(blueprint);
    await entities.update(BLUEPRINT, id, { data: {
      generateDrafts: false, generationState: 'generating', generationFingerprint: fingerprint,
      generationReport: 'Entwürfe werden erzeugt; noch nicht zur Veröffentlichung bereit.',
    } });
    let created = 0;
    for (const definition of levels) {
      const level = await createIfMissing(entities, 'api::level.level', {
        publicId: definition.publicId, slug: definition.slug,
        generatedFromBlueprint: blueprint.slug, generationFingerprint: fingerprint,
        releaseVersion: blueprint.releaseVersion, title: definition.title,
        levelNumber: definition.sequence, sequence: definition.sequence,
        learningGoal: definition.learningGoal,
        difficulty: definition.sequence <= 10 ? 'beginner' : 'intermediate',
        completionRule: definition.completionRule,
        ecosystem: blueprint.ecosystem.id, plants: [definition.plantId], publishedAt: null,
      });
      if (level.created) created += 1;
      for (const quiz of definition.quizzes) {
        const result = await createIfMissing(entities, 'api::quiz.quiz', {
          publicId: quiz.publicId, slug: quiz.slug,
          generatedFromBlueprint: blueprint.slug, generationFingerprint: fingerprint,
          releaseVersion: blueprint.releaseVersion, contentVersion: blueprint.releaseVersion,
          title: quiz.title, quizType: 'multiple-choice',
          data: { type: 'multiple_choice', prompt: quiz.prompt, choices: quiz.choices,
            correctChoiceId: quiz.correctChoiceId, reviewPhase: quiz.reviewPhase },
          level: level.entity.id, plant: definition.plantId,
          reviewStatus: 'draft', publishedAt: null,
        });
        if (result.created) created += 1;
      }
    }
    await entities.update(BLUEPRINT, id, { data: {
      generateDrafts: false, generationState: 'ready', generationFingerprint: fingerprint,
      generationReport: `Entwurf ${fingerprint}: 30 Level / 90 Fragen, davon ${created} Datensätze neu angelegt. Bestehende Datensätze unverändert. Vor Veröffentlichung Quellen, Texte und Antworten prüfen. Keine Veröffentlichung und kein Release aktiviert.`,
    } });
  } catch (error) {
    await entities.update(BLUEPRINT, id, { data: {
      generateDrafts: false, generationState: 'failed',
      generationReport: `Generierung nicht abgeschlossen: ${error.message}. Eventuell angelegte Entwürfe bleiben unveröffentlicht. Nach Korrektur erneut generieren.`,
    } });
  } finally {
    active.delete(id);
  }
}

async function createIfMissing(entities, uid, data) {
  const existing = await entities.findMany(uid, {
    publicationState: 'preview', filters: { publicId: data.publicId }, limit: 1,
  });
  if (existing.length) return { entity: existing[0], created: false };
  return { entity: await entities.create(uid, { data }), created: true };
}

module.exports = { compileBlueprint, generateBlueprintDrafts };

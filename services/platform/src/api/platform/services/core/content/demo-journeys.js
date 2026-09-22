'use strict';

const { stableContentId } = require('./demo-content');
const { quizzesFromCards, rotateChoices } = require('./lesson-cards');

// Deliberate species choices, never inferred from relation order. Collecting
// means a photographic herbarium record, not picking these plants.
const COLLECTION_TARGETS = {
  'mitteleuropaeischer-laubwald': ['rotbuche', 'stieleiche', 'gewoehnliche-hasel'],
  alpenraum: ['silberwurz', 'silberdistel', 'alpen-aster'],
  'artenreiche-wiese': ['wiesen-salbei', 'spitzwegerich', 'wiesen-glockenblume'],
};

const PHASES = [
  { slug: 'kennenlernen', title: 'Entdeckerpfad', notice: 'Mission Entdecken: Lies den Steckbrief, finde die Merkmale und löse drei Fragen. Zwei richtige Antworten bringen dir einen Stern.' },
  { slug: 'wiederholen', title: 'Spurensuche', notice: 'Mission Spurensuche: Erkennst du die Pflanze wieder? Übe die drei bekannten Fragen mit neu angeordneten Antworten. Dein Steckbrief hilft dir.' },
  { slug: 'festigen', title: 'Forscherfinale', notice: 'Mission Forscherfinale: Festige dein Wissen in drei bekannten Fragen. Für die Ökosystem-Trophäe brauchst du alle Levelsterne und die drei fotografischen Sammelziele.' },
];

function buildJourney(item) {
  const targets = COLLECTION_TARGETS[item.ecosystem.slug];
  if (item.plants.length !== 10 || !targets || new Set(targets).size !== 3
    || targets.some((slug) => !item.plants.some((plant) => plant.slug === slug))) {
    throw new Error(`Invalid journey plants or collection targets: ${item.ecosystem.slug}`);
  }
  const levels = [];
  for (const phase of PHASES) {
    for (const plant of item.plants) {
      const slug = `${item.ecosystem.slug}-${phase.slug}-${plant.slug}`;
      const sourceQuestions = item.quizzes.filter((quiz) => quiz.plantSlug === plant.slug);
      // Keep existing public quiz identities across the content upgrade.
      const questions = plant.learningCards?.length
        ? quizzesFromCards(plant).map((quiz, index) => ({ ...quiz, slug: sourceQuestions[index]?.slug || quiz.slug }))
        : sourceQuestions;
      if (questions.length !== 3) throw new Error(`Journey needs three source questions for ${plant.slug}`);
      const quizzes = questions.map((quiz, index) => ({
        ...rotateChoices(quiz, PHASES.indexOf(phase) + levels.length + index),
        slug: `${slug}-${quiz.slug}`,
        sourceQuizSlug: quiz.slug,
        reviewPhase: phase.slug,
      }));
      levels.push({
        slug,
        publicId: stableContentId('level', slug),
        title: `${phase.title}: ${plant.commonName}`,
        sequence: levels.length + 1,
        learningGoal: phase.notice,
        plantSlug: plant.slug,
        quizzes,
        completionRule: {
          minimumScore: 2 / 3,
          requiredQuizIds: quizzes.map((quiz) => stableContentId('quiz', quiz.slug)),
          collectionScope: 'ecosystem',
          requiredPlantIds: levels.length === 29 ? targets.map((target) => stableContentId('plant', target)) : [],
          requiredLevelIds: levels.length ? [levels[levels.length - 1].publicId] : [],
        },
      });
    }
  }
  return levels;
}

module.exports = { buildJourney, COLLECTION_TARGETS, PHASES };

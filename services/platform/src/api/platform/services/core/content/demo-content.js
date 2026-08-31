'use strict';

const { createHash } = require('crypto');

const DEMO_RELEASE_VERSION = '2026.08.28-de.1';

function stableContentId(kind, slug) {
  const hex = createHash('sha256')
    .update(`plantini:${kind}:${slug}`)
    .digest('hex')
    .slice(0, 32)
    .split('');
  hex[12] = '4';
  hex[16] = ((Number.parseInt(hex[16], 16) & 0x3) | 0x8).toString(16);
  const value = hex.join('');
  return `${value.slice(0, 8)}-${value.slice(8, 12)}-${value.slice(12, 16)}-${value.slice(16, 20)}-${value.slice(20)}`;
}

function validateDemoContent(content) {
  if (!content || !Array.isArray(content.ecosystems) || content.ecosystems.length < 3) {
    throw new Error('Demo content needs at least three ecosystems.');
  }
  const slugs = new Set();
  for (const item of content.ecosystems) {
    requireUniqueSlug(item.ecosystem && item.ecosystem.slug, slugs, 'ecosystem');
    if (!item.ecosystem.name || !item.ecosystem.description) {
      throw new Error(`Ecosystem ${item.ecosystem.slug} needs German name and description.`);
    }
    if (!Array.isArray(item.plants) || item.plants.length < 3) {
      throw new Error(`Ecosystem ${item.ecosystem.slug} needs real plant content.`);
    }
    if (!Array.isArray(item.quizzes) || item.quizzes.length < 30 || item.quizzes.length > 60) {
      throw new Error(`Ecosystem ${item.ecosystem.slug} needs 30 to 60 quizzes.`);
    }
    const plantSlugs = new Set();
    for (const plant of item.plants) {
      requireUniqueSlug(plant.slug, slugs, 'plant');
      plantSlugs.add(plant.slug);
      for (const field of ['scientificName', 'commonName', 'family', 'description', 'warning']) {
        if (typeof plant[field] !== 'string' || plant[field].trim().length === 0) {
          throw new Error(`Plant ${plant.slug} is missing ${field}.`);
        }
      }
      if (!Array.isArray(plant.sources) || plant.sources.length === 0 ||
          plant.sources.some((source) => !/^https:\/\//.test(source))) {
        throw new Error(`Plant ${plant.slug} needs an HTTPS source.`);
      }
    }
    for (const quiz of item.quizzes) {
      requireUniqueSlug(quiz.slug, slugs, 'quiz');
      if (!plantSlugs.has(quiz.plantSlug)) {
        throw new Error(`Quiz ${quiz.slug} references unknown plant ${quiz.plantSlug}.`);
      }
      if (!quiz.title || !quiz.prompt || !Array.isArray(quiz.choices) || quiz.choices.length !== 4) {
        throw new Error(`Quiz ${quiz.slug} needs title, prompt, and four choices.`);
      }
      const choiceIds = new Set(quiz.choices.map((choice) => choice.id));
      if (choiceIds.size !== 4 || !choiceIds.has(quiz.correctChoiceId) ||
          quiz.choices.some((choice) => !choice.id || !choice.label)) {
        throw new Error(`Quiz ${quiz.slug} has invalid choices or correctChoiceId.`);
      }
    }
  }
  return content;
}

function requireUniqueSlug(slug, slugs, label) {
  if (typeof slug !== 'string' || !/^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(slug)) {
    throw new Error(`${label} needs a stable ASCII slug.`);
  }
  if (slugs.has(slug)) throw new Error(`Duplicate demo content slug: ${slug}.`);
  slugs.add(slug);
}

module.exports = {
  DEMO_RELEASE_VERSION,
  stableContentId,
  validateDemoContent,
};

'use strict';

const FIELDS = ['heading', 'text', 'question', 'correctAnswer', 'wrongAnswer1', 'wrongAnswer2', 'wrongAnswer3'];

function validateLearningCards(cards, label) {
  if (!Array.isArray(cards) || cards.length !== 3) {
    throw new Error(`${label}: Genau drei vollständige Lernkarten erforderlich.`);
  }
  for (const [index, card] of cards.entries()) {
    if (!card || FIELDS.some((field) => typeof card[field] !== 'string' || !card[field].trim())) {
      throw new Error(`${label}, Lernkarte ${index + 1}: Überschrift, Text, Frage und vier Antworten ausfüllen.`);
    }
    const answers = [card.correctAnswer, card.wrongAnswer1, card.wrongAnswer2, card.wrongAnswer3];
    if (new Set(answers.map(normalise)).size !== 4) {
      throw new Error(`${label}, Lernkarte ${index + 1}: Antworten müssen unterscheidbar sein.`);
    }
    if (!normalise(card.text).includes(normalise(card.correctAnswer))) {
      throw new Error(`${label}, Lernkarte ${index + 1}: Die richtige Antwort muss im Steckbrief erklärt werden und wörtlich enthalten sein.`);
    }
  }
  return cards;
}

function normalise(text) {
  return text.normalize('NFC').toLocaleLowerCase('de').replace(/\s+/g, ' ').trim();
}

function quizzesFromCards(plant) {
  return validateLearningCards(plant.learningCards, plant.commonName || plant.slug).map((card, index) => ({
    slug: `${plant.slug}-lernkarte-${index + 1}`,
    plantSlug: plant.slug,
    title: card.heading,
    prompt: card.question,
    choices: [card.correctAnswer, card.wrongAnswer1, card.wrongAnswer2, card.wrongAnswer3]
      .map((label, choice) => ({ id: `choice-${choice + 1}`, label })),
    correctChoiceId: 'choice-1',
  }));
}

// Stable rotation: the solution is not always the first option; repetitions
// change its position without inventing new botanical claims.
function rotateChoices(quiz, offset) {
  const shift = offset % quiz.choices.length;
  const rotated = [...quiz.choices.slice(shift), ...quiz.choices.slice(0, shift)];
  return {
    ...quiz,
    correctChoiceId: `choice-${rotated.findIndex((choice) => choice.id === quiz.correctChoiceId) + 1}`,
    choices: rotated.map((choice, index) => ({ id: `choice-${index + 1}`, label: choice.label })),
  };
}

module.exports = { validateLearningCards, quizzesFromCards, rotateChoices };

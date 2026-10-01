'use strict';

const { invalidRequest } = require('../errors');

/**
 * The player's character: one of nine fixed explorers (modelled in Blender,
 * shipped with the app as assets/characters/explorers.json). Only the id is
 * stored, so nothing but a known choice can end up here.
 */
const VERSION = 2;
const EXPLORERS = ['amara', 'mei', 'samira', 'heinrich', 'mateo', 'arjun', 'robin', 'nia', 'kai'];

function validateCharacter(value) {
  if (value === null || typeof value !== 'object' || Array.isArray(value)) {
    throw invalidRequest({ character: 'Muss ein Objekt sein.' });
  }
  for (const key of Object.keys(value)) {
    if (key !== 'v' && key !== 'id') throw invalidRequest({ [`character.${key}`]: 'Unbekanntes Feld.' });
  }
  if (value.v !== VERSION) throw invalidRequest({ 'character.v': `Unterstützt wird nur Version ${VERSION}.` });
  if (!EXPLORERS.includes(value.id)) {
    throw invalidRequest({ 'character.id': `Erlaubt: ${EXPLORERS.join(', ')}.` });
  }
  return { v: VERSION, id: value.id };
}

/** Characters stored by an older version (the old designer) are not returned. */
function currentCharacter(stored) {
  return stored && stored.v === VERSION && EXPLORERS.includes(stored.id) ? stored : undefined;
}

module.exports = { validateCharacter, currentCharacter, EXPLORERS, VERSION };

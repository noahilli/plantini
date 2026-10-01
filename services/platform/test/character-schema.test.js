'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const test = require('node:test');

const { validateCharacter, EXPLORERS } = require('../src/api/platform/services/core/profile/character-schema');
const { validateProfilePatch, mapProfile } = require('../src/api/platform/services/core/profile/profile-service');
const { ProblemError } = require('../src/api/platform/services/core/errors');

test('every explorer id is accepted, nothing else', () => {
  for (const id of EXPLORERS) assert.deepEqual(validateCharacter({ v: 2, id }), { v: 2, id });
  const bad = [{ v: 2, id: 'robot' }, { v: 1, id: 'kai' }, { v: 2, id: 'kai', extra: 1 }, { v: 2 }, 'kai', [], null];
  for (const value of bad) {
    assert.throws(() => validateCharacter(value), (e) => e instanceof ProblemError && e.status === 400, JSON.stringify(value));
  }
});

test('the profile patch accepts a character on its own and returns it; old records are hidden', () => {
  const patch = validateProfilePatch({ character: { v: 2, id: 'nia' } });
  assert.deepEqual(patch.character, { v: 2, id: 'nia' });
  assert.throws(() => validateProfilePatch({}), ProblemError);
  const base = { id: 'a', displayName: 'x', locale: 'de-DE', roles: ['lernende'] };
  assert.equal(mapProfile({ ...base, character: patch.character }).character.id, 'nia');
  assert.equal(mapProfile({ ...base, character: { v: 1, gender: 'male' } }).character, undefined);
});

test('the app ships a model for every accepted explorer', () => {
  const file = path.join(__dirname, '../../../apps/flutter/assets/characters/explorers.json');
  if (!fs.existsSync(file)) return; // service built without the app checkout
  const ids = JSON.parse(fs.readFileSync(file, 'utf8')).characters.map((c) => c.id).sort();
  assert.deepEqual(ids, [...EXPLORERS].sort());
});

'use strict';

const assert = require('node:assert/strict');
const test = require('node:test');

const { validateCharacter } = require('../src/api/platform/services/core/profile/character-schema');
const { validateProfilePatch, mapProfile } = require('../src/api/platform/services/core/profile/profile-service');
const { ProblemError } = require('../src/api/platform/services/core/errors');

const valid = () => ({
  v: 1,
  gender: 'diverse',
  skin: '#E8B98F',
  hair: { style: 'curly', color: '#A8431F' },
  hat: { style: 'none' },
  glasses: { style: 'round', color: '#2d2a28' },
  top: { style: 'hoodie', color: '#3f7fd0' },
  bottom: { style: 'shorts', color: '#3d4860' },
  shoes: { style: 'boots', color: '#6a4428' },
  backpack: { style: 'rucksack', color: '#d9602f' },
});

test('a character is normalised: lower-case colours, no colour for "none"', () => {
  const character = validateCharacter({ ...valid(), hat: { style: 'none', color: '#ffffff' } });
  assert.equal(character.skin, '#e8b98f');
  assert.deepEqual(character.hat, { style: 'none' });
  assert.deepEqual(character.hair, { style: 'curly', color: '#a8431f' });
});

test('unknown styles, fields and colours are rejected', () => {
  const bad = [
    { ...valid(), gender: 'robot' },
    { ...valid(), v: 2 },
    { ...valid(), skin: 'red' },
    { ...valid(), extra: 1 },
    { ...valid(), hair: { style: 'mohawk', color: '#000000' } },
    { ...valid(), hat: { style: 'cap' } },
    { ...valid(), top: { style: 'tshirt', color: '#ffffff', url: 'http://x' } },
    { ...valid(), top: undefined },
    'hello',
    [],
  ];
  for (const value of bad) {
    assert.throws(() => validateCharacter(value), (error) => error instanceof ProblemError && error.status === 400, JSON.stringify(value));
  }
});

test('the profile patch accepts a character on its own and returns it', () => {
  const patch = validateProfilePatch({ character: valid() });
  assert.equal(patch.character.top.style, 'hoodie');
  assert.equal(patch.displayName, undefined);
  const profile = mapProfile({ id: 'a', displayName: 'x', locale: 'de-DE', roles: ['lernende'], character: patch.character });
  assert.equal(profile.character.gender, 'diverse');
  assert.throws(() => validateProfilePatch({}), ProblemError);
});

test('every accepted style has a part in the app\'s character kit', () => {
  // The kit is built in Blender (tools/blender/create_character_parts.py) and
  // shipped with the app; a style the server accepts but the kit lacks would
  // render as a missing part.
  const fs = require('node:fs');
  const path = require('node:path');
  const { STYLES } = require('../src/api/platform/services/core/profile/character-schema');
  const file = path.join(__dirname, '../../../apps/flutter/assets/characters/parts.json');
  if (!fs.existsSync(file)) return; // service built without the app checkout
  const kit = JSON.parse(fs.readFileSync(file, 'utf8')).parts;
  for (const [part, styles] of Object.entries(STYLES)) {
    for (const style of styles.filter((s) => s !== 'none')) {
      assert.ok(kit[`${part}.${style}`], `${part}.${style}`);
    }
  }
});

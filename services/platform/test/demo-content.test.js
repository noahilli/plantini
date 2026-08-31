'use strict';

const assert = require('node:assert/strict');
const test = require('node:test');

const content = require('../src/api/platform/services/core/content/demo-content.de.json');
const {
  DEMO_RELEASE_VERSION,
  stableContentId,
  validateDemoContent,
} = require('../src/api/platform/services/core/content/demo-content');

test('German demo release contains three complete learning worlds', () => {
  const dataset = validateDemoContent(content);

  assert.match(DEMO_RELEASE_VERSION, /^\d{4}\.\d{2}\.\d{2}-de\.\d+$/);
  assert.equal(dataset.ecosystems.length, 3);
  assert.equal(dataset.ecosystems.reduce((sum, item) => sum + item.plants.length, 0), 30);
  assert.equal(dataset.ecosystems.reduce((sum, item) => sum + item.quizzes.length, 0), 90);

  for (const item of dataset.ecosystems) {
    assert.equal(item.plants.length, 10);
    assert.equal(item.quizzes.length, 30);
    assert.equal(new Set(item.quizzes.map((quiz) => quiz.slug)).size, 30);
    for (const quiz of item.quizzes) {
      assert.equal(quiz.choices.length, 4);
      assert.ok(quiz.choices.some((choice) => choice.id === quiz.correctChoiceId));
    }
  }
});

test('stable content IDs are deterministic UUIDv4-shaped identifiers', () => {
  const first = stableContentId('plant', 'stieleiche');
  const second = stableContentId('plant', 'stieleiche');
  const other = stableContentId('plant', 'rotbuche');

  assert.equal(first, second);
  assert.notEqual(first, other);
  assert.match(first, /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/);
});

test('demo validator rejects incomplete or misleading content', () => {
  const invalid = structuredClone(content);
  invalid.ecosystems[0].plants[0].sources = ['http://insecure.example.test'];
  assert.throws(() => validateDemoContent(invalid), /needs an HTTPS source/);

  const brokenQuiz = structuredClone(content);
  brokenQuiz.ecosystems[0].quizzes[0].correctChoiceId = 'missing-choice';
  assert.throws(() => validateDemoContent(brokenQuiz), /invalid choices/);
});

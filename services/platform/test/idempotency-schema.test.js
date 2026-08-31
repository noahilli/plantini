'use strict';

const assert = require('node:assert/strict');
const test = require('node:test');

const privateMedia = require('../src/api/private-media/content-types/private-media/schema.json');
const identificationJob = require('../src/api/identification-job/content-types/identification-job/schema.json');
const observation = require('../src/api/observation/content-types/observation/schema.json');

test('FIELD-03/OFFLINE-04: private write models enforce public, client and idempotency uniqueness', () => {
  assertUnique(privateMedia, ['publicId', 'ownerClientMediaKey', 'idempotencyKey']);
  assertUnique(identificationJob, ['publicId', 'ownerClientJobKey', 'idempotencyKey']);
  assertUnique(observation, ['publicId', 'ownerClientObservationKey', 'idempotencyKey']);
});

function assertUnique(schema, fields) {
  for (const field of fields) {
    assert.equal(
      schema.attributes[field]?.required,
      true,
      `${schema.collectionName}.${field} must be required`,
    );
    assert.equal(
      schema.attributes[field]?.unique,
      true,
      `${schema.collectionName}.${field} must be unique`,
    );
  }
}

'use strict';

const assert = require('node:assert/strict');
const test = require('node:test');

const { asProblem, ProblemError } = require('../src/api/platform/services/core/errors');
const {
  API_VERSION,
  applyResponseConventions,
} = require('../src/api/platform/services/core/http-conventions');
const {
  pageFromQuery,
  requireDate,
  rejectUnknownQuery,
} = require('../src/api/platform/services/core/validation');

function context(requested = '') {
  const headers = new Map();
  return {
    headers,
    get(name) {
      return name.toLowerCase() === 'x-correlation-id' ? requested : '';
    },
    set(name, value) {
      headers.set(name.toLowerCase(), value);
    },
  };
}

test('API-04 applies stable v1 and correlation headers to every response', () => {
  const accepted = context('trace_user-flow.123');
  const traceId = applyResponseConventions(accepted, () => 'generated-id');
  assert.equal(traceId, 'trace_user-flow.123');
  assert.equal(accepted.headers.get('x-correlation-id'), traceId);
  assert.equal(accepted.headers.get('x-api-version'), API_VERSION);

  const rejected = context('contains spaces and secrets');
  assert.equal(
    applyResponseConventions(rejected, () => '11111111-1111-4111-8111-111111111111'),
    '11111111-1111-4111-8111-111111111111',
  );
});

test('API-04 emits bounded RFC problem details without leaking internals', () => {
  const problem = asProblem(
    new Error('database password=secret'),
    'trace-safe-123',
    '/api/v1/observations',
  );
  assert.deepEqual(problem, {
    type: '/problems/internal-error',
    title: 'Interner Fehler',
    status: 500,
    code: 'INTERNAL_ERROR',
    traceId: 'trace-safe-123',
    instance: '/api/v1/observations',
  });

  const known = asProblem(
    new ProblemError('VALIDATION_FAILED', {
      status: 400,
      detail: 'Ungültiger Wert.',
      fieldErrors: { page: 'Zu klein.' },
    }),
    'trace-safe-456',
    '/api/v1/ecosystems',
  );
  assert.equal(known.detail, 'Ungültiger Wert.');
  assert.deepEqual(known.fieldErrors, { page: 'Zu klein.' });
});

test('API-04 accepts only bounded pagination and documented filters', () => {
  assert.deepEqual(pageFromQuery({ page: '2', pageSize: '100' }), {
    page: 2,
    pageSize: 100,
  });
  assert.throws(() => pageFromQuery({ page: 0 }), ProblemError);
  assert.throws(() => pageFromQuery({ pageSize: 101 }), ProblemError);
  assert.throws(() => pageFromQuery({ organisationId: 'foreign' }), ProblemError);
  assert.doesNotThrow(() => rejectUnknownQuery({ since: 'cursor' }, ['since']));
  assert.throws(
    () => rejectUnknownQuery({ since: 'cursor', role: 'admin' }, ['since']),
    ProblemError,
  );
});

test('API-04 normalizes RFC 3339 timestamps and rejects ambiguous dates', () => {
  assert.equal(
    requireDate('2026-09-02T12:34:56+02:00', 'observedAt'),
    '2026-09-02T10:34:56.000Z',
  );
  for (const value of [
    '2026-09-02',
    '2026-09-02T12:34:56',
    'not-a-date',
    123,
  ]) {
    assert.throws(() => requireDate(value, 'observedAt'), ProblemError);
  }
});

'use strict';

const { createHash, randomUUID } = require('crypto');
const { invalidRequest } = require('./errors');

const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

function newId() {
  return randomUUID();
}

function requireUuid(value, field) {
  if (typeof value !== 'string' || !UUID_PATTERN.test(value)) {
    throw invalidRequest({ [field]: 'Muss eine UUID sein.' });
  }
  return value.toLowerCase();
}

function requireIdempotencyKey(value) {
  if (typeof value !== 'string' || value.length < 16 || value.length > 128) {
    throw invalidRequest({ 'Idempotency-Key': 'Muss zwischen 16 und 128 Zeichen lang sein.' });
  }
  if (!/^[A-Za-z0-9._~:/+=-]+$/.test(value)) {
    throw invalidRequest({ 'Idempotency-Key': 'Enthält unzulässige Zeichen.' });
  }
  return value;
}

/**
 * A database-safe, non-reversible idempotency key. The external key never
 * becomes a cross-user lookup key and a coincidental client ID cannot collide
 * between two user profiles.
 */
function scopedIdempotencyKey(ownerId, operation, externalKey) {
  return createHash('sha256')
    .update(`${ownerId}\u0000${operation}\u0000${externalKey}`)
    .digest('hex');
}

function payloadDigest(value) {
  return createHash('sha256').update(stableStringify(value)).digest('hex');
}

function stableStringify(value) {
  if (value === null || typeof value !== 'object') return JSON.stringify(value);
  if (Array.isArray(value)) return `[${value.map(stableStringify).join(',')}]`;
  return `{${Object.keys(value)
    .sort()
    .map((key) => `${JSON.stringify(key)}:${stableStringify(value[key])}`)
    .join(',')}}`;
}

module.exports = {
  newId,
  requireUuid,
  requireIdempotencyKey,
  scopedIdempotencyKey,
  payloadDigest,
  stableStringify,
};

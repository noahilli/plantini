'use strict';

const { randomUUID } = require('crypto');

const API_VERSION = 'v1';
const CORRELATION_PATTERN = /^[A-Za-z0-9._-]{8,128}$/;

function applyResponseConventions(ctx, idFactory = randomUUID) {
  const requested = ctx.get('x-correlation-id');
  const traceId = typeof requested === 'string' && CORRELATION_PATTERN.test(requested)
    ? requested
    : idFactory();
  ctx.set('X-Correlation-Id', traceId);
  ctx.set('X-API-Version', API_VERSION);
  return traceId;
}

module.exports = {
  API_VERSION,
  CORRELATION_PATTERN,
  applyResponseConventions,
};

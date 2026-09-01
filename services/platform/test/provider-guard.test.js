'use strict';

const assert = require('node:assert/strict');
const test = require('node:test');
const Redis = require('ioredis');

const { parseRedisConnection } = require('../src/api/platform/services/core/field/identification-queue');
const { RedisProviderGuard } = require('../src/api/platform/services/core/field/provider-guard');

const REDIS_URL = process.env.PLANTINI_TEST_REDIS_URL;

test('FIELD-07: Redis guard preserves quota reserve atomically', {
  skip: REDIS_URL ? false : 'PLANTINI_TEST_REDIS_URL is not set',
}, async (t) => {
  const redis = new Redis(parseRedisConnection(REDIS_URL));
  const prefix = `plantini:test:quota:${Date.now()}`;
  const guard = new RedisProviderGuard({ redis, prefix, dailyLimit: 3, quotaReserve: 1 });
  t.after(async () => {
    const keys = await redis.keys(`${prefix}:*`);
    if (keys.length) await redis.del(...keys);
    await redis.quit();
  });

  assert.equal(await guard.beforeRequest(new Date('2026-08-31T12:00:00Z')), 1);
  assert.equal(await guard.beforeRequest(new Date('2026-08-31T12:00:01Z')), 2);
  await assert.rejects(
    () => guard.beforeRequest(new Date('2026-08-31T12:00:02Z')),
    (error) => error.code === 'PROVIDER_QUOTA_RESERVED' && error.retryAfterMs > 0,
  );
});

test('FIELD-07: transient failures open a shared circuit breaker', {
  skip: REDIS_URL ? false : 'PLANTINI_TEST_REDIS_URL is not set',
}, async (t) => {
  const redis = new Redis(parseRedisConnection(REDIS_URL));
  const prefix = `plantini:test:circuit:${Date.now()}`;
  const guard = new RedisProviderGuard({
    redis, prefix, dailyLimit: 100, quotaReserve: 1,
    failureThreshold: 2, cooldownMs: 10_000,
  });
  t.after(async () => {
    const keys = await redis.keys(`${prefix}:*`);
    if (keys.length) await redis.del(...keys);
    await redis.quit();
  });

  await guard.recordFailure({ code: 'PROVIDER_TIMEOUT' });
  await guard.recordFailure({ code: 'PROVIDER_UNAVAILABLE' });
  await assert.rejects(
    () => guard.beforeRequest(),
    (error) => error.code === 'PROVIDER_CIRCUIT_OPEN' && error.retryAfterMs > 0,
  );
  await guard.recordSuccess();
  assert.equal(await guard.beforeRequest() > 0, true);
});

'use strict';

const Redis = require('ioredis');

const { parseRedisConnection } = require('./identification-queue');

const TRANSIENT_CODES = new Set([
  'PROVIDER_RATE_LIMITED',
  'PROVIDER_TIMEOUT',
  'PROVIDER_UNAVAILABLE',
]);

class RedisProviderGuard {
  constructor(options = {}) {
    this.redis = options.redis || new Redis(parseRedisConnection(options.redisUrl || process.env.REDIS_URL));
    this.ownsRedis = !options.redis;
    this.prefix = options.prefix || 'plantini:plantnet';
    this.dailyLimit = positiveInteger(options.dailyLimit || process.env.PLANTNET_DAILY_REQUEST_LIMIT || 500);
    this.quotaReserve = nonNegativeInteger(options.quotaReserve ?? process.env.PLANTNET_QUOTA_RESERVE ?? 25);
    this.failureThreshold = positiveInteger(options.failureThreshold || process.env.PLANTNET_CIRCUIT_FAILURE_THRESHOLD || 5);
    this.cooldownMs = positiveInteger(options.cooldownMs || process.env.PLANTNET_CIRCUIT_COOLDOWN_MS || 60_000);
    if (this.quotaReserve >= this.dailyLimit) {
      throw new Error('PLANTNET_QUOTA_RESERVE must be smaller than PLANTNET_DAILY_REQUEST_LIMIT.');
    }
  }

  async beforeRequest(now = new Date()) {
    const day = now.toISOString().slice(0, 10);
    const ttlMs = millisecondsUntilNextUtcDay(now);
    const result = await this.redis.eval(BEFORE_REQUEST_SCRIPT, 2,
      `${this.prefix}:circuit`, `${this.prefix}:quota:${day}`,
      this.dailyLimit, this.quotaReserve, ttlMs);
    if (Number(result[0]) === 1) return Number(result[1]);
    const code = result[1] === 'quota' ? 'PROVIDER_QUOTA_RESERVED' : 'PROVIDER_CIRCUIT_OPEN';
    throw guardError(code, Number(result[2]) || this.cooldownMs);
  }

  async recordSuccess() {
    await this.redis.del(`${this.prefix}:failures`, `${this.prefix}:circuit`);
  }

  async recordFailure(error) {
    if (!TRANSIENT_CODES.has(error?.code)) return;
    await this.redis.eval(RECORD_FAILURE_SCRIPT, 2,
      `${this.prefix}:failures`, `${this.prefix}:circuit`,
      this.failureThreshold, this.cooldownMs);
  }

  async close() {
    if (this.ownsRedis) await this.redis.quit();
  }
}

const BEFORE_REQUEST_SCRIPT = `
local circuitTtl = redis.call('PTTL', KEYS[1])
if circuitTtl > 0 then return {0, 'circuit', circuitTtl} end
local used = tonumber(redis.call('GET', KEYS[2]) or '0')
local available = tonumber(ARGV[1]) - tonumber(ARGV[2])
if used >= available then
  local quotaTtl = redis.call('PTTL', KEYS[2])
  return {0, 'quota', quotaTtl}
end
used = redis.call('INCR', KEYS[2])
if used == 1 then redis.call('PEXPIRE', KEYS[2], ARGV[3]) end
return {1, used, 0}
`;

const RECORD_FAILURE_SCRIPT = `
local failures = redis.call('INCR', KEYS[1])
redis.call('PEXPIRE', KEYS[1], ARGV[2])
if failures >= tonumber(ARGV[1]) then
  redis.call('SET', KEYS[2], 'open', 'PX', ARGV[2])
  redis.call('DEL', KEYS[1])
end
return failures
`;

function millisecondsUntilNextUtcDay(now) {
  const next = Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate() + 1);
  return Math.max(1_000, next - now.getTime());
}

function guardError(code, retryAfterMs) {
  const error = new Error(code === 'PROVIDER_QUOTA_RESERVED'
    ? 'The reserved PlantNet quota is protected.'
    : 'The PlantNet circuit breaker is open.');
  error.code = code;
  error.retryAfterMs = retryAfterMs;
  return error;
}

function positiveInteger(value) {
  const parsed = Number(value);
  if (!Number.isInteger(parsed) || parsed < 1) throw new Error('Provider guard values must be positive integers.');
  return parsed;
}

function nonNegativeInteger(value) {
  const parsed = Number(value);
  if (!Number.isInteger(parsed) || parsed < 0) throw new Error('Provider guard values must be non-negative integers.');
  return parsed;
}

module.exports = { RedisProviderGuard, millisecondsUntilNextUtcDay };

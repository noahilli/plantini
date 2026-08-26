'use strict';

const { Queue, Worker } = require('bullmq');

const QUEUE_NAME = 'plantini-identifications';

function createIdentificationQueue(options = {}) {
  const connection = parseRedisConnection(options.redisUrl || process.env.REDIS_URL);
  const queue = new Queue(QUEUE_NAME, { connection, defaultJobOptions: {
    removeOnComplete: 500,
    removeOnFail: 1_000,
  } });
  return {
    async enqueue(jobId, { delay = 0 } = {}) {
      await queue.add('identify', { jobId }, {
        jobId: `${jobId}:${Date.now()}:${Math.random().toString(16).slice(2)}`,
        delay,
        attempts: 1,
      });
    },
    async close() {
      await queue.close();
    },
  };
}

function createIdentificationWorker(options = {}) {
  const connection = parseRedisConnection(options.redisUrl || process.env.REDIS_URL);
  const worker = new Worker(QUEUE_NAME, async (job) => {
    const result = await options.process(job.data.jobId);
    if (result?.status === 'failed' && result.retryAfter) {
      const delay = Math.max(0, Date.parse(result.retryAfter) - Date.now());
      await options.enqueue(job.data.jobId, { delay });
    }
  }, {
    connection,
    concurrency: 2,
  });
  return {
    async close() {
      await worker.close();
    },
  };
}

function parseRedisConnection(urlValue) {
  if (!urlValue) throw new Error('REDIS_URL must be configured.');
  const url = new URL(urlValue);
  if (!['redis:', 'rediss:'].includes(url.protocol)) throw new Error('REDIS_URL must use redis or rediss.');
  return {
    host: url.hostname,
    port: Number(url.port || 6379),
    ...(url.username ? { username: decodeURIComponent(url.username) } : {}),
    ...(url.password ? { password: decodeURIComponent(url.password) } : {}),
    ...(url.pathname && url.pathname !== '/' ? { db: Number(url.pathname.slice(1)) } : {}),
    ...(url.protocol === 'rediss:' ? { tls: {} } : {}),
    maxRetriesPerRequest: null,
  };
}

module.exports = {
  QUEUE_NAME,
  createIdentificationQueue,
  createIdentificationWorker,
  parseRedisConnection,
};

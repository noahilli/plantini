'use strict';

const { createIdentificationQueue, createIdentificationWorker } = require('./api/platform/services/core/field/identification-queue');
const { seedDemoContent } = require('./api/platform/services/core/content/demo-seed');
const { PlantNetProvider } = require('./api/platform/services/core/field/plantnet-provider');
const {
  getExistingPlatformRuntime,
  getPlatformRuntime,
} = require('./api/platform/services/core/platform-runtime');

module.exports = {
  register() {},

  async bootstrap({ strapi }) {
    const runtime = getPlatformRuntime(strapi);
    if (process.env.PLATFORM_SEED_DEMO_CONTENT === 'true') {
      await seedDemoContent(strapi);
      strapi.log.warn('Synthetic E2E content is enabled; never use this flag in staging or production.');
    }
    const queue = createIdentificationQueue();
    runtime.identificationQueue = queue;
    const provider = new PlantNetProvider({ privateMediaStore: runtime.privateMediaStore });
    runtime.identificationWorker = createIdentificationWorker({
      process: (jobId) => runtime.field.processIdentification(jobId, provider),
      enqueue: queue.enqueue,
    });
    const recover = async () => {
      try {
        const recovered = await runtime.field.recoverPendingJobs();
        if (recovered > 0) strapi.log.info(`Reconciled ${recovered} pending Plantini identification job(s).`);
      } catch (error) {
        strapi.log.error('Plantini identification recovery could not reach its queue.');
      }
    };
    await recover();
    runtime.identificationRecoveryTimer = setInterval(recover, 30_000);
    runtime.identificationRecoveryTimer.unref?.();
    strapi.log.info('Plantini identification queue is connected.');
  },

  async destroy({ strapi }) {
    const runtime = getExistingPlatformRuntime(strapi);
    if (!runtime) return;
    if (runtime.identificationRecoveryTimer) clearInterval(runtime.identificationRecoveryTimer);
    await Promise.all([
      runtime.identificationWorker?.close(),
      runtime.identificationQueue?.close(),
    ]);
  },
};

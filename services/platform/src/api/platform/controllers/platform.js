'use strict';

const { randomUUID } = require('crypto');
const { readFile } = require('fs/promises');

const { asProblem, invalidRequest, ProblemError } = require('../services/core/errors');
const { getPlatformRuntime, resolveActor } = require('../services/core/platform-runtime');

module.exports = {
  async health(ctx) {
    return execute(ctx, async () => ({ status: 'ok', apiVersion: 'v1' }));
  },

  async getMe(ctx) {
    return withActor(ctx, (runtime, actor) => runtime.profile.getMe(actor));
  },

  async updateMe(ctx) {
    return withActor(ctx, (runtime, actor) => runtime.profile.updateMe(actor, ctx.request.body));
  },

  async getManifest(ctx) {
    return execute(ctx, async (runtime) => {
      const result = await runtime.content.getManifest(ctx.get('if-none-match'));
      ctx.set('ETag', result.etag);
      if (result.notModified) {
        ctx.status = 304;
        return undefined;
      }
      return result.manifest;
    });
  },

  async getContentChanges(ctx) {
    return execute(ctx, async (runtime) => runtime.repositories.content.findChangesSince(ctx.query.since));
  },

  async listEcosystems(ctx) {
    return execute(ctx, async (runtime) => runtime.content.listEcosystems(ctx.query));
  },

  async getEcosystem(ctx) {
    return execute(ctx, async (runtime) => runtime.content.getEcosystem(ctx.params.ecosystemId));
  },

  async getLevel(ctx) {
    return withActor(ctx, (runtime, actor) => runtime.content.getLevel(
      actor,
      ctx.params.levelId,
      runtime.learning.getLevelAccess.bind(runtime.learning),
    ));
  },

  async getPlant(ctx) {
    return execute(ctx, async (runtime) => runtime.content.getPlant(ctx.params.plantId));
  },

  async listQuizItems(ctx) {
    return withActor(ctx, (runtime, actor) => runtime.content.listQuizItems(
      actor,
      ctx.query.levelId,
      typeof ctx.query.contentVersion === 'string' ? ctx.query.contentVersion : undefined,
    ));
  },

  async startLevelAttempt(ctx) {
    return withActor(ctx, async (runtime, actor) => {
      const result = await runtime.learning.startAttempt(actor, ctx.request.body, ctx.get('idempotency-key'));
      ctx.status = result.created === false ? 200 : 201;
      return result.attempt;
    });
  },

  async completeLevelAttempt(ctx) {
    return withActor(ctx, (runtime, actor, traceId) => runtime.learning.completeAttempt(
      actor,
      ctx.params.attemptId,
      ctx.request.body,
      ctx.get('idempotency-key'),
      traceId,
    ));
  },

  async submitLearningEvents(ctx) {
    return withActor(ctx, (runtime, actor, traceId) => runtime.learning.submitEvents(
      actor,
      ctx.request.body,
      ctx.get('idempotency-key'),
      traceId,
    ));
  },

  async getProgress(ctx) {
    return withActor(ctx, (runtime, actor) => runtime.learning.getProgress(actor, ctx.query.since));
  },

  async synchronize(ctx) {
    return withActor(ctx, (runtime, actor, traceId) => runtime.learning.synchronize(
      actor,
      ctx.request.body,
      ctx.get('idempotency-key'),
      traceId,
      runtime.repositories.content.findChangesSince,
    ));
  },

  async reserveUpload(ctx) {
    return withActor(ctx, async (runtime, actor) => {
      const uploadUrlFor = (mediaId) => absoluteUrl(ctx, `/api/v1/media/uploads/${mediaId}/content`);
      const upload = await runtime.field.reserveUpload(actor, ctx.request.body, ctx.get('idempotency-key'), uploadUrlFor);
      ctx.status = upload.created === false ? 200 : 201;
      return upload;
    });
  },

  async uploadPrivateMediaContent(ctx) {
    return withActor(ctx, async (runtime, actor) => {
      const mediaId = ctx.params.mediaId;
      const reservation = await runtime.repositories.field.findPrivateMediaByPublicId(actor.id, mediaId);
      if (!reservation) throw new ProblemError('MEDIA_UPLOAD_NOT_FOUND', { status: 404 });
      if (reservation.status === 'uploaded') return existingUpload(reservation);
      const file = extractOneFile(ctx.request.files);
      if (!file) throw invalidRequest({ image: 'Ein einzelnes Bildfeld image ist erforderlich.' });
      const buffer = await readFile(file.filepath || file.path);
      const storageKey = await runtime.privateMediaStore.write(mediaId, buffer);
      try {
        return await runtime.field.attachUpload(actor, mediaId, {
          buffer,
          size: buffer.length,
          contentType: file.mimetype || file.type,
          storageKey,
        });
      } catch (error) {
        await runtime.privateMediaStore.remove(storageKey);
        throw error;
      }
    });
  },

  async createIdentification(ctx) {
    return withActor(ctx, async (runtime, actor) => {
      const job = await runtime.field.createIdentification(actor, ctx.request.body, ctx.get('idempotency-key'));
      ctx.status = job.created === false ? 200 : 202;
      return job;
    });
  },

  async getIdentification(ctx) {
    return withActor(ctx, (runtime, actor) => runtime.field.getIdentification(actor, ctx.params.jobId));
  },

  async retryIdentification(ctx) {
    return withActor(ctx, async (runtime, actor) => {
      const job = await runtime.field.retryIdentification(actor, ctx.params.jobId, ctx.get('idempotency-key'));
      ctx.status = 202;
      return job;
    });
  },

  async confirmIdentification(ctx) {
    return withActor(ctx, (runtime, actor) => runtime.field.confirmIdentification(actor, ctx.params.jobId, ctx.request.body));
  },

  async listObservations(ctx) {
    return withActor(ctx, (runtime, actor) => runtime.herbarium.list(actor, ctx.query));
  },

  async createObservation(ctx) {
    return withActor(ctx, async (runtime, actor) => {
      const result = await runtime.herbarium.create(actor, ctx.request.body, ctx.get('idempotency-key'));
      ctx.status = result.created ? 201 : 200;
      return result.observation;
    });
  },

  async getObservation(ctx) {
    return withActor(ctx, (runtime, actor) => runtime.herbarium.get(actor, ctx.params.observationId));
  },

  async updateObservation(ctx) {
    return withActor(ctx, (runtime, actor) => runtime.herbarium.update(
      actor,
      ctx.params.observationId,
      ctx.request.body,
      ctx.get('if-match'),
    ));
  },

  async deleteObservation(ctx) {
    return withActor(ctx, async (runtime, actor) => {
      await runtime.herbarium.delete(actor, ctx.params.observationId, ctx.get('if-match'));
      ctx.status = 202;
      return undefined;
    });
  },
};

async function withActor(ctx, action) {
  return execute(ctx, async (runtime, traceId) => {
    const actor = await resolveActor(ctx, runtime);
    return action(runtime, actor, traceId);
  });
}

async function execute(ctx, action) {
  const traceId = correlationId(ctx);
  ctx.set('X-Correlation-Id', traceId);
  try {
    const runtime = getPlatformRuntime(strapi);
    const body = await action(runtime, traceId);
    if (body !== undefined && ctx.status !== 304) {
      if (![201, 202, 204].includes(ctx.status)) ctx.status = 200;
      ctx.type = 'application/json';
      ctx.body = body;
    }
  } catch (error) {
    const problem = asProblem(error, traceId, ctx.path);
    ctx.status = problem.status;
    ctx.type = 'application/problem+json';
    ctx.body = problem;
  }
}

function correlationId(ctx) {
  const requested = ctx.get('x-correlation-id');
  return typeof requested === 'string' && /^[A-Za-z0-9._-]{8,128}$/.test(requested)
    ? requested
    : randomUUID();
}

function extractOneFile(files) {
  if (!files || typeof files !== 'object') return undefined;
  const candidate = files.image || files.file;
  if (Array.isArray(candidate)) return candidate.length === 1 ? candidate[0] : undefined;
  return candidate;
}

function existingUpload(reservation) {
  return {
    id: reservation.publicId,
    expiresAt: reservation.expiresAt,
    status: reservation.status,
  };
}

function absoluteUrl(ctx, path) {
  const origin = ctx.origin || `${ctx.protocol}://${ctx.host}`;
  return new URL(path, origin).toString();
}

'use strict';

const { readFile } = require('fs/promises');

const { asProblem, invalidRequest, ProblemError } = require('../services/core/errors');
const { API_VERSION, applyResponseConventions } = require('../services/core/http-conventions');
const { getPlatformRuntime, resolveActor } = require('../services/core/platform-runtime');
const { TileProxy } = require('../services/core/content/tile-proxy');
const { PrivateMediaStore } = require('../services/core/private-media-store');
const { requireUuid } = require('../services/core/ids');
const { rejectUnknownQuery } = require('../services/core/validation');

module.exports = {
  async health(ctx) {
    return execute(ctx, async () => ({ status: 'ok', apiVersion: API_VERSION }));
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

  async getContentPackage(ctx) {
    return execute(ctx, async (runtime) => {
      rejectUnknownQuery(ctx.query, []);
      const packageData = await runtime.content.getPackage(ctx.params.version, ctx.params.packageId);
      ctx.set('ETag', `"${packageData.sha256}"`);
      ctx.set('Cache-Control', 'public, max-age=31536000, immutable');
      ctx.set('X-Content-Type-Options', 'nosniff');
      if (ctx.get('if-none-match').split(',').some((tag) =>
        tag.trim().replace(/^W\//, '') === `"${packageData.sha256}"`)) {
        ctx.status = 304;
        return undefined;
      }
      ctx.type = 'application/json';
      ctx.body = packageData.bytes;
      return undefined;
    });
  },

  async getContentChanges(ctx) {
    return execute(ctx, async (runtime) => {
      rejectUnknownQuery(ctx.query, ['since']);
      return runtime.repositories.content.findChangesSince(ctx.query.since);
    });
  },

  async listEcosystems(ctx) {
    return execute(ctx, async (runtime) => runtime.content.listEcosystems(ctx.query));
  },

  async getEcosystem(ctx) {
    return execute(ctx, async (runtime) => runtime.content.getEcosystem(ctx.params.ecosystemId));
  },

  async getEcosystemProgress(ctx) {
    return withActor(ctx, (runtime, actor) => {
      rejectUnknownQuery(ctx.query, []);
      return runtime.learning.getEcosystemProgress(actor, ctx.params.ecosystemId);
    });
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

  async getPlantPhoto(ctx) {
    return execute(ctx, async (runtime) => {
      rejectUnknownQuery(ctx.query, ['photoId']);
      const photoId = ctx.query.photoId;
      if (photoId !== undefined && (typeof photoId !== 'string' || photoId.length > 64)) {
        throw new ProblemError('INVALID_QUERY', { status: 400, detail: 'photoId is invalid.' });
      }
      const photo = await runtime.content.getPlantPhoto(ctx.params.plantId, photoId);
      // A photo id names one source image for good (new photos get new ids), so
      // clients keep it; the id-less form follows the weekly refresh.
      ctx.set('Cache-Control', photoId ? 'public, max-age=31536000, immutable' : 'public, max-age=86400');
      ctx.set('X-Content-Type-Options', 'nosniff');
      ctx.type = photo.type;
      ctx.body = photo.bytes;
      return undefined;
    });
  },

  async editorDashboard(ctx) {
    return withActor(ctx, (runtime, actor) => runtime.editor.dashboard(actor));
  },

  async editorCatalog(ctx) {
    return withActor(ctx, (runtime, actor) => runtime.editor.catalog(actor));
  },

  async editorChanges(ctx) {
    return withActor(ctx, (runtime, actor) => runtime.editor.listChanges(actor));
  },

  async editorChange(ctx) {
    return withActor(ctx, (runtime, actor) => runtime.editor.change(actor, ctx.params.changeId));
  },

  async editorItem(ctx) {
    return withActor(ctx, (runtime, actor) => runtime.editor.item(actor, ctx.params.type, ctx.params.itemId));
  },

  async editorSave(ctx) {
    return withActor(ctx, async (runtime, actor) => {
      const change = await runtime.editor.save(actor, ctx.request.body);
      ctx.status = 201;
      return change;
    });
  },

  async editorUpdate(ctx) {
    return withActor(ctx, (runtime, actor) => runtime.editor.save(actor, {
      ...ctx.request.body, changeId: ctx.params.changeId,
    }));
  },

  async editorSubmit(ctx) {
    return withActor(ctx, (runtime, actor) => runtime.editor.submit(actor, ctx.params.changeId));
  },

  async editorReject(ctx) {
    return withActor(ctx, (runtime, actor) => runtime.editor.reject(actor, ctx.params.changeId, ctx.request.body?.note));
  },

  async editorApprove(ctx) {
    return withActor(ctx, (runtime, actor) => runtime.editor.approve(actor, ctx.params.changeId, ctx.request.body?.note));
  },

  async editorInvite(ctx) {
    return withActor(ctx, async (runtime, actor) => {
      const invitation = await runtime.editorInvitations.invite(actor, ctx.request.body);
      ctx.status = 201;
      return invitation;
    });
  },

  async listQuizItems(ctx) {
    return withActor(ctx, (runtime, actor) => {
      rejectUnknownQuery(ctx.query, ['levelId', 'contentVersion']);
      return runtime.content.listQuizItems(
        actor,
        ctx.query.levelId,
        typeof ctx.query.contentVersion === 'string' ? ctx.query.contentVersion : undefined,
      );
    });
  },

  async teachingSession(ctx) {
    return withActor(ctx, (runtime, actor) => runtime.teaching.session(actor));
  },
  async teachingDashboard(ctx) {
    return withActor(ctx, (runtime, actor) => runtime.teaching.dashboard(actor));
  },
  async teachingClasses(ctx) {
    return withActor(ctx, (runtime, actor) => runtime.teaching.classes(actor));
  },
  async teachingCreateClass(ctx) {
    return withActor(ctx, async (runtime, actor) => {
      const result = await runtime.teaching.createClass(actor, ctx.request.body);
      ctx.status = 201;
      return result;
    });
  },
  async teachingClass(ctx) {
    return withActor(ctx, (runtime, actor) => runtime.teaching.classroom(actor, ctx.params.classId));
  },
  async teachingCreateStudent(ctx) {
    return withActor(ctx, async (runtime, actor) => {
      const result = await runtime.teaching.createStudent(actor, ctx.params.classId, ctx.request.body);
      ctx.status = 201;
      return result;
    });
  },
  async teachingResetPassword(ctx) {
    return withActor(ctx, (runtime, actor) => runtime.teaching.resetPassword(actor, ctx.params.studentId, ctx.request.body));
  },
  async teachingUpdateStudent(ctx) {
    return withActor(ctx, (runtime, actor) => runtime.teaching.updateStudent(actor, ctx.params.studentId, ctx.request.body));
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
    return withActor(ctx, (runtime, actor) => {
      rejectUnknownQuery(ctx.query, ['since']);
      return runtime.learning.getProgress(actor, ctx.query.since);
    });
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

  async getPrivateMediaContent(ctx) {
    return withActor(ctx, async (runtime, actor) => {
      rejectUnknownQuery(ctx.query, ['width']);
      const mediaId = requireUuid(ctx.params.mediaId, 'mediaId');
      const width = ctx.query.width === undefined ? undefined : Number(ctx.query.width);
      if (width !== undefined && !PrivateMediaStore.VARIANT_WIDTHS.includes(width)) {
        throw invalidRequest({ width: `Erlaubte Breiten: ${PrivateMediaStore.VARIANT_WIDTHS.join(', ')}.` });
      }
      // Owner-scoped lookup: another account's media id is indistinguishable
      // from a missing one.
      const media = await runtime.repositories.field.findPrivateMediaByPublicId(actor.id, mediaId);
      if (!media || media.status !== 'uploaded' || !media.storageKey) {
        throw new ProblemError('MEDIA_NOT_FOUND', { status: 404, detail: 'Dieses Bild wurde nicht gefunden.' });
      }
      const resized = width ? await runtime.privateMediaStore.readVariant(media.storageKey, width) : undefined;
      const bytes = resized || await runtime.privateMediaStore.read(media.storageKey);
      // A media id is never reused for other bytes, so the response is immutable.
      ctx.set('Cache-Control', 'private, max-age=31536000, immutable');
      ctx.set('ETag', `"${media.sha256 || mediaId}${resized ? `-w${width}` : ''}"`);
      ctx.set('X-Content-Type-Options', 'nosniff');
      if (ctx.fresh) {
        ctx.status = 304;
        return undefined;
      }
      ctx.type = resized ? 'image/jpeg' : (media.contentType || 'application/octet-stream');
      ctx.body = bytes;
      return undefined;
    });
  },

  async getMapTile(ctx) {
    return withActor(ctx, async (runtime) => {
      rejectUnknownQuery(ctx.query, []);
      const tile = TileProxy.parse(ctx.params);
      if (!tile) throw invalidRequest({ tile: 'Ungültige Kachelkoordinaten.' });
      let bytes;
      try {
        bytes = await runtime.tiles.get(tile);
      } catch {
        throw new ProblemError('MAP_TILE_UNAVAILABLE', { status: 502, detail: 'Diese Kartenkachel ist gerade nicht verfügbar.' });
      }
      ctx.set('Cache-Control', 'private, max-age=604800');
      ctx.set('X-Content-Type-Options', 'nosniff');
      ctx.type = 'image/png';
      ctx.body = bytes;
      return undefined;
    });
  },

  async getSpeciesPhoto(ctx) {
    return withActor(ctx, async (runtime) => {
      rejectUnknownQuery(ctx.query, ['photoId']);
      const key = String(ctx.params.speciesKey || '');
      if (!/^[a-z0-9-]{2,120}$/.test(key)) {
        throw invalidRequest({ speciesKey: 'Ungültiger Artschlüssel.' });
      }
      const source = await runtime.species.getPhotoSource(key);
      let photo;
      try {
        photo = await runtime.photoCache.get(source);
      } catch {
        throw new ProblemError('PHOTO_UNAVAILABLE', { status: 503, detail: 'Das Foto ist momentan nicht verfügbar.' });
      }
      ctx.set('Cache-Control', ctx.query.photoId ? 'private, max-age=31536000, immutable' : 'private, max-age=86400');
      ctx.set('X-Content-Type-Options', 'nosniff');
      ctx.type = photo.type;
      ctx.body = photo.bytes;
      return undefined;
    });
  },

  async getSpeciesCard(ctx) {
    return withActor(ctx, async (runtime) => {
      const key = String(ctx.params.speciesKey || '');
      if (!/^[a-z0-9-]{2,120}$/.test(key)) {
        throw invalidRequest({ speciesKey: 'Ungültiger Artschlüssel.' });
      }
      const card = await runtime.species.getCard(key);
      const stats = await runtime.stats.collection();
      const collectedShare = stats.available ? stats.species[key] : undefined;
      ctx.set('Cache-Control', 'private, max-age=600');
      return { ...card, ...(collectedShare ? { collectedShare } : {}) };
    });
  },

  async getCollectionStats(ctx) {
    return withActor(ctx, async (runtime) => {
      ctx.set('Cache-Control', 'private, max-age=600');
      return runtime.stats.collection();
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
  ctx.set('Cache-Control', 'no-store');
  return execute(ctx, async (runtime, traceId) => {
    const actor = await resolveActor(ctx, runtime);
    return action(runtime, actor, traceId);
  });
}

async function execute(ctx, action) {
  const traceId = applyResponseConventions(ctx);
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
    ctx.body = problem;
    // Koa derives application/json when an object body is assigned. Set the
    // RFC 9457 media type afterwards so framework inference cannot overwrite
    // the public error contract.
    ctx.type = 'application/problem+json';
    ctx.set('Content-Type', 'application/problem+json');
  }
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

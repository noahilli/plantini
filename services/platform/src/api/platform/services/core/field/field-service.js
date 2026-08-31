'use strict';

const { createHash } = require('crypto');

const { ProblemError, conflict, invalidRequest, notFound } = require('../errors');
const { newId, payloadDigest, requireIdempotencyKey, requireUuid, scopedIdempotencyKey } = require('../ids');
const { optionalString, requireInteger, requirePlainObject, requireString, rejectUnknownFields } = require('../validation');

// PlantNet's real v2 endpoint accepts JPEG and PNG. The Flutter media service
// re-encodes captured input to one of these formats before it reaches this API.
const ALLOWED_IMAGE_TYPES = new Set(['image/jpeg', 'image/png']);
const MAX_IMAGE_BYTES = 20 * 1024 * 1024;
const RESERVATION_TTL_MS = 15 * 60 * 1000;
const MAX_IDENTIFICATION_ATTEMPTS = 5;
const MAX_PROVIDER_RETRY_DELAY_MS = 24 * 60 * 60 * 1000;

/**
 * Persistent, caller-owned upload and identification state.  The queue itself
 * is injected so unit tests and the Strapi host can use the same domain rules.
 */
class FieldService {
  constructor(options) {
    this.repository = options.repository;
    this.clock = options.clock || (() => new Date());
    this.enqueue = options.enqueue || (async () => undefined);
  }

  async reserveUpload(actor, body, idempotencyHeader, uploadUrlFor) {
    const input = validateUploadReservation(body);
    const externalKey = requireIdempotencyKey(input.idempotencyKey || input.clientMutationId || idempotencyHeader || input.clientMediaId);
    const idempotencyKey = scopedIdempotencyKey(actor.id, 'media-upload', externalKey);
    const requestDigest = payloadDigest(input);
    const existing = await this.repository.findPrivateMediaByIdempotencyKey(idempotencyKey);
    if (existing) {
      assertSamePayload(existing.requestDigest, requestDigest);
      return { ...mapUpload(existing, uploadUrlFor(existing.publicId)), created: false };
    }

    const clientExisting = await this.repository.findPrivateMediaByClientId(actor.id, input.clientMediaId);
    if (clientExisting) {
      if (clientExisting.contentType !== input.contentType || Number(clientExisting.bytes) !== input.bytes) {
        throw conflict('CLIENT_MEDIA_CONFLICT', 'Die Client-Medien-ID wurde bereits mit anderen Metadaten verwendet.');
      }
      return { ...mapUpload(clientExisting, uploadUrlFor(clientExisting.publicId)), created: false };
    }

    const expiresAt = new Date(this.clock().getTime() + RESERVATION_TTL_MS).toISOString();
    const media = await this.repository.createPrivateMedia({
      publicId: newId(),
      ownerId: actor.id,
      clientMediaId: input.clientMediaId,
      idempotencyKey,
      requestDigest,
      contentType: input.contentType,
      bytes: input.bytes,
      status: 'reserved',
      expiresAt,
    });
    return { ...mapUpload(media, uploadUrlFor(media.publicId)), created: true };
  }

  async attachUpload(actor, mediaId, file) {
    requireUuid(mediaId, 'mediaId');
    const media = await this.repository.findPrivateMediaByPublicId(actor.id, mediaId);
    if (!media) throw notFound('MEDIA_UPLOAD_NOT_FOUND');
    if (media.status === 'uploaded') return mapUpload(media);
    if (media.status !== 'reserved' || Date.parse(media.expiresAt) <= this.clock().getTime()) {
      throw conflict('MEDIA_UPLOAD_EXPIRED', 'Die Upload-Reservierung ist abgelaufen. Bitte starte den Upload erneut.');
    }

    const checked = validateImageUpload(file, media);
    const updated = await this.repository.updatePrivateMedia(media.id, {
      status: 'uploaded',
      sha256: checked.sha256,
      storageKey: checked.storageKey,
    });
    return mapUpload(updated);
  }

  async createIdentification(actor, body, idempotencyHeader) {
    const input = validateIdentificationRequest(body);
    const externalKey = requireIdempotencyKey(input.idempotencyKey || input.clientMutationId || idempotencyHeader || input.clientJobId);
    const idempotencyKey = scopedIdempotencyKey(actor.id, 'identification', externalKey);
    const requestDigest = payloadDigest(input);
    const existing = await this.repository.findJobByIdempotencyKey(idempotencyKey);
    if (existing) {
      assertSamePayload(existing.requestDigest, requestDigest);
      return { ...mapJob(existing), created: false };
    }

    const media = await this.repository.findPrivateMediaByPublicId(actor.id, input.mediaId);
    if (!media || media.status !== 'uploaded') {
      throw invalidRequest({ mediaId: 'Die angegebene private Bilddatei ist nicht hochgeladen oder gehört nicht zu diesem Konto.' });
    }
    if (input.expectedPlantId) {
      const expectedPlant = await this.repository.findPublishedPlantByPublicId(input.expectedPlantId);
      if (!expectedPlant) {
        throw invalidRequest({ expectedPlantId: 'Die erwartete Pflanze ist nicht veröffentlicht.' });
      }
    }
    const clientExisting = await this.repository.findJobByClientId(actor.id, input.clientJobId);
    if (clientExisting) {
      if (clientExisting.mediaId !== input.mediaId || clientExisting.expectedPlantId !== input.expectedPlantId) {
        throw conflict('CLIENT_JOB_CONFLICT', 'Die Client-Auftrags-ID wurde bereits mit anderen Daten verwendet.');
      }
      return { ...mapJob(clientExisting), created: false };
    }

    const job = await this.repository.createJob({
      publicId: newId(),
      ownerId: actor.id,
      clientJobId: input.clientJobId,
      idempotencyKey,
      requestDigest,
      mediaId: input.mediaId,
      ...(input.expectedPlantId ? { expectedPlantId: input.expectedPlantId } : {}),
      status: 'pending',
      attempts: 0,
      candidates: [],
    });
    await this.enqueuePersistedJob(job.publicId);
    return { ...mapJob(job), created: true };
  }

  async getIdentification(actor, jobId) {
    requireUuid(jobId, 'jobId');
    const job = await this.repository.findJobByPublicId(actor.id, jobId);
    if (!job) throw notFound('IDENTIFICATION_NOT_FOUND');
    return mapJob(job);
  }

  async retryIdentification(actor, jobId, idempotencyHeader) {
    requireUuid(jobId, 'jobId');
    requireIdempotencyKey(idempotencyHeader);
    const job = await this.repository.findJobByPublicId(actor.id, jobId);
    if (!job) throw notFound('IDENTIFICATION_NOT_FOUND');
    if (!['failed', 'pending'].includes(job.status)) {
      throw conflict('IDENTIFICATION_NOT_RETRYABLE', 'Dieser Identifikationsauftrag kann derzeit nicht erneut gestartet werden.');
    }
    const updated = await this.repository.updateJob(job.id, {
      status: 'pending',
      retryAfter: null,
      failureCode: null,
    });
    await this.enqueuePersistedJob(updated.publicId);
    return mapJob(updated);
  }

  /**
   * Redis can be restarted independently from PostgreSQL. Once a job is
   * persisted it must remain visible to the caller even if its first enqueue
   * attempt fails; the worker recovery loop will enqueue pending jobs later.
   */
  async enqueuePersistedJob(jobId, options) {
    try {
      await this.enqueue(jobId, options);
      return true;
    } catch (_) {
      return false;
    }
  }

  async recoverPendingJobs(limit = 100) {
    const jobs = await this.repository.findPendingJobs(limit);
    await Promise.all(jobs.map((job) => this.enqueuePersistedJob(job.publicId)));
    return jobs.length;
  }

  async confirmIdentification(actor, jobId, body) {
    requireUuid(jobId, 'jobId');
    const input = validateConfirmation(body);
    const job = await this.repository.findJobByPublicId(actor.id, jobId);
    if (!job) throw notFound('IDENTIFICATION_NOT_FOUND');
    if (job.status !== 'identified') {
      throw conflict('IDENTIFICATION_NOT_READY', 'Das Ergebnis kann erst nach abgeschlossener Identifikation bestätigt werden.');
    }
    const candidates = Array.isArray(job.candidates) ? job.candidates : [];
    const candidate = candidates.find((item) => item && (
      (input.candidateId && item.candidateId === input.candidateId)
      || (input.confirmedPlantId && item.plantId === input.confirmedPlantId)
    ));
    if (!candidate) {
      throw invalidRequest({ candidateId: 'Die bestätigte Pflanze ist kein Kandidat dieses Auftrags.' });
    }
    const selectedExpectedCandidate = !job.expectedPlantId
      || (job.expectedCandidateId && candidate.candidateId === job.expectedCandidateId);
    if (!selectedExpectedCandidate && input.acceptMismatch !== true) {
      throw conflict(
        'IDENTIFICATION_MISMATCH_NOT_ACCEPTED',
        'Der gewählte Vorschlag weicht von der erwarteten Levelart ab und muss ausdrücklich bestätigt werden.',
      );
    }
    const updated = await this.repository.updateJob(job.id, {
      // A user may replace a formerly curated selection with an external
      // PlantNet candidate. Persisting null deliberately clears the stale
      // catalogue UUID so the observation cannot be attributed to the wrong
      // species.
      confirmedPlantId: candidate.plantId || null,
      confirmedCandidateId: candidate.candidateId,
    });
    return mapJob(updated);
  }

  /** Used by the queue worker. It does not expose cross-user job access. */
  async processIdentification(jobId, provider) {
    requireUuid(jobId, 'jobId');
    const job = await this.repository.findAnyJobByPublicId(jobId);
    if (!job || job.status !== 'pending') return undefined;
    const nextAttempt = Number(job.attempts || 0) + 1;
    const processing = await this.repository.updateJob(job.id, {
      status: 'processing',
      attempts: nextAttempt,
      failureCode: null,
    });
    const media = await this.repository.findPrivateMediaByPublicId(processing.ownerId, processing.mediaId);
    if (!media || media.status !== 'uploaded') {
      return this.repository.updateJob(processing.id, { status: 'failed', failureCode: 'MEDIA_UNAVAILABLE' });
    }
    try {
      const result = await provider.identify({ job: processing, media });
      const candidates = validateProviderCandidates(result.candidates);
      const expectation = await matchExpectedPlant(this.repository, processing, candidates);
      return this.repository.updateJob(processing.id, {
        status: 'identified',
        candidates,
        providerMetadata: {
          provider: result.provider,
          modelVersion: result.modelVersion,
          floraVersion: result.floraVersion,
        },
        ...expectation,
        retryAfter: null,
      });
    } catch (error) {
      const retryAfter = nextAttempt >= MAX_IDENTIFICATION_ATTEMPTS
        ? undefined
        : retryAfterFor(error, this.clock(), nextAttempt, processing.publicId);
      return this.repository.updateJob(processing.id, {
        status: 'failed',
        failureCode: retryAfter ? providerFailureCode(error) : 'PROVIDER_RETRY_EXHAUSTED',
        ...(retryAfter ? { retryAfter } : {}),
      });
    }
  }
}

function validateUploadReservation(body) {
  const value = requirePlainObject(body);
  rejectUnknownFields(value, ['clientMediaId', 'contentType', 'bytes', 'idempotencyKey', 'clientMutationId']);
  const contentType = requireString(value.contentType, 'contentType', { max: 40 });
  if (!ALLOWED_IMAGE_TYPES.has(contentType)) {
    throw invalidRequest({ contentType: 'Erlaubt sind image/jpeg und image/png.' });
  }
  const idempotencyKey = value.idempotencyKey !== undefined
    ? optionalString(value.idempotencyKey, 'idempotencyKey', { min: 16, max: 128 })
    : undefined;
  const clientMutationId = value.clientMutationId !== undefined
    ? optionalString(value.clientMutationId, 'clientMutationId', { min: 16, max: 128 })
    : undefined;
  return {
    clientMediaId: requireUuid(value.clientMediaId, 'clientMediaId'),
    contentType,
    bytes: requireInteger(value.bytes, 'bytes', { min: 1, max: MAX_IMAGE_BYTES }),
    ...(idempotencyKey !== undefined ? { idempotencyKey } : {}),
    ...(clientMutationId !== undefined ? { clientMutationId } : {}),
  };
}

function validateImageUpload(file, reservation) {
  if (!file || !Buffer.isBuffer(file.buffer) || !Number.isInteger(file.size) || !file.storageKey) {
    throw invalidRequest({ file: 'Der Upload enthält keine verarbeitbare Bilddatei.' });
  }
  if (file.size !== Number(reservation.bytes) || file.size > MAX_IMAGE_BYTES) {
    throw invalidRequest({ file: 'Die tatsächliche Bildgröße stimmt nicht mit der Reservierung überein.' });
  }
  if (file.contentType !== reservation.contentType || !ALLOWED_IMAGE_TYPES.has(file.contentType)) {
    throw invalidRequest({ file: 'Der Bildtyp stimmt nicht mit der Reservierung überein.' });
  }
  if (!hasExpectedMagicBytes(file.buffer, file.contentType)) {
    throw invalidRequest({ file: 'Die Datei entspricht nicht dem angegebenen Bildformat.' });
  }
  return {
    storageKey: file.storageKey,
    sha256: createHash('sha256').update(file.buffer).digest('hex'),
  };
}

function validateIdentificationRequest(body) {
  const value = requirePlainObject(body);
  rejectUnknownFields(value, ['clientJobId', 'mediaId', 'expectedPlantId', 'idempotencyKey', 'clientMutationId']);
  const idempotencyKey = value.idempotencyKey !== undefined
    ? optionalString(value.idempotencyKey, 'idempotencyKey', { min: 16, max: 128 })
    : undefined;
  const clientMutationId = value.clientMutationId !== undefined
    ? optionalString(value.clientMutationId, 'clientMutationId', { min: 16, max: 128 })
    : undefined;
  return {
    clientJobId: requireUuid(value.clientJobId, 'clientJobId'),
    mediaId: requireUuid(value.mediaId, 'mediaId'),
    expectedPlantId: value.expectedPlantId === undefined ? undefined : requireUuid(value.expectedPlantId, 'expectedPlantId'),
    ...(idempotencyKey !== undefined ? { idempotencyKey } : {}),
    ...(clientMutationId !== undefined ? { clientMutationId } : {}),
  };
}

function validateConfirmation(body) {
  const value = requirePlainObject(body);
  rejectUnknownFields(value, ['confirmedPlantId', 'candidateId', 'acceptMismatch']);
  const confirmedPlantId = value.confirmedPlantId === undefined
    ? undefined
    : requireUuid(value.confirmedPlantId, 'confirmedPlantId');
  const candidateId = value.candidateId === undefined
    ? undefined
    : optionalString(value.candidateId, 'candidateId', { min: 3, max: 160 });
  if ((confirmedPlantId === undefined && candidateId === undefined)
      || (confirmedPlantId !== undefined && candidateId !== undefined)) {
    throw invalidRequest({ body: 'Genau candidateId oder confirmedPlantId muss gesetzt sein.' });
  }
  if (value.acceptMismatch !== undefined && typeof value.acceptMismatch !== 'boolean') {
    throw invalidRequest({ acceptMismatch: 'acceptMismatch muss ein boolescher Wert sein.' });
  }
  return { confirmedPlantId, candidateId, acceptMismatch: value.acceptMismatch === true };
}

async function matchExpectedPlant(repository, job, candidates) {
  if (!job.expectedPlantId) return {};
  const expectedPlant = await repository.findPublishedPlantByPublicId(job.expectedPlantId);
  if (!expectedPlant) return { expectedMatch: 'mismatch', expectedCandidateId: null };
  const expectedScientificName = normaliseScientificName(expectedPlant.scientificName);
  const match = candidates.find((candidate) =>
    candidate.plantId === job.expectedPlantId
    || normaliseScientificName(candidate.scientificName) === expectedScientificName);
  return {
    expectedMatch: match ? 'matched' : 'mismatch',
    expectedCandidateId: match?.candidateId || null,
  };
}

function normaliseScientificName(value) {
  return typeof value === 'string' ? value.trim().toLocaleLowerCase('en-US') : '';
}

function validateProviderCandidates(candidates) {
  if (!Array.isArray(candidates) || candidates.length === 0 || candidates.length > 10) {
    throw new Error('Provider returned no usable candidates.');
  }
  return candidates.map((candidate) => {
    if (!candidate || typeof candidate.candidateId !== 'string' || candidate.candidateId.length < 3
      || typeof candidate.scientificName !== 'string' || candidate.scientificName.length === 0
      || typeof candidate.score !== 'number' || candidate.score < 0 || candidate.score > 1) {
      throw new Error('Provider returned an invalid candidate.');
    }
    return {
      candidateId: candidate.candidateId,
      scientificName: candidate.scientificName,
      ...(typeof candidate.commonName === 'string' ? { commonName: candidate.commonName } : {}),
      ...(typeof candidate.plantId === 'string' ? { plantId: candidate.plantId } : {}),
      score: candidate.score,
      provider: candidate.provider || 'plantnet',
      modelVersion: candidate.modelVersion || 'unknown',
    };
  });
}

function mapUpload(media, uploadUrl) {
  return {
    id: media.publicId,
    ...(uploadUrl ? { uploadUrl } : {}),
    expiresAt: media.expiresAt,
    status: media.status,
  };
}

function mapJob(job) {
  return {
    id: job.publicId,
    status: job.status,
    createdAt: job.createdAt,
    attempts: Number(job.attempts || 0),
    ...(job.retryAfter ? { retryAfter: job.retryAfter } : {}),
    ...(Array.isArray(job.candidates) && job.candidates.length ? { candidates: job.candidates } : {}),
    ...(job.providerMetadata && typeof job.providerMetadata === 'object'
      ? { providerMetadata: job.providerMetadata }
      : {}),
    ...(job.expectedPlantId ? { expectedPlantId: job.expectedPlantId } : {}),
    ...(job.expectedMatch ? { expectedMatch: job.expectedMatch } : {}),
    ...(job.expectedCandidateId ? { expectedCandidateId: job.expectedCandidateId } : {}),
    ...(job.failureCode ? { failureCode: job.failureCode } : {}),
    ...(job.confirmedPlantId ? { confirmedPlantId: job.confirmedPlantId } : {}),
    ...(job.confirmedCandidateId ? { confirmedCandidateId: job.confirmedCandidateId } : {}),
  };
}

function hasExpectedMagicBytes(bytes, contentType) {
  if (contentType === 'image/jpeg') return bytes.length >= 3 && bytes[0] === 0xff && bytes[1] === 0xd8 && bytes[2] === 0xff;
  if (contentType === 'image/png') return bytes.length >= 8 && bytes.subarray(0, 8).equals(Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]));
  return false;
}

function retryAfterFor(error, now, attempt, jobId) {
  const retryable = error && (error.code === 'PROVIDER_RATE_LIMITED' || error.code === 'PROVIDER_TIMEOUT' || error.code === 'PROVIDER_UNAVAILABLE');
  if (!retryable) return undefined;
  const requestedDelay = Number(error.retryAfterMs || 1_000);
  const exponentialDelay = Math.min(60_000, 1_000 * (2 ** Math.max(0, attempt - 1)));
  const jitter = deterministicJitter(jobId, attempt);
  // PlantNet returns Retry-After as an HTTP date when its daily identify
  // quota is exhausted. Do not hammer the provider every minute: persist and
  // enqueue the returned delay, bounded to one day for recovery safety.
  const retryMs = Math.min(
    MAX_PROVIDER_RETRY_DELAY_MS,
    Math.max(requestedDelay, exponentialDelay) + jitter,
  );
  return new Date(now.getTime() + retryMs).toISOString();
}

function deterministicJitter(jobId, attempt) {
  const source = createHash('sha256').update(`${jobId || ''}:${attempt}`).digest();
  return source[0] % 751;
}

function providerFailureCode(error) {
  if (error && typeof error.code === 'string' && /^[A-Z0-9_]{3,80}$/.test(error.code)) return error.code;
  return 'PROVIDER_UNAVAILABLE';
}

function assertSamePayload(storedDigest, requestDigest) {
  if (storedDigest !== requestDigest) {
    throw conflict('IDEMPOTENCY_CONFLICT', 'Der Idempotency-Key wurde bereits mit einer anderen Anfrage verwendet.');
  }
}

module.exports = {
  ALLOWED_IMAGE_TYPES,
  FieldService,
  MAX_IDENTIFICATION_ATTEMPTS,
  deterministicJitter,
  hasExpectedMagicBytes,
  mapJob,
  validateImageUpload,
  validateUploadReservation,
};

'use strict';

const { conflict, invalidRequest, notFound } = require('../errors');
const { SpeciesService } = require('../species/species-service');
const { newId, payloadDigest, requireIdempotencyKey, requireUuid, scopedIdempotencyKey } = require('../ids');
const { optionalString, pageFromQuery, parseIfMatch, requireDate, requirePlainObject, rejectUnknownFields } = require('../validation');

class HerbariumService {
  constructor(options) {
    this.repository = options.repository;
    this.fieldRepository = options.fieldRepository;
    this.species = options.species;
    this.clock = options.clock || (() => new Date());
  }

  async list(actor, query) {
    const page = pageFromQuery(query);
    const result = await this.repository.listObservations(actor.id, page);
    return {
      items: await Promise.all(result.items.map((item) => this.mapObservation(actor, item))),
      page: { page: page.page, pageSize: page.pageSize, total: result.total },
    };
  }

  async get(actor, observationId) {
    requireUuid(observationId, 'observationId');
    const observation = await this.repository.findObservationByPublicId(actor.id, observationId);
    if (!observation || observation.syncStatus === 'deleted') throw notFound('OBSERVATION_NOT_FOUND');
    return this.mapObservation(actor, observation);
  }

  async create(actor, body, idempotencyHeader) {
    const input = validateCreateObservation(body);
    const externalKey = requireIdempotencyKey(input.idempotencyKey || input.clientMutationId || idempotencyHeader || input.clientObservationId);
    const idempotencyKey = scopedIdempotencyKey(actor.id, 'observation', externalKey);
    const requestDigest = payloadDigest(input);
    const existing = await this.repository.findObservationByIdempotencyKey(idempotencyKey);
    if (existing) {
      assertSamePayload(existing.requestDigest, requestDigest);
      return { observation: await this.mapObservation(actor, existing), created: false };
    }
    const clientExisting = await this.repository.findObservationByClientId(actor.id, input.clientObservationId);
    if (clientExisting) {
      return { observation: await this.mapObservation(actor, clientExisting), created: false };
    }

    const identification = input.identificationJobId
      ? await this.requireConfirmedIdentification(actor, input.identificationJobId)
      : undefined;
    if (input.mediaId) await this.requireOwnedMedia(actor, input.mediaId);
    const now = this.clock().toISOString();
    const observation = await this.repository.createObservation({
      publicId: newId(),
      ownerId: actor.id,
      clientObservationId: input.clientObservationId,
      idempotencyKey,
      requestDigest,
      timestamp: input.observedAt,
      ...(input.note !== undefined ? { notes: input.note } : {}),
      ...(input.mediaId ? { mediaId: input.mediaId } : {}),
      ...(input.identificationJobId ? { identificationJobId: input.identificationJobId } : {}),
      ...(identification?.confirmedPlantId ? { confirmedPlantId: identification.confirmedPlantId } : {}),
      ...(input.location ? { latitude: input.location.latitude, longitude: input.location.longitude, locationAccuracyMeters: input.location.accuracyMeters } : {}),
      version: newId(),
      syncStatus: 'synced',
      createdAt: now,
    });
    // A confirmed species outside the catalogue gets a shared info card (built
    // once, cached for everyone). Best effort: it must never delay or fail the save.
    if (this.species && identification && !identification.confirmedPlantId) {
      const candidate = confirmedCandidate(identification);
      if (candidate) void this.species.ensureFromCandidate(candidate);
    }
    return { observation: await this.mapObservation(actor, observation), created: true };
  }

  async update(actor, observationId, body, ifMatchHeader) {
    requireUuid(observationId, 'observationId');
    const input = validateUpdateObservation(body);
    const expectedVersion = parseIfMatch(ifMatchHeader);
    const current = await this.repository.findObservationByPublicId(actor.id, observationId);
    if (!current || current.syncStatus === 'deleted') throw notFound('OBSERVATION_NOT_FOUND');
    if (current.version !== expectedVersion) {
      throw conflict('OBSERVATION_VERSION_CONFLICT', 'Der Fund wurde auf einem anderen Gerät geändert. Bitte lade ihn neu.');
    }
    const updated = await this.repository.updateObservation(current.id, {
      ...(input.note !== undefined ? { notes: input.note } : {}),
      ...(input.confirmedPlantId ? { confirmedPlantId: input.confirmedPlantId } : {}),
      version: newId(),
    });
    return this.mapObservation(actor, updated);
  }

  async delete(actor, observationId, ifMatchHeader) {
    requireUuid(observationId, 'observationId');
    const expectedVersion = parseIfMatch(ifMatchHeader);
    const current = await this.repository.findObservationByPublicId(actor.id, observationId);
    if (!current || current.syncStatus === 'deleted') throw notFound('OBSERVATION_NOT_FOUND');
    if (current.version !== expectedVersion) {
      throw conflict('OBSERVATION_VERSION_CONFLICT', 'Der Fund wurde auf einem anderen Gerät geändert. Bitte lade ihn neu.');
    }
    await this.repository.updateObservation(current.id, {
      syncStatus: 'deleted',
      deletedAt: this.clock().toISOString(),
      version: newId(),
    });
  }

  async requireConfirmedIdentification(actor, jobId) {
    if (!this.fieldRepository) return undefined;
    const job = await this.fieldRepository.findJobByPublicId(actor.id, jobId);
    if (!job || job.status !== 'identified'
      || (!job.confirmedCandidateId && !job.confirmedPlantId)) {
      throw invalidRequest({ identificationJobId: 'Die Identifikation muss zuerst abgeschlossen und bestätigt werden.' });
    }
    return job;
  }

  async requireOwnedMedia(actor, mediaId) {
    if (!this.fieldRepository) return undefined;
    const media = await this.fieldRepository.findPrivateMediaByPublicId(actor.id, mediaId);
    if (!media || media.status !== 'uploaded') {
      throw invalidRequest({ mediaId: 'Das Bild muss zuerst vollständig und im eigenen Konto hochgeladen werden.' });
    }
    return media;
  }

  async mapObservation(actor, observation) {
    let identification;
    let species;
    if (observation.identificationJobId && this.fieldRepository) {
      const job = await this.fieldRepository.findJobByPublicId(actor.id, observation.identificationJobId);
      if (job) {
        identification = mapIdentification(job);
        const candidate = !observation.confirmedPlantId ? confirmedCandidate(job) : undefined;
        if (candidate) {
          species = {
            speciesKey: SpeciesService.keyFor(candidate.scientificName),
            speciesName: candidate.commonName || candidate.scientificName,
          };
        }
      }
    }
    return {
      id: observation.publicId,
      clientObservationId: observation.clientObservationId,
      observedAt: observation.timestamp,
      note: observation.notes || '',
      ...(observation.confirmedPlantId ? { confirmedPlantId: observation.confirmedPlantId } : {}),
      ...(observation.mediaId ? { mediaId: observation.mediaId, mediaUrl: `/api/v1/media/${observation.mediaId}/content` } : {}),
      ...(observation.latitude != null && observation.longitude != null
        ? { location: { latitude: observation.latitude, longitude: observation.longitude, accuracyMeters: observation.locationAccuracyMeters ?? 0 } }
        : {}),
      ...(species ? species : {}),
      ...(identification ? { identification } : {}),
      version: observation.version,
      syncStatus: observation.syncStatus,
    };
  }
}

function confirmedCandidate(job) {
  const candidates = Array.isArray(job?.candidates) ? job.candidates : [];
  return candidates.find((item) => item && item.candidateId === job.confirmedCandidateId && !item.plantId);
}

function validateCreateObservation(body) {
  const value = requirePlainObject(body);
  rejectUnknownFields(value, [
    'clientObservationId',
    'observedAt',
    'note',
    'mediaId',
    'identificationJobId',
    'location',
    'idempotencyKey',
    'clientMutationId',
  ]);
  const location = value.location === undefined ? undefined : validateLocation(value.location);
  const idempotencyKey = value.idempotencyKey !== undefined
    ? optionalString(value.idempotencyKey, 'idempotencyKey', { min: 16, max: 128 })
    : undefined;
  const clientMutationId = value.clientMutationId !== undefined
    ? optionalString(value.clientMutationId, 'clientMutationId', { min: 16, max: 128 })
    : undefined;
  return {
    clientObservationId: requireUuid(value.clientObservationId, 'clientObservationId'),
    observedAt: requireDate(value.observedAt, 'observedAt'),
    note: optionalString(value.note, 'note', { min: 0, max: 4000 }),
    mediaId: value.mediaId === undefined ? undefined : requireUuid(value.mediaId, 'mediaId'),
    identificationJobId: value.identificationJobId === undefined ? undefined : requireUuid(value.identificationJobId, 'identificationJobId'),
    location,
    ...(idempotencyKey !== undefined ? { idempotencyKey } : {}),
    ...(clientMutationId !== undefined ? { clientMutationId } : {}),
  };
}

function validateUpdateObservation(body) {
  const value = requirePlainObject(body);
  rejectUnknownFields(value, ['note', 'confirmedPlantId']);
  const note = optionalString(value.note, 'note', { min: 0, max: 4000 });
  const confirmedPlantId = value.confirmedPlantId === undefined ? undefined : requireUuid(value.confirmedPlantId, 'confirmedPlantId');
  if (note === undefined && confirmedPlantId === undefined) {
    throw invalidRequest({ body: 'Mindestens note oder confirmedPlantId muss gesetzt sein.' });
  }
  return { note, confirmedPlantId };
}

function validateLocation(value) {
  const location = requirePlainObject(value, 'location');
  rejectUnknownFields(location, ['latitude', 'longitude', 'accuracyMeters']);
  const latitude = location.latitude;
  const longitude = location.longitude;
  const accuracyMeters = location.accuracyMeters;
  if (typeof latitude !== 'number' || latitude < -90 || latitude > 90
    || typeof longitude !== 'number' || longitude < -180 || longitude > 180
    || typeof accuracyMeters !== 'number' || accuracyMeters < 0) {
    throw invalidRequest({ location: 'Standortkoordinaten oder Genauigkeit sind ungültig.' });
  }
  return { latitude, longitude, accuracyMeters };
}

function mapIdentification(job) {
  return {
    id: job.publicId,
    status: job.status,
    createdAt: job.createdAt,
    ...(job.retryAfter ? { retryAfter: job.retryAfter } : {}),
    ...(Array.isArray(job.candidates) ? { candidates: job.candidates } : {}),
    ...(job.failureCode ? { failureCode: job.failureCode } : {}),
    ...(job.confirmedPlantId ? { confirmedPlantId: job.confirmedPlantId } : {}),
    ...(job.confirmedCandidateId ? { confirmedCandidateId: job.confirmedCandidateId } : {}),
  };
}

function assertSamePayload(storedDigest, requestDigest) {
  if (storedDigest !== requestDigest) {
    throw conflict('IDEMPOTENCY_CONFLICT', 'Der Idempotency-Key wurde bereits mit einer anderen Anfrage verwendet.');
  }
}

module.exports = {
  HerbariumService,
  validateCreateObservation,
  validateLocation,
  validateUpdateObservation,
};

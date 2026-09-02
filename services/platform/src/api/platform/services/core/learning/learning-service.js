'use strict';

const { ProblemError, conflict, invalidRequest, notFound, asProblem } = require('../errors');
const { newId, payloadDigest, requireIdempotencyKey, requireUuid, scopedIdempotencyKey } = require('../ids');
const {
  requireArray,
  requireDate,
  requireInteger,
  optionalDate,
  requirePlainObject,
  requireString,
  optionalString,
  rejectUnknownFields,
} = require('../validation');
const { normaliseCompletionRule } = require('../content/content-service');

class LearningService {
  constructor(options) {
    this.repository = options.repository;
    this.herbariumRepository = options.herbariumRepository;
    this.clock = options.clock || (() => new Date());
  }

  async startAttempt(actor, body, idempotencyHeader) {
    const input = validateStartAttempt(body);
    const idempotencyKey = requireIdempotencyKey(input.idempotencyKey || input.clientMutationId || idempotencyHeader || input.clientAttemptId);
    const scopedKey = scopedIdempotencyKey(actor.id, 'level-attempt', idempotencyKey);
    const requestDigest = payloadDigest(input);
    const existing = await this.repository.findAttemptByIdempotencyKey(scopedKey);
    if (existing) {
      assertSamePayload(existing.requestDigest, requestDigest);
      return { attempt: mapAttempt(existing), created: false };
    }

    const level = await this.repository.findPublishedLevel(input.levelId);
    if (!level) throw notFound('LEVEL_NOT_FOUND');
    if (level.releaseVersion !== input.contentVersion) {
      throw conflict('CONTENT_VERSION_CONFLICT', 'Das Level gehört nicht zu der angefragten Inhaltsversion.');
    }

    const existingClientAttempt = await this.repository.findAttemptByClientId(actor.id, input.clientAttemptId);
    if (existingClientAttempt) {
      if (existingClientAttempt.levelPublicId !== input.levelId || existingClientAttempt.contentVersion !== input.contentVersion) {
        throw conflict('CLIENT_ATTEMPT_CONFLICT', 'Die Client-Attempt-ID wurde bereits für ein anderes Level verwendet.');
      }
      return { attempt: mapAttempt(existingClientAttempt), created: false };
    }

    const now = this.clock().toISOString();
    const attempt = await this.repository.createAttempt({
      publicId: newId(),
      ownerId: actor.id,
      clientAttemptId: input.clientAttemptId,
      idempotencyKey: scopedKey,
      requestDigest,
      levelPublicId: input.levelId,
      contentVersion: input.contentVersion,
      status: 'active',
      startedAt: now,
      completedAt: null,
      completionDigest: null,
      score: null,
      passed: null,
    });
    return { attempt: mapAttempt(attempt), created: true };
  }

  async completeAttempt(actor, attemptId, body, idempotencyHeader) {
    requireUuid(attemptId, 'attemptId');
    const input = validateCompletion(body);
    const idempotencyKey = requireIdempotencyKey(idempotencyHeader);
    const attempt = await this.repository.findAttemptByPublicId(actor.id, attemptId);
    if (!attempt) throw notFound('LEVEL_ATTEMPT_NOT_FOUND');

    const completionKey = scopedIdempotencyKey(actor.id, `attempt-complete:${attemptId}`, idempotencyKey);
    const requestDigest = payloadDigest(input);
    if (attempt.completionIdempotencyKey) {
      if (attempt.completionIdempotencyKey === completionKey) {
        assertSamePayload(attempt.completionDigest, requestDigest);
        return this.completionFromStored(actor, attempt);
      }
      throw conflict('ATTEMPT_ALREADY_COMPLETED', 'Dieser Levelversuch wurde bereits abgeschlossen.');
    }

    const level = await this.repository.findPublishedLevel(attempt.levelPublicId);
    if (!level || level.releaseVersion !== attempt.contentVersion) {
      throw new ProblemError('CONTENT_VERSION_UNAVAILABLE', {
        status: 409,
        detail: 'Die zugehörige Inhaltsversion ist nicht mehr verfügbar.',
      });
    }
    const rule = normaliseCompletionRule(level.completionRule, level.quizzes || []);
    const score = await this.scoreAnswers(level, rule, input.answers);
    const passed = score >= rule.minimumScore;
    if (passed) await this.requireCollectedPlants(actor, level, rule);
    const completedAt = this.clock().toISOString();
    const updated = await this.repository.updateAttempt(attempt.id || attempt.publicId, {
      status: 'completed',
      completedAt,
      score,
      passed,
      completionIdempotencyKey: completionKey,
      completionDigest: requestDigest,
      completionClientEventId: input.clientEventId,
    });
    const progress = await this.getProgress(actor);
    return {
      attemptId: updated.publicId,
      passed,
      score,
      status: passed ? 'completed' : 'failed',
      progress,
    };
  }

  async submitEvents(actor, body, idempotencyHeader, traceId) {
    requireIdempotencyKey(idempotencyHeader);
    const input = validateEventBatch(body);
    const acceptedClientEventIds = [];
    const rejected = [];

    for (const rawEvent of input.events) {
      try {
        const event = validateEvent(rawEvent);
        const idempotencyKey = scopedIdempotencyKey(actor.id, 'learning-event', event.clientEventId);
        const requestDigest = payloadDigest(event);
        const existing = await this.repository.findEventByIdempotencyKey(idempotencyKey);
        if (existing) {
          assertSamePayload(existing.requestDigest, requestDigest);
        } else {
          await this.repository.createEvent({
            publicId: newId(),
            ownerId: actor.id,
            clientEventId: event.clientEventId,
            idempotencyKey,
            requestDigest,
            type: event.type,
            occurredAt: event.occurredAt,
            payloadVersion: event.payloadVersion,
            payload: event.payload,
            receivedAt: this.clock().toISOString(),
          });
        }
        acceptedClientEventIds.push(event.clientEventId);
      } catch (error) {
        rejected.push(asProblem(error, traceId));
      }
    }

    return { acceptedClientEventIds, rejected };
  }

  async synchronize(actor, body, idempotencyHeader, traceId, contentChanges) {
    requireIdempotencyKey(idempotencyHeader);
    const input = validateSync(body);
    const acknowledgement = await this.submitEvents(actor, { events: input.events }, idempotencyHeader, traceId);
    const progress = await this.getProgress(actor);
    const changes = await contentChanges(input.contentCursor);
    return {
      progress,
      acknowledgedClientEventIds: acknowledgement.acceptedClientEventIds,
      contentCursor: changes.cursor,
    };
  }

  async getProgress(actor, since) {
    const normalizedSince = optionalDate(since, 'since');
    const [levels, attempts] = await Promise.all([
      this.repository.listPublishedLevels(),
      this.repository.listAttemptsByOwner(actor.id, normalizedSince),
    ]);
    const attemptsByLevel = new Map();
    for (const attempt of attempts) {
      const current = attemptsByLevel.get(attempt.levelPublicId);
      if (!current || timestampOf(attempt) > timestampOf(current)) attemptsByLevel.set(attempt.levelPublicId, attempt);
    }

    const completedLevelIds = new Set(
      attempts.filter((attempt) => attempt.status === 'completed' && attempt.passed).map((attempt) => attempt.levelPublicId)
    );
    const progressLevels = levels.map((level) => {
      const attempt = attemptsByLevel.get(level.publicId);
      const prerequisites = level.completionRule && Array.isArray(level.completionRule.requiredLevelIds)
        ? level.completionRule.requiredLevelIds
        : [];
      const locked = prerequisites.some((id) => !completedLevelIds.has(id));
      let status = 'available';
      let percentage = 0;
      let completedAt;
      if (completedLevelIds.has(level.publicId)) {
        status = 'completed';
        percentage = 1;
        completedAt = attempt && attempt.completedAt;
      } else if (locked) {
        status = 'locked';
      } else if (attempt) {
        status = 'in_progress';
        percentage = typeof attempt.progress === 'number' ? clamp(attempt.progress) : 0;
      }
      return { levelId: level.publicId, status, percentage, ...(completedAt ? { completedAt } : {}) };
    });

    const updatedAt = maxTimestamp([...attempts, ...levels]) || this.clock().toISOString();
    return { updatedAt, levels: progressLevels };
  }

  async getLevelAccess(actor, level) {
    const progress = await this.getProgress(actor);
    const state = progress.levels.find((item) => item.levelId === level.publicId);
    if (!state) return { status: 'available', progress: 0 };
    if (state.status !== 'locked') {
      return { status: state.status, progress: state.percentage };
    }
    return {
      status: state.status,
      progress: state.percentage,
      // The condition is derived from the server-side completion rule.  It is
      // deliberately generic: titles may change between content releases.
      blockedReason: 'Schließe zuerst die vorherige Etappe ab.',
    };
  }

  async scoreAnswers(level, rule, answers) {
    const questions = await this.repository.findPublishedQuizItems(level.publicId);
    const byId = new Map(questions.map((question) => [question.publicId, question]));
    const requiredIds = rule.requiredQuizIds;
    const byAnswerId = new Map();
    for (const answer of answers) {
      if (byAnswerId.has(answer.quizItemId)) {
        throw invalidRequest({ answers: 'Jede Quizfrage darf höchstens einmal beantwortet werden.' });
      }
      if (!requiredIds.includes(answer.quizItemId) || !byId.has(answer.quizItemId)) {
        throw invalidRequest({ answers: 'Eine Antwort gehört nicht zu diesem Levelabschluss.' });
      }
      byAnswerId.set(answer.quizItemId, answer);
    }
    if (byAnswerId.size !== requiredIds.length) {
      throw invalidRequest({ answers: 'Alle für den Abschluss erforderlichen Quizfragen müssen beantwortet werden.' });
    }
    if (requiredIds.length === 0) {
      throw new ProblemError('CONTENT_INTEGRITY_FAILED', {
        status: 503,
        detail: 'Das Level enthält keine bewertbaren Abschlussfragen.',
      });
    }

    let correct = 0;
    for (const questionId of requiredIds) {
      const question = byId.get(questionId);
      const answer = byAnswerId.get(questionId);
      if (isCorrect(question, answer.choiceId)) correct += 1;
    }
    return correct / requiredIds.length;
  }

  async requireCollectedPlants(actor, level, rule) {
    const relatedPlantIds = (level.plants || [])
      .filter((plant) => plant && plant.publishedAt)
      .map((plant) => plant.publicId)
      .filter(Boolean);
    const requiredPlantIds = rule.requiredPlantIds.length > 0
      ? rule.requiredPlantIds
      : relatedPlantIds.slice(0, 3);
    if (requiredPlantIds.length === 0) {
      throw new ProblemError('CONTENT_INTEGRITY_FAILED', {
        status: 503,
        detail: 'Das Level enthält keine sammelbaren Zielpflanzen.',
      });
    }
    if (!this.herbariumRepository) {
      throw new ProblemError('COLLECTION_GATE_UNAVAILABLE', {
        status: 503,
        detail: 'Der Herbarium-Fortschritt kann derzeit nicht geprüft werden.',
      });
    }
    const result = await this.herbariumRepository.listObservations(actor.id, {
      page: 1,
      pageSize: 1000,
    });
    const collected = new Set(
      result.items
        .filter((entry) => entry.syncStatus !== 'deleted')
        .map((entry) => entry.confirmedPlantId)
        .filter(Boolean),
    );
    const missingPlantIds = requiredPlantIds.filter((id) => !collected.has(id));
    if (missingPlantIds.length > 0) {
      throw new ProblemError('LEVEL_COLLECTION_INCOMPLETE', {
        status: 409,
        detail: `Sammle zuerst ${missingPlantIds.length} weitere Zielpflanzen im Herbarium.`,
        meta: { missingPlantIds },
      });
    }
  }

  async completionFromStored(actor, attempt) {
    const progress = await this.getProgress(actor);
    return {
      attemptId: attempt.publicId,
      passed: Boolean(attempt.passed),
      score: Number(attempt.score || 0),
      status: attempt.passed ? 'completed' : 'failed',
      progress,
    };
  }
}

function validateStartAttempt(body) {
  const value = requirePlainObject(body);
  rejectUnknownFields(value, ['levelId', 'clientAttemptId', 'contentVersion', 'idempotencyKey', 'clientMutationId']);
  const idempotencyKey = value.idempotencyKey !== undefined
    ? optionalString(value.idempotencyKey, 'idempotencyKey', { min: 16, max: 128 })
    : undefined;
  const clientMutationId = value.clientMutationId !== undefined
    ? optionalString(value.clientMutationId, 'clientMutationId', { min: 16, max: 128 })
    : undefined;
  return {
    levelId: requireUuid(value.levelId, 'levelId'),
    clientAttemptId: requireUuid(value.clientAttemptId, 'clientAttemptId'),
    contentVersion: requireString(value.contentVersion, 'contentVersion', { max: 128 }),
    ...(idempotencyKey !== undefined ? { idempotencyKey } : {}),
    ...(clientMutationId !== undefined ? { clientMutationId } : {}),
  };
}

function validateCompletion(body) {
  const value = requirePlainObject(body);
  rejectUnknownFields(value, ['clientEventId', 'answers']);
  return {
    clientEventId: requireUuid(value.clientEventId, 'clientEventId'),
    answers: requireArray(value.answers, 'answers', { min: 1, max: 100 }).map((answer, index) => {
      const item = requirePlainObject(answer, `answers[${index}]`);
      rejectUnknownFields(item, ['quizItemId', 'choiceId']);
      return {
        quizItemId: requireUuid(item.quizItemId, `answers[${index}].quizItemId`),
        choiceId: requireString(item.choiceId, `answers[${index}].choiceId`, { max: 256 }),
      };
    }),
  };
}

function validateEventBatch(body) {
  const value = requirePlainObject(body);
  rejectUnknownFields(value, ['events']);
  return { events: requireArray(value.events, 'events', { min: 1, max: 100 }) };
}

function validateSync(body) {
  const value = requirePlainObject(body);
  rejectUnknownFields(value, ['events', 'contentCursor']);
  return {
    events: requireArray(value.events, 'events', { max: 100 }),
    contentCursor: optionalString(value.contentCursor, 'contentCursor', { max: 512 }),
  };
}

function validateEvent(value) {
  const event = requirePlainObject(value, 'event');
  rejectUnknownFields(event, ['clientEventId', 'type', 'occurredAt', 'payloadVersion', 'payload']);
  return {
    clientEventId: requireUuid(event.clientEventId, 'clientEventId'),
    type: requireString(event.type, 'type', { max: 100 }),
    occurredAt: requireDate(event.occurredAt, 'occurredAt'),
    payloadVersion: requireInteger(event.payloadVersion, 'payloadVersion', { min: 1, max: 1_000_000 }),
    payload: requirePlainObject(event.payload || {}, 'payload'),
  };
}

function isCorrect(question, choiceId) {
  const data = question.data && typeof question.data === 'object' ? question.data : {};
  const expected = data.correctChoiceId;
  if (typeof expected !== 'string') {
    throw new ProblemError('CONTENT_INTEGRITY_FAILED', {
      status: 503,
      detail: 'Eine Abschlussfrage hat keine serverseitige Lösung.',
    });
  }
  return expected === choiceId;
}

function mapAttempt(attempt) {
  return {
    id: attempt.publicId,
    levelId: attempt.levelPublicId,
    status: attempt.status,
    contentVersion: attempt.contentVersion,
    startedAt: attempt.startedAt,
  };
}

function assertSamePayload(storedDigest, requestDigest) {
  if (storedDigest !== requestDigest) {
    throw conflict('IDEMPOTENCY_CONFLICT', 'Der Idempotency-Key wurde bereits mit einer anderen Anfrage verwendet.');
  }
}

function clamp(value) {
  return Math.max(0, Math.min(1, value));
}

function timestampOf(record) {
  return Date.parse(record.updatedAt || record.completedAt || record.startedAt || record.createdAt || 0) || 0;
}

function maxTimestamp(records) {
  const timestamps = records.map((record) => record.updatedAt || record.completedAt || record.startedAt || record.createdAt).filter(Boolean);
  if (timestamps.length === 0) return undefined;
  return timestamps.reduce((latest, value) => Date.parse(value) > Date.parse(latest) ? value : latest);
}

module.exports = {
  LearningService,
  validateStartAttempt,
  validateCompletion,
  validateEvent,
  isCorrect,
};

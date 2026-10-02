'use strict';

const { createHash } = require('crypto');
const { newId, requireUuid } = require('../ids');
const { ProblemError, invalidRequest, notFound, conflict } = require('../errors');
const { validateLearningCards } = require('../content/lesson-cards');

const CHANGE_UID = 'api::editor-change.editor-change';
const TYPES = Object.freeze({
  ecosystem: { uid: 'api::ecosystem.ecosystem', fields: ['slug', 'name', 'description', 'climateZone', 'region', 'season', 'language'] },
  level: { uid: 'api::level.level', fields: ['slug', 'title', 'sequence', 'difficulty', 'learningGoal', 'completionRule', 'ecosystemId', 'plantIds'] },
  plant: { uid: 'api::plant.plant', fields: ['slug', 'scientificName', 'commonName', 'family', 'description', 'warning', 'sources', 'features', 'learningCards'] },
  quiz: { uid: 'api::quiz.quiz', fields: ['slug', 'title', 'quizType', 'data', 'levelId', 'plantId'] },
});
const EDITOR_ROLES = new Set(['inhaltsredaktion', 'botanisches_review', 'systemadministration']);
const REVIEW_ROLES = new Set(['botanisches_review', 'systemadministration']);

function requireEditor(actor) {
  if (!actor?.roles?.some((role) => EDITOR_ROLES.has(role))) {
    throw new ProblemError('EDITOR_FORBIDDEN', { status: 403, detail: 'Für die Redaktion ist eine Redaktionsrolle erforderlich.' });
  }
}

function requireReviewer(actor) {
  requireEditor(actor);
  if (!actor.roles.some((role) => REVIEW_ROLES.has(role))) {
    throw new ProblemError('REVIEW_FORBIDDEN', { status: 403, detail: 'Nur das botanische Review darf Inhalte freigeben.' });
  }
}

function typeConfig(type) {
  const config = TYPES[type];
  if (!config) throw invalidRequest({ type: 'Unbekannter Inhaltstyp.' });
  return config;
}

class EditorService {
  constructor(strapi, runtime) {
    this.strapi = strapi;
    this.entities = strapi.entityService;
    this.runtime = runtime;
  }

  async dashboard(actor) {
    requireEditor(actor);
    const counts = await Promise.all([
      this.entities.count('api::profile.profile'),
      this.entities.count(TYPES.ecosystem.uid, { filters: { publishedAt: { $notNull: true } } }),
      this.entities.count(TYPES.level.uid, { filters: { publishedAt: { $notNull: true } } }),
      this.entities.count(TYPES.plant.uid, { filters: { publishedAt: { $notNull: true } } }),
      this.entities.count(TYPES.quiz.uid, { filters: { publishedAt: { $notNull: true } } }),
      this.entities.count(CHANGE_UID, { filters: { status: 'pending_review' } }),
      this.entities.count(CHANGE_UID, { filters: { status: 'approved', appliedAt: { $null: true } } }),
    ]);
    const [mediaTotal] = await this.strapi.db.connection('private_media')
      .where({ status: 'uploaded' }).sum({ total: 'bytes' });
    const day = new Date().toISOString().slice(0, 10);
    let plantNetToday = null;
    try {
      const guard = this.runtime.providerGuard;
      if (guard?.redis) {
        const value = await guard.redis.get(`${guard.prefix}:quota:${day}`);
        plantNetToday = Number(value || 0);
      }
    } catch { /* Show unavailable, never a misleading zero. */ }
    return {
      users: counts[0], ecosystems: counts[1], levels: counts[2], plants: counts[3],
      quizzes: counts[4], learningElements: counts[2] + counts[4],
      cards: counts[3] * 3, pendingReview: counts[5], approvedPendingRelease: counts[6],
      plantNetToday, storageBytes: Number(mediaTotal?.total || 0),
      storageScope: 'uploaded-private-media',
    };
  }

  async catalog(actor) {
    requireEditor(actor);
    const [ecosystems, levels, plants, quizzes] = await Promise.all([
      this.entities.findMany(TYPES.ecosystem.uid, { publicationState: 'preview', limit: 1000, sort: { name: 'asc' } }),
      this.entities.findMany(TYPES.level.uid, {
        publicationState: 'preview', limit: 1000, sort: { sequence: 'asc' },
        populate: { ecosystem: { fields: ['publicId'] }, plants: { fields: ['publicId'] } },
      }),
      this.entities.findMany(TYPES.plant.uid, { publicationState: 'preview', limit: 1000, sort: { commonName: 'asc' } }),
      this.entities.findMany(TYPES.quiz.uid, {
        publicationState: 'preview', limit: 1000, sort: { title: 'asc' },
        populate: { level: { fields: ['publicId'] }, plant: { fields: ['publicId'] } },
      }),
    ]);
    return {
      ecosystems: ecosystems.map((item) => summary('ecosystem', item)),
      levels: levels.map((item) => ({ ...summary('level', item), ecosystemId: item.ecosystem?.publicId,
        plantIds: (item.plants || []).map((plant) => plant.publicId), sequence: item.sequence })),
      plants: plants.map((item) => summary('plant', item)),
      quizzes: quizzes.map((item) => ({ ...summary('quiz', item), levelId: item.level?.publicId, plantId: item.plant?.publicId })),
    };
  }

  async item(actor, type, publicId) {
    requireEditor(actor);
    const record = await this.findTarget(type, requireUuid(publicId, 'id'));
    if (!record) throw notFound('EDITOR_ITEM_NOT_FOUND');
    return { type, id: record.publicId, updatedAt: record.updatedAt, published: Boolean(record.publishedAt),
      data: toPayload(type, record) };
  }

  async listChanges(actor) {
    requireEditor(actor);
    const records = await this.entities.findMany(CHANGE_UID, { limit: 500, sort: { updatedAt: 'desc' } });
    return records.filter((item) => actor.roles.some((role) => REVIEW_ROLES.has(role))
      || item.authorSubject === actor.subject).map(mapChange);
  }

  async change(actor, publicId) {
    requireEditor(actor);
    const record = await this.findChange(publicId);
    if (!record || !canSeeChange(actor, record)) throw notFound('EDITOR_CHANGE_NOT_FOUND');
    return mapChange(record);
  }

  async save(actor, input) {
    requireEditor(actor);
    if (!input || typeof input !== 'object' || Array.isArray(input)) throw invalidRequest({ body: 'Ein Objekt ist erforderlich.' });
    const type = input.type;
    typeConfig(type);
    const payload = validatePayload(type, input.data);
    const changeId = input.changeId ? requireUuid(input.changeId, 'changeId') : null;
    if (changeId) {
      const record = await this.findChange(changeId);
      if (!record || record.authorSubject !== actor.subject || !['draft', 'rejected'].includes(record.status)) {
        throw notFound('EDITOR_CHANGE_NOT_EDITABLE');
      }
      if (record.entityType !== type) throw invalidRequest({ type: 'Entwurfstyp darf nicht geändert werden.' });
      const changed = await this.strapi.db.connection('editor_changes')
        .where({ id: record.id })
        .whereIn('status', ['draft', 'rejected'])
        .whereRaw('payload = ?::jsonb', [JSON.stringify(record.payload)])
        .update({ payload: JSON.stringify(payload), payload_hash: null, status: 'draft',
          review_note: null, reviewer_subject: null, reviewed_at: null, updated_at: new Date() });
      if (changed !== 1) throw conflict('EDITOR_CHANGE_STATE_CHANGED', 'Der Entwurf wurde inzwischen geändert. Bitte neu laden.');
      return mapChange(await this.findChange(record.publicId));
    }
    const targetPublicId = input.targetId ? requireUuid(input.targetId, 'targetId') : newId();
    const target = input.targetId ? await this.findTarget(type, targetPublicId) : null;
    if (input.targetId && !target) throw notFound('EDITOR_ITEM_NOT_FOUND');
    const created = await this.entities.create(CHANGE_UID, { data: {
      publicId: newId(), entityType: type, targetPublicId, baseUpdatedAt: target?.updatedAt || null,
      payload, status: 'draft', authorSubject: actor.subject, reviewEvents: [],
    } });
    return mapChange(created);
  }

  async submit(actor, publicId) {
    requireEditor(actor);
    const record = await this.findChange(publicId);
    if (!record || record.authorSubject !== actor.subject || !['draft', 'rejected'].includes(record.status)) {
      throw notFound('EDITOR_CHANGE_NOT_EDITABLE');
    }
    await this.validateReferences(record);
    return this.transition(record, ['draft', 'rejected'], {
      status: 'pending_review', payload_hash: hashPayload(record.payload), review_note: null, reviewer_subject: null, reviewed_at: null,
    }, { action: 'submitted', actor: actor.subject });
  }

  async reject(actor, publicId, note) {
    requireReviewer(actor);
    const record = await this.findChange(publicId);
    if (!record || record.status !== 'pending_review') throw notFound('EDITOR_CHANGE_NOT_PENDING');
    this.assertSubmittedPayload(record);
    if (typeof note !== 'string' || note.trim().length < 3 || note.length > 2000) {
      throw invalidRequest({ note: 'Eine Begründung von 3 bis 2000 Zeichen ist erforderlich.' });
    }
    return this.transition(record, ['pending_review'], {
      status: 'rejected', reviewer_subject: actor.subject, review_note: note.trim(), reviewed_at: new Date(),
    }, { action: 'rejected', actor: actor.subject, note: note.trim() });
  }

  async approve(actor, publicId, note = '') {
    requireReviewer(actor);
    const record = await this.findChange(publicId);
    if (!record || record.status !== 'pending_review') throw notFound('EDITOR_CHANGE_NOT_PENDING');
    this.assertSubmittedPayload(record);
    if (typeof note !== 'string' || note.length > 2000) {
      throw invalidRequest({ note: 'Der optionale Review-Kommentar darf höchstens 2000 Zeichen lang sein.' });
    }
    await this.validateReferences(record);
    // Approval is an editorial decision only; applying it requires a
    // separately validated, atomic content release.
    return this.transition(record, ['pending_review'], {
      status: 'approved', reviewer_subject: actor.subject, review_note: note.trim(), reviewed_at: new Date(),
    }, { action: 'approved', actor: actor.subject, note: note.trim() });
  }

  async transition(record, allowed, patch, event) {
    const at = new Date();
    const history = Array.isArray(record.reviewEvents) ? record.reviewEvents : [];
    const changed = await this.strapi.db.connection('editor_changes')
      .where({ id: record.id })
      .whereIn('status', allowed)
      .whereRaw('payload = ?::jsonb', [JSON.stringify(record.payload)])
      .update({ ...patch, review_events: JSON.stringify([...history, { ...event, at: at.toISOString() }]), updated_at: at });
    if (changed !== 1) {
      throw conflict('EDITOR_CHANGE_STATE_CHANGED', 'Der Änderungsstatus hat sich inzwischen geändert. Bitte neu laden.');
    }
    return mapChange(await this.findChange(record.publicId));
  }

  assertSubmittedPayload(record) {
    if (!record.payloadHash || record.payloadHash !== hashPayload(record.payload)) {
      throw conflict('EDITOR_PAYLOAD_CHANGED', 'Der eingereichte Inhalt hat sich geändert. Bitte erneut einreichen.');
    }
  }

  async validateReferences(record) {
    const type = record.entityType;
    const data = record.payload;
    const competing = await this.strapi.db.connection('editor_changes')
      .where({ entity_type: type, status: 'approved' })
      .whereNull('applied_at')
      .whereNot('id', record.id)
      .andWhere((query) => query.where('target_public_id', record.targetPublicId)
        .orWhereRaw("payload->>'slug' = ?", [data.slug]))
      .first('id');
    if (competing) {
      throw conflict('EDITOR_APPROVED_CONFLICT', 'Für dieses Ziel oder diesen Slug wartet bereits eine freigegebene Änderung auf das Release.');
    }
    const target = await this.findTarget(type, record.targetPublicId);
    if (record.baseUpdatedAt && (!target || new Date(target.updatedAt).getTime() !== new Date(record.baseUpdatedAt).getTime())) {
      throw conflict('EDITOR_BASE_CHANGED', 'Der veröffentlichte Inhalt hat sich seit dem Entwurf geändert. Bitte neu erstellen.');
    }
    if (!record.baseUpdatedAt && target) {
      throw conflict('EDITOR_TARGET_EXISTS', 'Das neue Inhaltsziel existiert bereits. Bitte neu laden.');
    }
    const matches = await this.entities.findMany(typeConfig(type).uid, {
      publicationState: 'preview', filters: { slug: data.slug }, limit: 2,
    });
    if (matches.some((item) => item.publicId !== record.targetPublicId)) {
      throw conflict('EDITOR_SLUG_EXISTS', 'Dieser Slug wird bereits verwendet.');
    }
    const refs = [];
    if (type === 'level') {
      refs.push(['ecosystem', data.ecosystemId]);
      refs.push(...data.plantIds.map((id) => ['plant', id]));
      refs.push(...data.completionRule.requiredQuizIds.map((id) => ['quiz', id]));
      refs.push(...data.completionRule.requiredPlantIds.map((id) => ['plant', id]));
      refs.push(...data.completionRule.requiredLevelIds.map((id) => ['level', id]));
    } else if (type === 'quiz') {
      refs.push(['level', data.levelId], ['plant', data.plantId]);
    }
    for (const [refType, id] of refs) {
      if (!await this.findTarget(refType, id)) {
        throw invalidRequest({ relations: `Referenz ${refType}/${id} ist nicht vorhanden.` });
      }
    }
  }

  async findChange(publicId) {
    const id = requireUuid(publicId, 'changeId');
    const records = await this.entities.findMany(CHANGE_UID, { filters: { publicId: id }, limit: 1 });
    return records[0] || null;
  }

  async findTarget(type, publicId) {
    const { uid } = typeConfig(type);
    const populate = type === 'plant' ? { learningCards: true, media: { populate: { file: true } } }
      : type === 'level' ? { ecosystem: true, plants: true }
      : type === 'quiz' ? { level: true, plant: true } : undefined;
    const records = await this.entities.findMany(uid, {
      filters: { publicId }, publicationState: 'preview', populate, limit: 1,
    });
    return records[0] || null;
  }
}

function summary(type, item) {
  return { id: item.publicId, type, title: item.name || item.title || item.commonName || item.scientificName || item.slug,
    slug: item.slug, published: Boolean(item.publishedAt), reviewStatus: item.reviewStatus || null };
}

function mapChange(record) {
  return { id: record.publicId, type: record.entityType, targetId: record.targetPublicId,
    data: record.payload, status: record.status, author: record.authorSubject,
    reviewer: record.reviewerSubject || null, note: record.reviewNote || '',
    updatedAt: record.updatedAt, reviewedAt: record.reviewedAt || null, appliedAt: record.appliedAt || null,
    reviewEvents: Array.isArray(record.reviewEvents) ? record.reviewEvents : [],
    payloadHash: record.payloadHash || null };
}

function canSeeChange(actor, record) {
  return actor.subject === record.authorSubject || actor.roles.some((role) => REVIEW_ROLES.has(role));
}

function hashPayload(value) {
  const canonical = (item) => {
    if (Array.isArray(item)) return item.map(canonical);
    if (item && typeof item === 'object') {
      return Object.fromEntries(Object.keys(item).sort().map((key) => [key, canonical(item[key])]));
    }
    return item;
  };
  return createHash('sha256').update(JSON.stringify(canonical(value))).digest('hex');
}

function toPayload(type, record) {
  const result = {};
  for (const field of typeConfig(type).fields) {
    if (field === 'ecosystemId') result[field] = record.ecosystem?.publicId || '';
    else if (field === 'plantIds') result[field] = (record.plants || []).map((plant) => plant.publicId);
    else if (field === 'levelId') result[field] = record.level?.publicId || '';
    else if (field === 'plantId') result[field] = record.plant?.publicId || '';
    else if (field === 'learningCards') result[field] = (record.learningCards || []).map((card) => ({
      heading: card.heading, text: card.text, question: card.question,
      correctAnswer: card.correctAnswer, wrongAnswer1: card.wrongAnswer1,
      wrongAnswer2: card.wrongAnswer2, wrongAnswer3: card.wrongAnswer3,
    }));
    else result[field] = record[field] ?? null;
  }
  if (type === 'plant') result.media = (record.media || []).map((media) => ({
    id: media.publicId, title: media.title, altText: media.altText, author: media.author,
    license: media.license, source: media.source, url: media.file?.url,
  }));
  return result;
}

function validatePayload(type, data) {
  const config = typeConfig(type);
  if (!data || typeof data !== 'object' || Array.isArray(data)) throw invalidRequest({ data: 'Ein Objekt ist erforderlich.' });
  const unknown = Object.keys(data).filter((field) => !config.fields.includes(field));
  if (unknown.length) throw invalidRequest(Object.fromEntries(unknown.map((field) => [field, 'Unbekanntes Feld.'])));
  const output = {};
  for (const field of config.fields) output[field] = data[field];
  if (typeof output.slug !== 'string' || !/^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(output.slug)) {
    throw invalidRequest({ slug: 'Ein eindeutiger ASCII-Slug ist erforderlich.' });
  }
  const text = (field, max = 10000, required = false) => {
    const value = output[field];
    if (value == null && !required) { output[field] = ''; return; }
    if (typeof value !== 'string' || (required && !value.trim()) || value.length > max) {
      throw invalidRequest({ [field]: `Text mit höchstens ${max} Zeichen erforderlich.` });
    }
    output[field] = value.trim();
  };
  if (type === 'ecosystem') {
    text('name', 160, true); text('description'); text('climateZone', 120);
    text('region', 120); text('season', 120); text('language', 12);
  } else if (type === 'level') {
    text('title', 200, true); text('difficulty', 80); text('learningGoal');
    if (!Number.isInteger(output.sequence) || output.sequence < 1 || output.sequence > 10000) {
      throw invalidRequest({ sequence: 'Reihenfolge muss eine positive Ganzzahl sein.' });
    }
    requireUuid(output.ecosystemId, 'ecosystemId');
    if (!Array.isArray(output.plantIds) || output.plantIds.length < 1 || output.plantIds.length > 30) {
      throw invalidRequest({ plantIds: 'Mindestens eine Pflanze und höchstens 30 Pflanzen auswählen.' });
    }
    output.plantIds.forEach((id) => requireUuid(id, 'plantIds'));
    const rule = output.completionRule;
    if (!rule || typeof rule !== 'object' || Array.isArray(rule) ||
      typeof rule.minimumScore !== 'number' || rule.minimumScore < 0 || rule.minimumScore > 1 ||
      !Array.isArray(rule.requiredQuizIds) || !Array.isArray(rule.requiredPlantIds) ||
      !Array.isArray(rule.requiredLevelIds) || !['level', 'ecosystem'].includes(rule.collectionScope)) {
      throw invalidRequest({ completionRule: 'Abschlussregel mit Punktzahl und ID-Listen erforderlich.' });
    }
    for (const id of [...rule.requiredQuizIds, ...rule.requiredPlantIds, ...rule.requiredLevelIds]) requireUuid(id, 'completionRule');
  } else if (type === 'plant') {
    text('scientificName', 160, true); text('commonName', 160, true); text('family', 160);
    text('description', 20000, true); text('warning', 10000);
    if (!Array.isArray(output.sources) || output.sources.length === 0 ||
      output.sources.some((source) => typeof source !== 'string' || !/^https:\/\//.test(source))) {
      throw invalidRequest({ sources: 'Mindestens eine HTTPS-Quelle ist erforderlich.' });
    }
    if (!Array.isArray(output.features)) output.features = [];
    try { validateLearningCards(output.learningCards, output.commonName); }
    catch (error) { throw invalidRequest({ learningCards: error.message }); }
  } else if (type === 'quiz') {
    text('title', 200, true); requireUuid(output.levelId, 'levelId'); requireUuid(output.plantId, 'plantId');
    if (!['multiple-choice', 'flashcard', 'identification', 'feature-match'].includes(output.quizType)) {
      throw invalidRequest({ quizType: 'Unbekannter Fragetyp.' });
    }
    const quiz = output.data;
    if (!quiz || typeof quiz !== 'object' || Array.isArray(quiz) || typeof quiz.prompt !== 'string' || !quiz.prompt.trim() ||
      !Array.isArray(quiz.choices) || quiz.choices.length !== 4 ||
      quiz.choices.some((choice) => typeof choice?.id !== 'string' || !choice.id || typeof choice.label !== 'string' || !choice.label.trim()) ||
      new Set(quiz.choices.map((choice) => choice.id)).size !== 4 ||
      new Set(quiz.choices.map((choice) => choice.label.trim().toLocaleLowerCase('de'))).size !== 4 ||
      !quiz.choices.some((choice) => choice.id === quiz.correctChoiceId)) {
      throw invalidRequest({ data: 'Frage, vier Antworten und eine korrekte Antwort sind erforderlich.' });
    }
  }
  return output;
}

module.exports = { EditorService, requireEditor, requireReviewer, validatePayload, TYPES };

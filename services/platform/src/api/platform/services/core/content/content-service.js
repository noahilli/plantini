'use strict';

const { ProblemError, notFound } = require('../errors');
const { requireUuid } = require('../ids');
const { pageFromQuery } = require('../validation');

class ContentService {
  constructor(options) {
    this.repository = options.repository;
  }

  async getManifest(ifNoneMatch) {
    const release = await this.repository.findActiveRelease();
    if (!release) {
      throw new ProblemError('CONTENT_RELEASE_UNAVAILABLE', {
        status: 503,
        title: 'Inhalte vorübergehend nicht verfügbar',
        detail: 'Es ist kein vollständiges veröffentlichtes Inhaltsrelease aktiv.',
      });
    }
    validateManifest(release.manifest);
    const etag = `"${release.version}"`;
    return {
      notModified: normaliseEtag(ifNoneMatch) === release.version,
      etag,
      manifest: release.manifest,
    };
  }

  async listEcosystems(query) {
    const page = pageFromQuery(query);
    const result = await this.repository.listPublishedEcosystems(page);
    return {
      items: result.items.map(mapEcosystem),
      page: {
        page: page.page,
        pageSize: page.pageSize,
        total: result.total,
      },
    };
  }

  async getEcosystem(ecosystemId) {
    requireUuid(ecosystemId, 'ecosystemId');
    const ecosystem = await this.repository.findPublishedEcosystem(ecosystemId);
    if (!ecosystem) throw notFound('ECOSYSTEM_NOT_FOUND');
    return mapEcosystem(ecosystem);
  }

  async getLevel(actor, levelId, accessState) {
    requireUuid(levelId, 'levelId');
    const level = await this.repository.findPublishedLevel(levelId);
    if (!level) throw notFound('LEVEL_NOT_FOUND');
    const state = await accessState(actor, level);
    return mapLevel(level, state);
  }

  async getPlant(plantId) {
    requireUuid(plantId, 'plantId');
    const plant = await this.repository.findPublishedPlant(plantId);
    if (!plant) throw notFound('PLANT_NOT_FOUND');
    return mapPlant(plant);
  }

  async listQuizItems(actor, levelId, contentVersion) {
    requireUuid(levelId, 'levelId');
    const level = await this.repository.findPublishedLevel(levelId);
    if (!level) throw notFound('LEVEL_NOT_FOUND');
    if (contentVersion && level.releaseVersion && contentVersion !== level.releaseVersion) {
      throw new ProblemError('CONTENT_VERSION_UNAVAILABLE', {
        status: 409,
        detail: 'Die angefragte Inhaltsversion ist nicht mehr aktiv.',
      });
    }
    const quizzes = await this.repository.findPublishedQuizItems(levelId);
    return { items: quizzes.map((quiz) => mapQuizItem(quiz, level)) };
  }
}

function mapEcosystem(ecosystem) {
  assertPublicContent(ecosystem, 'Ecosystem');
  return {
    id: ecosystem.publicId,
    slug: ecosystem.slug,
    name: ecosystem.name,
    description: ecosystem.description || '',
    releaseVersion: ecosystem.releaseVersion,
    levelIds: (ecosystem.levels || []).filter(isPublished).map((level) => contentId(level, 'Level')),
  };
}

function mapLevel(level, state = {}) {
  assertPublicContent(level, 'Level');
  const ecosystemId = contentId(level.ecosystem, 'Ecosystem');
  const rule = normaliseCompletionRule(level.completionRule, level.quizzes || []);
  return {
    id: level.publicId,
    ecosystemId,
    title: level.title,
    sequence: Number.isInteger(level.sequence) ? level.sequence : level.levelNumber,
    learningGoal: level.learningGoal || '',
    plantIds: (level.plants || []).filter(isPublished).map((plant) => contentId(plant, 'Plant')),
    completionRule: rule,
    status: state.status || 'available',
    progress: clampProgress(state.progress),
    ...(typeof state.blockedReason === 'string' && state.blockedReason.length > 0
      ? { blockedReason: state.blockedReason }
      : {}),
  };
}

function mapPlant(plant) {
  assertPublicContent(plant, 'Plant');
  return {
    id: plant.publicId,
    scientificName: plant.scientificName,
    commonName: plant.commonName || '',
    family: plant.family || '',
    description: plant.description || '',
    warning: plant.warning || '',
    sources: Array.isArray(plant.sources) ? plant.sources : [],
    media: (plant.media || []).filter(isPublished).map((media) => {
      assertPublicContent(media, 'Media');
      return {
        id: media.publicId,
        url: media.file && media.file.url,
        altText: media.altText,
        license: media.license,
        author: media.author,
      };
    }),
    releaseVersion: plant.releaseVersion,
  };
}

function mapQuizItem(quiz, level) {
  assertPublicContent(quiz, 'QuizItem');
  const data = quiz.data && typeof quiz.data === 'object' ? quiz.data : {};
  const type = normaliseQuizType(data.type || quiz.quizType);
  const prompt = requireStringValue(data.prompt || quiz.title, 'QuizItem prompt');
  return {
    id: quiz.publicId,
    levelId: level.publicId,
    type,
    contentVersion: quiz.contentVersion || level.releaseVersion,
    prompt,
    choices: normaliseChoices(data.choices),
  };
}

function normaliseCompletionRule(rule, quizzes) {
  const source = rule && typeof rule === 'object' ? rule : {};
  const minimumScore = typeof source.minimumScore === 'number' ? source.minimumScore : 1;
  if (minimumScore < 0 || minimumScore > 1) {
    throw contentIntegrityError('Level completionRule.minimumScore must be between 0 and 1.');
  }
  const requiredQuizIds = Array.isArray(source.requiredQuizIds) && source.requiredQuizIds.length > 0
    ? source.requiredQuizIds
    : quizzes.filter(isPublished).map((quiz) => contentId(quiz, 'QuizItem'));
  const requiredPlantIds = Array.isArray(source.requiredPlantIds)
    ? [...new Set(source.requiredPlantIds.filter((id) => typeof id === 'string' && id.length > 0))]
    : [];
  return { minimumScore, requiredQuizIds, requiredPlantIds };
}

function normaliseChoices(value) {
  if (!Array.isArray(value)) return [];
  return value.map((choice) => {
    if (!choice || typeof choice.id !== 'string' || typeof choice.label !== 'string') {
      throw contentIntegrityError('Quiz choices need id and label.');
    }
    return { id: choice.id, label: choice.label };
  });
}

function normaliseQuizType(value) {
  const aliases = {
    'multiple-choice': 'multiple_choice',
    identification: 'image_identification',
    flashcard: 'flashcard',
  };
  const type = aliases[value] || value;
  if (!['multiple_choice', 'flashcard', 'image_identification', 'feature_match'].includes(type)) {
    throw contentIntegrityError('Quiz type is unsupported.');
  }
  return type;
}

function validateManifest(manifest) {
  if (!manifest || typeof manifest !== 'object') {
    throw contentIntegrityError('Content release has no manifest.');
  }
  for (const field of ['version', 'releasedAt', 'schemaVersion', 'minimumAppVersion']) {
    if (typeof manifest[field] !== 'string' || manifest[field].length === 0) {
      throw contentIntegrityError(`Content manifest field ${field} is missing.`);
    }
  }
  if (!Array.isArray(manifest.packages)) {
    throw contentIntegrityError('Content manifest packages are missing.');
  }
  for (const item of manifest.packages) {
    if (!item || typeof item.id !== 'string' || typeof item.url !== 'string'
      || !/^[a-f0-9]{64}$/i.test(item.sha256) || !Number.isInteger(item.bytes) || item.bytes < 0) {
      throw contentIntegrityError('Content manifest contains an invalid package.');
    }
  }
}

function assertPublicContent(record, label) {
  if (!record || !isPublished(record)) {
    throw contentIntegrityError(`${label} is not published.`);
  }
  contentId(record, label);
  if (typeof record.slug !== 'string' || record.slug.length === 0) {
    throw contentIntegrityError(`${label} has no stable slug.`);
  }
  if (typeof record.releaseVersion !== 'string' || record.releaseVersion.length === 0) {
    throw contentIntegrityError(`${label} has no release version.`);
  }
}

function contentId(record, label) {
  if (!record || typeof record.publicId !== 'string') {
    throw contentIntegrityError(`${label} has no stable public id.`);
  }
  try {
    return requireUuid(record.publicId, `${label}.publicId`);
  } catch (_) {
    throw contentIntegrityError(`${label} has an invalid stable public id.`);
  }
}

function isPublished(record) {
  return Boolean(record && record.publishedAt);
}

function requireStringValue(value, label) {
  if (typeof value !== 'string' || value.length === 0) {
    throw contentIntegrityError(`${label} is missing.`);
  }
  return value;
}

function clampProgress(value) {
  return typeof value === 'number' && Number.isFinite(value)
    ? Math.max(0, Math.min(1, value))
    : 0;
}

function normaliseEtag(value) {
  if (typeof value !== 'string') return undefined;
  return value.trim().replace(/^W\//, '').replace(/^"|"$/g, '');
}

function contentIntegrityError(detail) {
  return new ProblemError('CONTENT_INTEGRITY_FAILED', {
    status: 503,
    title: 'Inhalte vorübergehend nicht verfügbar',
    detail,
  });
}

module.exports = {
  ContentService,
  mapEcosystem,
  mapLevel,
  mapPlant,
  mapQuizItem,
  normaliseCompletionRule,
  validateManifest,
};

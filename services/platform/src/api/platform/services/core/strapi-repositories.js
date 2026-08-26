'use strict';

const { createHash } = require('crypto');

/**
 * The Strapi adapter is intentionally the only place that knows numeric
 * Strapi record identifiers.  Application services receive public UUIDs and
 * ownership fields exclusively, which prevents the CMS database ID from
 * becoming an API or sync key.
 */
function createStrapiRepositories(strapi) {
  if (!strapi || !strapi.entityService) {
    throw new Error('A Strapi entityService is required.');
  }
  const entities = strapi.entityService;

  return {
    profiles: {
      findBySubject: async (subject) => findOne(entities, 'api::profile.profile', {
        filters: { keycloakSubject: subject },
      }),
      create: async (draft) => entities.create('api::profile.profile', { data: draft }),
      update: async (profileId, patch) => {
        const profile = await findOne(entities, 'api::profile.profile', {
          filters: { profileId },
        });
        if (!profile) return null;
        return entities.update('api::profile.profile', profile.id, { data: patch });
      },
      findByProfileId: async (profileId) => findOne(entities, 'api::profile.profile', {
        filters: { profileId },
      }),
    },
    content: createContentRepository(entities),
    learning: createLearningRepository(entities),
    field: createFieldRepository(entities),
    herbarium: createHerbariumRepository(entities),
  };
}

function createContentRepository(entities) {
  return {
    findActiveRelease: async () => findOne(entities, 'api::content-release.content-release', {
      filters: { active: true },
      publicationState: 'live',
      sort: { publishedAt: 'desc' },
    }),
    findChangesSince: async (cursor) => {
      const release = await findOne(entities, 'api::content-release.content-release', {
        filters: { active: true },
        publicationState: 'live',
      });
      if (!release) return { cursor: cursor || '', changes: [] };
      return {
        cursor: release.cursor,
        changes: cursor === release.cursor ? [] : normaliseArray(release.changes),
      };
    },
    listPublishedEcosystems: async ({ page, pageSize }) => {
      const ecosystems = normaliseArray(await entities.findMany('api::ecosystem.ecosystem', {
        publicationState: 'live',
        sort: { name: 'asc' },
        populate: {
          levels: {
            filters: { publishedAt: { $notNull: true } },
            fields: ['publicId', 'publishedAt'],
          },
        },
      }));
      const start = (page - 1) * pageSize;
      return { items: ecosystems.slice(start, start + pageSize), total: ecosystems.length };
    },
    findPublishedEcosystem: async (publicId) => findOne(entities, 'api::ecosystem.ecosystem', {
      filters: { publicId },
      publicationState: 'live',
      populate: {
        levels: {
          filters: { publishedAt: { $notNull: true } },
          fields: ['publicId', 'publishedAt'],
        },
      },
    }),
    findPublishedLevel: async (publicId) => findOne(entities, 'api::level.level', {
      filters: { publicId },
      publicationState: 'live',
      populate: {
        ecosystem: { fields: ['publicId', 'slug', 'releaseVersion', 'publishedAt'] },
        plants: { filters: { publishedAt: { $notNull: true } }, fields: ['publicId', 'publishedAt'] },
        quizzes: { filters: { publishedAt: { $notNull: true } }, fields: ['publicId', 'publishedAt'] },
      },
    }),
    findPublishedPlant: async (publicId) => findOne(entities, 'api::plant.plant', {
      filters: { publicId },
      publicationState: 'live',
      populate: {
        media: {
          filters: { publishedAt: { $notNull: true } },
          populate: { file: { fields: ['url'] } },
        },
      },
    }),
    findPublishedQuizItems: async (levelPublicId) => entities.findMany('api::quiz.quiz', {
      publicationState: 'live',
      filters: { level: { publicId: levelPublicId } },
      sort: { publicId: 'asc' },
      populate: { level: { fields: ['publicId', 'releaseVersion', 'publishedAt'] } },
    }),
    listPublishedLevels: async () => entities.findMany('api::level.level', {
      publicationState: 'live',
      sort: { sequence: 'asc' },
      populate: { quizzes: { filters: { publishedAt: { $notNull: true } }, fields: ['publicId', 'publishedAt'] } },
    }),
  };
}

function createLearningRepository(entities) {
  return {
    findAttemptByIdempotencyKey: async (idempotencyKey) => findOne(entities, 'api::level-attempt.level-attempt', {
      filters: { idempotencyKey },
    }),
    findAttemptByClientId: async (ownerId, clientAttemptId) => findOne(entities, 'api::level-attempt.level-attempt', {
      filters: { ownerClientAttemptKey: ownerClientKey(ownerId, clientAttemptId) },
    }),
    findAttemptByPublicId: async (ownerId, publicId) => findOne(entities, 'api::level-attempt.level-attempt', {
      filters: { ownerId, publicId },
    }),
    createAttempt: async (draft) => entities.create('api::level-attempt.level-attempt', {
      data: { ...draft, ownerClientAttemptKey: ownerClientKey(draft.ownerId, draft.clientAttemptId) },
    }),
    updateAttempt: async (recordId, patch) => entities.update('api::level-attempt.level-attempt', recordId, { data: patch }),
    listAttemptsByOwner: async (ownerId) => entities.findMany('api::level-attempt.level-attempt', {
      filters: { ownerId },
      sort: { updatedAt: 'desc' },
    }),
    findEventByIdempotencyKey: async (idempotencyKey) => findOne(entities, 'api::learning-event.learning-event', {
      filters: { idempotencyKey },
    }),
    createEvent: async (draft) => entities.create('api::learning-event.learning-event', { data: draft }),
    ...createContentRepository(entities),
  };
}

function createFieldRepository(entities) {
  return {
    findPrivateMediaByIdempotencyKey: async (idempotencyKey) => findOne(entities, 'api::private-media.private-media', {
      filters: { idempotencyKey },
    }),
    findPrivateMediaByClientId: async (ownerId, clientMediaId) => findOne(entities, 'api::private-media.private-media', {
      filters: { ownerClientMediaKey: ownerClientKey(ownerId, clientMediaId) },
    }),
    findPrivateMediaByPublicId: async (ownerId, publicId) => findOne(entities, 'api::private-media.private-media', {
      filters: { ownerId, publicId },
    }),
    createPrivateMedia: async (draft) => entities.create('api::private-media.private-media', {
      data: { ...draft, ownerClientMediaKey: ownerClientKey(draft.ownerId, draft.clientMediaId) },
    }),
    updatePrivateMedia: async (recordId, patch) => entities.update('api::private-media.private-media', recordId, {
      data: patch,
    }),
    findJobByIdempotencyKey: async (idempotencyKey) => findOne(entities, 'api::identification-job.identification-job', {
      filters: { idempotencyKey },
    }),
    findJobByClientId: async (ownerId, clientJobId) => findOne(entities, 'api::identification-job.identification-job', {
      filters: { ownerClientJobKey: ownerClientKey(ownerId, clientJobId) },
    }),
    findJobByPublicId: async (ownerId, publicId) => findOne(entities, 'api::identification-job.identification-job', {
      filters: { ownerId, publicId },
    }),
    findAnyJobByPublicId: async (publicId) => findOne(entities, 'api::identification-job.identification-job', {
      filters: { publicId },
    }),
    createJob: async (draft) => entities.create('api::identification-job.identification-job', {
      data: { ...draft, ownerClientJobKey: ownerClientKey(draft.ownerId, draft.clientJobId) },
    }),
    updateJob: async (recordId, patch) => entities.update('api::identification-job.identification-job', recordId, { data: patch }),
    findPendingJobs: async (limit = 20) => entities.findMany('api::identification-job.identification-job', {
      filters: { status: 'pending' },
      sort: { createdAt: 'asc' },
      limit,
    }),
  };
}

function createHerbariumRepository(entities) {
  return {
    findObservationByIdempotencyKey: async (idempotencyKey) => findOne(entities, 'api::observation.observation', {
      filters: { idempotencyKey },
    }),
    findObservationByClientId: async (ownerId, clientObservationId) => findOne(entities, 'api::observation.observation', {
      filters: { ownerClientObservationKey: ownerClientKey(ownerId, clientObservationId) },
    }),
    findObservationByPublicId: async (ownerId, publicId) => findOne(entities, 'api::observation.observation', {
      filters: { ownerId, publicId },
    }),
    createObservation: async (draft) => entities.create('api::observation.observation', {
      data: { ...draft, ownerClientObservationKey: ownerClientKey(draft.ownerId, draft.clientObservationId) },
    }),
    updateObservation: async (recordId, patch) => entities.update('api::observation.observation', recordId, { data: patch }),
    listObservations: async (ownerId, { page, pageSize }) => {
      const filters = { ownerId, syncStatus: { $ne: 'deleted' } };
      const observations = normaliseArray(await entities.findMany('api::observation.observation', {
        filters,
        sort: { timestamp: 'desc' },
      }));
      const start = (page - 1) * pageSize;
      return { items: observations.slice(start, start + pageSize), total: observations.length };
    },
  };
}

async function findOne(entities, uid, options) {
  const results = await entities.findMany(uid, { ...options, limit: 1 });
  return normaliseArray(results)[0] || null;
}

function normaliseArray(value) {
  return Array.isArray(value) ? value : value ? [value] : [];
}

function ownerClientKey(ownerId, clientId) {
  return createHash('sha256').update(`${ownerId}\u0000${clientId}`).digest('hex');
}

module.exports = {
  createStrapiRepositories,
  ownerClientKey,
};

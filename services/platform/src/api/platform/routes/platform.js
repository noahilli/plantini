'use strict';

// Strapi adds the /api prefix, yielding the canonical /api/v1 boundary.
// Authentication is resolved by the controller's Keycloak verifier rather
// than Strapi's users-permissions plugin, so every protected route remains
// bound to the same issuer/audience/ownership rules.
const route = (method, path, handler) => ({
  method,
  path,
  handler: `api::platform.platform.${handler}`,
  config: { auth: false },
});

module.exports = {
  routes: [
    route('GET', '/v1/health', 'health'),
    route('GET', '/v1/me', 'getMe'),
    route('PATCH', '/v1/me', 'updateMe'),
    route('GET', '/v1/content/manifest', 'getManifest'),
    route('GET', '/v1/content/changes', 'getContentChanges'),
    route('GET', '/v1/ecosystems', 'listEcosystems'),
    route('GET', '/v1/ecosystems/:ecosystemId', 'getEcosystem'),
    route('GET', '/v1/levels/:levelId', 'getLevel'),
    route('GET', '/v1/plants/:plantId', 'getPlant'),
    route('GET', '/v1/quiz-items', 'listQuizItems'),
    route('POST', '/v1/level-attempts', 'startLevelAttempt'),
    route('POST', '/v1/level-attempts/:attemptId/complete', 'completeLevelAttempt'),
    route('POST', '/v1/learning-events/batch', 'submitLearningEvents'),
    route('GET', '/v1/progress', 'getProgress'),
    route('POST', '/v1/sync', 'synchronize'),
    route('POST', '/v1/media/uploads', 'reserveUpload'),
    route('POST', '/v1/media/uploads/:mediaId/content', 'uploadPrivateMediaContent'),
    route('POST', '/v1/identifications', 'createIdentification'),
    route('GET', '/v1/identifications/:jobId', 'getIdentification'),
    route('POST', '/v1/identifications/:jobId/retry', 'retryIdentification'),
    route('POST', '/v1/identifications/:jobId/confirm', 'confirmIdentification'),
    route('GET', '/v1/observations', 'listObservations'),
    route('POST', '/v1/observations', 'createObservation'),
    route('GET', '/v1/observations/:observationId', 'getObservation'),
    route('PATCH', '/v1/observations/:observationId', 'updateObservation'),
    route('DELETE', '/v1/observations/:observationId', 'deleteObservation'),
  ],
};

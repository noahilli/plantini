'use strict';

/**
 * Error boundary shared by the HTTP adapters and the pure application
 * services.  Error instances intentionally never retain request bodies,
 * bearer tokens, uploads or provider responses.
 */
class ProblemError extends Error {
  constructor(code, options = {}) {
    super(options.detail || options.title || code);
    this.name = 'ProblemError';
    this.code = code;
    this.status = options.status || 400;
    this.title = options.title || defaultTitle(this.status);
    this.detail = options.detail;
    this.fieldErrors = options.fieldErrors;
  }
}

function defaultTitle(status) {
  if (status === 400) return 'Ungültige Anfrage';
  if (status === 401) return 'Nicht authentifiziert';
  if (status === 403) return 'Nicht berechtigt';
  if (status === 404) return 'Nicht gefunden';
  if (status === 409) return 'Konflikt';
  if (status === 412) return 'Vorbedingung nicht erfüllt';
  if (status === 422) return 'Nicht verarbeitbar';
  if (status === 429) return 'Zu viele Anfragen';
  return 'Interner Fehler';
}

function invalidRequest(fieldErrors, detail = 'Ein oder mehrere Felder sind ungültig.') {
  return new ProblemError('VALIDATION_FAILED', {
    status: 400,
    detail,
    fieldErrors,
  });
}

function notFound(code = 'RESOURCE_NOT_FOUND') {
  return new ProblemError(code, {
    status: 404,
    detail: 'Die angefragte Ressource ist für dieses Konto nicht verfügbar.',
  });
}

function conflict(code, detail, fieldErrors) {
  return new ProblemError(code, {
    status: 409,
    detail,
    fieldErrors,
  });
}

function asProblem(error, traceId, instance) {
  const known = error instanceof ProblemError;
  const status = known ? error.status : 500;
  const code = known ? error.code : 'INTERNAL_ERROR';

  const problem = {
    type: `/problems/${code.toLowerCase().replace(/_/g, '-')}`,
    title: known ? error.title : defaultTitle(status),
    status,
    code,
    traceId,
  };

  if (known && error.detail) problem.detail = error.detail;
  if (instance) problem.instance = instance;
  if (known && error.fieldErrors && Object.keys(error.fieldErrors).length > 0) {
    problem.fieldErrors = error.fieldErrors;
  }

  return problem;
}

module.exports = {
  ProblemError,
  invalidRequest,
  notFound,
  conflict,
  asProblem,
};

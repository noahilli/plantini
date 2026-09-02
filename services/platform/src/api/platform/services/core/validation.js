'use strict';

const { invalidRequest } = require('./errors');

function requirePlainObject(value, field = 'body') {
  if (!value || typeof value !== 'object' || Array.isArray(value)) {
    throw invalidRequest({ [field]: 'Muss ein JSON-Objekt sein.' });
  }
  return value;
}

function requireString(value, field, options = {}) {
  const min = options.min === undefined ? 1 : options.min;
  const max = options.max === undefined ? Number.MAX_SAFE_INTEGER : options.max;
  if (typeof value !== 'string' || value.trim().length < min || value.length > max) {
    throw invalidRequest({ [field]: `Muss ein Text mit ${min} bis ${max} Zeichen sein.` });
  }
  return options.trim === false ? value : value.trim();
}

function optionalString(value, field, options = {}) {
  if (value === undefined || value === null) return undefined;
  return requireString(value, field, options);
}

function requireArray(value, field, options = {}) {
  const min = options.min === undefined ? 0 : options.min;
  const max = options.max === undefined ? Number.MAX_SAFE_INTEGER : options.max;
  if (!Array.isArray(value) || value.length < min || value.length > max) {
    throw invalidRequest({ [field]: `Muss eine Liste mit ${min} bis ${max} Einträgen sein.` });
  }
  return value;
}

function requireDate(value, field) {
  const rfc3339 = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d{1,9})?(?:Z|[+-]\d{2}:\d{2})$/;
  if (typeof value !== 'string' || !rfc3339.test(value) || Number.isNaN(Date.parse(value))) {
    throw invalidRequest({ [field]: 'Muss ein RFC-3339-Zeitstempel mit Zeitzone sein.' });
  }
  return new Date(value).toISOString();
}

function optionalDate(value, field) {
  if (value === undefined || value === null || value === '') return undefined;
  return requireDate(value, field);
}

function requireNumber(value, field, options = {}) {
  const min = options.min === undefined ? -Number.MAX_VALUE : options.min;
  const max = options.max === undefined ? Number.MAX_VALUE : options.max;
  if (typeof value !== 'number' || !Number.isFinite(value) || value < min || value > max) {
    throw invalidRequest({ [field]: `Muss eine Zahl zwischen ${min} und ${max} sein.` });
  }
  return value;
}

function requireInteger(value, field, options = {}) {
  const number = requireNumber(value, field, options);
  if (!Number.isInteger(number)) {
    throw invalidRequest({ [field]: 'Muss eine ganze Zahl sein.' });
  }
  return number;
}

function rejectUnknownFields(value, allowed) {
  const unknown = Object.keys(value).filter((key) => !allowed.includes(key));
  if (unknown.length > 0) {
    throw invalidRequest(
      Object.fromEntries(unknown.map((key) => [key, 'Dieses Feld ist nicht im API-Vertrag definiert.']))
    );
  }
}

function pageFromQuery(query = {}) {
  rejectUnknownQuery(query, ['page', 'pageSize']);
  const page = query.page === undefined ? 1 : Number(query.page);
  const pageSize = query.pageSize === undefined ? 50 : Number(query.pageSize);
  if (!Number.isInteger(page) || page < 1 || !Number.isInteger(pageSize) || pageSize < 1 || pageSize > 100) {
    throw invalidRequest({ page: 'page muss mindestens 1 sein.', pageSize: 'pageSize muss zwischen 1 und 100 liegen.' });
  }
  return { page, pageSize };
}

function rejectUnknownQuery(query = {}, allowed = []) {
  const unknown = Object.keys(query).filter((key) => !allowed.includes(key));
  if (unknown.length > 0) {
    throw invalidRequest(
      Object.fromEntries(unknown.map((key) => [key, 'Dieser Filter ist nicht im API-Vertrag definiert.']))
    );
  }
}

function parseIfMatch(value) {
  if (typeof value !== 'string' || value.length === 0 || value.length > 128) {
    throw invalidRequest({ 'If-Match': 'Ein gültiger Versionswert ist erforderlich.' });
  }
  return value.replace(/^W\//, '').replace(/^"|"$/g, '');
}

module.exports = {
  requirePlainObject,
  requireString,
  optionalString,
  requireArray,
  requireDate,
  optionalDate,
  requireNumber,
  requireInteger,
  rejectUnknownFields,
  pageFromQuery,
  rejectUnknownQuery,
  parseIfMatch,
};

'use strict';

const { createHash } = require('crypto');
const { setDefaultResultOrder } = require('dns');
const { readFile } = require('fs/promises');

const REAL_API_BASE_URL = 'https://my-api.plantnet.org';
const MAX_RESULTS = 5;

/**
 * Server-side Pl@ntNet adapter. API keys are deliberately consumed only in
 * this worker; the Flutter client receives normalized candidates, never a
 * provider key or provider URL with credentials.
 *
 * `mock` preserves the deterministic E2E contract. `real` uses the documented
 * v2 multipart API (`images`, `organs`, and `api-key` as a query parameter).
 */
class PlantNetProvider {
  constructor(options = {}) {
    this.mode = providerMode(options.mode || process.env.PLANTNET_MODE || 'mock');
    if (this.mode === 'real') {
      // The deployed environments have no usable IPv6 route. Node resolves
      // IPv4 first here instead of letting real identification requests wait
      // for an unreachable IPv6 address.
      setDefaultResultOrder('ipv4first');
    }
    this.baseUrl = requiredUrl(
      options.baseUrl || process.env.PLANTNET_BASE_URL ||
        (this.mode === 'real' ? REAL_API_BASE_URL : undefined),
    );
    this.apiKey = options.apiKey || process.env.PLANTNET_API_KEY || process.env.API_KEY;
    this.project = requiredProject(options.project || process.env.PLANTNET_PROJECT || 'all');
    this.language = optionalLanguage(options.language || process.env.PLANTNET_LANGUAGE || 'de');
    this.maxResults = boundedInteger(options.maxResults || process.env.PLANTNET_MAX_RESULTS || 3);
    this.privateMediaStore = options.privateMediaStore;
    this.fetch = options.fetch || global.fetch;
    this.FormData = options.FormData || global.FormData;
    this.Blob = options.Blob || global.Blob;
    this.timeoutMs = options.timeoutMs || 12_000;
    if (this.mode === 'real' && !this.apiKey) {
      throw new Error('PLANTNET_API_KEY must be configured when PLANTNET_MODE=real.');
    }
    if (typeof this.fetch !== 'function') {
      throw new Error('A fetch implementation is required for PlantNetProvider.');
    }
  }

  async identify({ job, media }) {
    if (!this.privateMediaStore || !media.storageKey) {
      throw providerError('PROVIDER_UNAVAILABLE', 'The private media is unavailable to the provider.');
    }
    const bytes = await readFile(this.privateMediaStore.resolve(media.storageKey));
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), this.timeoutMs);
    try {
      const response = this.mode === 'real'
        ? await this.identifyReal(media, bytes, controller.signal)
        : await this.identifyMock(job, media, bytes, controller.signal);
      if (response.status === 401 || response.status === 403) {
        throw providerError('PROVIDER_CREDENTIALS_INVALID', 'Plant identification credentials were rejected.');
      }
      if (response.status === 429) {
        throw providerError('PROVIDER_RATE_LIMITED', 'Plant identification is rate limited.', retryAfterMs(response));
      }
      if (response.status >= 500) {
        throw providerError('PROVIDER_UNAVAILABLE', 'Plant identification provider is unavailable.', 5_000);
      }
      if (!response.ok) {
        throw providerError('PROVIDER_REJECTED', 'Plant identification provider rejected the image.');
      }
      return normaliseProviderResponse(await response.json());
    } catch (error) {
      if (error?.name === 'AbortError') {
        throw providerError('PROVIDER_TIMEOUT', 'Plant identification timed out.', 5_000);
      }
      throw error;
    } finally {
      clearTimeout(timeout);
    }
  }

  async identifyMock(job, media, bytes, signal) {
    return this.fetch(new URL('/v1/identify', this.baseUrl), {
      method: 'POST',
      headers: {
        'content-type': media.contentType,
        'content-length': String(bytes.length),
        ...(this.apiKey ? { 'x-api-key': this.apiKey } : {}),
        'x-plantini-expected-plant-id': job.expectedPlantId || '',
      },
      body: bytes,
      signal,
    });
  }

  async identifyReal(media, bytes, signal) {
    if (typeof this.FormData !== 'function' || typeof this.Blob !== 'function') {
      throw new Error('The Node runtime must provide FormData and Blob for real PlantNet requests.');
    }
    const form = new this.FormData();
    form.append(
      'images',
      new this.Blob([bytes], { type: media.contentType }),
      `observation.${extensionFor(media.contentType)}`,
    );
    form.append('organs', 'auto');
    return this.fetch(this.realIdentifyUrl(), {
      method: 'POST',
      body: form,
      signal,
    });
  }

  realIdentifyUrl() {
    const url = new URL(`/v2/identify/${encodeURIComponent(this.project)}`, this.baseUrl);
    url.searchParams.set('api-key', this.apiKey);
    url.searchParams.set('lang', this.language);
    url.searchParams.set('nb-results', String(this.maxResults));
    url.searchParams.set('include-related-images', 'false');
    return url;
  }
}

function normaliseProviderResponse(body) {
  const source = Array.isArray(body?.candidates) ? body.candidates : body?.results;
  if (!Array.isArray(source)) {
    throw providerError('PROVIDER_INVALID_RESPONSE', 'Provider response has no candidate list.');
  }
  return {
    provider: typeof body.provider === 'string' ? body.provider : 'plantnet',
    modelVersion: typeof body.modelVersion === 'string'
      ? body.modelVersion
      : typeof body.version === 'string'
        ? body.version
        : 'unknown',
    floraVersion: typeof body.floraVersion === 'string' ? body.floraVersion : 'unknown',
    candidates: source.map((candidate) => normaliseCandidate(candidate, body)),
  };
}

function normaliseCandidate(candidate, body) {
  const scientificName = candidate?.scientificName || candidate?.species?.scientificNameWithoutAuthor;
  if (typeof scientificName !== 'string' || !scientificName.trim()) {
    throw providerError('PROVIDER_INVALID_RESPONSE', 'Provider candidate has no scientific name.');
  }
  const score = Number(candidate?.score);
  if (!Number.isFinite(score) || score < 0 || score > 1) {
    throw providerError('PROVIDER_INVALID_RESPONSE', 'Provider candidate has an invalid score.');
  }
  const plantId = typeof candidate?.plantId === 'string' ? candidate.plantId : undefined;
  return {
    candidateId: candidateIdFor(candidate, scientificName, plantId),
    scientificName,
    ...(typeof candidate?.commonName === 'string'
      ? { commonName: candidate.commonName }
      : Array.isArray(candidate?.species?.commonNames) && typeof candidate.species.commonNames[0] === 'string'
        ? { commonName: candidate.species.commonNames[0] }
        : {}),
    ...(plantId ? { plantId } : {}),
    score,
    provider: candidate?.provider || body?.provider || 'plantnet',
    modelVersion: candidate?.modelVersion || body?.modelVersion || body?.version || 'unknown',
  };
}

function candidateIdFor(candidate, scientificName, plantId) {
  if (typeof candidate?.candidateId === 'string' && candidate.candidateId.length > 0) {
    return candidate.candidateId;
  }
  if (plantId) return `plantini:${plantId}`;
  const gbifId = candidate?.gbif?.id;
  if (typeof gbifId === 'string' || typeof gbifId === 'number') {
    return `plantnet:gbif:${gbifId}`;
  }
  const taxonHash = createHash('sha256')
    .update(scientificName.trim().toLocaleLowerCase('en-US'))
    .digest('hex')
    .slice(0, 24);
  return `plantnet:taxon:${taxonHash}`;
}

function providerMode(value) {
  if (value === 'mock' || value === 'real') return value;
  throw new Error('PLANTNET_MODE must be mock or real.');
}

function requiredProject(value) {
  if (typeof value !== 'string' || !/^[A-Za-z0-9_-]{1,80}$/.test(value)) {
    throw new Error('PLANTNET_PROJECT must be a valid PlantNet project identifier.');
  }
  return value;
}

function optionalLanguage(value) {
  if (typeof value !== 'string' || !/^[a-z]{2,8}(?:-[A-Za-z]{2,8})?$/.test(value)) {
    throw new Error('PLANTNET_LANGUAGE must be a language tag.');
  }
  return value;
}

function boundedInteger(value) {
  const parsed = Number(value);
  if (!Number.isInteger(parsed) || parsed < 1 || parsed > MAX_RESULTS) {
    throw new Error(`PLANTNET_MAX_RESULTS must be an integer between 1 and ${MAX_RESULTS}.`);
  }
  return parsed;
}

function extensionFor(contentType) {
  if (contentType === 'image/png') return 'png';
  return 'jpg';
}

function retryAfterMs(response) {
  const header = response.headers?.get?.('retry-after');
  const seconds = Number(header);
  if (Number.isFinite(seconds) && seconds > 0) return seconds * 1000;
  const retryAt = typeof header === 'string' ? Date.parse(header) : NaN;
  const now = Date.now();
  if (Number.isFinite(retryAt) && retryAt > now) {
    return retryAt - now;
  }
  return 5_000;
}

function providerError(code, message, retryAfterMs) {
  const error = new Error(message);
  error.code = code;
  if (retryAfterMs) error.retryAfterMs = retryAfterMs;
  return error;
}

function requiredUrl(value) {
  if (!value) throw new Error('PLANTNET_BASE_URL must be configured.');
  const url = new URL(value);
  if (!['http:', 'https:'].includes(url.protocol)) {
    throw new Error('PLANTNET_BASE_URL must use HTTP(S).');
  }
  return url;
}

module.exports = {
  PlantNetProvider,
  candidateIdFor,
  normaliseProviderResponse,
  providerError,
  retryAfterMs,
};

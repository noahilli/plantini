'use strict';

const { readFile } = require('fs/promises');

/**
 * Provider adapter. The PlantNet key is used only here, never in the Flutter
 * app. The development mock follows the same bounded request/response shape.
 */
class PlantNetProvider {
  constructor(options = {}) {
    this.baseUrl = requiredUrl(options.baseUrl || process.env.PLANTNET_BASE_URL);
    this.apiKey = options.apiKey || process.env.PLANTNET_API_KEY;
    this.privateMediaStore = options.privateMediaStore;
    this.fetch = options.fetch || global.fetch;
    this.timeoutMs = options.timeoutMs || 12_000;
  }

  async identify({ job, media }) {
    if (!this.privateMediaStore || !media.storageKey) {
      throw providerError('PROVIDER_UNAVAILABLE', 'The private media is unavailable to the provider.');
    }
    const bytes = await readFile(this.privateMediaStore.resolve(media.storageKey));
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), this.timeoutMs);
    try {
      const response = await this.fetch(new URL('/v1/identify', this.baseUrl), {
        method: 'POST',
        headers: {
          'content-type': media.contentType,
          'content-length': String(bytes.length),
          ...(this.apiKey ? { 'x-api-key': this.apiKey } : {}),
          'x-plantini-expected-plant-id': job.expectedPlantId || '',
        },
        body: bytes,
        signal: controller.signal,
      });
      if (response.status === 429) {
        throw providerError('PROVIDER_RATE_LIMITED', 'Plant identification is rate limited.', retryAfterMs(response));
      }
      if (response.status >= 500) {
        throw providerError('PROVIDER_UNAVAILABLE', 'Plant identification provider is unavailable.', 5_000);
      }
      if (!response.ok) {
        throw providerError('PROVIDER_REJECTED', 'Plant identification provider rejected the image.');
      }
      const body = await response.json();
      return normaliseProviderResponse(body);
    } catch (error) {
      if (error?.name === 'AbortError') {
        throw providerError('PROVIDER_TIMEOUT', 'Plant identification timed out.', 5_000);
      }
      throw error;
    } finally {
      clearTimeout(timeout);
    }
  }
}

function normaliseProviderResponse(body) {
  const source = Array.isArray(body?.candidates) ? body.candidates : body?.results;
  if (!Array.isArray(source)) throw providerError('PROVIDER_INVALID_RESPONSE', 'Provider response has no candidate list.');
  return {
    provider: typeof body.provider === 'string' ? body.provider : 'plantnet',
    modelVersion: typeof body.modelVersion === 'string' ? body.modelVersion : 'mock-v1',
    floraVersion: typeof body.floraVersion === 'string' ? body.floraVersion : 'unknown',
    candidates: source.map((candidate) => ({
      scientificName: candidate.scientificName || candidate.species?.scientificNameWithoutAuthor,
      commonName: candidate.commonName || candidate.species?.commonNames?.[0],
      plantId: candidate.plantId,
      score: candidate.score,
      provider: candidate.provider || body.provider || 'plantnet',
      modelVersion: candidate.modelVersion || body.modelVersion || 'mock-v1',
    })),
  };
}

function retryAfterMs(response) {
  const header = response.headers?.get?.('retry-after');
  const seconds = Number(header);
  return Number.isFinite(seconds) && seconds > 0 ? seconds * 1000 : 5_000;
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
  if (!['http:', 'https:'].includes(url.protocol)) throw new Error('PLANTNET_BASE_URL must use HTTP(S).');
  return url;
}

module.exports = {
  PlantNetProvider,
  normaliseProviderResponse,
  providerError,
};

'use strict';

const assert = require('node:assert/strict');
const { mkdtemp, rm, writeFile } = require('node:fs/promises');
const { tmpdir } = require('node:os');
const { join } = require('node:path');
const test = require('node:test');

const {
  PlantNetProvider,
  retryAfterMs,
} = require('../src/api/platform/services/core/field/plantnet-provider');

test('real PlantNet mode sends a v2 multipart request and normalises an external candidate', async (t) => {
  const directory = await mkdtemp(join(tmpdir(), 'plantini-plantnet-'));
  const imagePath = join(directory, 'observation.jpg');
  const image = Buffer.from([0xff, 0xd8, 0xff, 0xe0, 0x00, 0x10]);
  await writeFile(imagePath, image);
  t.after(() => rm(directory, { recursive: true, force: true }));

  let request;
  const provider = new PlantNetProvider({
    mode: 'real',
    apiKey: 'test-key-only',
    privateMediaStore: {
      resolve(storageKey) {
        assert.equal(storageKey, 'private-observation.jpg');
        return imagePath;
      },
    },
    fetch: async (url, options) => {
      request = { url, options };
      return {
        ok: true,
        status: 200,
        async json() {
          return {
            version: 'plantnet-model-test',
            results: [{
              score: 0.98,
              species: {
                scientificNameWithoutAuthor: 'Bellis perennis',
                commonNames: ['Gaensebluemchen'],
              },
              gbif: { id: '2927079' },
            }],
          };
        },
      };
    },
  });

  const result = await provider.identify({
    job: { id: 'job-not-sent-to-real-provider' },
    media: {
      storageKey: 'private-observation.jpg',
      contentType: 'image/jpeg',
    },
  });

  assert.ok(request);
  assert.equal(request.url.protocol, 'https:');
  assert.equal(request.url.hostname, 'my-api.plantnet.org');
  assert.equal(request.url.pathname, '/v2/identify/all');
  assert.equal(request.url.searchParams.get('api-key'), 'test-key-only');
  assert.equal(request.url.searchParams.get('lang'), 'de');
  assert.equal(request.url.searchParams.get('nb-results'), '3');
  assert.equal(request.url.searchParams.get('include-related-images'), 'false');
  assert.equal(request.options.method, 'POST');
  assert.ok(request.options.body instanceof FormData);
  assert.equal(request.options.body.get('organs'), 'auto');
  const submittedImage = request.options.body.get('images');
  assert.ok(submittedImage instanceof Blob);
  assert.equal(submittedImage.type, 'image/jpeg');
  assert.equal(submittedImage.name, 'observation.jpg');
  assert.deepEqual(Buffer.from(await submittedImage.arrayBuffer()), image);

  assert.equal(result.provider, 'plantnet');
  assert.equal(result.modelVersion, 'plantnet-model-test');
  assert.deepEqual(result.candidates, [{
    candidateId: 'plantnet:gbif:2927079',
    scientificName: 'Bellis perennis',
    commonName: 'Gaensebluemchen',
    score: 0.98,
    provider: 'plantnet',
    modelVersion: 'plantnet-model-test',
  }]);
  assert.equal(Object.hasOwn(result.candidates[0], 'plantId'), false);
});

test('PlantNet Retry-After HTTP dates defer the next provider attempt', () => {
  const retryAt = new Date(Date.now() + 60_000).toUTCString();
  const delay = retryAfterMs({
    headers: { get: (name) => name === 'retry-after' ? retryAt : null },
  });

  assert.ok(delay >= 58_000);
  assert.ok(delay <= 60_000);
});

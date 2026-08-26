import { createServer } from 'node:http';

const port = Number(process.env.PORT ?? 1080);
const defaultPlantId = process.env.PLANTNET_MOCK_DEFAULT_PLANT_ID;
const mode = process.env.PLANTNET_MOCK_MODE ?? 'success';

if (!defaultPlantId) {
  throw new Error('PLANTNET_MOCK_DEFAULT_PLANT_ID must be configured.');
}

const server = createServer(async (request, response) => {
  if (request.method === 'GET' && request.url === '/health') {
    return send(response, 200, { status: 'ok' });
  }
  if (request.method !== 'POST' || request.url !== '/v1/identify') {
    return send(response, 404, { error: 'not_found' });
  }

  let bytes = 0;
  for await (const chunk of request) {
    bytes += chunk.length;
    if (bytes > 20 * 1024 * 1024) {
      request.destroy();
      return send(response, 413, { error: 'payload_too_large' });
    }
  }
  if (bytes === 0) return send(response, 400, { error: 'empty_image' });
  if (mode === 'rate_limited') {
    response.setHeader('Retry-After', '1');
    return send(response, 429, { error: 'rate_limited' });
  }
  if (mode === 'unavailable') return send(response, 503, { error: 'unavailable' });
  if (mode !== 'success') return send(response, 422, { error: 'rejected' });

  const expectedPlantId = request.headers['x-plantini-expected-plant-id'];
  const plantId = typeof expectedPlantId === 'string' && expectedPlantId.length > 0
    ? expectedPlantId
    : defaultPlantId;
  return send(response, 200, {
    provider: 'plantnet-mock',
    modelVersion: 'e2e-v1',
    floraVersion: 'synthetic-2026.08',
    candidates: [
      {
        plantId,
        scientificName: 'Quercus robur',
        commonName: 'Stieleiche',
        score: 0.97,
      },
      {
        scientificName: 'Fagus sylvatica',
        commonName: 'Rotbuche',
        score: 0.03,
      },
    ],
  });
});

server.listen(port, '0.0.0.0', () => {
  console.log(`PlantNet E2E mock listening on ${port}`);
});

function send(response, status, body) {
  response.writeHead(status, { 'content-type': 'application/json; charset=utf-8' });
  response.end(JSON.stringify(body));
}

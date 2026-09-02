import { expect, test } from '@playwright/test';

import { appendPath, requireE2EEnvironment } from '../support/environment';

interface Manifest {
  version: string;
  releasedAt: string;
  schemaVersion: string;
  minimumAppVersion: string;
}

interface Ecosystem {
  id: string;
  slug: string;
  releaseVersion: string;
  levelIds: string[];
}

test.describe('CMS published release contract', () => {
  test('seeds one immutable German release with three complete learning worlds', async ({ request }) => {
    const environment = requireE2EEnvironment();
    const [manifestResponse, ecosystemsResponse] = await Promise.all([
      request.get(appendPath(environment.apiUrl, '/content/manifest')),
      request.get(appendPath(environment.apiUrl, '/ecosystems?page=1&pageSize=10')),
    ]);

    expect(manifestResponse.status()).toBe(200);
    expect(ecosystemsResponse.status()).toBe(200);
    const manifest = await manifestResponse.json() as Manifest;
    const ecosystemPage = await ecosystemsResponse.json() as {
      items: Ecosystem[];
      page: { page: number; pageSize: number; total: number };
    };

    expect(manifest).toEqual(expect.objectContaining({
      version: expect.any(String),
      releasedAt: expect.any(String),
      schemaVersion: '1.0',
      minimumAppVersion: '1.0.0',
    }));
    expect(Number.isNaN(Date.parse(manifest.releasedAt))).toBe(false);
    expect(ecosystemPage.page).toEqual({ page: 1, pageSize: 10, total: 3 });
    expect(ecosystemPage.items.map((item) => item.slug).sort()).toEqual([
      'alpenraum',
      'artenreiche-wiese',
      'mitteleuropaeischer-laubwald',
    ]);

    const allLevelIds = ecosystemPage.items.flatMap((item) => item.levelIds);
    expect(ecosystemPage.items.every((item) => item.releaseVersion === manifest.version)).toBe(true);
    expect(ecosystemPage.items.every((item) => item.levelIds.length === 3)).toBe(true);
    expect(new Set(allLevelIds).size).toBe(9);
  });

  test('does not expose unknown or unpublished ecosystem identifiers', async ({ request }) => {
    const environment = requireE2EEnvironment();
    const response = await request.get(
      appendPath(environment.apiUrl, '/ecosystems/00000000-0000-4000-8000-000000000000'),
    );

    expect(response.status()).toBe(404);
    expect(response.headers()['content-type']).toContain('application/problem+json');
    expect(response.headers()['x-api-version']).toBe('v1');
    const problem = await response.json() as { traceId: string; status: number };
    expect(problem.status).toBe(404);
    expect(problem.traceId).toBe(response.headers()['x-correlation-id']);
  });

  test('rejects undocumented list filters instead of silently widening scope', async ({ request }) => {
    const environment = requireE2EEnvironment();
    const response = await request.get(
      appendPath(environment.apiUrl, '/ecosystems?organisationId=foreign-scope'),
    );

    expect(response.status()).toBe(400);
    expect(response.headers()['content-type']).toContain('application/problem+json');
    expect(await response.json()).toEqual(expect.objectContaining({
      code: 'VALIDATION_FAILED',
      fieldErrors: { organisationId: expect.any(String) },
    }));
  });
});

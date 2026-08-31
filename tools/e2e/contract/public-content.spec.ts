import { expect, test } from '@playwright/test';

import { appendPath, requireE2EEnvironment } from '../support/environment';

interface Ecosystem {
  id: string;
  slug: string;
  name: string;
  releaseVersion: string;
  levelIds: string[];
}

interface EcosystemPage {
  items: Ecosystem[];
  page: {
    page: number;
    pageSize: number;
    total: number;
  };
}

test.describe('published content API contract', () => {
  test('exposes the same published ecosystem detail that drives the web journey', async ({ request }) => {
    const environment = requireE2EEnvironment();
    const list = await request.get(appendPath(environment.apiUrl, '/ecosystems?page=1&pageSize=10'));

    expect(list.status()).toBe(200);
    const body = await list.json() as EcosystemPage;
    expect(body.page).toEqual({ page: 1, pageSize: 10, total: expect.any(Number) });
    expect(body.items).not.toHaveLength(0);

    const ecosystem = body.items.at(0);
    expect(ecosystem).toBeDefined();
    if (!ecosystem) throw new Error('The ecosystem response had no first item.');
    expect(ecosystem).toEqual(expect.objectContaining({
      id: expect.any(String),
      slug: expect.any(String),
      name: expect.any(String),
      releaseVersion: expect.any(String),
      levelIds: expect.any(Array),
    }));
    expect(ecosystem.levelIds).not.toHaveLength(0);

    const detail = await request.get(appendPath(environment.apiUrl, `/ecosystems/${ecosystem.id}`));
    expect(detail.status()).toBe(200);
    expect(await detail.json()).toEqual(ecosystem);
  });
});

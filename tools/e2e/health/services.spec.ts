import { expect, test } from '@playwright/test';

import { appendPath, requireE2EEnvironment } from '../support/environment';

test.describe('isolated E2E stack health', () => {
  test('serves the web shell, platform API, and OIDC discovery through IPv4 endpoints', async ({ request }) => {
    const environment = requireE2EEnvironment();

    const [web, platform, oidc] = await Promise.all([
      request.get(appendPath(environment.appUrl, '/healthz')),
      request.get(environment.readinessUrl, {
        headers: { 'X-Correlation-Id': 'e2e-health-contract-001' },
      }),
      request.get(appendPath(environment.oidcIssuerUrl, '/.well-known/openid-configuration')),
    ]);

    expect(web.status()).toBe(200);
    expect(await web.text()).toBe('ok');

    expect(platform.status()).toBe(200);
    expect(platform.headers()['x-api-version']).toBe('v1');
    expect(platform.headers()['x-correlation-id']).toBe('e2e-health-contract-001');
    expect(await platform.json()).toEqual({ status: 'ok', apiVersion: 'v1' });

    expect(oidc.status()).toBe(200);
    expect(await oidc.json()).toEqual(
      expect.objectContaining({
        issuer: environment.oidcIssuerUrl,
        authorization_endpoint: expect.any(String),
        token_endpoint: expect.any(String),
      }),
    );
  });
});

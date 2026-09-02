import { expect, test } from '@playwright/test';

import { appendPath, requireE2EEnvironment } from '../support/environment';

test.describe('Keycloak realm security contract', () => {
  test('publishes the expected OIDC endpoints and rejects the password grant', async ({ request }) => {
    const environment = requireE2EEnvironment();
    const discoveryResponse = await request.get(
      appendPath(environment.oidcIssuerUrl, '/.well-known/openid-configuration'),
    );

    expect(discoveryResponse.status()).toBe(200);
    const discovery = await discoveryResponse.json() as Record<string, unknown>;
    expect(discovery).toEqual(expect.objectContaining({
      issuer: environment.oidcIssuerUrl,
      authorization_endpoint: expect.any(String),
      token_endpoint: expect.any(String),
      jwks_uri: expect.any(String),
      code_challenge_methods_supported: expect.arrayContaining(['S256']),
    }));

    for (const key of ['authorization_endpoint', 'token_endpoint', 'jwks_uri']) {
      const endpoint = new URL(String(discovery[key]));
      expect(endpoint.hostname).toBe(new URL(environment.oidcIssuerUrl).hostname);
      expect(endpoint.username).toBe('');
      expect(endpoint.password).toBe('');
    }

    const passwordGrant = await request.post(String(discovery.token_endpoint), {
      form: {
        client_id: 'plantini-web-dev',
        grant_type: 'password',
        username: environment.username,
        password: environment.password,
      },
    });
    expect(passwordGrant.status()).toBe(400);
    expect(await passwordGrant.json()).toEqual(expect.objectContaining({
      error: 'unauthorized_client',
    }));
  });
});

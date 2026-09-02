import { randomUUID } from 'node:crypto';

import { expect, type APIRequestContext, type Page } from '@playwright/test';

import type { E2EEnvironment } from './environment';
import { appUi, enableFlutterWebSemantics } from './ui';

/** Creates a fresh learner so a rerun never inherits completed levels. */
export async function provisionIsolatedLearner(
  request: APIRequestContext,
  environment: E2EEnvironment,
  purpose: string,
): Promise<E2EEnvironment> {
  const suffix = randomUUID();
  const username = `e2e-${purpose}-${suffix}@plantini.test`;
  const password = `Aa1!${randomUUID()}${randomUUID()}`;
  const keycloakOrigin = new URL(environment.oidcIssuerUrl).origin;
  const tokenResponse = await request.post(
    `${keycloakOrigin}/realms/master/protocol/openid-connect/token`,
    {
      form: {
        client_id: 'admin-cli',
        grant_type: 'password',
        username: environment.keycloakAdminUsername,
        password: environment.keycloakAdminPassword,
      },
    },
  );
  expect(tokenResponse.status()).toBe(200);
  const { access_token: accessToken } = await tokenResponse.json() as { access_token?: string };
  expect(accessToken).toEqual(expect.any(String));

  const createResponse = await request.post(`${keycloakOrigin}/admin/realms/plantini/users`, {
    headers: { Authorization: `Bearer ${accessToken}` },
    data: {
      username,
      email: username,
      firstName: 'E2E',
      lastName: 'Journey',
      enabled: true,
      emailVerified: true,
      requiredActions: [],
    },
  });
  expect(createResponse.status()).toBe(201);
  const location = createResponse.headers().location;
  expect(location).toEqual(expect.any(String));
  const userId = location?.split('/').at(-1);
  expect(userId).toEqual(expect.any(String));

  const passwordResponse = await request.put(
    `${keycloakOrigin}/admin/realms/plantini/users/${userId}/reset-password`,
    {
      headers: { Authorization: `Bearer ${accessToken}` },
      data: { type: 'password', value: password, temporary: false },
    },
  );
  expect(passwordResponse.status()).toBe(204);

  return { ...environment, username, password };
}

/** Signs in through the real browser-facing Keycloak Authorization Code + PKCE flow. */
export async function signInAsE2ELearner(
  page: Page,
  environment: E2EEnvironment,
  options: { requireCredentials?: boolean } = {},
): Promise<void> {
  const appOrigin = new URL(environment.appUrl).origin;
  const issuerOrigin = new URL(environment.oidcIssuerUrl).origin;

  await page.goto(environment.appUrl, { waitUntil: 'domcontentloaded' });
  await enableFlutterWebSemantics(page);
  await expect(appUi.loginButton(page)).toBeVisible();

  // Register the wait before clicking: WebAuthPlatformHelper changes the top
  // level browser location, rather than opening a popup.
  // An existing Keycloak SSO session can redirect through the issuer too
  // quickly for Playwright to observe that intermediate document.
  const reachesAuthorizationTarget = page.waitForURL(
    (url) =>
      url.origin === issuerOrigin ||
      (url.origin === appOrigin && url.pathname === '/auth/callback'),
    { waitUntil: 'domcontentloaded' },
  );
  await appUi.loginButton(page).click();
  await reachesAuthorizationTarget;

  const username = page.locator('#username');
  const flow = await Promise.any([
    username.waitFor({ state: 'visible' }).then(() => 'credentials' as const),
    page
      .waitForURL((url) => url.origin === appOrigin, {
        waitUntil: 'domcontentloaded',
      })
      .then(() => 'existing-sso-session' as const),
  ]);

  if (options.requireCredentials) {
    expect(
      flow,
      'Global logout must end the Keycloak SSO session and require credentials again.',
    ).toBe('credentials');
  }

  if (flow === 'credentials') {
    await username.fill(environment.username);
    await page.locator('#password').fill(environment.password);
    const returnsToApp = page.waitForURL(
      (url) => url.origin === appOrigin,
      { waitUntil: 'domcontentloaded' },
    );
    await page.locator('#kc-login').click();
    await returnsToApp;
  }

  // The app persists the credential on /auth/callback and then performs a
  // same-origin replacement to remove the one-time authorization code. Wait
  // for that second navigation before touching Flutter semantics.
  await page.waitForURL(
    (url) =>
      url.origin === appOrigin &&
      !url.searchParams.has('code') &&
      url.pathname !== '/auth/callback',
    { waitUntil: 'domcontentloaded' },
  );

  await enableFlutterWebSemantics(page);
  await expect(appUi.ecosystemsTitle(page)).toBeVisible();
}

/**
 * Verifies that Plantini visibly clears its local credential. Callers can then
 * require a fresh credential form to prove that Keycloak SSO was ended too.
 */
export async function signOutFromPlantini(page: Page): Promise<void> {
  await appUi.profileNavigation(page).click();
  await expect(appUi.profileRoute(page)).toBeVisible();
  await appUi.logoutButton(page).click();
  await page.waitForLoadState('domcontentloaded');
  await enableFlutterWebSemantics(page);
  await expect(appUi.loginButton(page)).toBeVisible();
}

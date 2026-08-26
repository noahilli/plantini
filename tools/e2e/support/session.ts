import type { Page } from '@playwright/test';

import type { E2EEnvironment } from './environment';

/** Signs in through the real browser-facing Keycloak Authorization Code flow. */
export async function signInAsE2ELearner(page: Page, environment: E2EEnvironment): Promise<void> {
  await page.goto(environment.appUrl);
  await page.getByRole('button', { name: 'Anmelden' }).click();
  await page.locator('#username').fill(environment.username);
  await page.locator('#password').fill(environment.password);
  await page.locator('#kc-login').click();
  await page.waitForURL(`${environment.appUrl}/**`);
}

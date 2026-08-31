import { expect, test } from '@playwright/test';

import { requireE2EEnvironment } from '../support/environment';
import { signInAsE2ELearner } from '../support/session';
import { appUi, enableFlutterWebSemantics } from '../support/ui';

test('persists the learner session across a clean hard reload', async ({ page }) => {
  const environment = requireE2EEnvironment();
  page.on('console', (message) => {
    const text = message.text();
    if (/^(AuthService|SecureCredentialStore|WebAuthPlatformHelper)/.test(text)) {
      console.warn(`[browser-auth] ${text}`);
    }
  });

  await signInAsE2ELearner(page, environment);
  const callback = new URL(page.url());
  expect(callback.searchParams.has('code')).toBe(false);

  await page.reload({ waitUntil: 'domcontentloaded' });
  await enableFlutterWebSemantics(page);
  await expect(appUi.ecosystemsTitle(page)).toBeVisible();
});

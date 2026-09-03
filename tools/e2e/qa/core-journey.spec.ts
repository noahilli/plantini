import { expect, test } from '@playwright/test';

import { requireE2EEnvironment } from '../support/environment';
import {
  provisionIsolatedLearner,
  signInAsE2ELearner,
  signOutFromPlantini,
} from '../support/session';
import { appUi, enableFlutterWebSemantics, seededJourney } from '../support/ui';

const e2eLeafImage = Buffer.from(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M/wHwAF/gL+f9WYAAAAAElFTkSuQmCC',
  'base64',
);

test.describe('Plantini Web: echte Lernenden-Kernreise', () => {
  test('Keycloak-Login → veröffentlichter Inhalt → Quiz → Feld → Herbarium → Re-Login', async ({ page, request }) => {
    test.setTimeout(120_000);
    const environment = await provisionIsolatedLearner(
      request,
      requireE2EEnvironment(),
      'core',
    );
    page.on('console', (message) => {
      const text = message.text();
      if (/^(AuthService|SecureCredentialStore|WebAuthPlatformHelper)/.test(text)) {
        console.warn(`[browser-auth] ${text}`);
      }
    });

    await test.step('Lernende:r meldet sich über Keycloak an', async () => {
      await signInAsE2ELearner(page, environment, { requireCredentials: true });
      await expect(appUi.ecosystem(page)).toBeVisible();
    });

    await test.step('veröffentlichtes Ökosystem und Level werden aus dem Stack geladen', async () => {
      await appUi.ecosystem(page).click();
      await expect(appUi.levelsTitle(page)).toBeVisible();
      await expect(appUi.levelCard(page)).toBeVisible();

      await appUi.levelCard(page).click();
      await expect(appUi.learningUnitTitle(page)).toBeVisible();
      for (const plantName of seededJourney.collectionTargets) {
        await expect(page.getByText(plantName, { exact: true })).toBeVisible();
      }
      await expect(page.getByText(/Zielpflanze \d/)).toHaveCount(0);
    });

    await test.step('Lernende:r sammelt alle drei Zielpflanzen im Herbarium', async () => {
      for (let target = 1; target <= 3; target += 1) {
        await appUi.startExpeditionButton(page).click();
        await expect(appUi.fieldTitle(page)).toBeVisible();
        await expect(appUi.emptyPhotoState(page)).toBeVisible();
        const fileChooser = page.waitForEvent('filechooser');
        await appUi.chooseFromGalleryButton(page).click();
        await (await fileChooser).setFiles({
          name: `e2e-leaf-${target}.png`,
          mimeType: 'image/png',
          buffer: e2eLeafImage,
        });
        await expect(appUi.identifyPlantButton(page)).toBeEnabled();
        await appUi.identifyPlantButton(page).click();
        await expect(appUi.identificationProcessing(page)).toBeVisible();
        await expect.poll(async () => {
          const refresh = appUi.refreshIdentificationButton(page);
          if (await refresh.isVisible().catch(() => false)) await refresh.click();
          return appUi.identificationReady(page).isVisible().catch(() => false);
        }, {
          intervals: [100, 250, 500, 1_000],
          timeout: 15_000,
        }).toBe(true);
        await appUi.candidate(page, 'Stieleiche').click();
        await appUi.saveObservationButton(page).click();
        await expect(appUi.herbariumTitle(page)).toBeVisible();

        await appUi.learningNavigation(page).click();
        await expect(appUi.ecosystemsTitle(page)).toBeVisible();
        await appUi.ecosystem(page).click();
        await appUi.levelCard(page).click();
        await expect(appUi.learningUnitTitle(page)).toBeVisible();
      }
      await expect(appUi.startQuizButton(page)).toBeEnabled();
    });

    await test.step('Lernende:r beantwortet das servergestützte Quiz und schließt das Level ab', async () => {
      await appUi.startQuizButton(page).click();
      await expect(appUi.quizTitle(page)).toBeVisible();
      await expect(appUi.quizQuestion(page, seededJourney.quiz[0][0])).toBeVisible();
      for (let index = 0; index < seededJourney.quiz.length; index += 1) {
        let visibleQuestion: (typeof seededJourney.quiz)[number] | undefined;
        for (const candidate of seededJourney.quiz) {
          if (await appUi.quizQuestion(page, candidate[0]).isVisible().catch(() => false)) {
            visibleQuestion = candidate;
            break;
          }
        }
        expect(visibleQuestion, `Quizfrage ${index + 1} gehört zur veröffentlichten Freigabe`).toBeDefined();
        await appUi.quizAnswer(page, visibleQuestion![1]).click();
        if (index < seededJourney.quiz.length - 1) {
          await expect(appUi.quizQuestion(page, visibleQuestion![0])).toBeHidden();
        }
      }
      await expect(appUi.completeLevelButton(page)).toBeEnabled();
      await appUi.completeLevelButton(page).click();
      await expect(appUi.completedLevel(page)).toBeVisible();
    });

    await test.step('Sammelfortschritt bleibt nach einem Browser-Neustart erhalten', async () => {
      const beforeReload = new URL(page.url());
      expect(
        beforeReload.searchParams.has('code'),
        'The consumed OIDC authorization code must be removed before a reload.',
      ).toBe(false);
      await page.reload({ waitUntil: 'domcontentloaded' });
      await enableFlutterWebSemantics(page);
      await expect(appUi.ecosystemsTitle(page)).toBeVisible();
      await appUi.herbariumNavigation(page).click();
      await expect(appUi.herbariumTitle(page)).toBeVisible();
      await expect(appUi.herbariumEntry(page, 'Stieleiche')).toBeVisible();
    });

    await test.step('lokaler Logout wird sichtbar und eine erneute OIDC-Anmeldung funktioniert', async () => {
      await signOutFromPlantini(page);
      await signInAsE2ELearner(page, environment, { requireCredentials: true });
      await expect(appUi.ecosystem(page)).toBeVisible();
    });
  });
});

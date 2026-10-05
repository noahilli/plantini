import { expect, test, type Locator, type Page } from '@playwright/test';

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

async function scrollToControl(page: Page, control: Locator): Promise<void> {
  // Flutter lazily exposes ListView children in the semantics DOM. Native DOM
  // scrollIntoView cannot reveal a control that has not been rendered yet.
  const viewport = page.viewportSize()!;
  await page.mouse.move(viewport.width / 2, viewport.height / 2);
  await expect.poll(async () => {
    if (await control.isVisible()) return true;
    await page.mouse.wheel(0, 480);
    return false;
  }, { intervals: [200, 300], timeout: 10_000 }).toBe(true);
  await expect(control).toBeVisible();
}

async function expectSavedObservation(page: Page): Promise<void> {
  await expect(appUi.herbariumTitle(page)).toBeVisible();
  const observations = appUi.herbariumObservationsView(page);
  if (!await observations.isChecked()) await observations.click();
  await expect(observations).toBeChecked();
  await expect(appUi.herbariumEntry(page, 'Stieleiche')).toBeVisible();
}

test.describe('Plantini Web: echte Lernenden-Kernreise', () => {
  test('Keycloak-Login → veröffentlichter Inhalt → Quiz → Feld → Herbarium → Re-Login', async ({ page, request }) => {
    test.setTimeout(180_000);
    page.setDefaultTimeout(15_000);
    const environment = await provisionIsolatedLearner(
      request,
      requireE2EEnvironment(),
      'core',
    );

    await test.step('Lernende:r meldet sich über Keycloak an', async () => {
      await signInAsE2ELearner(page, environment, { requireCredentials: true });
      await expect(appUi.ecosystemsTitle(page)).toBeVisible();
    });

    await test.step('veröffentlichtes Ökosystem und Level werden aus dem Stack geladen', async () => {
      await scrollToControl(page, appUi.ecosystem(page));
      await appUi.ecosystem(page).click();
      await expect(appUi.levelsTitle(page)).toBeVisible();
      await expect(appUi.levelCard(page)).toBeVisible();
      // The map's Flutter semantics pan surface overlaps these DOM targets.
      // Send real pointer clicks at their visible bounds; verify both outcomes.
      await appUi.pauseLearningMapButton(page).click({ force: true });
      await expect(appUi.resumeLearningMapButton(page)).toBeVisible();
      await appUi.levelCard(page).click({ force: true });
      await expect(appUi.learningUnitTitle(page)).toBeVisible();
      await expect(appUi.levelTitle(page)).toBeVisible();
      await expect(appUi.startQuizButton(page)).toBeEnabled();
    });

    await test.step('Steckbrief → drei servergestützte Fragen → Levelstern', async () => {
      await appUi.startQuizButton(page).click();
      await expect(appUi.quizTitle(page)).toBeVisible();
      await expect(page.getByText('Rotbuche', { exact: true }).first()).toBeVisible();
      await scrollToControl(page, appUi.startQuestionsButton(page));
      await appUi.startQuestionsButton(page).click();
      const answeredQuestions = new Set<string>();
      for (let index = 0; index < seededJourney.quiz.length; index += 1) {
        let visibleQuestion: (typeof seededJourney.quiz)[number] | undefined;
        // The server can shuffle the three published questions.
        await expect.poll(async () => {
          visibleQuestion = undefined;
          for (const candidate of seededJourney.quiz) {
            if (await appUi.quizQuestion(page, candidate[0]).isVisible()) {
              visibleQuestion = candidate;
              break;
            }
          }
          return visibleQuestion !== undefined;
        }).toBe(true);
        expect(visibleQuestion, `Quizfrage ${index + 1} gehört zur veröffentlichten Freigabe`).toBeDefined();
        expect(answeredQuestions.has(visibleQuestion![0]), 'Jede der drei Fragen wird genau einmal beantwortet').toBe(false);
        answeredQuestions.add(visibleQuestion![0]);
        await appUi.quizAnswer(page, visibleQuestion![1]).click();
        if (index < seededJourney.quiz.length - 1) {
          await appUi.nextQuizQuestionButton(page).click();
          await expect(appUi.quizQuestion(page, visibleQuestion![0])).toBeHidden();
        }
      }
      await expect(appUi.completeLevelButton(page)).toBeEnabled();
      await appUi.completeLevelButton(page).click();
      await expect(appUi.completedLevel(page)).toBeVisible();
    });

    await test.step('Foto → PlantNet-Mock → bestätigter Herbariumeintrag', async () => {
      await appUi.fieldNavigation(page).click();
      await expect(appUi.fieldTitle(page)).toBeVisible();
      await expect(appUi.emptyPhotoState(page)).toBeVisible();
      const fileChooser = page.waitForEvent('filechooser');
      await appUi.chooseFromGalleryButton(page).click();
      await (await fileChooser).setFiles({
        name: 'e2e-leaf.png',
        mimeType: 'image/png',
        buffer: e2eLeafImage,
      });
      await expect(appUi.identifyPlantButton(page)).toBeEnabled();
      await appUi.identifyPlantButton(page).click();
      await expect.poll(async () => {
        const refresh = appUi.refreshIdentificationButton(page);
        if (await refresh.isVisible().catch(() => false)) await refresh.click();
        return appUi.identificationReady(page).isVisible().catch(() => false);
      }, { intervals: [100, 250, 500, 1_000], timeout: 15_000 }).toBe(true);
      await appUi.candidate(page, 'Stieleiche').click();
      await appUi.saveObservationButton(page).click();
      await expectSavedObservation(page);
    });

    await test.step('Sammelfortschritt bleibt nach einem Reload erhalten', async () => {
      const beforeReload = new URL(page.url());
      expect(
        beforeReload.searchParams.has('code'),
        'The consumed OIDC authorization code must be removed before a reload.',
      ).toBe(false);
      await page.reload({ waitUntil: 'domcontentloaded' });
      await enableFlutterWebSemantics(page);
      await appUi.herbariumNavigation(page).click();
      await expectSavedObservation(page);
    });

    await test.step('lokaler Logout wird sichtbar und eine erneute OIDC-Anmeldung funktioniert', async () => {
      await signOutFromPlantini(page);
      await signInAsE2ELearner(page, environment, { requireCredentials: true });
      await expect(appUi.ecosystemsTitle(page)).toBeVisible();
      await appUi.herbariumNavigation(page).click();
      await expectSavedObservation(page);
    });
  });
});

import { test, expect } from '@playwright/test';

test.describe('Walking Skeleton: Plantini Core Journey', () => {
  test('Login -> Ökosystem -> Level -> Neustart/Offline -> Verifizierung', async ({ page, context }) => {
    // 1. Login
    // Note: Assuming we have a test user and Keycloak is configured.
    // In a real scenario, this would use a robust login helper or seed the user via API.
    await test.step('Login über Keycloak', async () => {
      await page.goto('/');
      
      // Click login button in Flutter app shell
      const loginButton = page.getByRole('button', { name: /einloggen|login/i });
      await loginButton.waitFor({ state: 'visible' });
      await loginButton.click();

      // We expect to be redirected to Keycloak
      await expect(page).toHaveURL(/.*keycloak.*/);
      
      // Fill Keycloak login form
      await page.getByLabel(/username|benutzername/i).fill('test_learner');
      await page.getByLabel(/password|passwort/i).fill('test_password');
      await page.getByRole('button', { name: /sign in|anmelden/i }).click();

      // Redirect back to app
      await expect(page).toHaveURL(/.*ecosystems.*/, { timeout: 15000 });
    });

    // 2. Ökosystem auswählen
    await test.step('Ökosystem auswählen', async () => {
      const waldEcosystem = page.getByRole('button', { name: /wald/i });
      await waldEcosystem.waitFor({ state: 'visible' });
      await waldEcosystem.click();
      
      // Verify we are in the ecosystem view
      await expect(page.getByRole('heading', { name: /wald ökosystem/i })).toBeVisible();
    });

    // 3. Level starten
    await test.step('Level starten', async () => {
      const levelOne = page.getByRole('button', { name: /level 1/i });
      await levelOne.click();
      
      // Verify level is active (e.g. quiz or list of plants is shown)
      await expect(page.getByRole('heading', { name: /level 1/i })).toBeVisible();
      
      // Wait for data to load and cache to populate
      await page.waitForTimeout(2000); // Wait for Isar/IndexedDB write, replace with explicit await on network/storage later
    });

    // 4. Neustart/Offline
    await test.step('App neustarten und in Offline-Modus wechseln', async () => {
      // Simulate going offline
      await context.setOffline(true);
      
      // Reload page to simulate app restart while offline
      await page.reload();
      
      // Give app time to boot and detect offline state
      await expect(page.getByText(/offline/i)).toBeVisible({ timeout: 10000 });
    });

    // 5. Verifizierung, dass Daten gecacht sind
    await test.step('Gecachte Level-Daten überprüfen', async () => {
      // Navigate to ecosystems or verify we are still in the level / ecosystem
      // Since it's a reload, Flutter router might preserve state or go to home. Let's assume home.
      
      // Verify that previously loaded ecosystem is accessible
      const waldEcosystem = page.getByRole('button', { name: /wald/i });
      await expect(waldEcosystem).toBeVisible();
      await waldEcosystem.click();
      
      // Verify that level 1 is still accessible and shows data
      const levelOne = page.getByRole('button', { name: /level 1/i });
      await levelOne.click();
      
      // Data should be there despite being offline
      await expect(page.getByRole('heading', { name: /level 1/i })).toBeVisible();
      
      // Check for a specific plant or element that indicates data was fetched and cached
      const plantItem = page.getByTestId('plant-item');
      await expect(plantItem.first()).toBeVisible();
    });
  });
});

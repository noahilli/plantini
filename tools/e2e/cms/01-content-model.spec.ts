import { test, expect } from '@playwright/test';

test.describe('Strapi CMS Configuration', () => {
  test.beforeEach(async ({ page }) => {
    // Navigate to Strapi Admin and login
    await page.goto('/admin');
    
    // Check if we need to register first
    try {
      await expect(page.locator('text=Create the first administrator')).toBeVisible({ timeout: 5000 });
      await page.fill('input[name="firstname"]', 'Admin');
      await page.fill('input[name="lastname"]', 'Plantini');
      await page.fill('input[name="email"]', 'admin@plantini.local');
      await page.fill('input[name="password"]', 'Admin123!');
      await page.fill('input[name="confirmPassword"]', 'Admin123!');
      await page.click('button:has-text("Let\'s start")');
    } catch {
      // Already registered, just login
      await page.fill('input[name="email"]', 'admin@plantini.local');
      await page.fill('input[name="password"]', 'Admin123!');
      await page.click('button[type="submit"]');
    }
    
    await expect(page.locator('text=Welcome')).toBeVisible({ timeout: 15000 });
  });

  test('creates Ecosystem content type', async ({ page }) => {
    // Navigate to Content-Type Builder
    await page.click('text=Content-Type Builder');
    
    // Create new collection type
    await page.click('text=Create new collection type');
    await page.fill('input[name="displayName"]', 'Ecosystem');
    await page.click('button:has-text("Continue")');

    // Add fields
    // Name (Text)
    await page.click('button:has-text("Text")');
    await page.fill('input[name="name"]', 'name');
    await page.click('button:has-text("Finish")');
    
    // Save Content Type
    await page.click('button:has-text("Save")');
    await expect(page.locator('text=Restarting')).toBeVisible();
    await expect(page.locator('text=Restarting')).toBeHidden({ timeout: 15000 });
  });

  test('creates Level content type', async ({ page }) => {
    await page.click('text=Content-Type Builder');
    
    await page.click('text=Create new collection type');
    await page.fill('input[name="displayName"]', 'Level');
    await page.click('button:has-text("Continue")');

    // Add fields
    // Title (Text)
    await page.click('button:has-text("Text")');
    await page.fill('input[name="name"]', 'title');
    await page.click('button:has-text("Add another field")');

    // Number (Integer)
    await page.click('button:has-text("Number")');
    await page.fill('input[name="name"]', 'levelNumber');
    await page.click('label:has-text("integer")');
    await page.click('button:has-text("Add another field")');

    // Relation to Ecosystem
    await page.click('button:has-text("Relation")');
    // Configure relation (Level belongs to Ecosystem)
    // Detailed configuration would follow here
    
    await page.click('button:has-text("Finish")');
    
    // Save
    await page.click('button:has-text("Save")');
    await expect(page.locator('text=Restarting')).toBeVisible();
    await expect(page.locator('text=Restarting')).toBeHidden({ timeout: 15000 });
  });
});

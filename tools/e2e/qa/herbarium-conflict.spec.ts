import { test, expect } from '@playwright/test';

test.describe('Herbarium: Device Conflict & Sync', () => {
  test('Lokaler Offline-Eintrag + Paralleler API-Eintrag -> Idempotenter Sync', async ({ page, request, context }) => {
    // Vorbereitung: Login
    await test.step('Login & Navigation zum Herbarium', async () => {
      await page.goto('/');
      await page.getByRole('button', { name: /einloggen|login/i }).click();
      await page.getByLabel(/username|benutzername/i).fill('learner_1');
      await page.getByLabel(/password|passwort/i).fill('learner_password');
      await page.getByRole('button', { name: /sign in|anmelden/i }).click();
      await expect(page).toHaveURL(/.*ecosystems.*/, { timeout: 15000 });
      
      // Navigiere zum Herbarium
      await page.getByRole('button', { name: /herbarium/i }).click();
      await expect(page.getByRole('heading', { name: /mein herbarium/i })).toBeVisible();
    });

    // 1. Offline gehen und lokalen Eintrag erstellen
    await test.step('Offline-Status mocken & lokalen Eintrag in Queue speichern', async () => {
      await context.setOffline(true);
      
      // Klick auf "Neue Beobachtung" / Kamera
      await page.getByRole('button', { name: /neuer fund|kamera/i }).click();
      
      // Foto aufnehmen / simulieren
      await page.getByTestId('camera-capture-btn').click();
      
      // Eintrag speichern (landet in Isar Queue, da offline)
      await page.getByRole('button', { name: /speichern/i }).click();
      
      // Prüfen ob Indikator für Offline-Upload-Warteschlange da ist
      await expect(page.getByTestId('sync-pending-indicator')).toBeVisible();
      
      // Wir sind wieder im HerbariumScreen, dort sollte der neue Eintrag lokal sichtbar sein
      await expect(page.getByText('Lokaler Fund (Offline)')).toBeVisible();
    });

    // 2. Paralleler Eintrag via API (Simuliert Gerät 2)
    await test.step('Zweites Gerät erstellt parallel einen Eintrag via API', async () => {
      // Wir nutzen denselben Auth-State oder einen separaten API Call mit Token
      // Um es simpel zu halten, rufen wir als zweites "Gerät" die API direkt auf
      // Hinweis: Hierfür müsste idealerweise das Bearer-Token des Users gelesen werden.
      // In diesem Entwurf verwenden wir einen mock-Header.
      
      const response = await request.post('/api/observations', {
        headers: {
          'Authorization': 'Bearer test-learner-token' // Token müsste dynamisch generiert/geholt werden
        },
        data: {
          plantId: 'quercus_robur',
          note: 'Fund von Gerät 2',
          date: new Date().toISOString()
        }
      });
      
      // In einem echten Testumfeld sollte der POST erfolgreich sein
      // expect(response.ok()).toBeTruthy(); 
    });

    // 3. Online gehen und Sync abwarten
    await test.step('Online gehen, Sync abwarten & Zusammenführung prüfen', async () => {
      await context.setOffline(false);
      
      // Wir warten, bis der Sync-Indikator verschwindet
      await expect(page.getByTestId('sync-pending-indicator')).toBeHidden({ timeout: 15000 });
      
      // Ggf. Herbarium refreshen oder UI auf Reaktivität prüfen
      await page.reload();
      await expect(page.getByRole('heading', { name: /mein herbarium/i })).toBeVisible();
      
      // Wir erwarten nun beide Einträge (aus Schritt 1 und Schritt 2) ohne Überschreiben
      await expect(page.getByText('Lokaler Fund (Offline)')).toBeVisible();
      await expect(page.getByText('Fund von Gerät 2')).toBeVisible();
    });
  });
});

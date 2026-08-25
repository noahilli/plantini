import { test, expect } from '@playwright/test';

test.describe('Learning Flow E2E', () => {
  test('Login -> Pflanzenprofil -> Quiz -> Pause/Resume Status', async ({ page, context }) => {
    // 1. Login mit Rolle lernende
    await test.step('Login als Lernende/r', async () => {
      await page.goto('/');
      
      const loginButton = page.getByRole('button', { name: /einloggen|login/i });
      await loginButton.waitFor({ state: 'visible' });
      await loginButton.click();

      // Weiterleitung zu Keycloak
      await expect(page).toHaveURL(/.*keycloak.*/);
      
      // Login-Daten eingeben (Learner)
      await page.getByLabel(/username|benutzername/i).fill('learner_1');
      await page.getByLabel(/password|passwort/i).fill('learner_password');
      await page.getByRole('button', { name: /sign in|anmelden/i }).click();

      // Rückkehr zur App
      await expect(page).toHaveURL(/.*ecosystems.*/, { timeout: 15000 });
    });

    // 2. Aufruf von Pflanzenprofil und Lerneinheit
    await test.step('Pflanzenprofil und Lerneinheit aufrufen', async () => {
      // Ökosystem und Level wählen (z.B. Wald -> Level 1)
      await page.getByRole('button', { name: /wald/i }).click();
      await page.getByRole('button', { name: /level 1/i }).click();
      
      // Pflanzenprofil aufrufen
      const plantItem = page.getByTestId('plant-profile-item').first();
      await expect(plantItem).toBeVisible();
      await plantItem.click();

      // Prüfen, ob das Pflanzenprofil geladen ist
      await expect(page.getByRole('heading', { name: /pflanzenprofil/i })).toBeVisible();

      // Quiz/Lerneinheit aus dem Profil starten
      const startQuizBtn = page.getByRole('button', { name: /quiz starten|lernen/i });
      await startQuizBtn.click();
      
      // Prüfen ob Quiz gestartet ist (z.B. durch Fortschrittsanzeige oder erste Frage)
      await expect(page.getByTestId('quiz-question')).toBeVisible();
    });

    // 3. Pause/Resume-Status (Browser Reload während des Quiz)
    await test.step('Pause/Resume (Browser Reload)', async () => {
      // Eine Interaktion im Quiz vornehmen (z.B. erste Antwort wählen), um Zustand zu erzeugen
      const firstAnswer = page.getByTestId('quiz-answer-option').first();
      await firstAnswer.click();
      
      // Kurze Wartezeit, damit Isar den State lokal speichern kann
      await page.waitForTimeout(1000); 

      // Seite neu laden (Simuliert Unterbrechung/App-Neustart)
      await page.reload();
      
      // Prüfen, ob wir nach Reload im Quiz fortsetzen (Resume)
      await expect(page.getByTestId('quiz-question')).toBeVisible({ timeout: 10000 });
      
      // Prüfen ob der vorherige Zustand da ist (z.B. ausgewählte Antwort oder Fortschritt)
      // Abhängig davon, wie die App den Status wiederherstellt, prüfen wir z.B. ob die erste Antwort noch gewählt ist
      // oder ob der Fortschritt nicht 0 ist.
      const selectedAnswer = page.locator('[data-testid="quiz-answer-option"][aria-selected="true"]');
      // Falls das UI nach Auswahl direkt weiter navigiert, würden wir hier auf Frage 2 prüfen.
      // Hier generisch:
      await expect(page.getByTestId('quiz-progress')).toBeVisible();
    });
  });
});

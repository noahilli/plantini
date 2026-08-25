import { test, expect, request } from '@playwright/test';
const seedData = {
  "ecosystems": [
    {
      "name": "Mitteleuropäischer Laubwald",
      "description": "Typischer Laubmischwald mit Buche und Eiche als Leitbaumarten.",
      "climateZone": "Temperate",
      "levels": [
        {
          "title": "Bäume des Waldes",
          "levelNumber": 1,
          "difficulty": "beginner",
          "plants": ["Rotbuche", "Stieleiche", "Hainbuche"]
        },
        {
          "title": "Frühblüher",
          "levelNumber": 2,
          "difficulty": "intermediate",
          "plants": ["Buschwindröschen", "Lerchensporn", "Scharbockskraut"]
        }
      ]
    },
    {
      "name": "Alpenraum",
      "description": "Gebirgsökosystem oberhalb der Waldgrenze.",
      "climateZone": "Alpine",
      "levels": [
        {
          "title": "Alpenblumen für Einsteiger",
          "levelNumber": 1,
          "difficulty": "beginner",
          "plants": ["Alpenrose", "Enzian", "Edelweiß"]
        }
      ]
    }
  ]
};

test.describe('Strapi CMS Seeding', () => {
  let apiContext;
  let jwtToken = '';

  test.beforeAll(async () => {
    apiContext = await request.newContext({
      baseURL: process.env.PLATFORM_URL || 'http://localhost:1337',
    });

    // Authenticate to get JWT token
    const loginResponse = await apiContext.post('/admin/login', {
      data: {
        email: 'admin@plantini.local',
        password: 'Admin123!',
      }
    });
    const loginData = await loginResponse.json();
    jwtToken = loginData.data.token;
  });

  test('Seeds ecosystems and levels', async () => {
    for (const eco of seedData.ecosystems) {
      // Create Ecosystem
      const ecoResponse = await apiContext.post('/api/ecosystems', {
        headers: {
          Authorization: `Bearer ${jwtToken}`
        },
        data: {
          data: {
            name: eco.name,
            description: eco.description,
            climateZone: eco.climateZone
          }
        }
      });
      expect(ecoResponse.ok()).toBeTruthy();
      const createdEco = await ecoResponse.json();

      // Create Levels for Ecosystem
      for (const level of eco.levels) {
        const levelResponse = await apiContext.post('/api/levels', {
          headers: {
            Authorization: `Bearer ${jwtToken}`
          },
          data: {
            data: {
              title: level.title,
              levelNumber: level.levelNumber,
              difficulty: level.difficulty,
              ecosystem: createdEco.data.id
            }
          }
        });
        expect(levelResponse.ok()).toBeTruthy();
      }
    }
  });
});

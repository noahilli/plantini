import { test, expect } from '@playwright/test';

test('Configure Keycloak Roles and SMTP for Invitations', async ({ request }) => {
  const KEYCLOAK_URL = process.env.KEYCLOAK_URL || 'http://localhost:8082';
  const KEYCLOAK_ADMIN = process.env.KEYCLOAK_ADMIN || 'admin';
  const KEYCLOAK_ADMIN_PASSWORD = process.env.KEYCLOAK_ADMIN_PASSWORD || 'admin';

  // 1. Get Admin Token
  const tokenResponse = await request.post(`${KEYCLOAK_URL}/realms/master/protocol/openid-connect/token`, {
    form: {
      client_id: 'admin-cli',
      username: KEYCLOAK_ADMIN,
      password: KEYCLOAK_ADMIN_PASSWORD,
      grant_type: 'password',
    },
  });
  expect(tokenResponse.ok()).toBeTruthy();
  const tokenData = await tokenResponse.json();
  const adminToken = tokenData.access_token;

  // 2. Create Roles
  const roles = [
    'lernende',
    'lehrende',
    'inhaltsredaktion',
    'botanisches_review',
    'organisationsadministration',
    'systemadministration'
  ];

  for (const role of roles) {
    const roleRes = await request.post(`${KEYCLOAK_URL}/admin/realms/plantini/roles`, {
      headers: { Authorization: `Bearer ${adminToken}` },
      data: {
        name: role,
        description: `Rolle: ${role}`
      },
    });
    // Ignore 409 Conflict if role already exists
    if (roleRes.status() !== 409) {
      expect(roleRes.ok()).toBeTruthy();
    }
  }

  // 3. Configure Realm SMTP for invitations
  // Fetch existing realm config to update it
  const realmGetRes = await request.get(`${KEYCLOAK_URL}/admin/realms/plantini`, {
    headers: { Authorization: `Bearer ${adminToken}` }
  });
  expect(realmGetRes.ok()).toBeTruthy();
  const realmConfig = await realmGetRes.json();

  realmConfig.smtpServer = {
    host: 'mailpit',
    port: '1025',
    from: 'noreply@plantini.local',
    fromDisplayName: 'Plantini Auth'
  };

  const realmUpdateRes = await request.put(`${KEYCLOAK_URL}/admin/realms/plantini`, {
    headers: { Authorization: `Bearer ${adminToken}` },
    data: realmConfig
  });
  expect(realmUpdateRes.ok()).toBeTruthy();
});

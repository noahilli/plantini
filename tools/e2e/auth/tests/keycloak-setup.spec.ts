import { test, expect } from '@playwright/test';

test('Configure Keycloak Realm, Client, and Users via API', async ({ request }) => {
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

  // 2. Create Realm
  const realmResponse = await request.post(`${KEYCLOAK_URL}/admin/realms`, {
    headers: { Authorization: `Bearer ${adminToken}` },
    data: {
      id: 'plantini',
      realm: 'plantini',
      enabled: true,
      registrationAllowed: true,
      loginWithEmailAllowed: true,
      duplicateEmailsAllowed: false,
      resetPasswordAllowed: true,
      editUsernameAllowed: false,
    },
  });
  // 409 means it already exists
  if (realmResponse.status() !== 409) {
    expect(realmResponse.ok()).toBeTruthy();
  }

  // 3. Create Client 'plantini-flutter'
  const clientResponse = await request.post(`${KEYCLOAK_URL}/admin/realms/plantini/clients`, {
    headers: { Authorization: `Bearer ${adminToken}` },
    data: {
      clientId: 'plantini-flutter',
      enabled: true,
      clientAuthenticatorType: 'client-secret',
      redirectUris: ['*'], // In dev
      webOrigins: ['*'],
      publicClient: true,
      standardFlowEnabled: true,
      implicitFlowEnabled: false,
      directAccessGrantsEnabled: true,
    },
  });
  if (clientResponse.status() !== 409) {
    expect(clientResponse.ok()).toBeTruthy();
  }

  // 4. Create test user
  const userResponse = await request.post(`${KEYCLOAK_URL}/admin/realms/plantini/users`, {
    headers: { Authorization: `Bearer ${adminToken}` },
    data: {
      username: 'learner1',
      enabled: true,
      email: 'learner1@example.com',
      firstName: 'Learner',
      lastName: 'One',
      credentials: [{ type: 'password', value: 'password', temporary: false }],
    },
  });
  if (userResponse.status() !== 409) {
    expect(userResponse.ok()).toBeTruthy();
  }
});

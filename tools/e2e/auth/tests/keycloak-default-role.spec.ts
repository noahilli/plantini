import { test, expect } from '@playwright/test';

test('Configure default role to lernende', async ({ request }) => {
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

  // 2. Get default_roles role for the realm
  const defaultRolesRes = await request.get(`${KEYCLOAK_URL}/admin/realms/plantini/roles/default-roles-plantini`, {
    headers: { Authorization: `Bearer ${adminToken}` }
  });
  expect(defaultRolesRes.ok()).toBeTruthy();
  const defaultRolesData = await defaultRolesRes.json();
  
  // 3. Get the "lernende" role
  const lernendeRes = await request.get(`${KEYCLOAK_URL}/admin/realms/plantini/roles/lernende`, {
    headers: { Authorization: `Bearer ${adminToken}` }
  });
  expect(lernendeRes.ok()).toBeTruthy();
  const lernendeRole = await lernendeRes.json();
  
  // 4. Add "lernende" to default-roles-plantini composite role
  const addDefaultRoleRes = await request.post(`${KEYCLOAK_URL}/admin/realms/plantini/roles/default-roles-plantini/composites`, {
    headers: { Authorization: `Bearer ${adminToken}` },
    data: [lernendeRole]
  });
  
  // Ignore 409 or similar if already added, but usually returns 204 No Content
  // 204 or 409
});

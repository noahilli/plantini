'use strict';

const { ProblemError, invalidRequest } = require('../errors');
const { requireEditor } = require('./editor-service');

class KeycloakInvitations {
  constructor(options = {}) {
    this.base = options.base || process.env.PLATFORM_KEYCLOAK_ADMIN_BASE_URL || 'http://keycloak:8080';
    this.clientId = options.clientId || process.env.PLATFORM_KEYCLOAK_ADMIN_CLIENT_ID;
    this.clientSecret = options.clientSecret || process.env.PLATFORM_KEYCLOAK_ADMIN_CLIENT_SECRET;
    this.editorOrigin = options.editorOrigin || process.env.PLATFORM_EDITOR_ORIGIN;
    this.editorClientId = options.editorClientId || process.env.PLATFORM_EDITOR_OIDC_CLIENT_ID || 'plantini-editor-production';
    this.fetch = options.fetch || global.fetch;
  }

  async invite(actor, input) {
    requireEditor(actor);
    const email = typeof input?.email === 'string' ? input.email.trim().toLowerCase() : '';
    const role = input?.role || 'inhaltsredaktion';
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email) || email.length > 254) {
      throw invalidRequest({ email: 'Eine gültige E-Mail-Adresse ist erforderlich.' });
    }
    if (!['inhaltsredaktion', 'botanisches_review'].includes(role)) {
      throw invalidRequest({ role: 'Diese Rolle kann nicht eingeladen werden.' });
    }
    if (role === 'botanisches_review' && !actor.roles.includes('systemadministration')) {
      throw new ProblemError('EDITOR_INVITE_FORBIDDEN', {
        status: 403, detail: 'Nur die Systemadministration darf Reviewer einladen.',
      });
    }
    if (!this.clientId || !this.clientSecret || !this.editorOrigin) {
      throw new ProblemError('EDITOR_INVITES_UNAVAILABLE', {
        status: 503, detail: 'Der Keycloak-Einladungsdienst ist nicht konfiguriert.',
      });
    }

    const tokenResponse = await this.request('/realms/plantini/protocol/openid-connect/token', {
      method: 'POST', body: new URLSearchParams({
        grant_type: 'client_credentials', client_id: this.clientId, client_secret: this.clientSecret,
      }),
    });
    if (!tokenResponse.ok) throw unavailable();
    const token = (await tokenResponse.json()).access_token;
    if (!token) throw unavailable();
    const auth = { Authorization: `Bearer ${token}` };
    const roleResponse = await this.request(`/admin/realms/plantini/roles/${role}`, { headers: auth });
    if (!roleResponse.ok) throw unavailable();
    const roleInfo = await roleResponse.json();

    const create = await this.request('/admin/realms/plantini/users', {
      method: 'POST', headers: { ...auth, 'Content-Type': 'application/json' },
      body: JSON.stringify({
        username: email, email, enabled: true, emailVerified: false,
        requiredActions: ['VERIFY_EMAIL', 'UPDATE_PASSWORD'],
      }),
    });
    if (create.status === 409) {
      throw new ProblemError('EDITOR_INVITEE_EXISTS', { status: 409, detail: 'Für diese E-Mail-Adresse besteht bereits ein Keycloak-Konto.' });
    }
    if (create.status !== 201) throw unavailable();
    const userId = create.headers.get('location')?.split('/').pop();
    if (!userId || !/^[0-9a-f-]{36}$/i.test(userId)) throw unavailable();

    const mapping = await this.request(`/admin/realms/plantini/users/${userId}/role-mappings/realm`, {
      method: 'POST', headers: { ...auth, 'Content-Type': 'application/json' },
      body: JSON.stringify([{ id: roleInfo.id, name: roleInfo.name }]),
    });
    if (!mapping.ok) throw unavailable('Das Konto wurde angelegt, die Rolle konnte aber nicht zugewiesen werden.');
    const actionsUrl = new URL(`${this.base}/admin/realms/plantini/users/${userId}/execute-actions-email`);
    actionsUrl.search = new URLSearchParams({
      client_id: this.editorClientId, redirect_uri: `${this.editorOrigin.replace(/\/$/, '')}/`,
    }).toString();
    const invite = await this.request(actionsUrl, {
      method: 'PUT', headers: { ...auth, 'Content-Type': 'application/json' },
      body: JSON.stringify(['VERIFY_EMAIL', 'UPDATE_PASSWORD']),
    });
    if (!invite.ok) throw unavailable('Rolle zugewiesen, aber die Einladungs-E-Mail konnte nicht versendet werden.');
    return { email, role, status: 'invited' };
  }

  async request(path, options) {
    const url = path instanceof URL ? path : new URL(path, this.base);
    try { return await this.fetch(url, { ...options, signal: AbortSignal.timeout(10000) }); }
    catch { throw unavailable(); }
  }
}

function unavailable(detail = 'Der Keycloak-Einladungsdienst ist momentan nicht erreichbar.') {
  return new ProblemError('EDITOR_INVITES_UNAVAILABLE', { status: 503, detail });
}

module.exports = { KeycloakInvitations };

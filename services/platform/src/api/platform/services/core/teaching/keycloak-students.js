'use strict';

const { randomBytes } = require('crypto');
const { ProblemError } = require('../errors');

// Only the server holds this confidential client's credentials. Class ownership
// is checked before calling this adapter, and managed learner roles are checked
// again before account mutations. It cannot reset a teacher or administrator.
class KeycloakStudents {
  constructor(options = {}) {
    this.base = options.base || process.env.PLATFORM_KEYCLOAK_ADMIN_BASE_URL || 'http://keycloak:8080';
    this.clientId = options.clientId || process.env.PLATFORM_KEYCLOAK_ADMIN_CLIENT_ID;
    this.clientSecret = options.clientSecret || process.env.PLATFORM_KEYCLOAK_ADMIN_CLIENT_SECRET;
    this.fetch = options.fetch || global.fetch;
    this.cachedToken = null;
  }

  get configured() { return Boolean(this.clientId && this.clientSecret); }

  async token() {
    if (!this.configured) throw unavailable('Die Kontoverwaltung ist noch nicht eingerichtet.');
    if (this.cachedToken && this.cachedToken.expiresAt > Date.now()) return this.cachedToken.value;
    const response = await this.request('/realms/plantini/protocol/openid-connect/token', {
      method: 'POST', body: new URLSearchParams({ grant_type: 'client_credentials', client_id: this.clientId, client_secret: this.clientSecret }),
    });
    if (!response.ok) throw unavailable();
    const result = await response.json();
    if (!result.access_token) throw unavailable();
    this.cachedToken = { value: result.access_token, expiresAt: Date.now() + Math.max(0, (Number(result.expires_in) - 30) * 1000) };
    return result.access_token;
  }

  async admin(path, { method = 'GET', body } = {}) {
    return this.request(`/admin/realms/plantini${path}`, {
      method, headers: { Authorization: `Bearer ${await this.token()}`, ...(body ? { 'Content-Type': 'application/json' } : {}) },
      ...(body ? { body: JSON.stringify(body) } : {}),
    });
  }

  async create(input) {
    const roleResponse = await this.admin('/roles/lernende');
    if (!roleResponse.ok) throw unavailable();
    const role = await roleResponse.json();
    const response = await this.admin('/users', { method: 'POST', body: {
      username: input.username, firstName: input.displayName, lastName: '',
      ...(input.email ? { email: input.email } : {}),
      enabled: false, emailVerified: !input.email,
      attributes: { plantini_managed_student: ['true'] },
      requiredActions: ['UPDATE_PASSWORD'],
    } });
    if (response.status === 409) throw new ProblemError('TEACHING_USERNAME_EXISTS', {
      status: 409, detail: 'Dieser Anmeldename oder diese E-Mail-Adresse wird bereits verwendet.',
    });
    if (response.status !== 201) throw unavailable();
    const subject = response.headers.get('location')?.split('/').pop();
    if (!subject || !/^[0-9a-f-]{36}$/i.test(subject)) throw unavailable();
    try {
      const assigned = await this.admin(`/users/${subject}/role-mappings/realm`, { method: 'POST', body: [{ id: role.id, name: role.name }] });
      if (!assigned.ok) throw unavailable();
      const temporaryPassword = password();
      const reset = await this.admin(`/users/${subject}/reset-password`, { method: 'PUT', body: { type: 'password', value: temporaryPassword, temporary: true } });
      if (!reset.ok) throw unavailable();
      return { subject, temporaryPassword };
    } catch (error) {
      await this.removeNewAccount(subject).catch(() => {});
      throw error;
    }
  }

  async requireManagedLearner(subject) {
    const [userResponse, roleResponse] = await Promise.all([
      this.admin(`/users/${subject}`), this.admin(`/users/${subject}/role-mappings/realm/composite`),
    ]);
    if (!userResponse.ok || !roleResponse.ok) throw unavailable('Das verwaltete Konto konnte nicht geprüft werden.');
    const user = await userResponse.json();
    const roles = await roleResponse.json();
    const privileged = ['lehrende', 'inhaltsredaktion', 'botanisches_review', 'organisationsadministration', 'systemadministration'];
    if (user.attributes?.plantini_managed_student?.[0] !== 'true' || !roles.some((role) => role.name === 'lernende') || roles.some((role) => privileged.includes(role.name))) {
      throw new ProblemError('TEACHING_ACCOUNT_PROTECTED', { status: 403, detail: 'Dieses Konto darf nicht als Schülerkonto verwaltet werden.' });
    }
  }

  async resetPassword(subject) {
    await this.requireManagedLearner(subject);
    const temporaryPassword = password();
    const response = await this.admin(`/users/${subject}/reset-password`, { method: 'PUT', body: { type: 'password', value: temporaryPassword, temporary: true } });
    if (!response.ok) throw unavailable();
    await this.logout(subject);
    return temporaryPassword;
  }

  async setEnabled(subject, enabled) {
    await this.requireManagedLearner(subject);
    const response = await this.admin(`/users/${subject}`, { method: 'PUT', body: { enabled } });
    if (!response.ok) throw unavailable();
    if (!enabled) await this.logout(subject);
  }

  async logout(subject) {
    const response = await this.admin(`/users/${subject}/logout`, { method: 'POST' });
    if (!response.ok) throw unavailable('Die bestehenden Sitzungen konnten nicht beendet werden. Bitte erneut versuchen.');
  }

  async removeNewAccount(subject) {
    const response = await this.admin(`/users/${subject}`, { method: 'DELETE' });
    if (!response.ok && response.status !== 404) throw unavailable();
  }

  async request(path, options) {
    try { return await this.fetch(new URL(path, this.base), { ...options, signal: AbortSignal.timeout(10000) }); }
    catch { throw unavailable(); }
  }
}

function password() { return `Pn!${randomBytes(18).toString('base64url')}7aA`; }
function unavailable(detail = 'Die Kontoverwaltung ist momentan nicht erreichbar. Bitte erneut versuchen.') {
  return new ProblemError('TEACHING_IDENTITY_UNAVAILABLE', { status: 503, detail });
}

module.exports = { KeycloakStudents };

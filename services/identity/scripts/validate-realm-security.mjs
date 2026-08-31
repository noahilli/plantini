#!/usr/bin/env node

import { readFile } from 'node:fs/promises';
import { resolve } from 'node:path';

const REQUIRED_REALM_ROLES = [
  'lernende',
  'lehrende',
  'inhaltsredaktion',
  'botanisches_review',
  'organisationsadministration',
  'systemadministration',
  'forschende',
];

const APP_CLIENTS = [
  'plantini-web-dev',
  'plantini-mobile-dev',
  'plantini-web-staging',
  'plantini-mobile-staging',
  'plantini-web-production',
  'plantini-mobile-production',
];

const DISABLED_UNTIL_APPROVED = new Set([
  'plantini-web-staging',
  'plantini-mobile-staging',
  'plantini-web-production',
  'plantini-mobile-production',
]);

const sensitiveKey = /^(?:secret|privatekey|password|clientsecret|credentialdata|secretdata)$/i;

export function validateRealmSecurity(realm, { environment = 'development' } = {}) {
  const failures = [];
  const fail = (message) => failures.push(message);
  const clients = new Map((realm.clients ?? []).map((client) => [client.clientId, client]));
  const roles = new Set((realm.roles?.realm ?? []).map((role) => role.name));

  if (realm.realm !== 'plantini') {
    fail('realm must be named plantini');
  }
  if (!['external', 'all'].includes(realm.sslRequired)) {
    fail('sslRequired must reject cleartext external traffic');
  }
  if (realm.defaultSignatureAlgorithm !== 'RS256') {
    fail('defaultSignatureAlgorithm must be RS256');
  }
  if ((realm.users ?? []).length !== 0) {
    fail('versioned realm exports must not include users or credential material');
  }
  if ((realm.components?.['org.keycloak.keys.KeyProvider'] ?? []).length !== 0) {
    fail('versioned realm exports must not include generated Keycloak key providers');
  }
  findSensitiveValues(realm, '$', failures);

  for (const client of clients.values()) {
    if (client.directAccessGrantsEnabled) {
      fail(`${client.clientId}: Direct Access Grants must be disabled`);
    }
    if (client.implicitFlowEnabled) {
      fail(`${client.clientId}: implicit flow must be disabled`);
    }
  }

  if (!realm.registrationAllowed || !realm.verifyEmail || !realm.resetPasswordAllowed) {
    fail('registration, email verification, and password reset must be enabled together');
  }
  const verifyEmail = (realm.requiredActions ?? []).find(
    (action) => action.alias === 'VERIFY_EMAIL',
  );
  if (!verifyEmail?.enabled || !verifyEmail?.defaultAction) {
    fail('VERIFY_EMAIL must be an enabled default action');
  }
  if (!realm.bruteForceProtected || realm.failureFactor > 5 || realm.maxTemporaryLockouts < 1) {
    fail('brute-force protection must lock after at most five failed attempts');
  }
  if (!realm.passwordPolicy?.includes('length(14)') || !realm.passwordPolicy.includes('passwordHistory(5)')) {
    fail('password policy must require length(14) and passwordHistory(5)');
  }
  if (!realm.revokeRefreshToken || !realm.offlineSessionMaxLifespanEnabled) {
    fail('refresh-token rotation and a bounded offline-session lifetime are required');
  }
  if (realm.offlineSessionMaxLifespan > 2_592_000) {
    fail('offline sessions must not exceed 30 days');
  }

  for (const role of REQUIRED_REALM_ROLES) {
    if (!roles.has(role)) {
      fail(`missing realm role ${role}`);
    }
  }
  const defaultRole = (realm.roles?.realm ?? []).find(
    (role) => role.name === 'default-roles-plantini',
  );
  if (JSON.stringify(defaultRole?.composites?.realm ?? []) !== JSON.stringify(['lernende'])) {
    fail('the only default business role must be lernende');
  }

  if (!realm.eventsEnabled || !realm.adminEventsEnabled || realm.adminEventsDetailsEnabled) {
    fail('privacy-preserving user and admin audit events must be enabled without event details');
  }
  if (realm.eventsExpiration !== 7_776_000) {
    fail('auth event retention must be exactly 90 days until a legal retention decision changes it');
  }
  if ((realm.eventsListeners ?? []).length !== 0) {
    fail('realm events must not be copied to an unreviewed logging listener');
  }

  const legacy = clients.get('plantini-flutter');
  if (!legacy || legacy.enabled || legacy.standardFlowEnabled) {
    fail('the wildcard-era plantini-flutter client must remain disabled');
  }

  for (const clientId of APP_CLIENTS) {
    const client = clients.get(clientId);
    if (!client) {
      fail(`missing environment-specific client ${clientId}`);
      continue;
    }
    validateAppClient(client, failures);
    if (DISABLED_UNTIL_APPROVED.has(clientId)) {
      if (client.enabled || client.redirectUris?.length || client.webOrigins?.length) {
        fail(`${clientId}: must remain disabled without an approved exact origin`);
      }
    }
  }

  const api = clients.get('plantini-api');
  if (!api || !api.enabled || !api.bearerOnly || api.standardFlowEnabled || api.publicClient) {
    fail('plantini-api must be an enabled bearer-only resource server');
  }
  if (api && (api.redirectUris?.length || api.webOrigins?.length || api.fullScopeAllowed)) {
    fail('plantini-api must not have browser redirects, origins, or full scope');
  }

  const audienceScope = (realm.clientScopes ?? []).find(
    (scope) => scope.name === 'plantini-api-audience',
  );
  const audienceMapper = audienceScope?.protocolMappers?.find(
    (mapper) => mapper.protocolMapper === 'oidc-audience-mapper',
  );
  if (audienceMapper?.config?.['included.client.audience'] !== 'plantini-api') {
    fail('app tokens must carry the plantini-api audience for /api/v1');
  }

  validatePrivilegedMfa(realm, failures);

  if ((realm.identityProviders ?? []).length !== 0) {
    fail('identity providers need a separately approved provider configuration and must not be exported by default');
  }

  if (environment === 'production') {
    validateProductionPromotion(realm, clients, failures);
  }

  return failures;
}

function validateAppClient(client, failures) {
  if (!client.publicClient || client.bearerOnly || !client.standardFlowEnabled) {
    failures.push(`${client.clientId}: must be a public Authorization Code client`);
  }
  if (client.fullScopeAllowed || client.directAccessGrantsEnabled || client.implicitFlowEnabled) {
    failures.push(`${client.clientId}: must use least scope, PKCE, and no legacy grants`);
  }
  if (client.attributes?.['pkce.code.challenge.method'] !== 'S256') {
    failures.push(`${client.clientId}: must require PKCE S256`);
  }
  if (!client.defaultClientScopes?.includes('roles') || !client.defaultClientScopes?.includes('plantini-api-audience')) {
    failures.push(`${client.clientId}: must request only roles and the /api/v1 audience by default`);
  }
  for (const uri of [...(client.redirectUris ?? []), ...(client.webOrigins ?? [])]) {
    if (uri.includes('*') || uri === '+') {
      failures.push(`${client.clientId}: wildcard redirect URI or web origin is forbidden`);
    }
  }
}

function validatePrivilegedMfa(realm, failures) {
  const forms = (realm.authenticationFlows ?? []).find((flow) => flow.alias === 'forms');
  const configs = new Map((realm.authenticatorConfig ?? []).map((config) => [config.alias, config]));
  const expected = [
    ['plantini-systemadmin-otp', 'systemadministration'],
    ['plantini-organisationadmin-otp', 'organisationsadministration'],
  ];

  for (const [alias, role] of expected) {
    const execution = forms?.authenticationExecutions?.find(
      (item) => item.authenticator === 'auth-conditional-otp-form' && item.authenticatorConfig === alias,
    );
    const config = configs.get(alias)?.config;
    if (execution?.requirement !== 'REQUIRED' || config?.forceOtpRole !== role || config?.defaultOtpOutcome !== 'skip') {
      failures.push(`${role}: privileged MFA must be enforced through ${alias}`);
    }
  }
}

function validateProductionPromotion(realm, clients, failures) {
  if (realm.sslRequired !== 'all') {
    failures.push('production promotion requires sslRequired=all');
  }
  if (realm.smtpServer?.host === 'mailpit' || realm.smtpServer?.from?.endsWith('.local')) {
    failures.push('production promotion requires a production SMTP configuration from secret management');
  }
  for (const clientId of ['plantini-web-production', 'plantini-mobile-production']) {
    const client = clients.get(clientId);
    if (!client?.enabled || !client.redirectUris?.length) {
      failures.push(`${clientId}: must be enabled only after exact HTTPS/app-link redirects are approved`);
    }
    if (clientId.includes('web') && client?.redirectUris?.some((uri) => !uri.startsWith('https://'))) {
      failures.push(`${clientId}: production web redirects must use HTTPS`);
    }
  }
}

function findSensitiveValues(value, path, failures) {
  if (Array.isArray(value)) {
    value.forEach((child, index) => findSensitiveValues(child, `${path}[${index}]`, failures));
    return;
  }
  if (!value || typeof value !== 'object') {
    return;
  }
  for (const [key, child] of Object.entries(value)) {
    const childPath = `${path}.${key}`;
    if (sensitiveKey.test(key) && child !== undefined && child !== null && child !== '') {
      failures.push(`sensitive material is committed at ${childPath}`);
    }
    findSensitiveValues(child, childPath, failures);
  }
}

function parseArguments(args) {
  let environment = 'development';
  let file;
  for (const argument of args) {
    if (argument.startsWith('--environment=')) {
      environment = argument.slice('--environment='.length);
    } else if (!file) {
      file = argument;
    } else {
      throw new Error(`Unexpected argument: ${argument}`);
    }
  }
  if (!['development', 'staging', 'production'].includes(environment)) {
    throw new Error('environment must be development, staging, or production');
  }
  if (!file) {
    throw new Error('Usage: node validate-realm-security.mjs <realm.json> [--environment=development|staging|production]');
  }
  return { file, environment };
}

async function main() {
  const { file, environment } = parseArguments(process.argv.slice(2));
  const realm = JSON.parse(await readFile(resolve(file), 'utf8'));
  const failures = validateRealmSecurity(realm, { environment });
  if (failures.length) {
    console.error(`Realm security validation failed (${failures.length}):`);
    failures.forEach((failure) => console.error(`- ${failure}`));
    process.exitCode = 1;
    return;
  }
  console.log(`Realm security validation passed (${environment}).`);
}

if (import.meta.url === `file://${process.argv[1]}`) {
  main().catch((error) => {
    console.error(error.message);
    process.exitCode = 1;
  });
}

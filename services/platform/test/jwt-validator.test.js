'use strict';

const assert = require('node:assert/strict');
const test = require('node:test');
const crypto = require('node:crypto');

const { KeycloakJwtValidator } = require('../src/api/platform/services/core/auth/jwt-validator');
const { ActorService } = require('../src/api/platform/services/core/auth/actor-service');
const { ProblemError } = require('../src/api/platform/services/core/errors');

// Helper to generate an RSA keypair and sign test JWTs
function generateTestKeyPair() {
  return crypto.generateKeyPairSync('rsa', {
    modulusLength: 2048,
    publicKeyEncoding: { type: 'spki', format: 'jwk' },
    privateKeyEncoding: { type: 'pkcs8', format: 'pem' },
  });
}

function signJwt(payload, privateKeyPem, kid, alg = 'RS256') {
  const header = { alg, typ: 'JWT', kid };
  const encodedHeader = Buffer.from(JSON.stringify(header)).toString('base64url');
  const encodedPayload = Buffer.from(JSON.stringify(payload)).toString('base64url');
  const signature = crypto.sign('RSA-SHA256', Buffer.from(`${encodedHeader}.${encodedPayload}`), privateKeyPem);
  return `${encodedHeader}.${encodedPayload}.${signature.toString('base64url')}`;
}

test('jwt validator accepts valid signed token with matching issuer and audience', async () => {
  const { publicKey, privateKey } = generateTestKeyPair();
  const kid = 'test-key-id-01';
  publicKey.kid = kid;
  publicKey.use = 'sig';

  const issuer = 'http://localhost:8082/realms/plantini';
  const audience = 'plantini-backend';

  const mockFetch = async () => ({
    ok: true,
    json: async () => ({ keys: [publicKey] }),
  });

  const validator = new KeycloakJwtValidator({
    issuer,
    audience,
    fetch: mockFetch,
    clock: () => 1700000000000,
  });

  const nowSec = 1700000000;
  const token = signJwt({
    iss: issuer,
    aud: audience,
    sub: 'user-sub-12345',
    exp: nowSec + 3600,
    nbf: nowSec - 10,
    preferred_username: 'alex',
  }, privateKey, kid);

  const claims = await validator.validate(token);
  assert.equal(claims.sub, 'user-sub-12345');
  assert.equal(claims.preferred_username, 'alex');
});

test('jwt validator rejects expired token and invalid audience', async () => {
  const { publicKey, privateKey } = generateTestKeyPair();
  const kid = 'test-key-id-02';
  publicKey.kid = kid;
  publicKey.use = 'sig';

  const issuer = 'http://localhost:8082/realms/plantini';
  const audience = 'plantini-backend';

  const validator = new KeycloakJwtValidator({
    issuer,
    audience,
    fetch: async () => ({ ok: true, json: async () => ({ keys: [publicKey] }) }),
    clock: () => 1700000000000,
  });

  const nowSec = 1700000000;

  // Expired token
  const expiredToken = signJwt({
    iss: issuer,
    aud: audience,
    sub: 'user-sub-12345',
    exp: nowSec - 100,
  }, privateKey, kid);

  await assert.rejects(
    () => validator.validate(expiredToken),
    (err) => err instanceof ProblemError && err.code === 'AUTH_TOKEN_EXPIRED',
  );

  // Wrong audience
  const wrongAudToken = signJwt({
    iss: issuer,
    aud: 'wrong-audience',
    sub: 'user-sub-12345',
    exp: nowSec + 3600,
  }, privateKey, kid);

  await assert.rejects(
    () => validator.validate(wrongAudToken),
    (err) => err instanceof ProblemError && err.code === 'AUTH_TOKEN_INVALID',
  );
});

test('actor service resolves stable profile from sub and extracts roles', async () => {
  const profiles = new Map();
  const profileRepository = {
    async findBySubject(sub) {
      return profiles.get(sub);
    },
    async create(draft) {
      profiles.set(draft.keycloakSubject, draft);
      return draft;
    },
    async update(id, patch) {
      for (const p of profiles.values()) {
        if (p.profileId === id) {
          Object.assign(p, patch);
          return p;
        }
      }
      return null;
    },
  };

  const actorService = new ActorService({ profileRepository, roleClaimClientId: 'plantini-flutter' });
  const claims = {
    sub: 'auth0|9988776655',
    preferred_username: 'lea_explorer',
    realm_access: { roles: ['lehrende'] },
  };

  const actor = await actorService.resolve(claims);
  assert.equal(actor.subject, 'auth0|9988776655');
  assert.equal(actor.displayName, 'lea_explorer');
  assert.deepEqual(actor.roles, ['lehrende']);

  // Second resolve returns same profileId
  const actor2 = await actorService.resolve(claims);
  assert.equal(actor2.id, actor.id);
});

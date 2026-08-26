'use strict';

const crypto = require('crypto');
const { ProblemError } = require('../errors');

const SIGNING_ALGORITHMS = {
  RS256: 'RSA-SHA256',
  RS384: 'RSA-SHA384',
  RS512: 'RSA-SHA512',
};

class KeycloakJwtValidator {
  constructor(options) {
    this.issuer = requiredConfig(options.issuer, 'PLATFORM_OIDC_ISSUER');
    this.audience = requiredConfig(options.audience, 'PLATFORM_OIDC_AUDIENCE');
    this.jwksUri = options.jwksUri || `${this.issuer.replace(/\/$/, '')}/protocol/openid-connect/certs`;
    this.allowedAlgorithms = new Set(options.allowedAlgorithms || ['RS256']);
    this.fetch = options.fetch || global.fetch;
    this.clock = options.clock || (() => Date.now());
    this.cacheTtlMs = options.cacheTtlMs || 5 * 60 * 1000;
    this.clockToleranceSeconds = options.clockToleranceSeconds || 30;
    this.cachedJwks = undefined;

    if (typeof this.fetch !== 'function') {
      throw new Error('A fetch implementation is required for JWKS validation.');
    }
    for (const algorithm of this.allowedAlgorithms) {
      if (!SIGNING_ALGORITHMS[algorithm]) {
        throw new Error(`Unsupported JWT signing algorithm: ${algorithm}`);
      }
    }
  }

  async validate(token) {
    if (typeof token !== 'string' || token.length === 0 || token.length > 16_384) {
      throw authenticationError('AUTH_TOKEN_INVALID', 'Der Zugriffstoken ist ungültig.');
    }

    const parts = token.split('.');
    if (parts.length !== 3) {
      throw authenticationError('AUTH_TOKEN_INVALID', 'Der Zugriffstoken ist ungültig.');
    }

    const header = decodeJson(parts[0]);
    const claims = decodeJson(parts[1]);
    if (!header || !claims || typeof header !== 'object' || typeof claims !== 'object') {
      throw authenticationError('AUTH_TOKEN_INVALID', 'Der Zugriffstoken ist ungültig.');
    }

    if (!this.allowedAlgorithms.has(header.alg) || !SIGNING_ALGORITHMS[header.alg] || !header.kid) {
      throw authenticationError('AUTH_TOKEN_INVALID', 'Der Zugriffstoken verwendet keine erlaubte Signatur.');
    }

    const key = await this.findKey(header.kid);
    const signature = base64UrlDecode(parts[2]);
    const signedPayload = Buffer.from(`${parts[0]}.${parts[1]}`, 'utf8');
    let validSignature = false;
    try {
      const publicKey = crypto.createPublicKey({ key, format: 'jwk' });
      validSignature = crypto.verify(SIGNING_ALGORITHMS[header.alg], signedPayload, publicKey, signature);
    } catch (_) {
      validSignature = false;
    }
    if (!validSignature) {
      throw authenticationError('AUTH_TOKEN_INVALID', 'Der Zugriffstoken ist ungültig.');
    }

    this.validateClaims(claims);
    return claims;
  }

  async findKey(kid) {
    let keys = await this.getJwks(false);
    let key = keys.find((candidate) => candidate.kid === kid && candidate.use !== 'enc');
    // Keycloak can rotate a key between cache refreshes. Refresh exactly once;
    // no unbounded retry and no token data is emitted while doing so.
    if (!key) {
      keys = await this.getJwks(true);
      key = keys.find((candidate) => candidate.kid === kid && candidate.use !== 'enc');
    }
    if (!key) {
      throw authenticationError('AUTH_TOKEN_INVALID', 'Der Zugriffstoken wurde mit einem unbekannten Schlüssel signiert.');
    }
    return key;
  }

  async getJwks(forceRefresh) {
    const now = this.clock();
    if (!forceRefresh && this.cachedJwks && this.cachedJwks.expiresAt > now) {
      return this.cachedJwks.keys;
    }

    let response;
    try {
      response = await this.fetch(this.jwksUri, { headers: { accept: 'application/json' } });
    } catch (_) {
      throw new ProblemError('AUTH_KEYSET_UNAVAILABLE', {
        status: 503,
        title: 'Authentifizierung vorübergehend nicht verfügbar',
        detail: 'Der Signaturschlüssel des Identity-Providers ist nicht erreichbar.',
      });
    }
    if (!response || !response.ok) {
      throw new ProblemError('AUTH_KEYSET_UNAVAILABLE', {
        status: 503,
        title: 'Authentifizierung vorübergehend nicht verfügbar',
        detail: 'Der Signaturschlüssel des Identity-Providers ist nicht erreichbar.',
      });
    }

    let body;
    try {
      body = await response.json();
    } catch (_) {
      throw new ProblemError('AUTH_KEYSET_UNAVAILABLE', {
        status: 503,
        title: 'Authentifizierung vorübergehend nicht verfügbar',
      });
    }
    if (!body || !Array.isArray(body.keys)) {
      throw new ProblemError('AUTH_KEYSET_UNAVAILABLE', {
        status: 503,
        title: 'Authentifizierung vorübergehend nicht verfügbar',
      });
    }

    this.cachedJwks = { keys: body.keys, expiresAt: now + this.cacheTtlMs };
    return body.keys;
  }

  validateClaims(claims) {
    const now = Math.floor(this.clock() / 1000);
    const tolerance = this.clockToleranceSeconds;

    if (claims.iss !== this.issuer) {
      throw authenticationError('AUTH_TOKEN_INVALID', 'Der Zugriffstoken wurde für einen anderen Aussteller ausgestellt.');
    }
    const audiences = Array.isArray(claims.aud) ? claims.aud : [claims.aud];
    if (!audiences.includes(this.audience)) {
      throw authenticationError('AUTH_TOKEN_INVALID', 'Der Zugriffstoken ist nicht für diese API bestimmt.');
    }
    if (!Number.isFinite(claims.exp) || claims.exp <= now - tolerance) {
      throw authenticationError('AUTH_TOKEN_EXPIRED', 'Der Zugriffstoken ist abgelaufen.');
    }
    if (Number.isFinite(claims.nbf) && claims.nbf > now + tolerance) {
      throw authenticationError('AUTH_TOKEN_NOT_ACTIVE', 'Der Zugriffstoken ist noch nicht gültig.');
    }
    if (typeof claims.sub !== 'string' || claims.sub.length === 0 || claims.sub.length > 255) {
      throw authenticationError('AUTH_TOKEN_INVALID', 'Der Zugriffstoken enthält keine gültige Subjektkennung.');
    }
  }
}

function decodeJson(value) {
  try {
    return JSON.parse(base64UrlDecode(value).toString('utf8'));
  } catch (_) {
    return undefined;
  }
}

function base64UrlDecode(value) {
  if (typeof value !== 'string' || !/^[A-Za-z0-9_-]*$/.test(value)) {
    throw authenticationError('AUTH_TOKEN_INVALID', 'Der Zugriffstoken ist ungültig.');
  }
  return Buffer.from(value, 'base64url');
}

function requiredConfig(value, name) {
  if (typeof value !== 'string' || value.trim().length === 0) {
    throw new Error(`${name} must be configured.`);
  }
  return value.replace(/\/$/, '');
}

function authenticationError(code, detail) {
  return new ProblemError(code, { status: 401, detail });
}

module.exports = {
  KeycloakJwtValidator,
  authenticationError,
};

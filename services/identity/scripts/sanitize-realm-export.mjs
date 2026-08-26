#!/usr/bin/env node

import { readFile, writeFile } from 'node:fs/promises';
import { resolve } from 'node:path';

const sensitiveKey = /^(?:secret|privatekey|password|clientsecret|credentialdata|secretdata)$/i;

/**
 * Removes material that must never become part of the versioned realm baseline.
 * Keycloak generates realm signing/encryption keys at import time; test users,
 * client secrets, and provider credentials must be injected at runtime instead.
 */
export function sanitizeRealmExport(realm) {
  const sanitized = structuredClone(realm);

  sanitized.users = [];

  if (sanitized.components && typeof sanitized.components === 'object') {
    delete sanitized.components['org.keycloak.keys.KeyProvider'];
  }

  sanitized.clients = (sanitized.clients ?? []).map((client) => {
    const copy = structuredClone(client);
    delete copy.secret;
    return stripSensitiveValues(copy);
  });

  sanitized.identityProviders = (sanitized.identityProviders ?? []).map(
    stripSensitiveValues,
  );

  return stripSensitiveValues(sanitized);
}

function stripSensitiveValues(value) {
  if (Array.isArray(value)) {
    return value.map(stripSensitiveValues);
  }

  if (!value || typeof value !== 'object') {
    return value;
  }

  return Object.fromEntries(
    Object.entries(value)
      .filter(([key]) => !sensitiveKey.test(key))
      .map(([key, child]) => [key, stripSensitiveValues(child)]),
  );
}

async function main() {
  const [inputPath, outputPath] = process.argv.slice(2);
  if (!inputPath || !outputPath) {
    throw new Error(
      'Usage: node sanitize-realm-export.mjs <input-realm.json> <output-realm.json>',
    );
  }

  const source = JSON.parse(await readFile(resolve(inputPath), 'utf8'));
  const sanitized = sanitizeRealmExport(source);
  await writeFile(resolve(outputPath), `${JSON.stringify(sanitized, null, 2)}\n`);
}

if (import.meta.url === `file://${process.argv[1]}`) {
  main().catch((error) => {
    console.error(error.message);
    process.exitCode = 1;
  });
}

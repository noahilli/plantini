#!/usr/bin/env node

import { setDefaultResultOrder } from 'node:dns';
import { readFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const defaultApiBaseUrl = 'https://my-api.plantnet.org';
const defaultTimeoutMs = 12_000;
const defaultCredentialsFile = fileURLToPath(
  new URL('../../docs/plantnet-credentials', import.meta.url),
);

const usage = `Usage: node tools/scripts/verify-plantnet-credentials.mjs

Verifies a server-side PlantNet API key against the HTTPS quota endpoint.
Credential source order: PLANTNET_API_KEY, API_KEY, then the ignored local
docs/plantnet-credentials file. The script never prints credential values,
request URLs, response bodies, or an environment dump.
`;

async function main() {
  requireRealMode();
  const baseUrl = parseHttpsBaseUrl(process.env.PLANTNET_BASE_URL || defaultApiBaseUrl);
  const apiKey = await resolveApiKey();
  if (!apiKey) throw new VerificationError('MISSING_CREDENTIALS');

  const timeoutController = new AbortController();
  const timeout = setTimeout(() => timeoutController.abort(), defaultTimeoutMs);
  try {
    const response = await fetch(quotaUrl(baseUrl, apiKey), {
      method: 'GET',
      headers: { accept: 'application/json' },
      signal: timeoutController.signal,
    });
    if (response.body) await response.body.cancel().catch(() => {});

    if (response.ok) {
      process.stdout.write('PlantNet credential verification succeeded.\n');
      return;
    }
    if (response.status === 401 || response.status === 403) {
      throw new VerificationError('CREDENTIALS_REJECTED');
    }
    throw new VerificationError('UNEXPECTED_STATUS', response.status);
  } catch (error) {
    if (error?.name === 'AbortError') throw new VerificationError('TIMEOUT');
    throw error;
  } finally {
    clearTimeout(timeout);
  }
}

function requireRealMode() {
  const configuredMode = process.env.PLANTNET_MODE;
  if (configuredMode && configuredMode !== 'real') {
    throw new VerificationError('REAL_MODE_REQUIRED');
  }
}

function parseHttpsBaseUrl(value) {
  try {
    const url = new URL(value);
    if (
      url.protocol !== 'https:' ||
      url.username ||
      url.password ||
      url.search ||
      url.hash
    ) {
      throw new Error('invalid base URL');
    }
    return url;
  } catch {
    throw new VerificationError('INVALID_BASE_URL');
  }
}

function quotaUrl(baseUrl, apiKey) {
  const url = new URL('/v2/quota', baseUrl);
  url.searchParams.set('api-key', apiKey);
  return url;
}

async function resolveApiKey() {
  const fromEnvironment = nonEmpty(process.env.PLANTNET_API_KEY) || nonEmpty(process.env.API_KEY);
  if (fromEnvironment) return fromEnvironment;

  try {
    const file = process.env.PLANTNET_CREDENTIALS_FILE
      ? resolve(process.cwd(), process.env.PLANTNET_CREDENTIALS_FILE)
      : defaultCredentialsFile;
    return apiKeyFromCredentialFile(await readFile(file, 'utf8'));
  } catch {
    return undefined;
  }
}

function apiKeyFromCredentialFile(contents) {
  const values = new Map();
  for (const rawLine of contents.split(/\r?\n/)) {
    const match = /^\s*(?:export\s+)?(PLANTNET_API_KEY|API_KEY)\s*=\s*(.*?)\s*$/.exec(rawLine);
    if (!match) continue;
    const value = parseEnvValue(match[2]);
    if (value) values.set(match[1], value);
  }
  return values.get('PLANTNET_API_KEY') || values.get('API_KEY');
}

function parseEnvValue(value) {
  const trimmed = value.trim();
  if (!trimmed) return undefined;
  const quote = trimmed[0];
  if (quote === '"' || quote === "'") {
    return trimmed.length >= 2 && trimmed.at(-1) === quote
      ? nonEmpty(trimmed.slice(1, -1))
      : undefined;
  }
  return nonEmpty(trimmed.replace(/\s+#.*$/, ''));
}

function nonEmpty(value) {
  return typeof value === 'string' && value.trim() ? value.trim() : undefined;
}

function safeFailureMessage(error) {
  if (!(error instanceof VerificationError)) {
    return 'PlantNet credential verification failed without exposing request details.';
  }
  switch (error.code) {
    case 'MISSING_CREDENTIALS':
      return 'PlantNet credential verification could not find an API key.';
    case 'REAL_MODE_REQUIRED':
      return 'PlantNet credential verification requires PLANTNET_MODE=real when a mode is set.';
    case 'INVALID_BASE_URL':
      return 'PlantNet credential verification requires an HTTPS base URL without embedded credentials.';
    case 'CREDENTIALS_REJECTED':
      return 'PlantNet credential verification was rejected by the provider.';
    case 'TIMEOUT':
      return 'PlantNet credential verification timed out.';
    case 'UNEXPECTED_STATUS':
      return `PlantNet credential verification received HTTP ${error.status}.`;
    default:
      return 'PlantNet credential verification failed without exposing request details.';
  }
}

class VerificationError extends Error {
  constructor(code, status) {
    super(code);
    this.code = code;
    this.status = status;
  }
}

const arguments_ = process.argv.slice(2);
if (arguments_.includes('--help') || arguments_.includes('-h')) {
  process.stdout.write(usage);
} else if (arguments_.length > 0) {
  process.stderr.write(usage);
  process.exitCode = 64;
} else {
  // Local development hosts in this project do not have usable IPv6 routing.
  // PlantNet remains an external HTTPS hostname; IPv4 is only preferred for
  // DNS resolution and is never substituted with an insecure literal endpoint.
  setDefaultResultOrder('ipv4first');
  main().catch((error) => {
    process.stderr.write(`${safeFailureMessage(error)}\n`);
    process.exitCode = 1;
  });
}

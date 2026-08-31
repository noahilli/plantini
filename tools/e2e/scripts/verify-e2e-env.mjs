import { setDefaultResultOrder } from 'node:dns';
import { execFile } from 'node:child_process';
import { promisify } from 'node:util';
import { isIP } from 'node:net';
import { dirname, isAbsolute, relative, resolve, sep } from 'node:path';
import { fileURLToPath } from 'node:url';

const urlVariables = [
  'PLANTINI_E2E_APP_URL',
  'PLANTINI_E2E_API_URL',
  'PLANTINI_E2E_OIDC_ISSUER_URL',
  'PLANTINI_E2E_READINESS_URL',
];
const errors = [];
const mappings = new Map();
const arguments_ = process.argv.slice(2);
const checkReadiness = arguments_.includes('--check-readiness');
const scriptDirectory = dirname(fileURLToPath(import.meta.url));
const e2eDirectory = resolve(scriptDirectory, '..');
const runtimeDirectory = resolve(e2eDirectory, '.runtime');
const artifactPaths = {
  PLAYWRIGHT_TEST_RESULTS_DIR: '.runtime/test-results',
  PLAYWRIGHT_HTML_REPORT_DIR: '.runtime/playwright-report',
  PLAYWRIGHT_JUNIT_OUTPUT: '.runtime/test-results/junit.xml',
};

for (const argument of arguments_) {
  if (argument !== '--check-readiness') {
    errors.push(`Unsupported argument: ${argument}.`);
  }
}

for (const variable of [...urlVariables, 'E2E_USERNAME', 'E2E_USER_PASSWORD']) {
  if (!process.env[variable]?.trim()) {
    errors.push(`${variable} is required; no localhost default is available.`);
  }
}

for (const entry of (process.env.PLANTINI_E2E_IPV4_HOSTS ?? '').split(',')) {
  if (!entry.trim()) continue;
  const [rawHost, rawAddress, ...extra] = entry.trim().split('=');
  const host = rawHost?.trim().toLowerCase();
  const address = rawAddress?.trim();
  if (!host || !address || extra.length > 0 || isIP(address) !== 4) {
    errors.push('PLANTINI_E2E_IPV4_HOSTS must contain only host=IPv4 pairs.');
  } else {
    mappings.set(host, address);
  }
}

for (const variable of urlVariables) {
  const value = process.env[variable];
  if (!value) continue;
  try {
    const url = new URL(value);
    if (!['http:', 'https:'].includes(url.protocol)) {
      errors.push(`${variable} must use http or https.`);
      continue;
    }
    if (url.username || url.password) {
      errors.push(`${variable} must not embed credentials.`);
      continue;
    }
    if (isIP(url.hostname) === 6) {
      errors.push(`${variable} must not use an IPv6 literal.`);
    } else if (isIP(url.hostname) !== 4 && !mappings.has(url.hostname.toLowerCase())) {
      errors.push(`${variable} host ${url.hostname} needs an explicit IPv4 mapping.`);
    }
  } catch {
    errors.push(`${variable} must be an absolute URL.`);
  }
}

for (const [variable, expectedPath] of Object.entries(artifactPaths)) {
  const value = process.env[variable]?.trim();
  if (value !== expectedPath) {
    errors.push(`${variable} must use the isolated E2E runtime artifact path.`);
    continue;
  }

  const resolvedPath = resolve(e2eDirectory, expectedPath);
  const pathFromRuntime = relative(runtimeDirectory, resolvedPath);
  if (
    !pathFromRuntime
    || pathFromRuntime === '..'
    || pathFromRuntime.startsWith(`..${sep}`)
    || isAbsolute(pathFromRuntime)
  ) {
    errors.push(`${variable} must stay below the E2E runtime directory.`);
  }
}

if (errors.length > 0) {
  console.error(`Plantini E2E configuration is invalid:\n- ${errors.join('\n- ')}`);
  process.exit(1);
}

if (!checkReadiness) {
  console.log('Plantini E2E configuration is complete and IPv4-routed.');
  process.exit(0);
}

setDefaultResultOrder('ipv4first');

const issuer = process.env.PLANTINI_E2E_OIDC_ISSUER_URL.replace(/\/+$/, '');
const checks = [
  { name: 'web application', url: new URL('/', process.env.PLANTINI_E2E_APP_URL) },
  { name: 'platform readiness endpoint', url: new URL(process.env.PLANTINI_E2E_READINESS_URL) },
  { name: 'OIDC discovery endpoint', url: new URL(`${issuer}/.well-known/openid-configuration`) },
];
const readinessErrors = [];
const execFileAsync = promisify(execFile);

await Promise.all(checks.map(async ({ name, url }) => {
  try {
    const response = await fetch(url, {
      redirect: 'follow',
      signal: AbortSignal.timeout(10_000),
    });
    if (!response.ok) {
      readinessErrors.push(`${name} returned HTTP ${response.status}.`);
    }
  } catch {
    readinessErrors.push(`${name} is not reachable through the IPv4 E2E route.`);
  }
}));

if (readinessErrors.length === 0) {
  try {
    const repositoryDirectory = resolve(e2eDirectory, '..', '..');
    const composePath = resolve(repositoryDirectory, 'infra', 'compose.e2e.yaml');
    const environmentPath = resolve(runtimeDirectory, 'e2e.env');
    const probe = [
      "const issuer = process.env.PLATFORM_OIDC_ISSUER;",
      "const jwksUri = process.env.PLATFORM_OIDC_JWKS_URI;",
      "if (!issuer || !jwksUri) process.exit(64);",
      "fetch(jwksUri).then(async (response) => {",
      "  const body = await response.json().catch(() => undefined);",
      "  if (!response.ok || !Array.isArray(body?.keys)) process.exit(65);",
      "  process.stdout.write(JSON.stringify({ issuer, jwksUri }));",
      "}).catch(() => process.exit(66));",
    ].join(' ');
    const { stdout } = await execFileAsync('docker', [
      'compose',
      '--env-file', environmentPath,
      '-f', composePath,
      'exec',
      '-T',
      'platform',
      'node',
      '-e',
      probe,
    ], { maxBuffer: 8 * 1024 });
    const platformOidc = JSON.parse(stdout);
    if (platformOidc.issuer !== issuer) {
      readinessErrors.push('platform OIDC issuer differs from the host-visible Keycloak issuer.');
    }
  } catch {
    readinessErrors.push('platform cannot reach its configured OIDC JWKS endpoint through the E2E network.');
  }
}

if (readinessErrors.length > 0) {
  console.error(`Plantini E2E stack is not ready:\n- ${readinessErrors.join('\n- ')}`);
  process.exit(1);
}

console.log('Plantini E2E configuration is complete, IPv4-routed, and reachable.');

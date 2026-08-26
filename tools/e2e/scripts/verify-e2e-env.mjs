import { isIP } from 'node:net';

const urlVariables = [
  'PLANTINI_E2E_APP_URL',
  'PLANTINI_E2E_API_URL',
  'PLANTINI_E2E_OIDC_ISSUER_URL',
  'PLANTINI_E2E_READINESS_URL',
];
const errors = [];
const mappings = new Map();

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

if (errors.length > 0) {
  console.error(`Plantini E2E configuration is invalid:\n- ${errors.join('\n- ')}`);
  process.exit(1);
}

console.log('Plantini E2E configuration is complete and IPv4-routed.');

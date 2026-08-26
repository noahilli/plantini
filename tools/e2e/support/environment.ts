import { isIP } from 'node:net';

export interface E2EEnvironment {
  appUrl: string;
  apiUrl: string;
  oidcIssuerUrl: string;
  readinessUrl: string;
  username: string;
  password: string;
  ipv4Hosts: Map<string, string>;
}

const urlVariables = {
  appUrl: 'PLANTINI_E2E_APP_URL',
  apiUrl: 'PLANTINI_E2E_API_URL',
  oidcIssuerUrl: 'PLANTINI_E2E_OIDC_ISSUER_URL',
  readinessUrl: 'PLANTINI_E2E_READINESS_URL',
} as const;

const requiredVariables = [
  ...Object.values(urlVariables),
  'E2E_USERNAME',
  'E2E_USER_PASSWORD',
];

function parseUrl(variable: string, value: string, errors: string[]): URL | undefined {
  try {
    const parsed = new URL(value);
    if (!['http:', 'https:'].includes(parsed.protocol)) {
      errors.push(`${variable} must use http or https.`);
      return undefined;
    }
    if (parsed.username || parsed.password) {
      errors.push(`${variable} must not embed credentials.`);
      return undefined;
    }
    return parsed;
  } catch {
    errors.push(`${variable} must be an absolute URL.`);
    return undefined;
  }
}

export function parseIpv4Hosts(value: string | undefined, errors: string[] = []): Map<string, string> {
  const mappings = new Map<string, string>();
  if (!value?.trim()) {
    return mappings;
  }

  for (const entry of value.split(',')) {
    const [rawHost, rawAddress, ...unexpected] = entry.trim().split('=');
    const host = rawHost?.trim().toLowerCase();
    const address = rawAddress?.trim();
    if (!host || !address || unexpected.length > 0 || isIP(address) !== 4) {
      errors.push('PLANTINI_E2E_IPV4_HOSTS must use comma-separated host=IPv4 entries.');
      continue;
    }
    mappings.set(host, address);
  }
  return mappings;
}

export function getE2EEnvironmentErrors(source: NodeJS.ProcessEnv = process.env): string[] {
  const errors: string[] = [];
  const parsedUrls = new Map<string, URL>();

  for (const variable of requiredVariables) {
    if (!source[variable]?.trim()) {
      errors.push(`${variable} is required; this suite intentionally has no localhost fallback.`);
    }
  }

  for (const variable of Object.values(urlVariables)) {
    const value = source[variable];
    if (value?.trim()) {
      const parsed = parseUrl(variable, value, errors);
      if (parsed) {
        parsedUrls.set(variable, parsed);
      }
    }
  }

  const ipv4Hosts = parseIpv4Hosts(source.PLANTINI_E2E_IPV4_HOSTS, errors);
  for (const [variable, url] of parsedUrls) {
    if (isIP(url.hostname) === 4) {
      continue;
    }
    if (isIP(url.hostname) === 6) {
      errors.push(`${variable} must not use an IPv6 literal; provide an IPv4 URL or host mapping.`);
      continue;
    }
    if (!ipv4Hosts.has(url.hostname.toLowerCase())) {
      errors.push(
        `${variable} uses ${url.hostname}; add ${url.hostname}=<IPv4> to PLANTINI_E2E_IPV4_HOSTS.`,
      );
    }
  }

  return errors;
}

export function requireE2EEnvironment(source: NodeJS.ProcessEnv = process.env): E2EEnvironment {
  const errors = getE2EEnvironmentErrors(source);
  if (errors.length > 0) {
    throw new Error(`Invalid Plantini E2E configuration:\n- ${errors.join('\n- ')}`);
  }

  return {
    appUrl: source.PLANTINI_E2E_APP_URL!,
    apiUrl: source.PLANTINI_E2E_API_URL!,
    oidcIssuerUrl: source.PLANTINI_E2E_OIDC_ISSUER_URL!,
    readinessUrl: source.PLANTINI_E2E_READINESS_URL!,
    username: source.E2E_USERNAME!,
    password: source.E2E_USER_PASSWORD!,
    ipv4Hosts: parseIpv4Hosts(source.PLANTINI_E2E_IPV4_HOSTS),
  };
}

export function optionalE2EEnvironment(): E2EEnvironment | undefined {
  try {
    return requireE2EEnvironment();
  } catch {
    return undefined;
  }
}

export function getBrowserHostResolverRules(source: NodeJS.ProcessEnv = process.env): string | undefined {
  const mappings = parseIpv4Hosts(source.PLANTINI_E2E_IPV4_HOSTS);
  if (mappings.size === 0) {
    return undefined;
  }
  return [...mappings.entries()].map(([host, address]) => `MAP ${host} ${address}`).join(', ');
}

export function appendPath(baseUrl: string, path: string): string {
  const base = new URL(baseUrl.endsWith('/') ? baseUrl : `${baseUrl}/`);
  return new URL(path.replace(/^\//, ''), base).toString();
}

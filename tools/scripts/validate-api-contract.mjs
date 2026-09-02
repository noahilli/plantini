import { createHash } from 'node:crypto';
import {
  existsSync,
  readFileSync,
  writeFileSync,
} from 'node:fs';

const root = new URL('../../', import.meta.url);
const at = (path) => new URL(path, root);
const read = (path) => readFileSync(at(path), 'utf8');
const errors = [];
const writeDigests = process.argv.includes('--write-digests');

const generatorVersion = '7.25.0';
const generatorDigest =
  'sha256:2ab0a9680222de65dc9d3baf861aa02b99e1b80c211d8221ebf3ae8f8a102524';
const config = JSON.parse(read('apps/flutter/openapitools.json'));
const packageVersion = read(
  'packages/api/.openapi-generator/VERSION',
).trim();
const generatorScript = read('tools/scripts/generate-api-client.sh');

if (config['generator-cli']?.version !== generatorVersion) {
  errors.push(`Flutter generator version must be ${generatorVersion}`);
}
if (packageVersion !== generatorVersion) {
  errors.push(`Generated package version must be ${generatorVersion}`);
}
if (!generatorScript.includes(`v${generatorVersion}@${generatorDigest}`)) {
  errors.push('Generator script must pin the approved image tag and digest');
}

const contractSource = read('contracts/api.yaml');
const operations = parseOperations(contractSource);
const duplicateIds = duplicates(operations.map((operation) => operation.id));
if (duplicateIds.length > 0) {
  errors.push(`Duplicate operationId values: ${duplicateIds.join(', ')}`);
}

const routeSource = read(
  'services/platform/src/api/platform/routes/platform.js',
);
const controllerSource = read(
  'services/platform/src/api/platform/controllers/platform.js',
);
const routes = [...routeSource.matchAll(
  /route\('([A-Z]+)', '\/v1([^']*)', '([^']+)'\)/g,
)].map((match) => ({
  method: match[1].toLowerCase(),
  path: normalizePath(match[2] || '/'),
  handler: match[3],
}));

for (const operation of operations) {
  const route = routes.find(
    (candidate) =>
      candidate.method === operation.method &&
      candidate.path === normalizePath(operation.path),
  );
  if (operation.status === 'implemented') {
    if (!route) {
      errors.push(
        `Implemented contract operation has no server route: ${operation.method.toUpperCase()} ${operation.path}`,
      );
      continue;
    }
    if (!new RegExp(`\\basync\\s+${escapeRegex(route.handler)}\\s*\\(`).test(controllerSource)) {
      errors.push(`Server handler is missing: ${route.handler}`);
    }
  } else if (route) {
    errors.push(
      `Planned operation already has a route and must be marked implemented: ${operation.method.toUpperCase()} ${operation.path}`,
    );
  }
}

const documented = new Set(
  operations
    .filter((operation) => operation.status === 'implemented')
    .map((operation) => `${operation.method} ${normalizePath(operation.path)}`),
);
const allowedServerOnly = new Set(['get /health']);
for (const route of routes) {
  const key = `${route.method} ${route.path}`;
  if (!documented.has(key) && !allowedServerOnly.has(key)) {
    errors.push(`Undocumented server route: ${key.toUpperCase()}`);
  }
}

const specDigest = sha256(Buffer.from(contractSource));
const generatedFiles = [...new Set(
  read('packages/api/.openapi-generator/FILES')
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter(Boolean),
)].sort();
const treeHash = createHash('sha256');
for (const relative of generatedFiles) {
  const path = `packages/api/${relative}`;
  if (!existsSync(at(path))) {
    errors.push(`Generated file listed but missing: ${path}`);
    continue;
  }
  treeHash.update(relative);
  treeHash.update('\0');
  treeHash.update(readFileSync(at(path)));
  treeHash.update('\0');
}
const generatedDigest = treeHash.digest('hex');

const digestFiles = {
  'packages/api/.openapi-generator/SPEC_SHA256': `${specDigest}\n`,
  'packages/api/.openapi-generator/TREE_SHA256': `${generatedDigest}\n`,
};
if (writeDigests) {
  if (errors.length > 0) fail();
  for (const [path, value] of Object.entries(digestFiles)) {
    writeFileSync(at(path), value);
  }
} else {
  for (const [path, expected] of Object.entries(digestFiles)) {
    if (!existsSync(at(path)) || read(path) !== expected) {
      errors.push(`${path} is stale; regenerate the Dart API client`);
    }
  }
}

if (errors.length > 0) fail();
const implementedCount = operations.filter(
  (operation) => operation.status === 'implemented',
).length;
console.log(
  `API contract validation OK: ${implementedCount} implemented, ${operations.length - implementedCount} planned, generator ${generatorVersion}`,
);

function parseOperations(source) {
  const methods = new Set([
    'get',
    'post',
    'put',
    'patch',
    'delete',
    'head',
    'options',
  ]);
  const parsed = [];
  let path;
  let operation;
  let inPaths = false;
  for (const line of source.split(/\r?\n/)) {
    if (line === 'paths:') {
      inPaths = true;
      continue;
    }
    if (inPaths && line === 'components:') break;
    if (!inPaths) continue;
    const pathMatch = line.match(/^  (\/[^:]+):$/);
    if (pathMatch) {
      path = pathMatch[1];
      operation = undefined;
      continue;
    }
    const methodMatch = line.match(/^    ([a-z]+):$/);
    if (path && methodMatch && methods.has(methodMatch[1])) {
      operation = {
        path,
        method: methodMatch[1],
        status: 'implemented',
      };
      parsed.push(operation);
      continue;
    }
    if (!operation) continue;
    const idMatch = line.match(/^      operationId: ([A-Za-z][A-Za-z0-9]*)$/);
    if (idMatch) operation.id = idMatch[1];
    const statusMatch = line.match(
      /^      x-plantini-implementation-status: (implemented|planned)$/,
    );
    if (statusMatch) operation.status = statusMatch[1];
  }
  for (const item of parsed) {
    if (!item.id) {
      errors.push(
        `Contract operation lacks operationId: ${item.method.toUpperCase()} ${item.path}`,
      );
    }
  }
  return parsed;
}

function normalizePath(path) {
  return path.replace(/\{([^}]+)\}/g, ':$1');
}

function duplicates(values) {
  const seen = new Set();
  const duplicates = new Set();
  for (const value of values.filter(Boolean)) {
    if (seen.has(value)) duplicates.add(value);
    seen.add(value);
  }
  return [...duplicates];
}

function sha256(value) {
  return createHash('sha256').update(value).digest('hex');
}

function escapeRegex(value) {
  return value.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

function fail() {
  console.error('API contract validation FAILED');
  for (const error of errors) console.error(`- ${error}`);
  process.exit(1);
}

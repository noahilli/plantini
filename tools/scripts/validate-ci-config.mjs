import { existsSync, readFileSync } from 'node:fs';

const read = (path) => readFileSync(new URL(`../../${path}`, import.meta.url), 'utf8');
const canonicalFlutter = read('.flutter-version').trim();
const gitlab = read('.gitlab-ci.yml');
const github = read('.github/workflows/ci.yml');
const e2eRunner = read('tools/e2e/scripts/run-e2e-stack.sh');
const platformPackage = JSON.parse(read('services/platform/package.json'));
const errors = [];

const requireText = (source, expected, scope) => {
  if (!source.includes(expected)) errors.push(`${scope}: missing ${JSON.stringify(expected)}`);
};

requireText(gitlab, `FLUTTER_VERSION: "${canonicalFlutter}"`, 'GitLab CI');
requireText(gitlab, 'mcr.microsoft.com/playwright:v1.55.0-noble', 'GitLab CI');
requireText(gitlab, 'PLANTINI_E2E_SKIP_WEB_BUILD: "true"', 'GitLab CI');
requireText(github, "flutter-version-file: '.flutter-version'", 'GitHub CI');
requireText(e2eRunner, 'cat "$repo_dir/.flutter-version"', 'E2E runner');
requireText(e2eRunner, 'PLANTINI_E2E_SKIP_WEB_BUILD', 'E2E runner');

if (!existsSync(new URL('../../services/platform/package-lock.json', import.meta.url))) {
  errors.push('Platform: package-lock.json is required for npm ci');
}
if (existsSync(new URL('../../services/platform/yarn.lock', import.meta.url))) {
  errors.push('Platform: yarn.lock must not coexist with the canonical npm lockfile');
}
if (platformPackage.devDependencies?.eslint !== '10.9.1') {
  errors.push('Platform: ESLint must stay pinned to 10.9.1');
}

for (const [scope, source] of [['GitLab CI', gitlab], ['GitHub CI', github]]) {
  requireText(source, 'node tools/scripts/validate-ci-config.mjs', scope);
  requireText(source, 'node tools/scripts/validate-api-contract.mjs', scope);
  requireText(source, '@redocly/cli@1.34.3 lint contracts/api.yaml', scope);
  requireText(source, 'knowledge/scripts/validate_knowledge.py', scope);
  requireText(source, 'npm run stack:up', scope);
  requireText(source, 'npm test', scope);
  requireText(source, 'npm run stack:down', scope);
  requireText(source, 'tools/e2e/.runtime/playwright-report/', scope);
  requireText(source, 'tools/e2e/.runtime/test-results/', scope);
  requireText(source, 'npm run lint', scope);
  requireText(source, 'npm run check', scope);
  requireText(source, 'npm run build', scope);
  requireText(source, 'dart format --output=none --set-exit-if-changed lib test', scope);
  requireText(source, 'flutter analyze', scope);
  requireText(source, 'flutter test', scope);
  requireText(source, 'dart run build_runner build', scope);
  requireText(source, 'git diff --exit-code -- packages/api', scope);
}

if (/3\.24\./.test(`${gitlab}\n${github}\n${e2eRunner}`)) {
  errors.push('CI still references the obsolete Flutter 3.24 toolchain');
}

for (const [scope, source] of [['GitLab CI', gitlab], ['GitHub CI', github]]) {
  if (/\|\|\s*true|allow_failure\s*:\s*true|continue-on-error\s*:\s*true/.test(source)) {
    errors.push(`${scope}: mandatory gates must not be fail-open`);
  }
}

if (errors.length > 0) {
  console.error('CI configuration validation FAILED');
  for (const error of errors) console.error(`- ${error}`);
  process.exit(1);
}

console.log(`CI configuration validation OK: Flutter ${canonicalFlutter}, IPv4 E2E lifecycle and artifact paths agree`);

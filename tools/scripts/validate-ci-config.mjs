import { readFileSync } from 'node:fs';

const read = (path) => readFileSync(new URL(`../../${path}`, import.meta.url), 'utf8');
const canonicalFlutter = read('.flutter-version').trim();
const gitlab = read('.gitlab-ci.yml');
const github = read('.github/workflows/ci.yml');
const e2eRunner = read('tools/e2e/scripts/run-e2e-stack.sh');
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

for (const [scope, source] of [['GitLab CI', gitlab], ['GitHub CI', github]]) {
  requireText(source, 'node tools/scripts/validate-ci-config.mjs', scope);
  requireText(source, '@redocly/cli@1.34.3 lint contracts/api.yaml', scope);
  requireText(source, 'knowledge/scripts/validate_knowledge.py', scope);
  requireText(source, 'npm run stack:up', scope);
  requireText(source, 'npm test', scope);
  requireText(source, 'npm run stack:down', scope);
  requireText(source, 'tools/e2e/.runtime/playwright-report/', scope);
  requireText(source, 'tools/e2e/.runtime/test-results/', scope);
}

if (/3\.24\./.test(`${gitlab}\n${github}\n${e2eRunner}`)) {
  errors.push('CI still references the obsolete Flutter 3.24 toolchain');
}

if (errors.length > 0) {
  console.error('CI configuration validation FAILED');
  for (const error of errors) console.error(`- ${error}`);
  process.exit(1);
}

console.log(`CI configuration validation OK: Flutter ${canonicalFlutter}, IPv4 E2E lifecycle and artifact paths agree`);

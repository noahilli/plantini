import { setDefaultResultOrder } from 'node:dns';

import { defineConfig, devices } from '@playwright/test';

import {
  getBrowserHostResolverRules,
  optionalE2EEnvironment,
} from './support/environment';

// Playwright API requests use Node's resolver. Chromium receives explicit host
// mappings below, so an unavailable IPv6 route cannot make an E2E run flake.
setDefaultResultOrder('ipv4first');

const environment = optionalE2EEnvironment();
const hostResolverRules = getBrowserHostResolverRules();
const captureFailureArtifacts = process.env.PLANTINI_E2E_CAPTURE_FAILURE_ARTIFACTS === 'true';
const resultDirectory = process.env.PLAYWRIGHT_TEST_RESULTS_DIR ?? 'test-results';
const reportDirectory = process.env.PLAYWRIGHT_HTML_REPORT_DIR ?? 'playwright-report';
const junitReport = process.env.PLAYWRIGHT_JUNIT_OUTPUT ?? `${resultDirectory}/junit.xml`;

const chromiumUse = {
  ...devices['Desktop Chrome'],
  baseURL: environment?.appUrl,
  launchOptions: hostResolverRules
    ? { args: [`--host-resolver-rules=${hostResolverRules}`] }
    : undefined,
  trace: captureFailureArtifacts ? 'retain-on-failure' : 'off',
  screenshot: captureFailureArtifacts ? 'only-on-failure' : 'off',
  video: 'off',
};

export default defineConfig({
  testDir: '.',
  testIgnore: [
    '**/auth/**',
    '**/cms/**',
    '**/node_modules/**',
    '**/playwright-report/**',
    '**/test-results/**',
  ],
  fullyParallel: true,
  forbidOnly: Boolean(process.env.CI),
  retries: process.env.CI ? 1 : 0,
  workers: process.env.CI ? 2 : undefined,
  timeout: 45_000,
  expect: {
    timeout: 10_000,
  },
  outputDir: resultDirectory,
  reporter: [
    ['list'],
    ['html', { outputFolder: reportDirectory, open: 'never' }],
    ['junit', { outputFile: junitReport }],
  ],
  use: chromiumUse,
  projects: [
    {
      name: 'health',
      testMatch: /health\/.*\.spec\.ts/,
      fullyParallel: false,
      use: chromiumUse,
    },
    {
      name: 'contract',
      dependencies: ['health'],
      testMatch: /contract\/.*\.spec\.ts/,
      use: chromiumUse,
    },
    {
      name: 'web-app',
      dependencies: ['health'],
      testMatch: /qa\/core-journey\.spec\.ts/,
      use: chromiumUse,
    },
    {
      name: 'resilience',
      dependencies: ['health'],
      testMatch: /qa\/resilience\.spec\.ts/,
      use: chromiumUse,
    },
    {
      name: 'accessibility',
      dependencies: ['health'],
      testMatch: /accessibility\/.*\.spec\.ts/,
      use: chromiumUse,
    },
  ],
});

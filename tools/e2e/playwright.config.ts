import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './cms',
  fullyParallel: false,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  use: {
    baseURL: process.env.PLATFORM_URL || 'http://localhost:1337',
    trace: 'on-first-retry',
  },
  projects: [
    {
      name: 'cms',
      testDir: './cms',
      use: { 
        ...devices['Desktop Chrome'],
        baseURL: process.env.PLATFORM_URL || 'http://localhost:1338',
      },
    },
    {
      name: 'qa',
      testDir: './qa',
      use: {
        ...devices['Desktop Chrome'],
        baseURL: process.env.APP_URL || 'http://localhost:3000',
      }
    }
  ],
});

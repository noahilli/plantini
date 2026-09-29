import { defineConfig } from 'vite';
import { resolve } from 'node:path';

// Public origin of the web app; override with PLANTINI_APP_URL for other environments.
const APP_URL = process.env.PLANTINI_APP_URL || 'https://app.plantini.eu';

export default defineConfig({
  build: {
    target: 'es2022',
    chunkSizeWarningLimit: 700,
    rollupOptions: {
      input: {
        main: resolve(import.meta.dirname, 'index.html'),
        impressum: resolve(import.meta.dirname, 'impressum/index.html'),
        datenschutz: resolve(import.meta.dirname, 'datenschutz/index.html'),
        bildnachweise: resolve(import.meta.dirname, 'bildnachweise/index.html'),
      },
    },
  },
  plugins: [
    {
      name: 'plantini-tokens',
      transformIndexHtml: (html) => html.replaceAll('__APP_URL__', APP_URL),
    },
  ],
});

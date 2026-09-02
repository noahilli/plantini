import js from '@eslint/js';

const readonly = 'readonly';

export default [
  {
    ignores: [
      '**/node_modules/**',
      'build/**',
      '.cache/**',
      '.tmp/**',
      'public/uploads/**',
      'src/admin/*.example.js',
    ],
  },
  {
    files: ['config/**/*.js', 'src/**/*.js', 'test/**/*.js'],
    ...js.configs.recommended,
    languageOptions: {
      ecmaVersion: 2022,
      sourceType: 'commonjs',
      globals: {
        Buffer: readonly,
        URL: readonly,
        clearInterval: readonly,
        clearTimeout: readonly,
        console: readonly,
        fetch: readonly,
        module: readonly,
        process: readonly,
        queueMicrotask: readonly,
        require: readonly,
        setInterval: readonly,
        setTimeout: readonly,
        strapi: readonly,
        structuredClone: readonly,
      },
    },
    rules: {
      'no-unused-vars': ['error', {
        argsIgnorePattern: '^_',
        caughtErrors: 'none',
        varsIgnorePattern: '^_',
      }],
    },
  },
];

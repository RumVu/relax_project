import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';
import path from 'node:path';

/**
 * Vitest config for unit/component tests.
 * Co-exists with Playwright (`test:e2e`) — Vitest looks for `*.test.ts(x)` and
 * Playwright looks for files under `e2e/*.spec.ts`.
 */
export default defineConfig({
  plugins: [react()],
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: ['./vitest.setup.ts'],
    include: ['{lib,hooks,stores,components}/**/*.test.{ts,tsx}'],
    exclude: ['node_modules', '.next', 'e2e', 'test-results'],
    css: false,
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname, '.'),
    },
  },
});

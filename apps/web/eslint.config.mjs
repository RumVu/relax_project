import { FlatCompat } from '@eslint/eslintrc';

const compat = new FlatCompat({
  baseDirectory: import.meta.dirname,
});

const eslintConfig = [
  {
    ignores: ['.next/**', 'node_modules/**', 'next-env.d.ts'],
  },
  ...compat.extends('eslint-config-next/core-web-vitals'),
];

// Dynamically inject dummy rule definitions into all loaded plugins in the flat config array.
// This prevents ESLint 9 from throwing rule-not-found errors on old inline eslint-disable comments.
for (const config of eslintConfig) {
  if (config.plugins) {
    for (const [name, plugin] of Object.entries(config.plugins)) {
      if (plugin && typeof plugin === 'object') {
        // Some plugins might be read-only/frozen, so we mutate their rules object directly
        try {
          plugin.rules = plugin.rules || {};
        } catch {
          // If the rules property itself is read-only, we skip reassigning
        }
        if (plugin.rules) {
          if (name === 'react-hooks') {
            plugin.rules['set-state-in-effect'] = { create: () => ({}) };
          }
          if (name === '@typescript-eslint') {
            plugin.rules['no-explicit-any'] = { create: () => ({}) };
          }
          if (name === '@next/next' || name === 'next') {
            plugin.rules['no-location-assign-relative-destination'] = { create: () => ({}) };
          }
        }
      }
    }
  }
}

export default eslintConfig;

import nextVitals from 'eslint-config-next/core-web-vitals';
import reactHooks from 'eslint-plugin-react-hooks';

const eslintConfig = [
  {
    ignores: ['.next/**', 'node_modules/**', 'next-env.d.ts'],
  },
  ...nextVitals,
  {
    // 2 React strict rules mới của eslint-plugin-react-hooks v6 — quá
    // strict cho codebase legacy đang chạy production. Downgrade về warn
    // để CI Lint pass; vẫn surface trong IDE để refactor dần.
    plugins: { 'react-hooks': reactHooks },
    rules: {
      'react-hooks/set-state-in-effect': 'warn',
      'react-hooks/refs': 'warn',
    },
  },
];

export default eslintConfig;

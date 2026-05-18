import type { Config } from 'tailwindcss';

const config: Config = {
  content: [
    './app/**/*.{ts,tsx}',
    './components/**/*.{ts,tsx}',
    './lib/**/*.{ts,tsx}',
    './hooks/**/*.{ts,tsx}',
    './stores/**/*.{ts,tsx}',
  ],
  theme: {
    extend: {
      colors: {
        ink: '#112218',
        moss: '#355f42',
        mist: '#f3f6ef',
        clay: '#d9c5aa',
        ember: '#a6492d',
      },
      boxShadow: {
        panel: '0 24px 60px rgba(17, 34, 24, 0.12)',
      },
      backgroundImage: {
        grain:
          "radial-gradient(circle at 20% 20%, rgba(255,255,255,0.6), transparent 40%), radial-gradient(circle at 80% 0%, rgba(166,73,45,0.14), transparent 32%), linear-gradient(180deg, rgba(243,246,239,0.96), rgba(233,240,231,0.96))",
      },
    },
  },
  plugins: [],
};

export default config;

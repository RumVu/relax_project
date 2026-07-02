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
        ink: '#1a1a1a',
        night: '#242424',
        plum: '#4b36a8',
        violet: '#7357f6',
        lilac: '#dcd6ff',
        mint: '#40c9a2',
        coral: '#ef767a',
        sun: '#f8c66d',
        mist: '#f8f7ff',
        cloud: '#eef1f8',
        slate: '#536071',
      },
      boxShadow: {
        panel: '0 18px 50px rgba(0, 0, 0, 0.12)',
      },
      backgroundImage: {
        grain:
          "linear-gradient(180deg, rgba(248,247,255,0.98), rgba(238,241,248,0.98))",
      },
    },
  },
  plugins: [],
};

export default config;

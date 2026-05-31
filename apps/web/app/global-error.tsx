'use client';

import { AlertOctagon, RefreshCcw } from 'lucide-react';

export default function GlobalError({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  const locale =
    typeof window !== 'undefined'
      ? window.localStorage.getItem('digital-break:locale')
      : 'vi';
  const copy =
    locale === 'en'
      ? {
          eyebrow: 'Critical error',
          title: 'The app crashed at the layout layer.',
          fallback: 'An unexpected error occurred. Please try again.',
          retry: 'Try again',
        }
      : {
          eyebrow: 'Lỗi nghiêm trọng',
          title: 'Ứng dụng bị ngắt ở tầng bố cục.',
          fallback: 'Một lỗi không mong muốn vừa xảy ra. Vui lòng thử lại.',
          retry: 'Thử lại',
        };
  return (
    // Global error renders OUTSIDE I18nProvider so we can't use the
    // useTranslation hook. Use Vietnamese as the default copy — covers
    // the most common audience and matches the rest of the app's
    // default locale.
    <html lang={locale === 'en' ? 'en' : 'vi'}>
      <body>
        <main
          style={{
            alignItems: 'center',
            background:
              'linear-gradient(135deg, #101425 0%, #171c2f 52%, #201a3a 100%)',
            color: '#eef1ff',
            display: 'flex',
            minHeight: '100vh',
            justifyContent: 'center',
            padding: 24,
          }}
        >
          <section
            style={{
              background: 'rgba(26,31,52,0.92)',
              border: '1px solid rgba(238,241,255,0.14)',
              borderRadius: 28,
              boxShadow: '0 24px 70px rgba(0,0,0,0.28)',
              maxWidth: 560,
              padding: 32,
            }}
          >
            <AlertOctagon color="#ef767a" size={36} />
            <p
              style={{
                color: '#dcd6ff',
                fontSize: 12,
                fontWeight: 800,
                letterSpacing: '0.2em',
                marginTop: 24,
                textTransform: 'uppercase',
              }}
            >
              {copy.eyebrow}
            </p>
            <h1 style={{ fontSize: 36, lineHeight: 1.05, margin: '12px 0' }}>
              {copy.title}
            </h1>
            <p style={{ color: '#aab4c7', fontWeight: 600 }}>
              {error.message || copy.fallback}
            </p>
            {error.digest ? (
              <p style={{ color: '#dcd6ff', fontFamily: 'monospace' }}>
                digest: {error.digest}
              </p>
            ) : null}
            <button
              onClick={reset}
              style={{
                alignItems: 'center',
                background: '#7357f6',
                border: 0,
                borderRadius: 16,
                color: 'white',
                cursor: 'pointer',
                display: 'inline-flex',
                fontWeight: 800,
                gap: 8,
                marginTop: 24,
                padding: '12px 18px',
              }}
              type="button"
            >
              <RefreshCcw size={16} />
              {copy.retry}
            </button>
          </section>
        </main>
      </body>
    </html>
  );
}

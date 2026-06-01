import type { Metadata } from 'next';
import { Manrope } from 'next/font/google';
import { Analytics } from '@vercel/analytics/next';
import './globals.css';
import { ThemeProvider } from '@/components/providers/theme-provider';
import { ToastRegion } from '@/components/ui/toast-region';
import { I18nProvider } from '@/lib/i18n/i18n-provider';

const manrope = Manrope({
  subsets: ['latin'],
  variable: '--font-manrope',
});

export const metadata: Metadata = {
  title: 'Digital Cigarette Break',
  description: 'Mood tracking, mindful breaks, journaling, and recovery rituals.',
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  // `lang` defaults to "vi" but I18nProvider updates it on mount based
  // on the user's saved preference, so screen readers + Google translate
  // get the right hint after the first paint.
  return (
    <html lang="vi">
      <body className={`${manrope.variable} font-sans antialiased`}>
        <I18nProvider>
          <ThemeProvider />
          <ToastRegion />
          {children}
          <Analytics />
        </I18nProvider>
      </body>
    </html>
  );
}

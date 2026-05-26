import type { Metadata } from 'next';
import { Manrope } from 'next/font/google';
import './globals.css';
import { ThemeProvider } from '@/components/providers/theme-provider';
import { ToastRegion } from '@/components/ui/toast-region';

const manrope = Manrope({
  subsets: ['latin'],
  variable: '--font-manrope',
});

export const metadata: Metadata = {
  title: 'Digital Cigarette Break',
  description: 'Mood tracking, mindful breaks, journaling, and recovery rituals.',
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className={`${manrope.variable} font-sans antialiased`}>
        <ThemeProvider />
        <ToastRegion />
        {children}
      </body>
    </html>
  );
}

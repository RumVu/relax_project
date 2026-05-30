'use client';

import { Leaf } from 'lucide-react';
import { useTranslation } from '@/lib/i18n/i18n-provider';

export default function Loading() {
  const { t } = useTranslation();
  return (
    <main className="flex min-h-screen items-center justify-center px-4 py-10">
      <section className="w-full max-w-xl rounded-lg border border-[var(--panel-border)] bg-[var(--panel-bg)] p-8 text-center shadow-panel">
        <div className="mx-auto flex h-14 w-14 animate-pulse items-center justify-center rounded-lg bg-violet text-white">
          <Leaf className="h-7 w-7" />
        </div>
        <p className="mt-6 text-xs font-bold uppercase tracking-[0.2em] text-plum">
          {t('page.loading.title')}
        </p>
        <h1 className="mt-3 text-3xl font-extrabold text-[var(--app-text)]">
          {t('page.loading.subtitle')}
        </h1>
        <div className="mt-6 space-y-3">
          <div className="h-3 rounded-full bg-lilac/70" />
          <div className="mx-auto h-3 w-3/4 rounded-full bg-lilac/50" />
          <div className="mx-auto h-3 w-1/2 rounded-full bg-lilac/30" />
        </div>
      </section>
    </main>
  );
}

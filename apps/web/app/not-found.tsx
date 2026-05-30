'use client';

import Link from 'next/link';
import { Home, SearchX } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { useTranslation } from '@/lib/i18n/i18n-provider';

export default function NotFound() {
  const { t } = useTranslation();
  return (
    <main className="flex min-h-screen items-center justify-center px-4 py-10">
      <Card className="max-w-xl">
        <div className="flex h-12 w-12 items-center justify-center rounded-lg bg-lilac text-plum">
          <SearchX className="h-6 w-6" />
        </div>
        <p className="mt-6 text-xs font-bold uppercase tracking-[0.2em] text-plum">
          404
        </p>
        <h1 className="mt-3 text-3xl font-extrabold text-[var(--app-text)]">
          {t('page.notFound.title')}
        </h1>
        <p className="mt-3 text-sm font-semibold text-[var(--app-muted)]">
          {t('page.notFound.description')}
        </p>
        <Link href="/dashboard">
          <Button className="mt-6">
            <Home className="h-4 w-4" />
            {t('page.error.home')}
          </Button>
        </Link>
      </Card>
    </main>
  );
}

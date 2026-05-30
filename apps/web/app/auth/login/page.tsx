'use client';

import Link from 'next/link';
import { AuthForm } from '@/components/auth/auth-form';
import { GoogleSignInButton } from '@/components/auth/google-sign-in-button';
import { Card } from '@/components/ui/card';
import { useTranslation } from '@/lib/i18n/i18n-provider';

export default function LoginPage() {
  const { t } = useTranslation();
  return (
    <main className="flex min-h-screen items-center justify-center p-6">
      <Card className="w-full max-w-md">
        <p className="text-sm uppercase tracking-[0.2em] text-violet">
          {t('auth.welcomeBack')}
        </p>
        <h1 className="mt-3 text-3xl font-bold text-ink">
          {t('auth.signIn.title')}
        </h1>
        <div className="mt-6">
          <GoogleSignInButton mode="signin" />
        </div>
        <div className="my-5 flex items-center gap-3 text-xs font-semibold uppercase tracking-[0.18em] text-[var(--app-muted)]">
          <span className="h-px flex-1 bg-[var(--field-border)]" />
          {t('auth.or')}
          <span className="h-px flex-1 bg-[var(--field-border)]" />
        </div>
        <AuthForm mode="login" />
        <p className="mt-6 text-center text-sm text-[var(--app-muted)]">
          {t('auth.noAccount')}{' '}
          <Link
            className="font-semibold text-[var(--brand-primary)] hover:underline"
            href="/auth/register"
          >
            {t('auth.createOne')}
          </Link>
        </p>
      </Card>
    </main>
  );
}

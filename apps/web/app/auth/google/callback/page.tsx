'use client';

import { useEffect, useMemo, useState } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import {
  apiFetch,
  type AuthResponse,
  persistAuthSession,
} from '@/lib/api';
import { authRoutes } from '@/lib/auth';
import { GOOGLE_OAUTH_STATE_KEY } from '@/components/auth/google-sign-in-button';
import { Card } from '@/components/ui/card';
import { useTranslation } from '@/lib/i18n/i18n-provider';

type CallbackState = 'loading' | 'success' | 'error';

export default function GoogleCallbackPage() {
  const router = useRouter();
  const { t } = useTranslation();
  const [state, setState] = useState<CallbackState>('loading');
  const [message, setMessage] = useState('');

  const fallbackHref = useMemo(() => authRoutes.login, []);

  useEffect(() => {
    async function finishGoogleLogin() {
      const hashParams = new URLSearchParams(window.location.hash.slice(1));
      const queryParams = new URLSearchParams(window.location.search);
      const error =
        hashParams.get('error_description') ??
        hashParams.get('error') ??
        queryParams.get('error_description') ??
        queryParams.get('error');
      const returnedState = hashParams.get('state') ?? queryParams.get('state');
      const expectedState = window.sessionStorage.getItem(GOOGLE_OAUTH_STATE_KEY);
      const accessToken = hashParams.get('access_token');

      window.history.replaceState(null, '', '/auth/google/callback');
      window.sessionStorage.removeItem(GOOGLE_OAUTH_STATE_KEY);

      if (error) {
        throw new Error(error);
      }
      if (!expectedState || returnedState !== expectedState) {
        throw new Error(t('auth.google.stateMismatch'));
      }
      if (!accessToken) {
        throw new Error(t('auth.google.noToken'));
      }

      const auth = await apiFetch<AuthResponse>('/auth/google', {
        method: 'POST',
        body: JSON.stringify({ accessToken }),
      });
      persistAuthSession(auth);
      setState('success');
      setMessage(auth.user.email);
      router.replace(
        auth.user.role === 'ADMIN' ? authRoutes.admin : authRoutes.dashboard,
      );
      router.refresh();
    }

    finishGoogleLogin().catch((cause) => {
      setState('error');
      setMessage(cause instanceof Error ? cause.message : t('auth.google.serverDenied'));
    });
  }, [router, t]);

  return (
    <main className="flex min-h-screen items-center justify-center p-6">
      <Card className="w-full max-w-md text-center">
        <p className="text-sm uppercase tracking-[0.2em] text-violet">
          {t('auth.google.callbackEyebrow')}
        </p>
        <h1 className="mt-3 text-3xl font-bold text-ink">
          {state === 'error'
            ? t('auth.google.failed')
            : state === 'success'
              ? t('auth.google.success')
              : t('auth.google.finishing')}
        </h1>
        {message ? (
          <p className="mt-4 text-sm font-semibold text-[var(--app-muted)]">
            {message}
          </p>
        ) : null}
        {state === 'error' ? (
          <Link
            className="mt-6 inline-flex font-semibold text-[var(--brand-primary)] hover:underline"
            href={fallbackHref}
          >
            {t('auth.google.backToLogin')}
          </Link>
        ) : null}
      </Card>
    </main>
  );
}

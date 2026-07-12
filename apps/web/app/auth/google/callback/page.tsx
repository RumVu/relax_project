'use client';

import { useEffect, useMemo, useRef, useState } from 'react';
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

const MAX_RETRIES = 3;
const RETRY_DELAY_MS = 1500;

async function fetchWithRetry<T>(
  path: string,
  init: RequestInit,
  retries = MAX_RETRIES,
): Promise<T> {
  for (let attempt = 0; attempt <= retries; attempt++) {
    try {
      return await apiFetch<T>(path, init);
    } catch (err) {
      const isNetworkError =
        err instanceof TypeError && /fetch|network/i.test(err.message);
      if (!isNetworkError || attempt === retries) throw err;
      await new Promise((r) => setTimeout(r, RETRY_DELAY_MS * (attempt + 1)));
    }
  }
  throw new Error('Unreachable');
}

export default function GoogleCallbackPage() {
  const router = useRouter();
  const { t } = useTranslation();
  const [state, setState] = useState<CallbackState>('loading');
  const [message, setMessage] = useState('');
  const [retryCount, setRetryCount] = useState(0);
  const handledRef = useRef(false);
  const paramsRef = useRef<{
    authorizationCode: string;
    redirectUri: string;
  } | null>(null);

  const fallbackHref = useMemo(() => authRoutes.login, []);

  useEffect(() => {
    async function finishGoogleLogin() {
      if (handledRef.current) {
        return;
      }
      handledRef.current = true;

      const hashParams = new URLSearchParams(window.location.hash.slice(1));
      const queryParams = new URLSearchParams(window.location.search);
      const error =
        hashParams.get('error_description') ??
        hashParams.get('error') ??
        queryParams.get('error_description') ??
        queryParams.get('error');
      const returnedState = hashParams.get('state') ?? queryParams.get('state');
      const expectedState = window.sessionStorage.getItem(GOOGLE_OAUTH_STATE_KEY);
      const authorizationCode = queryParams.get('code') ?? hashParams.get('code');
      const redirectUri = `${window.location.origin}/auth/google/callback`;

      window.history.replaceState(null, '', '/auth/google/callback');
      window.sessionStorage.removeItem(GOOGLE_OAUTH_STATE_KEY);

      if (error) {
        throw new Error(error);
      }
      if (!expectedState || returnedState !== expectedState) {
        throw new Error(t('auth.google.stateMismatch'));
      }
      if (!authorizationCode) {
        throw new Error(t('auth.google.noToken'));
      }

      paramsRef.current = { authorizationCode, redirectUri };

      const auth = await fetchWithRetry<AuthResponse>('/auth/google', {
        method: 'POST',
        body: JSON.stringify({ authorizationCode, redirectUri }),
      });
      await persistAuthSession(auth);
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

  async function handleManualRetry() {
    if (!paramsRef.current) return;
    setState('loading');
    setMessage('');
    setRetryCount((c) => c + 1);
    try {
      const auth = await fetchWithRetry<AuthResponse>('/auth/google', {
        method: 'POST',
        body: JSON.stringify(paramsRef.current),
      });
      await persistAuthSession(auth);
      setState('success');
      setMessage(auth.user.email);
      router.replace(
        auth.user.role === 'ADMIN' ? authRoutes.admin : authRoutes.dashboard,
      );
      router.refresh();
    } catch (cause) {
      setState('error');
      setMessage(
        cause instanceof Error ? cause.message : t('auth.google.serverDenied'),
      );
    }
  }

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
          <div className="mt-6 flex flex-col items-center gap-3">
            {paramsRef.current && retryCount < 3 ? (
              <button
                type="button"
                onClick={handleManualRetry}
                className="inline-flex items-center gap-2 rounded-lg bg-violet px-5 py-2.5 text-sm font-semibold text-white transition-opacity hover:opacity-90"
              >
                {t('auth.google.retry')}
              </button>
            ) : null}
            <Link
              className="inline-flex font-semibold text-[var(--brand-primary)] hover:underline"
              href={fallbackHref}
            >
              {t('auth.google.backToLogin')}
            </Link>
          </div>
        ) : null}
      </Card>
    </main>
  );
}

'use client';

import { useEffect, useRef, useState } from 'react';
import { useRouter } from 'next/navigation';
import {
  apiFetch,
  type AuthResponse,
  persistAuthSession,
} from '@/lib/api';
import { authRoutes } from '@/lib/auth';
import { Button } from '@/components/ui/button';
import { useUiStore } from '@/stores/use-ui-store';
import { useTranslation } from '@/lib/i18n/i18n-provider';

const GIS_SRC = 'https://accounts.google.com/gsi/client';

type GsiTokenResponse = {
  access_token?: string;
  error?: string;
  error_description?: string;
};
type GsiTokenClient = {
  requestAccessToken: (overrideConfig?: { prompt?: string }) => void;
};

declare global {
  interface Window {
    google?: {
      accounts?: {
        oauth2?: {
          initTokenClient: (config: {
            client_id: string;
            scope: string;
            prompt?: string;
            callback: (response: GsiTokenResponse) => void;
            error_callback?: (error: { type?: string; message?: string }) => void;
          }) => GsiTokenClient;
        };
      };
    };
  }
}

/**
 * "Sign in with Google" button. We use the GIS OAuth popup instead
 * of the pre-rendered iframe button so users always see a stable app
 * button and Google is forced to open the account chooser.
 *
 * Requires NEXT_PUBLIC_GOOGLE_CLIENT_ID to be set at build time.
 * Falls back to a disabled hint when missing so the page still
 * renders + the operator gets a clear setup message.
 */
export function GoogleSignInButton({
  mode: _mode = 'signin',
}: {
  mode?: 'signin' | 'signup';
}) {
  const router = useRouter();
  const pushToast = useUiStore((state) => state.pushToast);
  const { t } = useTranslation();
  const tokenClientRef = useRef<GsiTokenClient | null>(null);
  const [busy, setBusy] = useState(false);
  const [ready, setReady] = useState(false);
  const clientId = process.env.NEXT_PUBLIC_GOOGLE_CLIENT_ID;

  useEffect(() => {
    if (!clientId) return;

    let cancelled = false;

    async function ensureScript(): Promise<void> {
      if (window.google?.accounts?.oauth2) return;
      await new Promise<void>((resolve, reject) => {
        const existing = document.querySelector<HTMLScriptElement>(
          `script[src="${GIS_SRC}"]`,
        );
        if (existing) {
          existing.addEventListener('load', () => resolve());
          existing.addEventListener('error', () =>
            reject(new Error('GIS load failed')),
          );
          if (window.google?.accounts?.oauth2) resolve();
          return;
        }
        const script = document.createElement('script');
        script.src = GIS_SRC;
        script.async = true;
        script.defer = true;
        script.onload = () => resolve();
        script.onerror = () => reject(new Error('GIS load failed'));
        document.head.appendChild(script);
      });
    }

    ensureScript()
      .then(async () => {
        if (cancelled) return;
        const oauth2 = window.google?.accounts?.oauth2;
        if (!oauth2) return;
        tokenClientRef.current = oauth2.initTokenClient({
          client_id: clientId,
          scope: 'openid email profile',
          prompt: 'select_account',
          callback: async (response) => {
            if (response.error) {
              pushToast({
                tone: 'error',
                title: t('auth.google.failed'),
                message: response.error_description ?? response.error,
              });
              return;
            }
            if (!response.access_token) return;
            await exchangeAccessToken(response.access_token);
          },
          error_callback: (error) => {
            pushToast({
              tone: 'error',
              title: t('auth.google.failed'),
              message: error.message ?? error.type ?? t('auth.google.popupFailed'),
            });
          },
        });
        setReady(true);
      })
      .catch(() => {
        if (!cancelled) {
          pushToast({
            tone: 'error',
            title: t('auth.google.failed'),
            message: t('auth.google.popupFailed'),
          });
        }
      });

    async function exchangeAccessToken(accessToken: string) {
      setBusy(true);
      try {
        const auth = await apiFetch<AuthResponse>('/auth/google', {
          method: 'POST',
          body: JSON.stringify({ accessToken }),
        });
        persistAuthSession(auth);
        pushToast({
          tone: 'success',
          title: t('auth.google.success'),
          message: auth.user.email,
        });
        router.push(
          auth.user.role === 'ADMIN' ? authRoutes.admin : authRoutes.dashboard,
        );
        router.refresh();
      } catch (error) {
        const message =
          error && typeof error === 'object' && 'message' in error
            ? String((error as { message?: string }).message)
            : t('auth.google.serverDenied');
        pushToast({
          tone: 'error',
          title: t('auth.google.failed'),
          message,
        });
      } finally {
        setBusy(false);
      }
    }

    return () => {
      cancelled = true;
    };
  }, [clientId, pushToast, router, t]);

  if (!clientId) {
    return (
      <div className="rounded-2xl border border-dashed border-[var(--field-border)] bg-[var(--panel-bg)] px-4 py-3 text-xs font-semibold text-[var(--app-muted)]">
        {t('auth.google.notConfigured', { key: 'NEXT_PUBLIC_GOOGLE_CLIENT_ID' })}
      </div>
    );
  }

  return (
    <div className="space-y-2">
      <Button
        className="h-12 w-full bg-white text-slate-900 hover:bg-white/90"
        disabled={busy || !ready}
        onClick={() => tokenClientRef.current?.requestAccessToken({ prompt: 'select_account' })}
        type="button"
        variant="secondary"
      >
        <span className="flex h-7 w-7 items-center justify-center rounded-full bg-white text-lg font-extrabold text-blue-600">
          G
        </span>
        {busy ? t('auth.signingIn') : t('auth.google.button')}
      </Button>
      {busy ? (
        <p className="text-center text-xs font-semibold text-[var(--app-muted)]">
          {t('auth.signingIn')}
        </p>
      ) : null}
    </div>
  );
}

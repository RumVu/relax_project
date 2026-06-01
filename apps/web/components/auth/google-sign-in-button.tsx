'use client';

import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { useTranslation } from '@/lib/i18n/i18n-provider';

const GOOGLE_AUTH_URL = 'https://accounts.google.com/o/oauth2/v2/auth';
const GOOGLE_OAUTH_STATE_KEY = 'relax_google_oauth_state';

function createState() {
  if (typeof crypto !== 'undefined' && 'randomUUID' in crypto) {
    return crypto.randomUUID();
  }

  return `${Date.now()}-${Math.random().toString(36).slice(2)}`;
}

export function GoogleSignInButton({
  mode = 'signin',
}: {
  mode?: 'signin' | 'signup';
}) {
  const { t } = useTranslation();
  const [busy, setBusy] = useState(false);
  const clientId = process.env.NEXT_PUBLIC_GOOGLE_CLIENT_ID;

  function startGoogleLogin() {
    if (!clientId || typeof window === 'undefined') return;

    setBusy(true);
    const state = createState();
    window.sessionStorage.setItem(GOOGLE_OAUTH_STATE_KEY, state);

    const params = new URLSearchParams({
      client_id: clientId,
      redirect_uri: `${window.location.origin}/auth/google/callback`,
      response_type: 'code',
      scope: 'openid email profile',
      prompt: 'select_account',
      state,
      include_granted_scopes: 'true',
    });

    // eslint-disable-next-line @next/next/no-location-assign-relative-destination
    window.location.href = `${GOOGLE_AUTH_URL}?${params.toString()}`;
  }

  if (!clientId) {
    return (
      <div className="rounded-2xl border border-dashed border-[var(--field-border)] bg-[var(--panel-bg)] px-4 py-3 text-xs font-semibold text-[var(--app-muted)]">
        {t('auth.google.notConfigured', { key: 'NEXT_PUBLIC_GOOGLE_CLIENT_ID' })}
      </div>
    );
  }

  return (
    <Button
      className="h-12 w-full bg-white text-slate-900 hover:bg-white/90"
      disabled={busy}
      onClick={startGoogleLogin}
      type="button"
      variant="secondary"
    >
      <span className="flex h-7 w-7 items-center justify-center rounded-full bg-white text-lg font-extrabold text-blue-600">
        G
      </span>
      {busy
        ? t('auth.google.redirecting')
        : mode === 'signup'
          ? t('auth.google.signupButton')
          : t('auth.google.button')}
    </Button>
  );
}

export { GOOGLE_OAUTH_STATE_KEY };

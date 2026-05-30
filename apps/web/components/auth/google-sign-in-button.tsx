'use client';

import { useEffect, useRef, useState } from 'react';
import { useRouter } from 'next/navigation';
import {
  apiFetch,
  type AuthResponse,
  persistAuthSession,
} from '@/lib/api';
import { authRoutes } from '@/lib/auth';
import { useUiStore } from '@/stores/use-ui-store';

const GIS_SRC = 'https://accounts.google.com/gsi/client';

type GsiCredentialResponse = { credential?: string };
type GsiButtonOptions = {
  type?: 'standard' | 'icon';
  theme?: 'outline' | 'filled_blue' | 'filled_black';
  size?: 'large' | 'medium' | 'small';
  text?: 'signin_with' | 'signup_with' | 'continue_with' | 'signin';
  shape?: 'rectangular' | 'pill' | 'circle' | 'square';
  logo_alignment?: 'left' | 'center';
  width?: number;
};

declare global {
  interface Window {
    google?: {
      accounts?: {
        id?: {
          initialize: (config: {
            client_id: string;
            callback: (response: GsiCredentialResponse) => void;
            auto_select?: boolean;
            cancel_on_tap_outside?: boolean;
          }) => void;
          renderButton: (
            parent: HTMLElement,
            options: GsiButtonOptions,
          ) => void;
        };
      };
    };
  }
}

/**
 * "Sign in with Google" button. Loads Google Identity Services
 * (gsi/client) once per page, renders Google's official branded
 * button, and on success POSTs the ID token to /v1/auth/google.
 *
 * Requires NEXT_PUBLIC_GOOGLE_CLIENT_ID to be set at build time.
 * Falls back to a disabled hint when missing so the page still
 * renders + the operator gets a clear setup message.
 */
export function GoogleSignInButton({
  mode = 'signin',
}: {
  mode?: 'signin' | 'signup';
}) {
  const router = useRouter();
  const pushToast = useUiStore((state) => state.pushToast);
  const containerRef = useRef<HTMLDivElement>(null);
  const [busy, setBusy] = useState(false);
  const clientId = process.env.NEXT_PUBLIC_GOOGLE_CLIENT_ID;

  useEffect(() => {
    if (!clientId || !containerRef.current) return;

    let cancelled = false;
    const parent = containerRef.current;

    async function ensureScript(): Promise<void> {
      if (window.google?.accounts?.id) return;
      await new Promise<void>((resolve, reject) => {
        const existing = document.querySelector<HTMLScriptElement>(
          `script[src="${GIS_SRC}"]`,
        );
        if (existing) {
          existing.addEventListener('load', () => resolve());
          existing.addEventListener('error', () =>
            reject(new Error('GIS load failed')),
          );
          if (window.google?.accounts?.id) resolve();
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
        const gsi = window.google?.accounts?.id;
        if (!gsi) return;
        gsi.initialize({
          client_id: clientId,
          callback: async (response) => {
            if (!response.credential) return;
            await exchangeIdToken(response.credential);
          },
          auto_select: false,
          cancel_on_tap_outside: true,
        });
        parent.innerHTML = '';
        // GIS width must be 200-400. We hard-code 320 (a safe middle
        // value) instead of reading `parent.clientWidth` because the
        // flex container can render 0 wide before children exist,
        // which silently produced an invisible 0px button on prod.
        gsi.renderButton(parent, {
          type: 'standard',
          theme: 'filled_blue',
          size: 'large',
          shape: 'pill',
          text: mode === 'signup' ? 'signup_with' : 'continue_with',
          logo_alignment: 'left',
          width: 320,
        });
      })
      .catch(() => undefined);

    async function exchangeIdToken(idToken: string) {
      setBusy(true);
      try {
        const auth = await apiFetch<AuthResponse>('/auth/google', {
          method: 'POST',
          body: JSON.stringify({ idToken }),
        });
        persistAuthSession(auth);
        pushToast({
          tone: 'success',
          title: 'Đã đăng nhập bằng Google',
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
            : 'Backend không nhận Google ID token.';
        pushToast({
          tone: 'error',
          title: 'Đăng nhập Google thất bại',
          message,
        });
      } finally {
        setBusy(false);
      }
    }

    return () => {
      cancelled = true;
    };
  }, [clientId, mode, pushToast, router]);

  if (!clientId) {
    return (
      <div className="rounded-2xl border border-dashed border-[var(--field-border)] bg-[var(--panel-bg)] px-4 py-3 text-xs font-semibold text-[var(--app-muted)]">
        Đăng nhập Google chưa bật. Set <code>NEXT_PUBLIC_GOOGLE_CLIENT_ID</code>
        {' '}rồi rebuild web.
      </div>
    );
  }

  return (
    <div className="space-y-2">
      {/* min-h ensures the row has measurable height even before GIS
       *  injects its iframe — prevents the layout from flickering and
       *  gives the user a "loading" affordance if the script is slow.
       *  Inline-grid centring keeps the GIS iframe naturally sized. */}
      <div
        className="grid min-h-[44px] place-items-center"
        ref={containerRef}
      />
      {busy ? (
        <p className="text-center text-xs font-semibold text-[var(--app-muted)]">
          Đang đăng nhập…
        </p>
      ) : null}
    </div>
  );
}

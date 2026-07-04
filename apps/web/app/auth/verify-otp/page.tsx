'use client';

import { FormEvent, useCallback, useEffect, useState } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { apiFetch, type AuthResponse, persistAuthSession } from '@/lib/api';
import { authRoutes } from '@/lib/auth';
import { OtpInput } from '@/components/auth/otp-input';
import { CatMascot } from '@/components/dashboard/cat-mascot';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';

export default function VerifyOtpPage() {
  const router = useRouter();
  const params = useSearchParams();
  const email = params.get('email') ?? '';
  const purpose = (params.get('purpose') ?? 'registration') as
    | 'registration'
    | 'password-reset';

  const [code, setCode] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const [resending, setResending] = useState(false);
  const [resent, setResent] = useState(false);
  const [cooldown, setCooldown] = useState(0);

  useEffect(() => {
    if (cooldown <= 0) return;
    const timer = setTimeout(() => setCooldown((c) => c - 1), 1000);
    return () => clearTimeout(timer);
  }, [cooldown]);

  const handleResend = useCallback(async () => {
    if (resending || cooldown > 0) return;
    setResending(true);
    setResent(false);
    setError(null);
    try {
      await apiFetch('/auth/otp/resend', {
        method: 'POST',
        body: JSON.stringify({ email, purpose }),
      });
      setResent(true);
      setCooldown(60);
    } catch {
      setError('Could not resend OTP. Please try again.');
    } finally {
      setResending(false);
    }
  }, [email, purpose, resending, cooldown]);

  async function handleSubmit(e: FormEvent) {
    e.preventDefault();
    const trimmed = code.replace(/\s/g, '');
    if (trimmed.length !== 6) {
      setError('Please enter the full 6-digit code.');
      return;
    }

    setError(null);
    setLoading(true);

    try {
      if (purpose === 'registration') {
        const auth = await apiFetch<AuthResponse>('/auth/otp/verify', {
          method: 'POST',
          body: JSON.stringify({ email, code: trimmed }),
        });
        persistAuthSession(auth);
        router.push(
          auth.user.role === 'ADMIN'
            ? authRoutes.admin
            : authRoutes.dashboard,
        );
        router.refresh();
      }
    } catch {
      setError('Invalid or expired OTP code. Please try again.');
    } finally {
      setLoading(false);
    }
  }

  if (!email) {
    router.replace('/auth/register');
    return null;
  }

  return (
    <main className="flex min-h-screen items-center justify-center p-6">
      <Card className="w-full max-w-md text-center">
        <div className="flex justify-center">
          <CatMascot variant="stand" size="lg" className="opacity-80" />
        </div>
        <h1 className="mt-4 text-2xl font-bold text-ink">Verify your email</h1>
        <p className="mt-2 text-sm text-[var(--app-muted)]">
          We sent a 6-digit code to{' '}
          <span className="font-semibold text-[var(--app-text)]">{email}</span>
        </p>

        <form className="mt-8 space-y-6" onSubmit={handleSubmit}>
          <OtpInput value={code} onChange={setCode} disabled={loading} />

          {error && (
            <p className="text-sm font-medium text-red-700">{error}</p>
          )}
          {resent && !error && (
            <p className="text-sm font-medium text-emerald-600">
              A new code has been sent!
            </p>
          )}

          <Button className="w-full" disabled={loading || code.replace(/\s/g, '').length !== 6} type="submit">
            {loading ? 'Verifying...' : 'Verify'}
          </Button>
        </form>

        <p className="mt-6 text-sm text-[var(--app-muted)]">
          {"Didn't receive the code? "}
          <button
            className="font-semibold text-[var(--brand-primary)] hover:underline disabled:opacity-50"
            disabled={resending || cooldown > 0}
            onClick={handleResend}
            type="button"
          >
            {cooldown > 0 ? `Resend in ${cooldown}s` : 'Resend'}
          </button>
        </p>
      </Card>
    </main>
  );
}

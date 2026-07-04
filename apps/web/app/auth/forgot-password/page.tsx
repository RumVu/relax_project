'use client';

import { FormEvent, useCallback, useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { apiFetch } from '@/lib/api';
import { OtpInput } from '@/components/auth/otp-input';
import { CatMascot } from '@/components/dashboard/cat-mascot';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { PASSWORD_REQUIREMENT, isStrongPassword } from '@/lib/password';

type Step = 'email' | 'otp' | 'done';

export default function ForgotPasswordPage() {
  const router = useRouter();
  const [step, setStep] = useState<Step>('email');
  const [email, setEmail] = useState('');
  const [code, setCode] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const [cooldown, setCooldown] = useState(0);

  useEffect(() => {
    if (cooldown <= 0) return;
    const timer = setTimeout(() => setCooldown((c) => c - 1), 1000);
    return () => clearTimeout(timer);
  }, [cooldown]);

  async function handleRequestOtp(e: FormEvent) {
    e.preventDefault();
    setError(null);
    setLoading(true);
    try {
      await apiFetch('/auth/password-reset/request', {
        method: 'POST',
        body: JSON.stringify({ email }),
      });
      setStep('otp');
      setCooldown(60);
    } catch {
      setError('Could not send reset code. Please try again.');
    } finally {
      setLoading(false);
    }
  }

  const handleResend = useCallback(async () => {
    if (cooldown > 0) return;
    setError(null);
    try {
      await apiFetch('/auth/otp/resend', {
        method: 'POST',
        body: JSON.stringify({ email, purpose: 'password-reset' }),
      });
      setCooldown(60);
    } catch {
      setError('Could not resend code.');
    }
  }, [email, cooldown]);

  async function handleResetPassword(e: FormEvent) {
    e.preventDefault();
    const trimmed = code.replace(/\s/g, '');
    if (trimmed.length !== 6) {
      setError('Please enter the full 6-digit code.');
      return;
    }
    if (!isStrongPassword(password)) {
      setError(PASSWORD_REQUIREMENT);
      return;
    }
    setError(null);
    setLoading(true);
    try {
      await apiFetch('/auth/password-reset/otp', {
        method: 'POST',
        body: JSON.stringify({ email, code: trimmed, password }),
      });
      setStep('done');
    } catch {
      setError('Invalid or expired code. Please try again.');
    } finally {
      setLoading(false);
    }
  }

  return (
    <main className="flex min-h-screen items-center justify-center p-6">
      <Card className="w-full max-w-md text-center">
        <div className="flex justify-center">
          <CatMascot variant="sleep" size="lg" className="opacity-80" />
        </div>

        {step === 'email' && (
          <>
            <h1 className="mt-4 text-2xl font-bold text-ink">Reset password</h1>
            <p className="mt-2 text-sm text-[var(--app-muted)]">
              Enter your email and we&apos;ll send a 6-digit code.
            </p>
            <form className="mt-6 space-y-4" onSubmit={handleRequestOtp}>
              <input
                autoComplete="email"
                className="w-full rounded-2xl border bg-white/70 px-4 py-3"
                onChange={(e) => setEmail(e.target.value)}
                placeholder="Email"
                required
                type="email"
                value={email}
              />
              {error && <p className="text-sm font-medium text-red-700">{error}</p>}
              <Button className="w-full" disabled={loading} type="submit">
                {loading ? 'Sending...' : 'Send reset code'}
              </Button>
            </form>
          </>
        )}

        {step === 'otp' && (
          <>
            <h1 className="mt-4 text-2xl font-bold text-ink">Enter code</h1>
            <p className="mt-2 text-sm text-[var(--app-muted)]">
              Code sent to{' '}
              <span className="font-semibold text-[var(--app-text)]">{email}</span>
            </p>
            <form className="mt-6 space-y-4" onSubmit={handleResetPassword}>
              <OtpInput value={code} onChange={setCode} disabled={loading} />
              <input
                autoComplete="new-password"
                className="w-full rounded-2xl border bg-white/70 px-4 py-3"
                maxLength={72}
                minLength={10}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="New password"
                required
                type="password"
                value={password}
              />
              <p className="text-xs font-semibold text-slate-600">{PASSWORD_REQUIREMENT}</p>
              {error && <p className="text-sm font-medium text-red-700">{error}</p>}
              <Button className="w-full" disabled={loading || code.replace(/\s/g, '').length !== 6} type="submit">
                {loading ? 'Resetting...' : 'Reset password'}
              </Button>
            </form>
            <p className="mt-4 text-sm text-[var(--app-muted)]">
              <button
                className="font-semibold text-[var(--brand-primary)] hover:underline disabled:opacity-50"
                disabled={cooldown > 0}
                onClick={handleResend}
                type="button"
              >
                {cooldown > 0 ? `Resend in ${cooldown}s` : 'Resend code'}
              </button>
            </p>
          </>
        )}

        {step === 'done' && (
          <>
            <h1 className="mt-4 text-2xl font-bold text-ink">Password reset!</h1>
            <p className="mt-2 text-sm text-[var(--app-muted)]">
              Your password has been updated. You can now sign in.
            </p>
            <Button className="mt-6 w-full" onClick={() => router.push('/auth/login')}>
              Sign in
            </Button>
          </>
        )}

        <p className="mt-6 text-center text-sm text-[var(--app-muted)]">
          <Link className="font-semibold text-[var(--brand-primary)] hover:underline" href="/auth/login">
            Back to sign in
          </Link>
        </p>
      </Card>
    </main>
  );
}

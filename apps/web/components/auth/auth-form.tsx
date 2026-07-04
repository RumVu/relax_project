'use client';

import { FormEvent, useState } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { apiFetch, type AuthResponse, persistAuthSession } from '@/lib/api';
import { authRoutes } from '@/lib/auth';
import { Button } from '@/components/ui/button';
import { PASSWORD_REQUIREMENT, isStrongPassword } from '@/lib/password';

type AuthFormMode = 'login' | 'register';

interface AuthFormProps {
  mode: AuthFormMode;
}

interface RegisterOtpResponse {
  success: boolean;
  requiresOtp: boolean;
  email: string;
}

export function AuthForm({ mode }: AuthFormProps) {
  const router = useRouter();
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const isRegister = mode === 'register';

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setError(null);

    if (isRegister && !isStrongPassword(password)) {
      setError(PASSWORD_REQUIREMENT);
      return;
    }

    setLoading(true);

    try {
      if (isRegister) {
        const result = await apiFetch<RegisterOtpResponse>(
          '/auth/register',
          {
            method: 'POST',
            body: JSON.stringify({ email, password, name }),
          },
        );
        if (result.requiresOtp) {
          router.push(
            `/auth/verify-otp?email=${encodeURIComponent(result.email)}&purpose=registration`,
          );
          return;
        }
      } else {
        const auth = await apiFetch<AuthResponse>('/auth/login', {
          method: 'POST',
          body: JSON.stringify({ email, password }),
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
      setError(
        isRegister
          ? 'Could not create that account. Check the details and try again.'
          : 'Email or password is incorrect.',
      );
    } finally {
      setLoading(false);
    }
  }

  return (
    <form className="mt-6 space-y-4" onSubmit={handleSubmit}>
      {isRegister ? (
        <input
          autoComplete="name"
          className="w-full rounded-2xl border border-[var(--field-border)] bg-[var(--field-bg)] px-4 py-3 text-[var(--app-text)] placeholder:text-[var(--app-muted)] focus:border-[var(--brand-primary)]"
          onChange={(event) => setName(event.target.value)}
          placeholder="Full name"
          required
          value={name}
        />
      ) : null}
      <input
        autoComplete="email"
        className="w-full rounded-2xl border bg-white/70 px-4 py-3"
        onChange={(event) => setEmail(event.target.value)}
        placeholder="Email"
        required
        type="email"
        value={email}
      />
      <div className="relative">
        <input
          autoComplete={isRegister ? 'new-password' : 'current-password'}
          className="w-full rounded-2xl border bg-white/70 px-4 py-3 pr-12"
          maxLength={isRegister ? 72 : undefined}
          minLength={isRegister ? 10 : undefined}
          onChange={(event) => setPassword(event.target.value)}
          placeholder="Password"
          required
          type={showPassword ? 'text' : 'password'}
          value={password}
        />
        <button
          type="button"
          className="absolute right-3 top-1/2 -translate-y-1/2 text-[var(--app-muted)] hover:text-[var(--app-text)] transition-colors"
          onClick={() => setShowPassword(!showPassword)}
          tabIndex={-1}
        >
          {showPassword ? (
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"/><line x1="1" y1="1" x2="23" y2="23"/></svg>
          ) : (
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
          )}
        </button>
      </div>
      {isRegister ? (
        <p className="text-xs font-semibold text-slate-600">
          {PASSWORD_REQUIREMENT}
        </p>
      ) : null}
      {!isRegister ? (
        <div className="text-right">
          <Link
            className="text-xs font-semibold text-[var(--brand-primary)] hover:underline"
            href="/auth/forgot-password"
          >
            Forgot password?
          </Link>
        </div>
      ) : null}
      {error ? <p className="text-sm font-medium text-red-700">{error}</p> : null}
      <Button className="w-full" disabled={loading} type="submit">
        {loading ? 'Please wait...' : isRegister ? 'Register' : 'Login'}
      </Button>
    </form>
  );
}

'use client';

import { FormEvent, useState } from 'react';
import { useRouter } from 'next/navigation';
import { apiFetch, type AuthResponse, persistAuthSession } from '@/lib/api';
import { authRoutes } from '@/lib/auth';
import { Button } from '@/components/ui/button';

type AuthFormMode = 'login' | 'register';

interface AuthFormProps {
  mode: AuthFormMode;
}

export function AuthForm({ mode }: AuthFormProps) {
  const router = useRouter();
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const isRegister = mode === 'register';

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setError(null);
    setLoading(true);

    try {
      const auth = await apiFetch<AuthResponse>(
        isRegister ? '/auth/register' : '/auth/login',
        {
          method: 'POST',
          body: JSON.stringify({
            email,
            password,
            ...(isRegister ? { name } : {}),
          }),
        },
      );

      persistAuthSession(auth);
      router.push(auth.user.role === 'ADMIN' ? authRoutes.admin : authRoutes.dashboard);
      router.refresh();
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
      <input
        autoComplete={isRegister ? 'new-password' : 'current-password'}
        className="w-full rounded-2xl border bg-white/70 px-4 py-3"
        minLength={8}
        onChange={(event) => setPassword(event.target.value)}
        placeholder="Password"
        required
        type="password"
        value={password}
      />
      {error ? <p className="text-sm font-medium text-red-700">{error}</p> : null}
      <Button className="w-full" disabled={loading} type="submit">
        {loading ? 'Please wait...' : isRegister ? 'Register' : 'Login'}
      </Button>
    </form>
  );
}

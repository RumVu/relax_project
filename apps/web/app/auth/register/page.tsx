import Link from 'next/link';
import { AuthForm } from '@/components/auth/auth-form';
import { GoogleSignInButton } from '@/components/auth/google-sign-in-button';
import { Card } from '@/components/ui/card';

export default function RegisterPage() {
  return (
    <main className="flex min-h-screen items-center justify-center p-6">
      <Card className="w-full max-w-md">
        <p className="text-sm uppercase tracking-[0.2em] text-violet">Create account</p>
        <h1 className="mt-3 text-3xl font-bold text-ink">Start building healthier break rituals</h1>
        <div className="mt-6">
          <GoogleSignInButton mode="signup" />
        </div>
        <div className="my-5 flex items-center gap-3 text-xs font-semibold uppercase tracking-[0.18em] text-[var(--app-muted)]">
          <span className="h-px flex-1 bg-[var(--field-border)]" />
          hoặc
          <span className="h-px flex-1 bg-[var(--field-border)]" />
        </div>
        <AuthForm mode="register" />
        <p className="mt-6 text-center text-sm text-[var(--app-muted)]">
          Already have an account?{' '}
          <Link
            className="font-semibold text-[var(--brand-primary)] hover:underline"
            href="/auth/login"
          >
            Sign in
          </Link>
        </p>
      </Card>
    </main>
  );
}

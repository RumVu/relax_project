import Link from 'next/link';
import { AuthForm } from '@/components/auth/auth-form';
import { Card } from '@/components/ui/card';

export default function LoginPage() {
  return (
    <main className="flex min-h-screen items-center justify-center p-6">
      <Card className="w-full max-w-md">
        <p className="text-sm uppercase tracking-[0.2em] text-ember">Welcome back</p>
        <h1 className="mt-3 text-3xl font-bold text-ink">Sign in to the recovery dashboard</h1>
        <AuthForm mode="login" />
        <p className="mt-6 text-sm text-ink/60">
          No account yet? <Link className="font-semibold text-moss" href="/auth/register">Create one</Link>
        </p>
      </Card>
    </main>
  );
}

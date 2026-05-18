import Link from 'next/link';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';

export default function RegisterPage() {
  return (
    <main className="flex min-h-screen items-center justify-center p-6">
      <Card className="w-full max-w-md">
        <p className="text-sm uppercase tracking-[0.2em] text-ember">Create account</p>
        <h1 className="mt-3 text-3xl font-bold text-ink">Start building healthier break rituals</h1>
        <div className="mt-6 space-y-4">
          <input className="w-full rounded-2xl border bg-white/70 px-4 py-3" placeholder="Full name" />
          <input className="w-full rounded-2xl border bg-white/70 px-4 py-3" placeholder="Email" />
          <input className="w-full rounded-2xl border bg-white/70 px-4 py-3" placeholder="Password" type="password" />
          <Button className="w-full">Register</Button>
        </div>
        <p className="mt-6 text-sm text-ink/60">
          Already have an account? <Link className="font-semibold text-moss" href="/auth/login">Sign in</Link>
        </p>
      </Card>
    </main>
  );
}

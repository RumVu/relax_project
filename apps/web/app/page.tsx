import Link from 'next/link';
import { dashboardStats } from '@/lib/constants';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';

export default function HomePage() {
  return (
    <main className="min-h-screen px-4 py-10 md:px-8">
      <section className="mx-auto max-w-6xl space-y-10">
        <div className="rounded-[36px] bg-ink px-8 py-10 text-mist shadow-panel">
          <Badge className="bg-white/12 text-mist">Recovery rituals for modern stress</Badge>
          <h1 className="mt-6 max-w-3xl text-5xl font-extrabold tracking-tight">
            Digital Cigarette Break turns burnout patterns into intentional reset moments.
          </h1>
          <p className="mt-4 max-w-2xl text-base text-mist/75">
            A product system for mood tracking, mindful breaks, journaling, ambient recovery, and supportive admin tooling.
          </p>
          <div className="mt-8 flex flex-wrap gap-3">
            <Link href="/dashboard">
              <Button>Open dashboard</Button>
            </Link>
            <Link href="/auth/login">
              <Button variant="secondary">Try auth flow</Button>
            </Link>
          </div>
        </div>

        <div className="grid gap-4 md:grid-cols-3">
          {dashboardStats.map((stat) => (
            <Card key={stat.label}>
              <p className="text-sm text-ink/60">{stat.label}</p>
              <p className="mt-3 text-3xl font-extrabold text-ink">{stat.value}</p>
              <p className="mt-2 text-sm text-ink/70">{stat.note}</p>
            </Card>
          ))}
        </div>
      </section>
    </main>
  );
}

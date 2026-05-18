'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { adminNav, primaryNav } from '@/lib/constants';
import { cn } from '@/lib/utils';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { useDashboardStore } from '@/stores/use-dashboard-store';

export function DashboardShell({
  title,
  eyebrow,
  children,
  admin = false,
}: {
  title: string;
  eyebrow: string;
  children: React.ReactNode;
  admin?: boolean;
}) {
  const pathname = usePathname();
  const nav = admin ? adminNav : primaryNav;
  const { focusMode, toggleFocusMode } = useDashboardStore();

  return (
    <main className="min-h-screen p-4 md:p-8">
      <div className="mx-auto grid max-w-7xl gap-6 lg:grid-cols-[260px_minmax(0,1fr)]">
        <Card className="h-fit bg-ink text-mist">
          <p className="text-xs uppercase tracking-[0.25em] text-mist/60">Digital Cigarette Break</p>
          <h1 className="mt-3 text-2xl font-bold">{admin ? 'Admin Console' : 'Recovery Dashboard'}</h1>
          <div className="mt-8 space-y-2">
            {nav.map((item) => (
              <Link
                key={item.href}
                href={item.href}
                className={cn(
                  'block rounded-2xl px-4 py-3 text-sm transition',
                  pathname === item.href ? 'bg-white/16 text-white' : 'text-mist/70 hover:bg-white/10 hover:text-white',
                )}
              >
                {item.label}
              </Link>
            ))}
          </div>
          <div className="mt-8 rounded-3xl bg-white/10 p-4">
            <p className="text-sm font-semibold">Focus mode</p>
            <p className="mt-1 text-sm text-mist/70">
              Reduce dashboard noise while the user is in a guided break cycle.
            </p>
            <Button className="mt-4 w-full" variant="secondary" onClick={toggleFocusMode}>
              {focusMode ? 'Disable Focus Mode' : 'Enable Focus Mode'}
            </Button>
          </div>
        </Card>

        <section className="space-y-6">
          <div className="rounded-[32px] bg-grain p-8">
            <p className="text-sm uppercase tracking-[0.25em] text-ember">{eyebrow}</p>
            <div className="mt-2 flex flex-col gap-4 md:flex-row md:items-end md:justify-between">
              <div>
                <h2 className="text-4xl font-extrabold tracking-tight text-ink">{title}</h2>
                <p className="mt-2 max-w-2xl text-sm text-ink/70">
                  A calm control surface for mood recovery, mindful rituals, and lightweight operational visibility.
                </p>
              </div>
              <Button>Sync with API</Button>
            </div>
          </div>
          {children}
        </section>
      </div>
    </main>
  );
}

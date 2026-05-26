'use client';

import { AlertTriangle, RefreshCcw } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';

export default function ErrorPage({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  return (
    <main className="flex min-h-screen items-center justify-center px-4 py-10">
      <Card className="max-w-xl">
        <div className="flex h-12 w-12 items-center justify-center rounded-lg bg-coral/15 text-coral">
          <AlertTriangle className="h-6 w-6" />
        </div>
        <p className="mt-6 text-xs font-bold uppercase tracking-[0.2em] text-plum">
          Có lỗi rồi ní
        </p>
        <h1 className="mt-3 text-3xl font-extrabold text-[var(--app-text)]">
          Trang này vừa vấp một nhịp.
        </h1>
        <p className="mt-3 text-sm font-semibold text-[var(--app-muted)]">
          {error.message || 'Không tải được dữ liệu cho trang hiện tại.'}
        </p>
        {error.digest ? (
          <p className="mt-3 rounded-lg bg-lilac/40 px-3 py-2 text-xs font-mono text-plum">
            digest: {error.digest}
          </p>
        ) : null}
        <Button className="mt-6" onClick={reset}>
          <RefreshCcw className="h-4 w-4" />
          Thử lại
        </Button>
      </Card>
    </main>
  );
}

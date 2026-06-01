'use client';

import { useCallback, useEffect, useState } from 'react';
import { AlertCircle, CheckCircle2, Info, X } from 'lucide-react';
import { useUiStore } from '@/stores/use-ui-store';
import { cn } from '@/lib/utils';

const iconByTone = {
  success: CheckCircle2,
  error: AlertCircle,
  info: Info,
};

export function ToastRegion() {
  const toasts = useUiStore((state) => state.toasts);
  const removeToast = useUiStore((state) => state.removeToast);
  const [closingIds, setClosingIds] = useState<Set<string>>(() => new Set());
  const closeToast = useCallback(
    (id: string) => {
      setClosingIds((current) => new Set(current).add(id));
      window.setTimeout(() => {
        removeToast(id);
        setClosingIds((current) => {
          const next = new Set(current);
          next.delete(id);
          return next;
        });
      }, 280);
    },
    [removeToast],
  );

  useEffect(() => {
    const timers = toasts.map((toast) =>
      window.setTimeout(() => closeToast(toast.id), 2000),
    );

    return () => {
      for (const timer of timers) {
        window.clearTimeout(timer);
      }
    };
  }, [closeToast, toasts]);

  return (
    <div className="pointer-events-none fixed right-4 top-4 z-50 flex w-[min(92vw,360px)] flex-col gap-3">
      {toasts.map((toast) => {
        const Icon = iconByTone[toast.tone];
        const closing = closingIds.has(toast.id);

        return (
          <div
            className={cn(
              'pointer-events-auto rounded-2xl border bg-white/95 p-4 shadow-panel backdrop-blur transition-all duration-300 ease-in-out',
              closing ? 'translate-x-[120%] scale-95 opacity-0' : 'translate-x-0 opacity-100',
              toast.tone === 'success' && 'border-mint/40',
              toast.tone === 'error' && 'border-coral/40',
              toast.tone === 'info' && 'border-violet/30',
            )}
            key={toast.id}
          >
            <div className="flex items-start gap-3">
              <div
                className={cn(
                  'mt-0.5 flex h-9 w-9 shrink-0 items-center justify-center rounded-full',
                  toast.tone === 'success' && 'bg-mint/15 text-mint',
                  toast.tone === 'error' && 'bg-coral/15 text-coral',
                  toast.tone === 'info' && 'bg-violet/15 text-violet',
                )}
              >
                <Icon className="h-4 w-4" />
              </div>
              <div className="min-w-0 flex-1">
                <p className="text-sm font-extrabold text-ink">{toast.title}</p>
                {toast.message ? (
                  <p className="mt-1 text-sm text-slate">{toast.message}</p>
                ) : null}
              </div>
              <button
                className="text-slate transition hover:text-ink"
                onClick={() => closeToast(toast.id)}
                type="button"
              >
                <X className="h-4 w-4" />
              </button>
            </div>
          </div>
        );
      })}
    </div>
  );
}

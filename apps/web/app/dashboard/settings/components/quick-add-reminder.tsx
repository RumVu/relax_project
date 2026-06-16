'use client';

import { useState } from 'react';
import { Save } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { apiFetch } from '@/lib/api';
import { useUiStore } from '@/stores/use-ui-store';
import { useTranslation } from '@/lib/i18n/i18n-provider';
import { VI_SETTINGS_COPY, EN_SETTINGS_COPY } from '../settings-copy';

export function QuickAddReminder({
  defaultTitle,
  onCreated,
}: {
  defaultTitle: string;
  onCreated: () => void;
}) {
  const pushToast = useUiStore((state) => state.pushToast);
  const { locale } = useTranslation();
  const copy = locale === 'en' ? EN_SETTINGS_COPY : VI_SETTINGS_COPY;
  const [time, setTime] = useState(() => {
    const d = new Date();
    d.setHours(d.getHours() + 1, 0, 0, 0);
    return `${String(d.getHours()).padStart(2, '0')}:${String(d.getMinutes()).padStart(2, '0')}`;
  });
  const [busy, setBusy] = useState(false);

  return (
    <div className="mt-3 flex flex-wrap items-end gap-3">
      <label className="flex-1 min-w-[120px]">
        <span className="text-xs font-semibold text-[var(--app-muted,theme(colors.slate))]">
          {copy.reminderTime}
        </span>
        <input
          className="mt-2 h-11 w-full rounded-lg border border-[var(--field-border)] bg-[var(--field-bg)] px-3 text-sm font-semibold text-[var(--app-text,theme(colors.ink))] outline-none"
          onChange={(event) => setTime(event.target.value)}
          type="time"
          value={time}
        />
      </label>
      <Button
        disabled={busy || !time}
        onClick={async () => {
          if (!time) return;
          setBusy(true);
          try {
            const [hh, mm] = time.split(':').map(Number);
            const scheduled = new Date();
            scheduled.setHours(hh ?? 9, mm ?? 0, 0, 0);
            if (scheduled.getTime() < Date.now()) {
              scheduled.setDate(scheduled.getDate() + 1);
            }
            await apiFetch('/reminders/me', {
              method: 'POST',
              body: JSON.stringify({
                title: defaultTitle,
                message: copy.quickAddMessage,
                type: 'BREATHING',
                scheduledAt: scheduled.toISOString(),
                isActive: true,
              }),
            });
            onCreated();
            pushToast({ tone: 'success', title: copy.quickAdded(time) });
          } catch {
            pushToast({ tone: 'error', title: copy.quickAddFailed });
          } finally {
            setBusy(false);
          }
        }}
        variant="secondary"
      >
        <Save className="h-4 w-4" />
        {busy ? copy.adding : copy.quickAdd}
      </Button>
    </div>
  );
}


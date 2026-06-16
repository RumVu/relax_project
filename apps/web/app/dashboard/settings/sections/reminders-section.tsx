'use client';

import { useState } from 'react';
import { Repeat, Save, Trash2 } from 'lucide-react';
import { Card } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { SectionTitle, DataTable } from '@/components/dashboard/dashboard-ui';
import { apiFetch } from '@/lib/api';
import { Field } from '../components/ui-cards';
import { nextLocalReminderTime } from '../settings-utils';
import type { ReminderDraft } from '../settings-types';

interface RemindersSectionProps {
  t: any;
  locale: 'vi' | 'en';
  copy: any;
  settings: any;
  triggerRefresh: () => void;
  setRefreshKey: (updater: (prev: number) => number) => void;
  pushToast: (toast: any) => void;
}

export function RemindersSection({
  t,
  locale,
  copy,
  settings,
  triggerRefresh,
  setRefreshKey,
  pushToast,
}: RemindersSectionProps) {
  const [reminderDraft, setReminderDraft] = useState<ReminderDraft>({
    title: copy.defaultReminderTitle,
    message: copy.defaultReminderMessage,
    type: 'BREATHING',
    scheduledAt: nextLocalReminderTime(),
  });
  const [reminderState, setReminderState] = useState<'idle' | 'saving'>('idle');

  return (
    <Card>
      <SectionTitle
        title={copy.remindersTitle}
        copy={copy.remindersCopy}
        action={<Repeat className="h-5 w-5 text-violet" />}
      />
      <div className="mt-5 grid gap-4">
        <div className="grid gap-3 sm:grid-cols-2 xl:grid-cols-[minmax(0,1fr)_180px_220px_auto]">
          <Field
            label={copy.titleLabel}
            value={reminderDraft.title}
            onChange={(value) =>
              setReminderDraft((current) => ({ ...current, title: value }))
            }
          />
          <Field
            label={copy.typeLabel}
            select
            value={reminderDraft.type}
            options={['WATER', 'REST', 'BREATHING', 'JOURNAL', 'SLEEP', 'CUSTOM']}
            onChange={(value) =>
              setReminderDraft((current) => ({
                ...current,
                type: value as ReminderDraft['type'],
              }))
            }
          />
          <Field
            label={copy.datetimeLabel}
            type="datetime-local"
            value={reminderDraft.scheduledAt}
            onChange={(value) =>
              setReminderDraft((current) => ({
                ...current,
                scheduledAt: value,
              }))
            }
          />
          <div className="sm:col-span-2">
            <Button
              className="w-full sm:w-auto"
              disabled={reminderState === 'saving'}
              onClick={async () => {
                setReminderState('saving');
                try {
                  await apiFetch('/reminders/me', {
                    method: 'POST',
                    body: JSON.stringify({
                      ...reminderDraft,
                      scheduledAt: new Date(
                        reminderDraft.scheduledAt,
                      ).toISOString(),
                      isActive: true,
                    }),
                  });
                  setRefreshKey((current) => current + 1);
                  triggerRefresh();
                  setReminderDraft((current) => ({
                    ...current,
                    scheduledAt: nextLocalReminderTime(),
                  }));
                  pushToast({
                    tone: 'success',
                    title: copy.reminderCreated,
                    message: copy.reminderCreatedMessage(reminderDraft.title),
                  });
                } catch {
                  pushToast({
                    tone: 'error',
                    title: copy.reminderCreateFailed,
                    message: t('settings.toast.serverHint'),
                  });
                } finally {
                  setReminderState('idle');
                }
              }}
            >
              <Save className="h-4 w-4" />
              {reminderState === 'saving' ? copy.creating : copy.createReminder}
            </Button>
          </div>
        </div>
        <div className="mt-2 flex flex-wrap items-center justify-between gap-3">
          <p className="text-sm font-semibold text-[var(--app-muted,theme(colors.slate))]">
            {copy.savedReminderCount(settings.reminders.length)}
          </p>
          {settings.reminders.length > 0 ? (
            <Button
              className="h-9 px-3 text-xs"
              disabled={reminderState === 'saving'}
              onClick={async () => {
                const ok = window.confirm(
                  copy.confirmDeleteAllReminders(settings.reminders.length),
                );
                if (!ok) return;
                setReminderState('saving');
                try {
                  await Promise.all(
                    settings.reminders.map((reminder: any) =>
                      apiFetch(`/reminders/${reminder.id}`, {
                        method: 'DELETE',
                      }).catch(() => undefined),
                    ),
                  );
                  setRefreshKey((current) => current + 1);
                  triggerRefresh();
                  pushToast({
                    tone: 'success',
                    title: copy.deletedReminderCount(settings.reminders.length),
                  });
                } finally {
                  setReminderState('idle');
                }
              }}
              variant="secondary"
            >
              <Trash2 className="h-3.5 w-3.5" />
              {copy.deleteAll}
            </Button>
          ) : null}
        </div>
        <DataTable
          columns={[
            copy.typeLabel,
            copy.titleLabel,
            copy.scheduleLabel,
            t('catalog.col.status'),
            t('catalog.col.actions'),
          ]}
          rows={settings.reminders.map((reminder: any) => [
            <span
              className="inline-flex rounded-full bg-violet/15 px-2 py-0.5 text-xs font-bold text-violet"
              key={`${reminder.id}-type`}
            >
              {reminder.type}
            </span>,
            reminder.title,
            reminder.schedule,
            reminder.active ? copy.on : copy.off,
            <div className="flex gap-2" key={reminder.id}>
              <Button
                className="h-8 px-3 text-xs"
                onClick={async () => {
                  try {
                    await apiFetch(`/reminders/${reminder.id}`, {
                      method: 'PATCH',
                      body: JSON.stringify({
                        isActive: !reminder.active,
                      }),
                    });
                    setRefreshKey((current) => current + 1);
                    triggerRefresh();
                    pushToast({
                      tone: 'success',
                      title: reminder.active
                        ? copy.reminderDisabled
                        : copy.reminderEnabled,
                    });
                  } catch {
                    pushToast({
                      tone: 'error',
                      title: copy.reminderStatusFailed,
                    });
                  }
                }}
                variant="secondary"
              >
                {reminder.active ? copy.disable : copy.enable}
              </Button>
              <Button
                className="h-8 px-3 text-xs"
                onClick={async () => {
                  try {
                    await apiFetch(`/reminders/${reminder.id}`, {
                      method: 'DELETE',
                    });
                    setRefreshKey((current) => current + 1);
                    triggerRefresh();
                    pushToast({
                      tone: 'success',
                      title: copy.reminderDeleted,
                    });
                  } catch {
                    pushToast({
                      tone: 'error',
                      title: copy.reminderDeleteFailed,
                    });
                  }
                }}
              >
                {t('btn.delete')}
              </Button>
            </div>,
          ])}
        />
      </div>
    </Card>
  );
}

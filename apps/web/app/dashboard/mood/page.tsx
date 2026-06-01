'use client';

import { useMemo, useState } from 'react';
import { useRouter } from 'next/navigation';
import {
  BatteryMedium,
  CloudRain,
  Moon,
  Plus,
  Save,
  Sparkles,
  Sun,
  Trash2,
  Zap,
} from 'lucide-react';
import { DashboardShell } from '@/components/layout/dashboard-shell';
import {
  DataTable,
  DistributionChart,
  MetricCard,
  MoodAreaDashboardChart,
  ProgressList,
  SectionTitle,
} from '@/components/dashboard/dashboard-ui';
import { DashboardFilterBar, useDashboardFilters } from '@/components/dashboard/dashboard-filters';
import { ActionModal } from '@/components/ui/action-modal';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { apiFetch } from '@/lib/api';
import { useUserDashboardData } from '@/lib/live-dashboard';
import { useDashboardStore } from '@/stores/use-dashboard-store';
import { useUiStore } from '@/stores/use-ui-store';
import { cn } from '@/lib/utils';
import { useTranslation } from '@/lib/i18n/i18n-provider';

const iconMap = {
  sun: Sun,
  cloud: CloudRain,
  zap: Zap,
  moon: Moon,
  battery: BatteryMedium,
  sparkles: Sparkles,
};

export default function MoodPage() {
  const router = useRouter();
  const { t } = useTranslation();
  const moodFilters = useDashboardFilters('/mood-checkins/me', 'mood');
  const refreshNonce = useDashboardStore((state) => state.refreshNonce);
  const triggerRefresh = useDashboardStore((state) => state.triggerRefresh);
  const pushToast = useUiStore((state) => state.pushToast);
  const data = useUserDashboardData({
    refreshKey: refreshNonce,
    moodQuery: moodFilters.query,
    moodAnalyticsQuery: moodFilters.query,
    weeklyStatsQuery: moodFilters.query,
  });
  const [selectedMood, setSelectedMood] = useState(data.moodOptions[0]?.type ?? 'NEUTRAL');
  const [note, setNote] = useState('');
  const [editingId, setEditingId] = useState<string | null>(null);
  const [editingIntensity, setEditingIntensity] = useState(3);
  const [saveState, setSaveState] = useState<'idle' | 'saving' | 'saved' | 'error'>('idle');
  const [modalOpen, setModalOpen] = useState(false);
  const selected =
    data.moodOptions.find((mood) => mood.type === selectedMood) ?? data.moodOptions[0];
  const historyRows = useMemo(
    () =>
      data.moodHistory.map((item) => [
        item.createdAt,
        item.mood,
        `${item.intensity || '-'} / 5`,
        item.note,
        <div className="flex flex-wrap gap-2" key={item.id}>
          <Button
            className="h-8 px-3 text-xs"
            onClick={() => {
              setEditingId(item.id);
              setSelectedMood(item.moodType);
              setEditingIntensity(item.intensity || 3);
              setNote(item.note === t('mood.history.noNote') || item.note === 'Không có ghi chú' ? '' : item.note);
            }}
            variant="secondary"
          >
            {t('mood.history.edit')}
          </Button>
          <Button
            className="h-8 px-3 text-xs"
            onClick={async () => {
              try {
                await apiFetch(`/mood-checkins/${item.id}`, { method: 'DELETE' });
                triggerRefresh();
                pushToast({
                  tone: 'success',
                  title: t('mood.toast.deleted'),
                });
              } catch {
                pushToast({
                  tone: 'error',
                  title: t('mood.toast.deleteFailed'),
                });
              }
            }}
          >
            <Trash2 className="h-3.5 w-3.5" />
            {t('mood.history.delete')}
          </Button>
        </div>,
      ]),
    [data.moodHistory, pushToast, triggerRefresh, t],
  );

  return (
    <DashboardShell eyebrow={t('mood.page.eyebrow')} title={t('mood.page.title')}>
      <ActionModal
        description={t('mood.modal.description')}
        onClose={() => setModalOpen(false)}
        onPrimary={() => {
          setModalOpen(false);
          router.push('/dashboard/analytics');
        }}
        onSecondary={() => setModalOpen(false)}
        open={modalOpen}
        primaryLabel={t('mood.modal.viewAnalytics')}
        secondaryLabel={t('mood.modal.stay')}
        title={t('mood.modal.title')}
      />
      <DashboardFilterBar {...moodFilters} title={t('mood.filterTitle')} />

      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        <MetricCard
          icon={Sparkles}
          label={t('mood.metric.current')}
          note={data.overview.mood.prompt}
          value={data.overview.mood.currentMood}
        />
        <MetricCard
          icon={Zap}
          label={t('mood.metric.averageIntensity')}
          note={t('mood.metric.averageIntensity.note')}
          tone="coral"
          value={data.overview.mood.summary.averageIntensity}
        />
        <MetricCard
          icon={Sun}
          label={t('mood.metric.topMood')}
          note={t('mood.metric.topMood.note')}
          tone="sun"
          value={data.overview.mood.summary.topMood}
        />
        <MetricCard
          icon={Moon}
          label={t('mood.metric.longestStreak')}
          note={t('mood.metric.longestStreak.note')}
          tone="lilac"
          value={data.overview.mood.summary.longestStreak}
        />
      </div>

      <div className="grid gap-4 xl:grid-cols-[minmax(0,0.95fr)_minmax(0,1.05fr)]">
        <Card>
          <SectionTitle
            title={editingId ? t('mood.checkin.editHeading') : t('mood.checkin.heading')}
            copy={t('mood.checkin.copy')}
            action={<Plus className="h-5 w-5 text-violet" />}
          />
          <div className="mt-5 grid gap-3 sm:grid-cols-2">
            {data.moodOptions.map((mood) => {
              const Icon = iconMap[mood.icon as keyof typeof iconMap] ?? Sparkles;
              const active = selectedMood === mood.type;

              return (
                <button
                  className={cn(
                    'flex min-h-[96px] flex-col items-start justify-between rounded-lg border p-4 text-left transition',
                    active
                      ? 'border-violet bg-violet text-white shadow-panel'
                      : 'border-lilac/70 bg-white/70 hover:border-violet',
                  )}
                  key={mood.type}
                  onClick={() => setSelectedMood(mood.type)}
                  type="button"
                >
                  <Icon className="h-5 w-5" />
                  <span className="font-bold">{mood.label}</span>
                  <span className={cn('text-xs', active ? 'text-white/70' : 'text-slate')}>
                    {t('mood.history.rawScore', { value: mood.value })}
                  </span>
                </button>
              );
            })}
          </div>
          <label className="mt-5 block">
            <span className="text-sm font-semibold text-ink">{t('mood.form.note')}</span>
            <textarea
              className="mt-2 min-h-[120px] w-full rounded-lg border border-lilac bg-white/85 p-3 text-sm outline-none focus:border-violet"
              maxLength={120}
              onChange={(event) => setNote(event.target.value)}
              placeholder={t('mood.checkin.notePlaceholder')}
              value={note}
            />
          </label>
          <div className="mt-4 flex flex-wrap items-center justify-between gap-3">
            <p className="text-sm font-semibold text-slate">
              {t('mood.history.selected', {
                label: selected?.label ?? '',
                used: note.length,
                max: 120,
              })}
            </p>
            {editingId ? (
              <label className="flex items-center gap-2 text-sm font-semibold text-slate">
                {t('mood.checkin.intensity')}
                <input
                  className="h-10 w-20 rounded-lg border border-lilac bg-white/85 px-3 text-sm text-ink outline-none focus:border-violet"
                  max={5}
                  min={1}
                  onChange={(event) => setEditingIntensity(Number(event.target.value))}
                  type="number"
                  value={editingIntensity}
                />
              </label>
            ) : null}
            <Button
              disabled={saveState === 'saving'}
              onClick={async () => {
                setSaveState('saving');
                try {
                  await apiFetch(editingId ? `/mood-checkins/${editingId}` : '/mood-checkins/me', {
                    method: editingId ? 'PATCH' : 'POST',
                    body: JSON.stringify({
                      mood: selectedMood,
                      intensity: editingId
                        ? Math.max(1, Math.min(5, editingIntensity))
                        : Math.max(
                            1,
                            Math.min(5, Math.round((selected?.value ?? 60) / 20)),
                          ),
                      note: note || undefined,
                      tags: ['web-dashboard'],
                  }),
                  });
                  setSaveState('saved');
                  setEditingId(null);
                  setNote('');
                  triggerRefresh();
                  setModalOpen(true);
                  pushToast({
                    tone: 'success',
                    title: editingId ? t('mood.toast.updatedTitle') : t('mood.toast.savedTitle'),
                    message: t('mood.toast.savedMessage'),
                  });
                } catch {
                  setSaveState('error');
                  pushToast({
                    tone: 'error',
                    title: t('mood.toast.saveFailed'),
                    message: t('mood.toast.saveFailedMessage'),
                  });
                }
              }}
            >
              <Save className="h-4 w-4" />
              {saveState === 'saving'
                ? t('mood.checkin.saving')
                : editingId
                  ? t('mood.checkin.update')
                  : t('mood.checkin.save')}
            </Button>
          </div>
          {editingId ? (
            <Button
              className="mt-3"
              onClick={() => {
                setEditingId(null);
                setNote('');
                setEditingIntensity(3);
                setSelectedMood(data.moodOptions[0]?.type ?? 'NEUTRAL');
              }}
              variant="secondary"
            >
              {t('mood.checkin.cancelEdit')}
            </Button>
          ) : null}
          {saveState === 'saved' || saveState === 'error' ? (
            <p
              className={cn(
                'mt-3 text-sm font-semibold',
                saveState === 'saved' ? 'text-mint' : 'text-coral',
              )}
            >
              {saveState === 'saved' ? t('mood.checkin.saved') : t('mood.checkin.failed')}
            </p>
          ) : null}
        </Card>

        <Card>
          <SectionTitle
            title={t('mood.suggestions.heading')}
            copy={t('mood.suggestions.copy')}
          />
          <div className="mt-5 space-y-3">
            {data.overview.mood.recommendations.map((item, index) => (
              <div
                className="flex gap-3 rounded-lg border border-lilac/70 bg-white/75 p-4"
                key={item}
              >
                <span className="flex h-7 w-7 shrink-0 items-center justify-center rounded-lg bg-lilac text-sm font-extrabold text-plum">
                  {index + 1}
                </span>
                <p className="text-sm font-medium text-ink">{item}</p>
              </div>
            ))}
          </div>
          <div className="mt-5">
            <ProgressList items={data.distribution} />
          </div>
        </Card>
      </div>

      <div className="grid gap-4 xl:grid-cols-[minmax(0,1.2fr)_minmax(320px,0.8fr)]">
        <MoodAreaDashboardChart data={data.timeline} />
        <DistributionChart data={data.distribution} />
      </div>

      <Card>
        <SectionTitle
          title={t('mood.historyTable.heading')}
          copy={t('mood.historyTable.copy')}
        />
        <div className="mt-5">
          <DataTable
            columns={[
              t('mood.historyTable.time'),
              t('mood.historyTable.mood'),
              t('mood.historyTable.intensity'),
              t('mood.historyTable.note'),
              t('mood.historyTable.action'),
            ]}
            rows={historyRows}
          />
        </div>
      </Card>
    </DashboardShell>
  );
}

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
      ]),
    [data.moodHistory],
  );

  return (
    <DashboardShell eyebrow="Mood intelligence" title="Theo dõi cảm xúc">
      <ActionModal
        description="Check-in mới đã được lưu. Anh có thể qua Analytics để xem ảnh hưởng lên biểu đồ, hoặc ở lại ghi thêm một mood khác."
        onClose={() => setModalOpen(false)}
        onPrimary={() => {
          setModalOpen(false);
          router.push('/dashboard/analytics');
        }}
        onSecondary={() => setModalOpen(false)}
        open={modalOpen}
        primaryLabel="Xem analytics"
        secondaryLabel="Ở lại màn này"
        title="Đã lưu check-in"
      />
      <DashboardFilterBar {...moodFilters} title="Bộ lọc lịch sử mood" />

      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        <MetricCard
          icon={Sparkles}
          label="Mood hiện tại"
          note={data.overview.mood.prompt}
          value={data.overview.mood.currentMood}
        />
        <MetricCard
          icon={Zap}
          label="Average intensity"
          note="0-100"
          tone="coral"
          value={data.overview.mood.summary.averageIntensity}
        />
        <MetricCard
          icon={Sun}
          label="Top mood"
          note="trong tuần"
          tone="sun"
          value={data.overview.mood.summary.topMood}
        />
        <MetricCard
          icon={Moon}
          label="Longest streak"
          note="ngày"
          tone="lilac"
          value={data.overview.mood.summary.longestStreak}
        />
      </div>

      <div className="grid gap-4 xl:grid-cols-[minmax(0,0.95fr)_minmax(0,1.05fr)]">
        <Card>
          <SectionTitle
            title="Check-in mới"
            copy="Chọn cảm xúc gần nhất của anh rồi ghi vài dòng để hệ thống hiểu nhịp tâm trạng tốt hơn."
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
                    rawScore {mood.value}/100
                  </span>
                </button>
              );
            })}
          </div>
          <label className="mt-5 block">
            <span className="text-sm font-semibold text-ink">Ghi chú</span>
            <textarea
              className="mt-2 min-h-[120px] w-full rounded-lg border border-lilac bg-white/85 p-3 text-sm outline-none focus:border-violet"
              maxLength={120}
              onChange={(event) => setNote(event.target.value)}
              placeholder="Viết vài dòng cho bé nghe nè..."
              value={note}
            />
          </label>
          <div className="mt-4 flex flex-wrap items-center justify-between gap-3">
            <p className="text-sm font-semibold text-slate">
              Selected: {selected?.label} • {note.length}/120
            </p>
            <Button
              disabled={saveState === 'saving'}
              onClick={async () => {
                setSaveState('saving');
                try {
                  await apiFetch('/mood-checkins/me', {
                    method: 'POST',
                    body: JSON.stringify({
                      mood: selectedMood,
                      intensity: Math.max(
                        1,
                        Math.min(5, Math.round((selected?.value ?? 60) / 20)),
                      ),
                      note: note || undefined,
                      tags: ['web-dashboard'],
                  }),
                });
                  setSaveState('saved');
                  setNote('');
                  triggerRefresh();
                  setModalOpen(true);
                  pushToast({
                    tone: 'success',
                    title: 'Đã lưu mood check-in',
                    message: 'Biểu đồ và lịch sử đang được làm mới.',
                  });
                } catch {
                  setSaveState('error');
                  pushToast({
                    tone: 'error',
                    title: 'Không lưu được check-in',
                    message: 'Kiểm tra đăng nhập hoặc backend.',
                  });
                }
              }}
            >
              <Save className="h-4 w-4" />
              {saveState === 'saving' ? 'Đang lưu' : 'Lưu check-in'}
            </Button>
          </div>
          {saveState === 'saved' || saveState === 'error' ? (
            <p
              className={cn(
                'mt-3 text-sm font-semibold',
                saveState === 'saved' ? 'text-mint' : 'text-coral',
              )}
            >
              {saveState === 'saved'
                ? 'Đã lưu qua API và refetch dashboard.'
                : 'Lưu check-in thất bại. Dữ liệu không được ghi và UI không dùng số liệu giả.'}
            </p>
          ) : null}
        </Card>

        <Card>
          <SectionTitle
            title="Gợi ý theo mood"
            copy="Ba gợi ý nhẹ nhàng được ưu tiên theo cảm xúc hiện tại và thói quen thư giãn gần đây."
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
          title="Lịch sử check-in"
          copy="Danh sách này lấy từ các lần check-in thật gần nhất để anh nhìn lại trạng thái và ghi chú của mình."
        />
        <div className="mt-5">
          <DataTable
            columns={['Thời điểm', 'Mood', 'Cường độ', 'Ghi chú']}
            rows={historyRows}
          />
        </div>
      </Card>
    </DashboardShell>
  );
}

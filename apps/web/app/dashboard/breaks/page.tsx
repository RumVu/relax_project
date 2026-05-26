'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { CheckCircle2, Headphones, Pause, PenLine, Play, Shuffle, Wind } from 'lucide-react';
import { DashboardShell } from '@/components/layout/dashboard-shell';
import {
  DataTable,
  MetricCard,
  RelaxActivityChart,
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

const activityIcons = {
  MUSIC: Headphones,
  PODCAST: Headphones,
  JOURNAL: PenLine,
  BREATHING: Wind,
  MYSTERY: Shuffle,
  MEDITATION: CheckCircle2,
};

export default function BreaksPage() {
  const router = useRouter();
  const relaxFilters = useDashboardFilters('/relax-activities/me/stats', 'relax');
  const refreshNonce = useDashboardStore((state) => state.refreshNonce);
  const triggerRefresh = useDashboardStore((state) => state.triggerRefresh);
  const pushToast = useUiStore((state) => state.pushToast);
  const data = useUserDashboardData({
    refreshKey: refreshNonce,
    relaxQuery: relaxFilters.query,
  });
  const [activeActivity, setActiveActivity] = useState(data.relaxActivities[0]?.id ?? '');
  const [activeSessionId, setActiveSessionId] = useState<string | null>(null);
  const [actionState, setActionState] = useState<
    'idle' | 'starting' | 'started' | 'finishing' | 'finished' | 'error'
  >('idle');
  const [sessionModal, setSessionModal] = useState<{
    open: boolean;
    phase: 'started' | 'finished';
  }>({
    open: false,
    phase: 'started',
  });
  const active =
    data.relaxActivities.find((activity) => activity.id === activeActivity) ??
    data.relaxActivities[0];
  const hasActivities = Boolean(active);
  const ActiveIcon = activityIcons[active?.type as keyof typeof activityIcons] ?? Play;

  return (
    <DashboardShell eyebrow="Break orchestration" title="Khu thư giãn">
      <ActionModal
        description={
          sessionModal.phase === 'started'
            ? `${active?.title ?? 'Phiên thư giãn'} đã bắt đầu. Khi xong anh có thể quay lại đây để finish hoặc đi thẳng sang Mood check-in.`
            : `${active?.title ?? 'Phiên thư giãn'} đã kết thúc. Anh có thể check-in lại mood ngay để ghi nhận mức nhẹ đầu sau phiên thư giãn.`
        }
        onClose={() => setSessionModal((current) => ({ ...current, open: false }))}
        onPrimary={() => {
          setSessionModal((current) => ({ ...current, open: false }));
          router.push(
            sessionModal.phase === 'started'
              ? '/dashboard/breaks'
              : '/dashboard/mood',
          );
        }}
        onSecondary={() => setSessionModal((current) => ({ ...current, open: false }))}
        open={sessionModal.open}
        primaryLabel={
          sessionModal.phase === 'started' ? 'Tiếp tục phiên' : 'Qua Mood check-in'
        }
        secondaryLabel="Đóng"
        title={
          sessionModal.phase === 'started'
            ? 'Phiên đã bắt đầu'
            : 'Phiên đã hoàn tất'
        }
      />
      <DashboardFilterBar {...relaxFilters} title="Bộ lọc break/relax" />

      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        <MetricCard icon={Play} label="Tổng phiên" value={data.overview.relax.totalSessions} />
        <MetricCard icon={Pause} label="Tổng thời gian" tone="lilac" value={data.overview.relax.totalDurationLabel} />
        <MetricCard icon={CheckCircle2} label="Streak thư giãn" note="ngày" tone="sun" value={data.overview.relax.streak} />
        <MetricCard icon={Wind} label="Relief trung bình" note="after activity" tone="mint" value={`${data.overview.relax.relief}%`} />
      </div>

      <div className="grid gap-4 xl:grid-cols-[minmax(0,1fr)_380px]">
        <Card>
          <SectionTitle title="Catalog hoạt động" copy="MUSIC/PODCAST/JOURNAL/BREATHING/MYSTERY/MEDITATION" />
          <div className="mt-5 grid gap-3 md:grid-cols-2">
            {data.relaxActivities.map((activity, index) => {
              const Icon = activityIcons[activity.type as keyof typeof activityIcons] ?? Play;
              const activeRow = activeActivity === activity.id;

              return (
                <button
                  className={`rounded-lg border p-4 text-left transition ${
                    activeRow
                      ? 'border-violet bg-violet text-white shadow-panel'
                      : 'border-lilac/70 bg-white/75 hover:border-violet'
                  }`}
                  key={activity.id}
                  onClick={() => setActiveActivity(activity.id)}
                  type="button"
                >
                  <div className="flex items-start justify-between gap-3">
                    <div className={`flex h-11 w-11 items-center justify-center rounded-lg ${activeRow ? 'bg-white/15' : 'bg-lilac text-plum'}`}>
                      <Icon className="h-5 w-5" />
                    </div>
                    <span className="font-mono text-xs font-bold">0{index + 1}</span>
                  </div>
                  <h3 className="mt-4 text-lg font-extrabold">{activity.title}</h3>
                  <p className={`mt-1 text-sm ${activeRow ? 'text-white/70' : 'text-slate'}`}>{activity.subtitle}</p>
                  <p className="mt-3 text-sm font-bold">{activity.duration} • relief {activity.relief}%</p>
                </button>
              );
            })}
            {data.relaxActivities.length === 0 ? (
              <div className="rounded-lg border border-dashed border-lilac bg-white/70 p-6 text-sm font-medium text-slate">
                Chưa tải được danh sách hoạt động thư giãn từ API.
              </div>
            ) : null}
          </div>
        </Card>

        <Card className="bg-night text-white">
          <SectionTitle
            title="Phiên đang chọn"
            copy="Start/finish flow cho popup check-in sau activity"
            action={<ActiveIcon className="h-5 w-5 text-mint" />}
          />
          <div className="mt-8 rounded-lg border border-white/10 bg-white/10 p-5">
            <div className="flex h-16 w-16 items-center justify-center rounded-lg bg-violet">
              <ActiveIcon className="h-8 w-8" />
            </div>
            <h3 className="mt-5 text-2xl font-extrabold">
              {active?.title ?? 'Chưa có hoạt động'}
            </h3>
            <p className="mt-2 text-sm text-mist/70">
              {active?.subtitle ?? 'Kết nối API để nạp catalog thư giãn.'}
            </p>
            <div className="mt-6 h-3 overflow-hidden rounded-full bg-white/15">
              <div className="h-full w-2/3 rounded-full bg-mint" />
            </div>
            <p className="mt-2 text-xs font-semibold text-mist/60">Đang chuẩn bị không gian thư giãn...</p>
          </div>
          <div className="mt-5 grid gap-2 sm:grid-cols-2">
            <Button
              disabled={actionState === 'starting' || !hasActivities}
              onClick={async () => {
                setActionState('starting');
                try {
                  if (!active) {
                    throw new Error('No active activity');
                  }
                  const session = await apiFetch<{ id?: string }>(
                    '/relax-activities/sessions/start',
                    {
                      method: 'POST',
                      body: JSON.stringify({
                        activityType: active.type,
                        title: active.title,
                        moodBefore: 'STRESSED',
                      }),
                    },
                  );
                  setActiveSessionId(session.id ?? null);
                  setActionState('started');
                  setSessionModal({ open: true, phase: 'started' });
                  pushToast({
                    tone: 'success',
                    title: 'Đã bắt đầu phiên thư giãn',
                    message: `${active.title} đang chạy.`,
                  });
                } catch {
                  setActionState('error');
                  pushToast({
                    tone: 'error',
                    title: 'Không start được session',
                  });
                }
              }}
            >
              <Play className="h-4 w-4" />
              {actionState === 'starting' ? 'Starting' : 'Start'}
            </Button>
            <Button
              disabled={actionState === 'finishing' || !activeSessionId}
              onClick={async () => {
                setActionState('finishing');
                try {
                  if (!activeSessionId) {
                    throw new Error('No active session');
                  }
                  await apiFetch(`/relax-activities/sessions/${activeSessionId}/finish`, {
                    method: 'POST',
                    body: JSON.stringify({
                      moodAfter: 'CALM',
                      reliefLevel: 4,
                      note: 'Finished from web dashboard',
                    }),
                  });
                  setActionState('finished');
                  setActiveSessionId(null);
                  triggerRefresh();
                  setSessionModal({ open: true, phase: 'finished' });
                  pushToast({
                    tone: 'success',
                    title: 'Đã kết thúc phiên thư giãn',
                    message: 'Bảng thống kê và lịch sử đã được làm mới.',
                  });
                } catch {
                  setActionState('error');
                  pushToast({
                    tone: 'error',
                    title: 'Không finish được session',
                  });
                }
              }}
              variant="secondary"
            >
              <CheckCircle2 className="h-4 w-4" />
              {actionState === 'finishing' ? 'Finishing' : 'Finish'}
            </Button>
          </div>
          {actionState === 'started' || actionState === 'finished' || actionState === 'error' ? (
            <p
              className={`mt-3 text-sm font-semibold ${
                actionState === 'error' ? 'text-coral' : 'text-mint'
              }`}
            >
              {actionState === 'error'
                ? 'Phiên chưa đổi trạng thái vì API trả lỗi.'
                : actionState === 'started'
                  ? 'Phiên đã start qua API.'
                  : 'Phiên đã finish qua API.'}
            </p>
          ) : null}
        </Card>
      </div>

      <RelaxActivityChart data={data.relaxActivities} />

      <Card>
        <SectionTitle title="Lịch sử phiên" copy="Các phiên thư giãn gần đây của anh." />
        <div className="mt-5">
          <DataTable
            columns={['Activity', 'Time', 'Duration', 'Relief']}
            rows={data.overview.relax.recentMoments.map((moment) => [
              moment.title,
              moment.time,
              moment.duration,
              `${moment.relief}%`,
            ])}
          />
        </div>
      </Card>
    </DashboardShell>
  );
}

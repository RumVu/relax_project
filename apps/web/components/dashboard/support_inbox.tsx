'use client';

import { useCallback, useEffect, useState } from 'react';
import { CheckCircle2, MessageSquare, AlertCircle, RefreshCcw, Archive } from 'lucide-react';
import { DashboardShell } from '@/components/layout/dashboard-shell';
import { DataTable, MetricCard, SectionTitle } from '@/components/dashboard/dashboard-ui';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { apiFetch } from '@/lib/api';
import { useUiStore } from '@/stores/use-ui-store';
import { useTranslation } from '@/lib/i18n/i18n-provider';

type Feedback = {
  id: string;
  subject: string;
  message: string;
  status: string;
  createdAt: string;
  user?: {
    id: string;
    name: string | null;
    email: string;
  } | null;
};

export function SupportInbox() {
  const { t } = useTranslation();
  const pushToast = useUiStore((state) => state.pushToast);
  const [feedbacks, setFeedbacks] = useState<Feedback[]>([]);
  const [loading, setLoading] = useState(true);

  const loadFeedbacks = useCallback(async () => {
    setLoading(true);
    try {
      const data = await apiFetch<Feedback[]>('/feedbacks');
      setFeedbacks(data);
    } catch (e) {
      pushToast({
        tone: 'error',
        title: t('admin.support.loadError'),
        message: e instanceof Error ? e.message : String(e),
      });
    } finally {
      setLoading(false);
    }
  }, [pushToast, t]);

  useEffect(() => {
    void loadFeedbacks();
  }, [loadFeedbacks]);

  const updateStatus = async (id: string, newStatus: string) => {
    try {
      await apiFetch(`/feedbacks/${id}/status`, {
        method: 'PATCH',
        body: JSON.stringify({ status: newStatus }),
      });
      pushToast({
        tone: 'success',
        title: t('admin.support.statusUpdated'),
        message: `Feedback status set to ${newStatus}`,
      });
      void loadFeedbacks();
    } catch (e) {
      pushToast({
        tone: 'error',
        title: t('admin.support.statusError'),
        message: e instanceof Error ? e.message : String(e),
      });
    }
  };

  const openTickets = feedbacks.filter((f) => f.status === 'OPEN').length;
  const resolvedTickets = feedbacks.filter((f) => f.status === 'RESOLVED').length;

  return (
    <DashboardShell admin title={t('admin.support.title')} eyebrow="Admin Panel">
      <div className="grid gap-4 sm:grid-cols-3">
        <MetricCard
          icon={MessageSquare}
          label={t('admin.support.totalFeedbacks')}
          tone="violet"
          value={String(feedbacks.length)}
        />
        <MetricCard
          icon={AlertCircle}
          label={t('admin.support.openTickets')}
          tone="coral"
          value={String(openTickets)}
        />
        <MetricCard
          icon={CheckCircle2}
          label={t('admin.support.resolved')}
          tone="mint"
          value={String(resolvedTickets)}
        />
      </div>

      <Card>
        <SectionTitle
          title={t('admin.support.sectionTitle')}
          copy={t('admin.support.sectionCopy')}
          action={
            <Button onClick={() => void loadFeedbacks()} variant="secondary">
              <RefreshCcw className="h-4 w-4 mr-2" />
              {t('admin.support.refresh')}
            </Button>
          }
        />

        <div className="mt-6">
          {loading ? (
            <div className="py-8 text-center text-sm font-semibold text-slate-500">
              {t('admin.support.loading')}
            </div>
          ) : feedbacks.length === 0 ? (
            <div className="py-8 text-center text-sm font-semibold text-slate-400">
              {t('admin.support.empty')}
            </div>
          ) : (
            <DataTable
              columns={['User', 'Type & Subject', 'Message', 'Date', 'Status', 'Actions']}
              rows={feedbacks.map((f) => {
                const type = f.subject.match(/^\[(.*?)\]/)?.[1] || 'FEEDBACK';
                const subjectText = f.subject.replace(/^\[.*?\]\s*/, '');

                let typeColor = 'bg-slate-100 text-slate-700';
                if (type === 'BUG') typeColor = 'bg-red-100 text-red-700';
                if (type === 'FEATURE') typeColor = 'bg-blue-100 text-blue-700';

                return [
                  <div key={`${f.id}-user`} className="flex flex-col">
                    <span className="font-bold text-ink">{f.user?.name || 'Anonymous'}</span>
                    <span className="text-xs text-slate-500">{f.user?.email || 'No email'}</span>
                  </div>,
                  <div key={`${f.id}-sub`} className="flex items-center gap-2">
                    <span className={`rounded px-1.5 py-0.5 text-xs font-bold ${typeColor}`}>
                      {type}
                    </span>
                    <span className="font-semibold text-slate-700">{subjectText}</span>
                  </div>,
                  <p key={`${f.id}-msg`} className="max-w-md truncate text-xs text-slate-600" title={f.message}>
                    {f.message}
                  </p>,
                  <span key={`${f.id}-date`} className="text-xs text-slate-500">
                    {new Date(f.createdAt).toLocaleDateString()}
                  </span>,
                  <span
                    key={`${f.id}-status`}
                    className={`rounded px-2 py-0.5 text-xs font-extrabold ${
                      f.status === 'OPEN'
                        ? 'bg-rose-100 text-rose-700'
                        : f.status === 'RESOLVED'
                        ? 'bg-emerald-100 text-emerald-700'
                        : 'bg-slate-100 text-slate-600'
                    }`}
                  >
                    {f.status}
                  </span>,
                  <div key={`${f.id}-actions`} className="flex gap-2">
                    {f.status === 'OPEN' && (
                      <Button
                        onClick={() => void updateStatus(f.id, 'RESOLVED')}
                        className="h-8 px-2 text-xs bg-emerald-500 text-white hover:bg-emerald-600"
                      >
                        <CheckCircle2 className="h-3.5 w-3.5 mr-1" />
                        {t('admin.support.resolve')}
                      </Button>
                    )}
                    {f.status !== 'ARCHIVED' && (
                      <Button
                        onClick={() => void updateStatus(f.id, 'ARCHIVED')}
                        className="h-8 px-2 text-xs"
                        variant="secondary"
                      >
                        <Archive className="h-3.5 w-3.5 mr-1" />
                        {t('admin.support.archive')}
                      </Button>
                    )}
                  </div>,
                ];
              })}
            />
          )}
        </div>
      </Card>
    </DashboardShell>
  );
}

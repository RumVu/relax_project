'use client';

import { useCallback, useEffect, useState } from 'react';
import { FileClock, Filter, RefreshCcw } from 'lucide-react';
import { DashboardShell } from '@/components/layout/dashboard-shell';
import { DataTable, MetricCard, SectionTitle } from '@/components/dashboard/dashboard-ui';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { apiFetch } from '@/lib/api';
import { useUiStore } from '@/stores/use-ui-store';
import { useTranslation } from '@/lib/i18n/i18n-provider';

type AdminLog = {
  id: string;
  action: string;
  targetId?: string | null;
  targetType?: string | null;
  details: string;
  createdAt: string;
  admin?: {
    email?: string | null;
    name?: string | null;
  };
};

type PageResponse<T> = {
  total?: number;
  items?: T[];
};

export default function AdminLogsPage() {
  const { t, locale } = useTranslation();
  const pushToast = useUiStore((state) => state.pushToast);
  const [logs, setLogs] = useState<AdminLog[]>([]);
  const [total, setTotal] = useState(0);
  const [action, setAction] = useState('');
  const [targetType, setTargetType] = useState('');
  const [loading, setLoading] = useState(false);

  const loadLogs = useCallback(async () => {
    setLoading(true);
    try {
      const payload = await apiFetch<PageResponse<AdminLog>>('/admin-logs', undefined, {
        query: {
          limit: 50,
          action: action || undefined,
          targetType: targetType || undefined,
        },
      });

      setLogs(payload.items ?? []);
      setTotal(payload.total ?? payload.items?.length ?? 0);
    } catch {
      pushToast({
        tone: 'error',
        title: t('admin.logs.toast.loadFailed'),
      });
    } finally {
      setLoading(false);
    }
  }, [action, pushToast, targetType, t]);

  useEffect(() => {
    const timer = window.setTimeout(() => {
      void loadLogs();
    }, 0);

    return () => {
      window.clearTimeout(timer);
    };
  }, [loadLogs]);

  return (
    <DashboardShell admin eyebrow={t('admin.eyebrow')} title={t('admin.logs.title')}>
      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
        <MetricCard icon={FileClock} label={t('admin.logs.metric.total')} value={total} />
        <MetricCard
          icon={Filter}
          label={t('admin.logs.filter.action')}
          tone="lilac"
          value={action || t('admin.logs.filter.allActions')}
        />
        <MetricCard
          icon={RefreshCcw}
          label={t('admin.logs.filter.target')}
          tone="mint"
          value={targetType || t('admin.logs.filter.allTargets')}
        />
      </div>

      <Card>
        <SectionTitle
          title={t('admin.logs.filter.title')}
          copy={t('admin.logs.filter.copy')}
          action={
            <Button disabled={loading} onClick={() => void loadLogs()} variant="secondary">
              <RefreshCcw className="h-4 w-4" />
              {loading ? t('common.loading') : t('common.refresh')}
            </Button>
          }
        />
        <div className="mt-5 grid gap-3 md:grid-cols-2">
          <label className="text-sm font-bold text-slate">
            Action
            <input
              className="mt-2 h-11 w-full rounded-lg border border-lilac bg-white px-3 text-ink outline-none"
              onChange={(event) => setAction(event.target.value)}
            placeholder={t('admin.logs.filter.actionPlaceholder')}
              value={action}
            />
          </label>
          <label className="text-sm font-bold text-slate">
            Target type
            <input
              className="mt-2 h-11 w-full rounded-lg border border-lilac bg-white px-3 text-ink outline-none"
              onChange={(event) => setTargetType(event.target.value)}
            placeholder={t('admin.logs.filter.targetPlaceholder')}
              value={targetType}
            />
          </label>
        </div>
      </Card>

      <Card>
        <SectionTitle
          title={t('admin.logs.history.title')}
          copy={t('admin.logs.history.copy')}
        />
        <div className="mt-5">
          <DataTable
            columns={[t('admin.logs.col.when'), t('admin.logs.col.admin'), t('admin.logs.col.action'), t('admin.logs.col.target'), t('admin.logs.col.detail')]}
            rows={logs.map((log) => [
              formatDateTime(log.createdAt, locale),
              log.admin?.email ?? log.admin?.name ?? '-',
              log.action,
              [log.targetType, log.targetId].filter(Boolean).join(' / ') || '-',
              truncate(log.details, 120),
            ])}
          />
        </div>
      </Card>
    </DashboardShell>
  );
}

function formatDateTime(value: string, locale: string) {
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) {
    return '-';
  }

  return date.toLocaleString(locale === 'vi' ? 'vi-VN' : 'en-US', {
    dateStyle: 'short',
    timeStyle: 'short',
  });
}

function truncate(value: string, maxLength: number) {
  return value.length > maxLength ? `${value.slice(0, maxLength - 1)}…` : value;
}

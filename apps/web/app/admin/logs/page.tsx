'use client';

import { useCallback, useEffect, useState } from 'react';
import { FileClock, Filter, RefreshCcw } from 'lucide-react';
import { DashboardShell } from '@/components/layout/dashboard-shell';
import { DataTable, MetricCard, SectionTitle } from '@/components/dashboard/dashboard-ui';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { apiFetch } from '@/lib/api';
import { useUiStore } from '@/stores/use-ui-store';

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
        title: 'Không tải được audit logs',
      });
    } finally {
      setLoading(false);
    }
  }, [action, pushToast, targetType]);

  useEffect(() => {
    const timer = window.setTimeout(() => {
      void loadLogs();
    }, 0);

    return () => {
      window.clearTimeout(timer);
    };
  }, [loadLogs]);

  return (
    <DashboardShell admin eyebrow="Audit trail" title="Admin logs">
      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
        <MetricCard icon={FileClock} label="Tổng log khớp filter" value={total} />
        <MetricCard
          icon={Filter}
          label="Action filter"
          tone="lilac"
          value={action || 'All'}
        />
        <MetricCard
          icon={RefreshCcw}
          label="Target filter"
          tone="mint"
          value={targetType || 'All'}
        />
      </div>

      <Card>
        <SectionTitle
          title="Bộ lọc audit"
          copy="Đọc trực tiếp từ GET /admin-logs, dùng để kiểm tra ai vừa tạo/sửa/xoá nội dung nào."
          action={
            <Button disabled={loading} onClick={() => void loadLogs()} variant="secondary">
              <RefreshCcw className="h-4 w-4" />
              {loading ? 'Đang tải' : 'Reload'}
            </Button>
          }
        />
        <div className="mt-5 grid gap-3 md:grid-cols-2">
          <label className="text-sm font-bold text-slate">
            Action
            <input
              className="mt-2 h-11 w-full rounded-lg border border-lilac bg-white px-3 text-ink outline-none"
              onChange={(event) => setAction(event.target.value)}
              placeholder="VD: CREATE, UPDATE, DELETE"
              value={action}
            />
          </label>
          <label className="text-sm font-bold text-slate">
            Target type
            <input
              className="mt-2 h-11 w-full rounded-lg border border-lilac bg-white px-3 text-ink outline-none"
              onChange={(event) => setTargetType(event.target.value)}
              placeholder="VD: cozy-quotes, users"
              value={targetType}
            />
          </label>
        </div>
      </Card>

      <Card>
        <SectionTitle
          title="Lịch sử thao tác"
          copy="Chi tiết request đã được backend sanitize trước khi ghi log."
        />
        <div className="mt-5">
          <DataTable
            columns={['Thời gian', 'Admin', 'Action', 'Target', 'Details']}
            rows={logs.map((log) => [
              formatDateTime(log.createdAt),
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

function formatDateTime(value: string) {
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) {
    return '-';
  }

  return date.toLocaleString('vi-VN', {
    dateStyle: 'short',
    timeStyle: 'short',
  });
}

function truncate(value: string, maxLength: number) {
  return value.length > maxLength ? `${value.slice(0, maxLength - 1)}…` : value;
}

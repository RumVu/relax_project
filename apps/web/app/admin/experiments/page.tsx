'use client';

import { useEffect, useState, useCallback } from 'react';
import {
  Activity,
  Beaker,
  CheckCircle2,
  PauseCircle,
  PlusCircle,
  RefreshCcw,
  ToggleLeft,
  ToggleRight,
  Users,
  XCircle,
} from 'lucide-react';
import { DashboardShell } from '@/components/layout/dashboard-shell';
import { MetricCard, SectionTitle } from '@/components/dashboard/dashboard-ui';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { apiFetch } from '@/lib/api';
import { useTranslation } from '@/lib/i18n/i18n-provider';

type Experiment = {
  id: string;
  key: string;
  name: string;
  description?: string;
  isActive: boolean;
  variants: Array<{ name: string; weight: number }>;
  enrollmentCount?: number;
  createdAt: string;
  updatedAt: string;
};

export default function ExperimentsPage() {
  const { t } = useTranslation();
  const [experiments, setExperiments] = useState<Experiment[]>([]);
  const [loading, setLoading] = useState(true);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const data = await apiFetch<Experiment[] | { items: Experiment[] }>('/experiments');
      const list = Array.isArray(data) ? data : ((data && typeof data === 'object' && 'items' in data) ? data.items ?? [] : []);
      setExperiments(list);
    } catch {
      setExperiments([]);
    }
    setLoading(false);
  }, []);

  useEffect(() => {
    void load();
  }, [load]);

  const toggleExperiment = async (key: string, isActive: boolean) => {
    try {
      await apiFetch(`/experiments/${key}`, {
        method: 'PATCH',
        body: JSON.stringify({ isActive: !isActive }),
      });
      await load();
    } catch {}
  };

  const activeCount = experiments.filter((e) => e.isActive).length;
  const totalVariants = experiments.reduce(
    (sum, e) => sum + (e.variants?.length ?? 0),
    0,
  );

  return (
    <DashboardShell
      admin
      eyebrow={t('admin.eyebrow' as any)}
      title="Experiments"
    >
      <div className="flex items-center gap-3">
        <span className="inline-flex items-center gap-1.5 rounded-full bg-violet/10 px-3 py-1 text-xs font-bold text-violet">
          <Beaker className="h-3.5 w-3.5" />
          A/B Testing Dashboard
        </span>
        <button
          className="ml-auto inline-flex h-9 w-9 items-center justify-center rounded-lg border border-[var(--field-border)] bg-[var(--field-bg)] text-[var(--app-text)] transition hover:bg-violet/10"
          disabled={loading}
          onClick={() => void load()}
          type="button"
        >
          <RefreshCcw className={`h-4 w-4 ${loading ? 'animate-spin' : ''}`} />
        </button>
      </div>

      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        <MetricCard
          icon={Beaker}
          label="Total Experiments"
          value={`${experiments.length}`}
          tone="violet"
        />
        <MetricCard
          icon={Activity}
          label="Active"
          value={`${activeCount}`}
          tone="mint"
        />
        <MetricCard
          icon={PauseCircle}
          label="Paused"
          value={`${experiments.length - activeCount}`}
          tone="violet"
        />
        <MetricCard
          icon={Users}
          label="Total Variants"
          value={`${totalVariants}`}
          tone="mint"
        />
      </div>

      <Card>
        <SectionTitle
          title="All Experiments"
          copy={`${experiments.length} experiments configured`}
        />
        <div className="mt-4 space-y-3">
          {loading && experiments.length === 0 && (
            <p className="text-sm text-[var(--app-muted)]">Loading experiments...</p>
          )}
          {!loading && experiments.length === 0 && (
            <div className="rounded-xl border border-dashed border-[var(--field-border)] p-8 text-center">
              <Beaker className="mx-auto h-8 w-8 text-[var(--app-muted)]" />
              <p className="mt-2 text-sm font-semibold text-[var(--app-muted)]">
                No experiments yet
              </p>
              <p className="text-xs text-[var(--app-muted)]">
                Create experiments via the API: POST /experiments
              </p>
            </div>
          )}
          {experiments.map((exp) => (
            <div
              key={exp.id}
              className="rounded-xl border border-[var(--field-border)] bg-[var(--panel-bg)] p-4"
            >
              <div className="flex items-start justify-between gap-3">
                <div className="min-w-0 flex-1">
                  <div className="flex items-center gap-2">
                    <span
                      className={`inline-flex h-2 w-2 rounded-full ${
                        exp.isActive ? 'bg-mint' : 'bg-[var(--app-muted)]'
                      }`}
                    />
                    <h3 className="truncate text-sm font-bold text-[var(--app-text)]">
                      {exp.name || exp.key}
                    </h3>
                    <code className="rounded bg-[var(--field-bg)] px-1.5 py-0.5 text-[10px] text-[var(--app-muted)]">
                      {exp.key}
                    </code>
                  </div>
                  {exp.description && (
                    <p className="mt-1 text-xs text-[var(--app-muted)]">
                      {exp.description}
                    </p>
                  )}
                </div>
                <button
                  className="shrink-0 rounded-lg border border-[var(--field-border)] bg-[var(--field-bg)] p-2 transition hover:bg-violet/10"
                  onClick={() => void toggleExperiment(exp.key, exp.isActive)}
                  title={exp.isActive ? 'Pause experiment' : 'Activate experiment'}
                  type="button"
                >
                  {exp.isActive ? (
                    <ToggleRight className="h-5 w-5 text-mint" />
                  ) : (
                    <ToggleLeft className="h-5 w-5 text-[var(--app-muted)]" />
                  )}
                </button>
              </div>

              {/* Variants */}
              {exp.variants && exp.variants.length > 0 && (
                <div className="mt-3 flex flex-wrap gap-2">
                  {exp.variants.map((v, i) => {
                    const totalWeight = exp.variants.reduce(
                      (s, vr) => s + (vr.weight ?? 1),
                      0,
                    );
                    const pct =
                      totalWeight > 0
                        ? Math.round(((v.weight ?? 1) / totalWeight) * 100)
                        : 0;
                    return (
                      <div
                        key={i}
                        className="flex items-center gap-1.5 rounded-lg border border-[var(--field-border)] bg-[var(--field-bg)] px-2.5 py-1"
                      >
                        <span
                          className="inline-block h-2 w-2 rounded-full"
                          style={{
                            backgroundColor:
                              i === 0
                                ? 'var(--violet, #7c3aed)'
                                : i === 1
                                  ? 'var(--mint, #34d399)'
                                  : '#f59e0b',
                          }}
                        />
                        <span className="text-xs font-semibold text-[var(--app-text)]">
                          {v.name}
                        </span>
                        <span className="text-[10px] font-bold text-[var(--app-muted)]">
                          {pct}%
                        </span>
                      </div>
                    );
                  })}
                </div>
              )}

              <div className="mt-3 flex items-center gap-3 text-[10px] text-[var(--app-muted)]">
                <span>
                  Created: {new Date(exp.createdAt).toLocaleDateString()}
                </span>
                <span>
                  Updated: {new Date(exp.updatedAt).toLocaleDateString()}
                </span>
              </div>
            </div>
          ))}
        </div>
      </Card>
    </DashboardShell>
  );
}

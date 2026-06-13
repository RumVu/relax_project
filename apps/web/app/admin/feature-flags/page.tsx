'use client';

import { useCallback, useEffect, useState } from 'react';
import { Flag, Plus, RefreshCcw, ToggleLeft, ToggleRight, Trash2 } from 'lucide-react';
import { DashboardShell } from '@/components/layout/dashboard-shell';
import { MetricCard, SectionTitle } from '@/components/dashboard/dashboard-ui';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { apiFetch } from '@/lib/api';
import { useUiStore } from '@/stores/use-ui-store';
import { useTranslation } from '@/lib/i18n/i18n-provider';

type FeatureFlag = {
  id: string;
  key: string;
  label: string;
  description?: string | null;
  enabled: boolean;
  createdAt: string;
  updatedAt: string;
};

export default function FeatureFlagsPage() {
  const { t } = useTranslation();
  const pushToast = useUiStore((s) => s.pushToast);
  const [flags, setFlags] = useState<FeatureFlag[]>([]);
  const [loading, setLoading] = useState(false);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const data = await apiFetch<{ items: FeatureFlag[] }>('/feature-flags');
      setFlags(data.items ?? []);
    } catch {
      pushToast({ tone: 'error', title: 'Failed to load feature flags' });
    } finally {
      setLoading(false);
    }
  }, [pushToast]);

  useEffect(() => {
    void load();
  }, [load]);

  const toggle = async (key: string) => {
    try {
      await apiFetch(`/feature-flags/${key}/toggle`, { method: 'PATCH' });
      pushToast({ tone: 'success', title: `Toggled ${key}` });
      await load();
    } catch {
      pushToast({ tone: 'error', title: 'Toggle failed' });
    }
  };

  const deleteFlag = async (key: string) => {
    if (!confirm(`Delete flag "${key}"?`)) return;
    try {
      await apiFetch(`/feature-flags/${key}`, { method: 'DELETE' });
      pushToast({ tone: 'success', title: `Deleted ${key}` });
      await load();
    } catch {
      pushToast({ tone: 'error', title: 'Delete failed' });
    }
  };

  const addFlag = async () => {
    const key = prompt('Flag key (e.g. enable_voice_journal):');
    if (!key) return;
    const label = prompt('Label:') ?? key;
    try {
      await apiFetch('/feature-flags', {
        method: 'POST',
        body: JSON.stringify({ key, label, description: '', enabled: false }),
      });
      pushToast({ tone: 'success', title: `Created ${key}` });
      await load();
    } catch {
      pushToast({ tone: 'error', title: 'Create failed' });
    }
  };

  const enabledCount = flags.filter((f) => f.enabled).length;

  return (
    <DashboardShell admin eyebrow={t('admin.eyebrow')} title={t('admin.featureFlags.title')}>
      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
        <MetricCard icon={Flag} label="Total Flags" value={flags.length} />
        <MetricCard icon={ToggleRight} label="Enabled" tone="mint" value={enabledCount} />
        <MetricCard icon={ToggleLeft} label="Disabled" tone="lilac" value={flags.length - enabledCount} />
      </div>

      <Card>
        <SectionTitle
          title="Feature Flags"
          copy="Toggle features on/off at runtime without deployments."
          action={
            <div className="flex gap-2">
              <Button variant="secondary" onClick={() => void load()} disabled={loading}>
                <RefreshCcw className="h-4 w-4" />
                {loading ? 'Loading...' : 'Refresh'}
              </Button>
              <Button onClick={() => void addFlag()}>
                <Plus className="h-4 w-4" />
                Add Flag
              </Button>
            </div>
          }
        />
        <div className="mt-5 space-y-3">
          {flags.length === 0 && !loading && (
            <p className="text-sm text-slate py-8 text-center">No feature flags yet. Click &quot;Add Flag&quot; to create one.</p>
          )}
          {flags.map((flag) => (
            <div
              key={flag.id}
              className="flex items-center gap-4 rounded-xl border border-lilac/30 p-4"
            >
              <button
                type="button"
                onClick={() => void toggle(flag.key)}
                className={`flex h-8 w-14 items-center rounded-full px-1 transition-colors ${
                  flag.enabled ? 'bg-mint' : 'bg-slate/20'
                }`}
              >
                <div
                  className={`h-6 w-6 rounded-full bg-white shadow transition-transform ${
                    flag.enabled ? 'translate-x-6' : 'translate-x-0'
                  }`}
                />
              </button>
              <div className="flex-1 min-w-0">
                <p className="font-bold text-ink text-sm">{flag.label}</p>
                <p className="text-xs text-slate truncate">
                  <code className="bg-lavender/30 rounded px-1">{flag.key}</code>
                  {flag.description ? ` — ${flag.description}` : ''}
                </p>
              </div>
              <button
                type="button"
                onClick={() => void deleteFlag(flag.key)}
                className="text-coral hover:text-coral/70 transition-colors"
              >
                <Trash2 className="h-4 w-4" />
              </button>
            </div>
          ))}
        </div>
      </Card>
    </DashboardShell>
  );
}

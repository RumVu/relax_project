'use client';

import { useCallback, useEffect, useState } from 'react';
import { Save, RefreshCcw, Sparkles, Plus, Trash2 } from 'lucide-react';
import { DashboardShell } from '@/components/layout/dashboard-shell';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { SectionTitle } from '@/components/dashboard/dashboard-ui';
import { apiFetch } from '@/lib/api';
import { useUiStore } from '@/stores/use-ui-store';
import { useTranslation } from '@/lib/i18n/i18n-provider';

type PromptsMap = Record<string, string>;

export function PromptManagement() {
  const { t } = useTranslation();
  const pushToast = useUiStore((state) => state.pushToast);
  const [prompts, setPrompts] = useState<PromptsMap>({});
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [newKey, setNewKey] = useState('');

  const loadPrompts = useCallback(async () => {
    setLoading(true);
    try {
      const data = await apiFetch<PromptsMap>('/admin/prompts');
      setPrompts(data || {});
    } catch (e) {
      pushToast({
        tone: 'error',
        title: t('admin.prompts.loadError'),
        message: e instanceof Error ? e.message : String(e),
      });
    } finally {
      setLoading(false);
    }
  }, [pushToast, t]);

  useEffect(() => {
    void loadPrompts();
  }, [loadPrompts]);

  const handlePromptChange = (key: string, value: string) => {
    setPrompts((prev) => ({
      ...prev,
      [key]: value,
    }));
  };

  const handleAddKey = () => {
    const k = newKey.trim();
    if (!k) return;
    if (prompts[k] !== undefined) {
      pushToast({
        tone: 'error',
        title: t('admin.prompts.duplicateKey'),
        message: t('admin.prompts.duplicateMsg', { key: k }),
      });
      return;
    }
    setPrompts((prev) => ({
      ...prev,
      [k]: '',
    }));
    setNewKey('');
  };

  const handleDeleteKey = (keyToDelete: string) => {
    const next = { ...prompts };
    delete next[keyToDelete];
    setPrompts(next);
  };

  const handleSave = async () => {
    setSaving(true);
    try {
      await apiFetch('/admin/prompts', {
        method: 'POST',
        body: JSON.stringify(prompts),
      });
      pushToast({
        tone: 'success',
        title: t('admin.prompts.saved'),
        message: t('admin.prompts.savedMsg'),
      });
      void loadPrompts();
    } catch (e) {
      pushToast({
        tone: 'error',
        title: t('admin.prompts.saveError'),
        message: e instanceof Error ? e.message : String(e),
      });
    } finally {
      setSaving(false);
    }
  };

  return (
    <DashboardShell admin title="AI Prompt Management 🧪" eyebrow="Admin Panel">
      <Card>
        <SectionTitle
          title="Gemini AI Prompt Configurations"
          copy="Customize AI behaviors, companion personalities, weekly reports and reflections. Prompt changes will apply instantly to all mobile devices."
          action={
            <div className="flex gap-2">
              <Button onClick={() => void loadPrompts()} variant="secondary">
                <RefreshCcw className="h-4 w-4 mr-2" />
                {t('admin.prompts.reload')}
              </Button>
              <Button onClick={() => void handleSave()} disabled={saving}>
                <Save className="h-4 w-4 mr-2" />
                {saving ? t('admin.prompts.saving') : t('admin.prompts.saveChanges')}
              </Button>
            </div>
          }
        />

        {/* Add new key bar */}
        <div className="mt-6 flex gap-2 max-w-md">
          <input
            type="text"
            className="flex-1 rounded-lg border border-lilac bg-white px-3 py-2 text-sm font-semibold text-ink focus:border-violet focus:outline-none"
            placeholder="New prompt key (e.g. weekly_summary)..."
            value={newKey}
            onChange={(e) => setNewKey(e.target.value)}
          />
          <Button onClick={handleAddKey} variant="secondary">
            <Plus className="h-4 w-4 mr-1" /> {t('admin.prompts.addKey')}
          </Button>
        </div>

        <div className="mt-6 space-y-6">
          {loading ? (
            <div className="py-8 text-center text-sm font-semibold text-slate-500">
              {t('admin.prompts.loading')}
            </div>
          ) : Object.keys(prompts).length === 0 ? (
            <div className="py-8 text-center text-sm font-semibold text-slate-400">
              {t('admin.prompts.empty')}
            </div>
          ) : (
            Object.entries(prompts).map(([key, value]) => (
              <div key={key} className="p-4 rounded-xl border border-lilac bg-slate-50/50 flex flex-col gap-2">
                <div className="flex justify-between items-center">
                  <div className="flex items-center gap-2">
                    <Sparkles className="h-4 w-4 text-violet" />
                    <span className="font-bold text-ink text-sm">{key}</span>
                  </div>
                  <Button
                    onClick={() => handleDeleteKey(key)}
                    className="h-8 px-2 text-rose-600 hover:text-rose-700 bg-transparent hover:bg-rose-50 border-none"
                  >
                    <Trash2 className="h-3.5 w-3.5" />
                  </Button>
                </div>
                <textarea
                  className="w-full min-h-[120px] p-3 rounded-lg border border-lilac bg-white text-sm text-slate-700 focus:border-violet focus:outline-none"
                  value={value}
                  onChange={(e) => handlePromptChange(key, e.target.value)}
                  placeholder={`Write the prompt instructions for ${key}...`}
                />
              </div>
            ))
          )}
        </div>
      </Card>
    </DashboardShell>
  );
}

'use client';

import { useCallback, useEffect, useState } from 'react';
import { Volume2, Award, RefreshCcw, Star } from 'lucide-react';
import { DashboardShell } from '@/components/layout/dashboard-shell';
import { DataTable, SectionTitle } from '@/components/dashboard/dashboard-ui';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { apiFetch } from '@/lib/api';
import { useUiStore } from '@/stores/use-ui-store';
import { useTranslation } from '@/lib/i18n/i18n-provider';

type PopularSound = {
  id: string | null;
  title: string;
  category: string;
  listens: number;
};

type RatedItem = {
  contentType: string;
  contentId: string;
  title: string;
  avgRating: number;
  totalReviews: number;
};

type ContentQualityData = {
  popularSounds: PopularSound[];
  ratedItems: RatedItem[];
};

export function ContentQuality() {
  const { t } = useTranslation();
  const pushToast = useUiStore((state) => state.pushToast);
  const [data, setData] = useState<ContentQualityData>({ popularSounds: [], ratedItems: [] });
  const [loading, setLoading] = useState(true);

  const loadData = useCallback(async () => {
    setLoading(true);
    try {
      const res = await apiFetch<ContentQualityData>('/admin/content-quality');
      setData(res || { popularSounds: [], ratedItems: [] });
    } catch (e) {
      pushToast({
        tone: 'error',
        title: t('admin.quality.loadError'),
        message: e instanceof Error ? e.message : String(e),
      });
    } finally {
      setLoading(false);
    }
  }, [pushToast, t]);

  useEffect(() => {
    void loadData();
  }, [loadData]);

  return (
    <DashboardShell admin title="Content Quality Review 📊" eyebrow="Admin Panel">
      <div className="grid gap-6 xl:grid-cols-2">
        {/* Popular sounds card */}
        <Card>
          <SectionTitle
            title={t('admin.quality.popularSounds')}
            copy={t('admin.quality.popularSoundsCopy')}
            action={
              <Button onClick={() => void loadData()} variant="secondary">
                <RefreshCcw className="h-4 w-4 mr-2" />
                {t('admin.quality.refresh')}
              </Button>
            }
          />
          <div className="mt-6">
            {loading ? (
              <div className="py-8 text-center text-sm font-semibold text-slate-500">
                {t('admin.quality.loadingSounds')}
              </div>
            ) : data.popularSounds.length === 0 ? (
              <div className="py-8 text-center text-sm font-semibold text-slate-400">
                {t('admin.quality.noListens')}
              </div>
            ) : (
              <DataTable
                columns={['Title', 'Category', 'Listens']}
                rows={data.popularSounds.map((sound, idx) => [
                  <div key={`${sound.id || idx}-title`} className="flex items-center gap-2">
                    <Volume2 className="h-4 w-4 text-violet" />
                    <span className="font-bold text-ink">{sound.title}</span>
                  </div>,
                  <span
                    key={`${sound.id || idx}-cat`}
                    className="rounded bg-violet-100 text-violet-700 px-2 py-0.5 text-xs font-bold"
                  >
                    {sound.category}
                  </span>,
                  <span key={`${sound.id || idx}-listens`} className="font-extrabold text-slate-700">
                    {sound.listens} times
                  </span>,
                ])}
              />
            )}
          </div>
        </Card>

        {/* Highly rated items card */}
        <Card>
          <SectionTitle
            title={t('admin.quality.ratedContent')}
            copy={t('admin.quality.ratedContentCopy')}
          />
          <div className="mt-6">
            {loading ? (
              <div className="py-8 text-center text-sm font-semibold text-slate-500">
                {t('admin.quality.loadingRated')}
              </div>
            ) : data.ratedItems.length === 0 ? (
              <div className="py-8 text-center text-sm font-semibold text-slate-400">
                {t('admin.quality.noReviews')}
              </div>
            ) : (
              <DataTable
                columns={['Content Title', 'Type', 'Average Rating', 'Total Reviews']}
                rows={data.ratedItems.map((item, idx) => [
                  <div key={`${item.contentId}-${idx}-title`} className="flex items-center gap-2">
                    <Award className="h-4 w-4 text-mint" />
                    <span className="font-bold text-ink">{item.title}</span>
                  </div>,
                  <span key={`${item.contentId}-${idx}-type`} className="text-xs text-slate-500 font-semibold">
                    {item.contentType}
                  </span>,
                  <div key={`${item.contentId}-${idx}-rating`} className="flex items-center gap-1">
                    <Star className="h-4 w-4 fill-amber-400 text-amber-400" />
                    <span className="font-extrabold text-slate-700">
                      {item.avgRating.toFixed(1)} / 5.0
                    </span>
                  </div>,
                  <span key={`${item.contentId}-${idx}-reviews`} className="font-semibold text-slate-600">
                    {item.totalReviews} reviews
                  </span>,
                ])}
              />
            )}
          </div>
        </Card>
      </div>
    </DashboardShell>
  );
}

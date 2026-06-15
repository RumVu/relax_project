'use client';

import { useCallback, useEffect, useState } from 'react';
import {
  AlertTriangle,
  Award,
  BarChart3,
  CheckCircle2,
  Clock,
  RefreshCcw,
  Star,
  TrendingUp,
  Volume2,
} from 'lucide-react';
import { DashboardShell } from '@/components/layout/dashboard-shell';
import { DataTable, MetricCard, SectionTitle } from '@/components/dashboard/dashboard-ui';
import { Badge } from '@/components/ui/badge';
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

type ContentStats = {
  area: string;
  live: number;
  drafts: number;
  endpoint: string;
};

export function ContentQuality() {
  const { t } = useTranslation();
  const pushToast = useUiStore((state) => state.pushToast);
  const [data, setData] = useState<ContentQualityData>({
    popularSounds: [],
    ratedItems: [],
  });
  const [stats, setStats] = useState<ContentStats[]>([]);
  const [loading, setLoading] = useState(true);

  const loadData = useCallback(async () => {
    setLoading(true);
    try {
      const [qualityRes, statsRes] = await Promise.allSettled([
        apiFetch<ContentQualityData>('/admin/content-quality'),
        apiFetch<ContentStats[]>('/admin/content-stats'),
      ]);
      if (qualityRes.status === 'fulfilled') {
        setData(qualityRes.value || { popularSounds: [], ratedItems: [] });
      }
      if (statsRes.status === 'fulfilled' && Array.isArray(statsRes.value)) {
        setStats(statsRes.value);
      }
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

  const totalLive = stats.reduce((s, c) => s + c.live, 0);
  const totalDrafts = stats.reduce((s, c) => s + c.drafts, 0);
  const avgRating =
    data.ratedItems.length > 0
      ? data.ratedItems.reduce((s, r) => s + r.avgRating, 0) / data.ratedItems.length
      : 0;
  const totalListens = data.popularSounds.reduce((s, p) => s + p.listens, 0);

  return (
    <DashboardShell admin title="Content Quality Dashboard" eyebrow="Admin Panel">
      {/* Summary metrics */}
      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        <MetricCard
          icon={CheckCircle2}
          label="Nội dung đã xuất bản"
          note="Tổng nội dung live"
          tone="mint"
          value={totalLive}
        />
        <MetricCard
          icon={Clock}
          label="Bản nháp"
          note="Đang chờ duyệt"
          tone="sun"
          value={totalDrafts}
        />
        <MetricCard
          icon={Star}
          label="Đánh giá trung bình"
          note="Từ người dùng"
          tone="violet"
          value={avgRating > 0 ? `${avgRating.toFixed(1)}/5` : 'N/A'}
        />
        <MetricCard
          icon={TrendingUp}
          label="Tổng lượt nghe"
          note="Âm thanh & podcast"
          tone="lilac"
          value={totalListens}
        />
      </div>

      {/* Content health */}
      {stats.length > 0 && (
        <Card>
          <SectionTitle
            title="Content Health"
            copy="Tình trạng nội dung theo danh mục"
            action={
              <Button onClick={() => void loadData()} variant="secondary">
                <RefreshCcw className="h-4 w-4" />
              </Button>
            }
          />
          <div className="mt-5 grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
            {stats.map((area) => {
              const healthy = area.live > 0;
              return (
                <div
                  key={area.area}
                  className="flex items-center gap-3 rounded-xl border border-border bg-surface-alt p-4"
                >
                  {healthy ? (
                    <CheckCircle2 className="h-5 w-5 text-mint" />
                  ) : (
                    <AlertTriangle className="h-5 w-5 text-amber-500" />
                  )}
                  <div className="flex-1">
                    <p className="font-bold text-sm">{area.area}</p>
                    <p className="text-xs text-muted">{area.endpoint}</p>
                  </div>
                  <div className="text-right">
                    <Badge className={healthy ? 'bg-mint/15 text-mint' : 'bg-amber-500/15 text-amber-600'}>
                      {area.live} live
                    </Badge>
                    {area.drafts > 0 && (
                      <p className="mt-1 text-xs text-muted">{area.drafts} draft</p>
                    )}
                  </div>
                </div>
              );
            })}
          </div>
        </Card>
      )}

      <div className="grid gap-6 xl:grid-cols-2">
        {/* Popular sounds card */}
        <Card>
          <SectionTitle
            title={t('admin.quality.popularSounds')}
            copy={t('admin.quality.popularSoundsCopy')}
            action={<BarChart3 className="h-5 w-5 text-violet" />}
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
                    {sound.listens}
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
                columns={['Content Title', 'Type', 'Average Rating', 'Reviews']}
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
                      {item.avgRating.toFixed(1)}
                    </span>
                  </div>,
                  <span key={`${item.contentId}-${idx}-reviews`} className="font-semibold text-slate-600">
                    {item.totalReviews}
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

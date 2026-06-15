'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import {
  BookOpen,
  Headphones,
  Image,
  MessageSquare,
  Music,
  Palette,
  PenLine,
  Podcast,
  SlidersHorizontal,
  Sparkles,
  Wind,
} from 'lucide-react';
import { DashboardShell } from '@/components/layout/dashboard-shell';
import { SectionTitle } from '@/components/dashboard/dashboard-ui';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { apiFetch } from '@/lib/api';
import { useTranslation } from '@/lib/i18n/i18n-provider';

interface ContentArea {
  key: string;
  label: string;
  icon: typeof BookOpen;
  href: string;
  endpoint: string;
  count: number | null;
  description: string;
}

const AREAS: Omit<ContentArea, 'count'>[] = [
  { key: 'quotes', label: 'Câu nói', icon: PenLine, href: '/admin/quotes', endpoint: '/cozy-quotes', description: 'Quản lý câu nói truyền cảm hứng' },
  { key: 'sounds', label: 'Âm thanh', icon: Music, href: '/admin/sounds', endpoint: '/ambient-sounds', description: 'Nhạc nền & âm thanh thiên nhiên' },
  { key: 'podcasts', label: 'Podcast', icon: Podcast, href: '/admin/podcasts', endpoint: '/ambient-sounds?category=PODCAST', description: 'Nội dung podcast' },
  { key: 'exercises', label: 'Bài tập thở', icon: Wind, href: '/admin/exercises', endpoint: '/breathing-exercises', description: 'Bài tập hít thở có hướng dẫn' },
  { key: 'meditations', label: 'Thiền', icon: Sparkles, href: '/admin/meditations', endpoint: '/meditations', description: 'Bài thiền & mindfulness' },
  { key: 'themes', label: 'Giao diện', icon: Palette, href: '/admin/themes', endpoint: '/app-themes', description: 'Giao diện ứng dụng' },
  { key: 'onboarding', label: 'Onboarding', icon: SlidersHorizontal, href: '/admin/onboarding', endpoint: '/onboarding-slides', description: 'Slide giới thiệu ứng dụng' },
  { key: 'companion-assets', label: 'Companion', icon: Image, href: '/admin/companion-assets', endpoint: '/companion-assets', description: 'Tài nguyên companion' },
  { key: 'companion-messages', label: 'Tin nhắn Companion', icon: MessageSquare, href: '/admin/companion-messages', endpoint: '/companion-messages', description: 'Kịch bản tin nhắn' },
];

export default function ContentHubPage() {
  const { t } = useTranslation();
  const [areas, setAreas] = useState<ContentArea[]>(
    AREAS.map((a) => ({ ...a, count: null })),
  );

  useEffect(() => {
    AREAS.forEach(async (area, idx) => {
      try {
        const res = await apiFetch<any>(area.endpoint);
        const count = Array.isArray(res)
          ? res.length
          : typeof res === 'object' && res?.data
            ? (res.data as unknown[]).length
            : null;
        setAreas((prev) => {
          const next = [...prev];
          next[idx] = { ...next[idx], count };
          return next;
        });
      } catch {
        // keep null
      }
    });
  }, []);

  return (
    <DashboardShell
      admin
      eyebrow={t('admin.eyebrow' as any)}
      title="Content Hub"
    >
      <Card>
        <SectionTitle
          title="Content Management Hub"
          copy="Trung tâm quản lý tất cả nội dung ứng dụng"
        />
        <div className="mt-6 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {areas.map((area) => {
            const Icon = area.icon;
            return (
              <Link key={area.key} href={area.href}>
                <div className="group flex items-start gap-4 rounded-xl border border-border bg-surface-alt p-4 transition hover:border-violet hover:shadow-md">
                  <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-lg bg-violet/10 text-violet transition group-hover:bg-violet group-hover:text-white">
                    <Icon className="h-5 w-5" />
                  </div>
                  <div className="min-w-0 flex-1">
                    <div className="flex items-center gap-2">
                      <p className="truncate font-bold">{area.label}</p>
                      {area.count !== null && (
                        <span className="rounded-full bg-violet/10 px-2 py-0.5 text-xs font-bold text-violet">
                          {area.count}
                        </span>
                      )}
                    </div>
                    <p className="mt-0.5 text-xs text-muted">
                      {area.description}
                    </p>
                  </div>
                </div>
              </Link>
            );
          })}
        </div>
      </Card>

      <Card>
        <SectionTitle
          title="Quick Actions"
          copy="Thao tác nhanh cho quản trị viên"
        />
        <div className="mt-4 flex flex-wrap gap-3">
          <Link href="/admin/search">
            <Button variant="secondary">Tìm kiếm nội dung</Button>
          </Link>
          <Link href="/admin/content-quality">
            <Button variant="secondary">Kiểm tra chất lượng</Button>
          </Link>
          <Link href="/admin/prompt-management">
            <Button variant="secondary">Quản lý Prompt AI</Button>
          </Link>
          <Link href="/admin/logs">
            <Button variant="secondary">Nhật ký audit</Button>
          </Link>
          <Link href="/admin/support-inbox">
            <Button variant="secondary">Hộp thư hỗ trợ</Button>
          </Link>
        </div>
      </Card>
    </DashboardShell>
  );
}

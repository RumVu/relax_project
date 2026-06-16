'use client';

import { useState } from 'react';
import { Moon } from 'lucide-react';
import { Card } from '@/components/ui/card';
import { SectionTitle } from '@/components/dashboard/dashboard-ui';
import { apiFetch } from '@/lib/api';
import { getReadableTextColor } from '@/lib/contrast';
import { dispatchDashboardTheme } from '../settings-utils';
import type { ThemeCard, ThemeMode } from '../settings-types';

interface ThemeGallerySectionProps {
  copy: any;
  locale: 'vi' | 'en';
  themeCatalog: ThemeCard[];
  activeThemeId: string | null;
  setActiveThemeId: (val: string | null) => void;
  settings: any;
  triggerRefresh: () => void;
  setRefreshKey: (updater: (prev: number) => number) => void;
  pushToast: (toast: any) => void;
}

export function ThemeGallerySection({
  copy,
  locale,
  themeCatalog,
  activeThemeId,
  setActiveThemeId,
  settings,
  triggerRefresh,
  setRefreshKey,
  pushToast,
}: ThemeGallerySectionProps) {
  const [themeState, setThemeState] = useState<string | null>(null);

  return (
    <Card>
      <SectionTitle
        title={copy.themeGalleryTitle}
        copy={copy.themeGalleryCopy}
        action={<Moon className="h-5 w-5 text-violet" />}
      />
      <div className="mt-5 space-y-3">
        {themeCatalog.map((theme) => {
          const isActiveTheme = activeThemeId === theme.id;
          const statusLabel = isActiveTheme
            ? copy.inUse
            : themeState === theme.id
              ? copy.applying
              : copy.apply;
          // Auto-fix unreadable palettes (e.g. dark ink on a dark
          // surface). If the admin's textColor has enough contrast we
          // keep it; otherwise we fall back to white/near-black.
          const readableText = getReadableTextColor(
            theme.surfaceColor,
            theme.textColor,
          );
          const readableMuted = getReadableTextColor(
            theme.surfaceColor,
            theme.mutedTextColor || theme.textColor,
          );

          return (
            <button
              className="w-full rounded-xl border p-4 text-left transition hover:-translate-y-0.5"
              key={theme.id}
              onClick={async () => {
                setThemeState(theme.id);
                dispatchDashboardTheme(theme.mode, theme);
                try {
                  await apiFetch('/user-preferences/me/preferences', {
                    method: 'PATCH',
                    body: JSON.stringify({
                      themeId: theme.id,
                      themeMode: theme.mode,
                    }),
                  });
                  setActiveThemeId(theme.id);
                  setRefreshKey((current) => current + 1);
                  triggerRefresh();
                  pushToast({
                    tone: 'success',
                    title: copy.themeApplied(theme.name),
                  });
                } catch {
                  const currentTheme = themeCatalog.find(
                    (item) => item.id === activeThemeId,
                  );
                  const themeMode = (settings.preferences.theme.toUpperCase() as ThemeMode);
                  dispatchDashboardTheme(
                    themeMode,
                    currentTheme ?? null,
                  );
                  pushToast({
                    tone: 'error',
                    title: copy.themeApplyFailed,
                  });
                } finally {
                  setThemeState(null);
                }
              }}
              style={{
                backgroundColor: theme.surfaceColor,
                borderColor: isActiveTheme
                  ? theme.primaryColor
                  : theme.secondaryColor || theme.primaryColor,
                boxShadow: isActiveTheme
                  ? `0 0 0 1px ${theme.primaryColor}`
                  : 'none',
                color: readableText,
              }}
              type="button"
            >
              <div className="flex items-start justify-between gap-3">
                <div>
                  <p
                    className="text-lg font-extrabold"
                    style={{ color: readableText }}
                  >
                    {theme.name}
                  </p>
                  <p
                    className="mt-1 text-sm"
                    style={{ color: readableMuted }}
                  >
                    {theme.mode} {theme.isDefault ? copy.systemDefaultSuffix : ''}
                  </p>
                </div>
                <div
                  className="text-xs font-bold"
                  style={{
                    color: getReadableTextColor(
                      theme.surfaceColor,
                      theme.primaryColor,
                    ),
                  }}
                >
                  {statusLabel}
                </div>
              </div>
              <div className="mt-4 grid grid-cols-4 gap-2">
                {[
                  theme.backgroundColor,
                  theme.surfaceColor,
                  theme.primaryColor,
                  theme.accentColor || theme.secondaryColor || theme.textColor,
                ].map((color) => (
                  <div
                    className="h-12 rounded-lg border"
                    key={color}
                    style={{
                      backgroundColor: color,
                      borderColor: theme.mutedTextColor || 'rgba(0,0,0,0.08)',
                    }}
                  />
                ))}
              </div>
            </button>
          );
        })}
      </div>
    </Card>
  );
}

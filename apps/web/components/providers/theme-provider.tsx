'use client';

import { useEffect, useRef, useState } from 'react';
import {
  apiFetch,
  extractList,
  getStoredAccessToken,
  syncAuthRouteCookie,
} from '@/lib/api';

export type DashboardThemeMode = 'light' | 'dark' | 'system';

export type DashboardThemePalette = {
  id?: string;
  mode?: string;
  backgroundColor?: string;
  surfaceColor?: string;
  primaryColor?: string;
  secondaryColor?: string | null;
  accentColor?: string | null;
  textColor?: string;
  mutedTextColor?: string | null;
};

export type DashboardThemeAppliedDetail = {
  mode: DashboardThemeMode;
  palette: DashboardThemePalette | null;
};

export const DASHBOARD_THEME_APPLIED_EVENT = 'dashboard-theme-applied';

const THEME_VARIABLES = [
  '--app-bg-start',
  '--app-bg-end',
  '--app-text',
  '--app-muted',
  '--panel-bg',
  '--panel-strong',
  '--panel-border',
  '--field-bg',
  '--field-border',
  '--hero-bg',
  '--brand-primary',
  '--brand-secondary',
  '--brand-accent',
] as const;

export function applyDashboardTheme(
  mode: DashboardThemeMode,
  palette?: DashboardThemePalette | null,
) {
  if (typeof window === 'undefined') {
    return;
  }

  const media = window.matchMedia('(prefers-color-scheme: dark)');
  const resolvedMode = mode === 'system' ? (media.matches ? 'dark' : 'light') : mode;
  const root = document.documentElement;

  root.dataset.theme = resolvedMode;
  root.style.colorScheme = resolvedMode;

  if (!palette) {
    THEME_VARIABLES.forEach((name) => root.style.removeProperty(name));
    return;
  }

  const background = palette.backgroundColor;
  const surface = palette.surfaceColor;
  const primary = palette.primaryColor;
  const secondary = palette.secondaryColor ?? palette.surfaceColor;
  const accent = palette.accentColor ?? palette.primaryColor;
  const text = palette.textColor;
  const muted = palette.mutedTextColor ?? text;

  setCssVar('--app-bg-start', background);
  setCssVar(
    '--app-bg-end',
    blendColor(background, resolvedMode === 'dark' ? '#020617' : '#eef1f8', 0.18),
  );
  setCssVar('--app-text', text);
  setCssVar('--app-muted', muted);
  setCssVar('--panel-bg', toAlpha(surface, resolvedMode === 'dark' ? 0.88 : 0.92));
  setCssVar('--panel-strong', surface);
  setCssVar('--panel-border', toAlpha(accent, resolvedMode === 'dark' ? 0.24 : 0.28));
  setCssVar('--field-bg', surface);
  setCssVar('--field-border', toAlpha(accent, resolvedMode === 'dark' ? 0.36 : 0.32));
  setCssVar(
    '--hero-bg',
    `radial-gradient(circle at top left, ${toAlpha(primary, 0.18)}, transparent 34%), radial-gradient(circle at top right, ${toAlpha(accent, 0.14)}, transparent 30%), ${toAlpha(surface, 0.78)}`,
  );
  setCssVar('--brand-primary', primary);
  setCssVar('--brand-secondary', secondary);
  setCssVar('--brand-accent', accent);

  function setCssVar(name: string, value?: string | null) {
    if (value) {
      root.style.setProperty(name, value);
    }
  }
}

function toAlpha(color: string | null | undefined, alpha: number) {
  const hex = normalizeHex(color);
  if (!hex) {
    return color ?? '';
  }

  const red = parseInt(hex.slice(0, 2), 16);
  const green = parseInt(hex.slice(2, 4), 16);
  const blue = parseInt(hex.slice(4, 6), 16);
  return `rgba(${red}, ${green}, ${blue}, ${alpha})`;
}

function blendColor(
  color: string | null | undefined,
  fallback: string,
  fallbackWeight: number,
) {
  const sourceHex = normalizeHex(color);
  const fallbackHex = normalizeHex(fallback);
  if (!sourceHex || !fallbackHex) {
    return color ?? fallback;
  }

  const channel = (start: string, end: string) =>
    Math.round(
      parseInt(start, 16) * (1 - fallbackWeight) +
        parseInt(end, 16) * fallbackWeight,
    )
      .toString(16)
      .padStart(2, '0');

  return `#${channel(sourceHex.slice(0, 2), fallbackHex.slice(0, 2))}${channel(
    sourceHex.slice(2, 4),
    fallbackHex.slice(2, 4),
  )}${channel(sourceHex.slice(4, 6), fallbackHex.slice(4, 6))}`;
}

function normalizeHex(color: string | null | undefined) {
  if (!color?.startsWith('#')) {
    return undefined;
  }

  const raw = color.slice(1);
  if (/^[0-9a-fA-F]{3}$/.test(raw)) {
    return raw
      .split('')
      .map((char) => `${char}${char}`)
      .join('');
  }

  return /^[0-9a-fA-F]{6}$/.test(raw) ? raw : undefined;
}

export function ThemeProvider() {
  const [themeMode, setThemeMode] = useState<DashboardThemeMode>('system');
  const [themePalette, setThemePalette] = useState<DashboardThemePalette | null>(null);
  const themeModeRef = useRef(themeMode);
  const themePaletteRef = useRef(themePalette);

  useEffect(() => {
    let cancelled = false;
    const media = window.matchMedia('(prefers-color-scheme: dark)');

    const handleSchemeChange = () => {
      applyDashboardTheme(themeModeRef.current, themePaletteRef.current);
    };

    const handleThemeApplied = (event: Event) => {
      const detail = (event as CustomEvent<DashboardThemeAppliedDetail>).detail;
      if (!detail) {
        return;
      }

      themeModeRef.current = detail.mode;
      themePaletteRef.current = detail.palette;
      setThemeMode(detail.mode);
      setThemePalette(detail.palette);
      applyDashboardTheme(detail.mode, detail.palette);
    };

    applyDashboardTheme(themeModeRef.current, themePaletteRef.current);
    media.addEventListener('change', handleSchemeChange);
    window.addEventListener(DASHBOARD_THEME_APPLIED_EVENT, handleThemeApplied);
    syncAuthRouteCookie();

    if (getStoredAccessToken()) {
      void Promise.allSettled([
        apiFetch<Record<string, unknown>>('/user-preferences/me/preferences'),
        apiFetch<unknown>('/app-themes'),
      ])
        .then(([preferencesResult, themesResult]) => {
          if (cancelled) {
            return;
          }

          const preferences =
            preferencesResult.status === 'fulfilled' ? preferencesResult.value : {};
          const themes =
            themesResult.status === 'fulfilled'
              ? extractList<Record<string, unknown>>(themesResult.value)
              : [];
          const nextMode = String(preferences.themeMode ?? 'SYSTEM').toLowerCase();
          if (nextMode === 'light' || nextMode === 'dark' || nextMode === 'system') {
            const resolvedMode =
              nextMode === 'system'
                ? window.matchMedia('(prefers-color-scheme: dark)').matches
                  ? 'DARK'
                  : 'LIGHT'
                : nextMode.toUpperCase();
            const userTheme = preferences.themeId
              ? themes.find(
                  (theme) => String(theme.id) === String(preferences.themeId),
                )
              : undefined;
            const nextPalette = (userTheme ??
              themes.find(
                (theme) =>
                  Boolean(theme.isDefault) &&
                  String(theme.mode).toUpperCase() === resolvedMode,
              ) ??
              null) as DashboardThemePalette | null;
            setThemeMode(nextMode);
            setThemePalette(nextPalette);
            themeModeRef.current = nextMode;
            themePaletteRef.current = nextPalette;
            applyDashboardTheme(nextMode, nextPalette);
          }
        })
        .catch(() => {
          applyDashboardTheme(themeModeRef.current, themePaletteRef.current);
        });
    }

    return () => {
      cancelled = true;
      media.removeEventListener('change', handleSchemeChange);
      window.removeEventListener(DASHBOARD_THEME_APPLIED_EVENT, handleThemeApplied);
    };
  }, []);

  return null;
}

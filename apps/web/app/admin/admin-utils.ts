import { Activity, Bell, CreditCard, Users } from 'lucide-react';
import {
  API_URL,
  API_VERSION_PREFIX,
  getStoredAccessToken,
} from '@/lib/api';
import { useTranslation } from '@/lib/i18n/i18n-provider';

export const metricIcons = [Activity, Users, Users, CreditCard, Activity, Bell];

export const catalogLinks = [
  { area: 'Quotes', href: '/admin/quotes' },
  { area: 'Sounds', href: '/admin/sounds' },
  { area: 'Podcasts', href: '/admin/podcasts' },
  { area: 'Exercises', href: '/admin/exercises' },
  { area: 'Meditations', href: '/admin/meditations' },
  { area: 'Themes', href: '/admin/themes' },
  { area: 'Onboarding', href: '/admin/onboarding' },
  { area: 'Companion Assets', href: '/admin/companion-assets' },
  { area: 'Companion Messages', href: '/admin/companion-messages' },
];

/**
 * Hits an endpoint WITHOUT the /v1 global prefix that apiFetch hard-codes.
 * Used for the small set of infra routes (/, /health, /ready) the backend
 * explicitly excludes from versioning.
 */
export async function fetchUnversioned(
  path: string,
): Promise<Record<string, unknown>> {
  const token = getStoredAccessToken();
  const headers: Record<string, string> = { Accept: 'application/json' };
  if (token) headers.Authorization = `Bearer ${token}`;
  // Strip the /v1 prefix that API_VERSION_PREFIX adds — we just want
  // `${API_URL}${path}`.
  void API_VERSION_PREFIX;
  const response = await fetch(`${API_URL}${path}`, {
    headers,
    cache: 'no-store',
  });
  if (!response.ok) {
    throw new Error(`HTTP ${response.status}`);
  }
  const text = await response.text();
  try {
    return text ? (JSON.parse(text) as Record<string, unknown>) : {};
  } catch {
    return { raw: text };
  }
}

/**
 * Different health probes return wildly different payload shapes:
 * /health             → { status, timestamp, uptimeSeconds }
 * /redis/health       → { status, mode, enabled }
 * /queues/health      → { status, enabled, queueCount }
 * /realtime/health    → { status, adapter: { provider, namespace, mode, … } }
 *
 * Distill any of them down to a short single-line string for the card so
 * we never accidentally try to render an object (which is what produced
 * the "Objects are not valid as a React child {provider, namespace, mode,
 * redisConfigured, redisConnected}" crash).
 */
export function summariseHealthPayload(payload: Record<string, unknown>): string {
  const parts: string[] = [];

  // adapter: prefer "<provider> on <namespace>" if it's an object.
  const adapter = payload.adapter;
  if (typeof adapter === 'string' && adapter) {
    parts.push(adapter);
  } else if (adapter && typeof adapter === 'object') {
    const a = adapter as Record<string, unknown>;
    const provider = typeof a.provider === 'string' ? a.provider : null;
    const namespace = typeof a.namespace === 'string' ? a.namespace : null;
    const mode = typeof a.mode === 'string' ? a.mode : null;
    const tag = [provider, namespace ? `ns=${namespace}` : null, mode]
      .filter(Boolean)
      .join(' · ');
    if (tag) parts.push(tag);
  }

  if (typeof payload.mode === 'string' && payload.mode) {
    parts.push(`mode ${payload.mode}`);
  }
  if (typeof payload.enabled === 'boolean') {
    parts.push(payload.enabled ? 'enabled' : 'disabled');
  }
  if (typeof payload.queueCount === 'number') {
    parts.push(`${payload.queueCount} queue`);
  }
  if (typeof payload.uptimeSeconds === 'number') {
    parts.push(`uptime ${Math.round(payload.uptimeSeconds)}s`);
  }
  if (typeof payload.redisConnected === 'boolean') {
    parts.push(`redis ${payload.redisConnected ? '✓' : '✗'}`);
  }

  return parts.join(' • ') || 'OK';
}

export function areaKey(area: string) {
  const keys: Record<string, Parameters<ReturnType<typeof useTranslation>['t']>[0]> = {
    Quotes: 'nav.quotes',
    Sounds: 'nav.sounds',
    Podcasts: 'nav.podcasts',
    Exercises: 'nav.exercises',
    Themes: 'nav.themes',
    Onboarding: 'nav.onboarding',
    'Companion Assets': 'nav.companionAssets',
    'Companion Messages': 'nav.companionMessages',
    Meditations: 'nav.meditations',
  };
  return keys[area] ?? 'admin.content.col.area';
}

'use client';

import { useCallback, useEffect, useMemo, useState } from 'react';
import {
  Globe,
  MapPin,
  MapPinOff,
  RefreshCw,
  Users,
} from 'lucide-react';
import { DashboardShell } from '@/components/layout/dashboard-shell';
import {
  DataTable,
  MetricCard,
  SectionTitle,
} from '@/components/dashboard/dashboard-ui';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { apiFetch } from '@/lib/api';
import { useTranslation } from '@/lib/i18n/i18n-provider';

interface RawUserWithPrefs {
  id: string;
  name?: string;
  email?: string;
  role?: string;
  lastLoginAt?: string;
  profile?: { displayName?: string } | null;
  preferences?: {
    latitude?: number | null;
    longitude?: number | null;
    locationName?: string | null;
  } | null;
}

interface UserLocation {
  id: string;
  name: string;
  email: string;
  latitude: number | null;
  longitude: number | null;
  locationName: string | null;
  lastLogin: string;
}

function formatDate(iso: string | null | undefined): string {
  if (!iso) return '-';
  try {
    return new Intl.DateTimeFormat('vi-VN', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    }).format(new Date(iso));
  } catch {
    return iso;
  }
}

function coordStr(v: number | null): string {
  return v != null ? v.toFixed(5) : '-';
}

export default function AdminUserLocationsPage() {
  const { t } = useTranslation();
  const [users, setUsers] = useState<UserLocation[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [filter, setFilter] = useState<'ALL' | 'HAS_LOCATION' | 'NO_LOCATION'>(
    'ALL',
  );

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const res = await apiFetch<{ items: RawUserWithPrefs[]; total: number }>(
        '/users',
        undefined,
        { query: { limit: 100 } },
      );

      // Nếu có nhiều hơn 100 user → fetch thêm các trang còn lại.
      const allItems = [...(res.items ?? [])];
      const total = res.total ?? allItems.length;
      let skip = allItems.length;
      while (skip < total) {
        const next = await apiFetch<{ items: RawUserWithPrefs[] }>(
          '/users',
          undefined,
          { query: { limit: 100, skip } },
        );
        allItems.push(...(next.items ?? []));
        skip += (next.items ?? []).length;
        if ((next.items ?? []).length === 0) break; // tránh loop vô hạn
      }
      const mapped: UserLocation[] = allItems.map((u) => ({
        id: u.id,
        name:
          u.profile?.displayName ?? u.name ?? u.email?.split('@')[0] ?? 'User',
        email: u.email ?? '-',
        latitude: u.preferences?.latitude ?? null,
        longitude: u.preferences?.longitude ?? null,
        locationName: u.preferences?.locationName ?? null,
        lastLogin: formatDate(u.lastLoginAt),
      }));
      setUsers(mapped);
    } catch (err) {
      const message =
        err && typeof err === 'object' && 'message' in err
          ? String((err as { message?: string }).message)
          : 'Unknown error';
      console.error('[UserLocations] fetch failed:', message);
      setError(message);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    void load();
  }, [load]);

  const withLoc = useMemo(
    () => users.filter((u) => u.latitude != null),
    [users],
  );
  const noLoc = useMemo(
    () => users.filter((u) => u.latitude == null),
    [users],
  );

  const displayed =
    filter === 'HAS_LOCATION'
      ? withLoc
      : filter === 'NO_LOCATION'
        ? noLoc
        : users;

  return (
    <DashboardShell
      admin
      eyebrow={t('admin.eyebrow')}
      title={t('admin.userLocations.title')}
    >
      <div className="grid gap-4 sm:grid-cols-3">
        <MetricCard
          icon={Users}
          label={t('admin.userLocations.metric.total')}
          value={users.length}
        />
        <MetricCard
          icon={MapPin}
          label={t('admin.userLocations.metric.hasLocation')}
          tone="mint"
          value={withLoc.length}
        />
        <MetricCard
          icon={MapPinOff}
          label={t('admin.userLocations.metric.noLocation')}
          tone="coral"
          value={noLoc.length}
        />
      </div>

      <Card>
        <SectionTitle
          title={t('admin.userLocations.table.title')}
          copy={t('admin.userLocations.table.copy')}
          action={
            <div className="flex flex-wrap gap-2">
              <select
                className="h-10 rounded-lg border border-lilac bg-white px-3 text-sm font-semibold text-ink"
                onChange={(e) =>
                  setFilter(
                    e.target.value as 'ALL' | 'HAS_LOCATION' | 'NO_LOCATION',
                  )
                }
                value={filter}
              >
                <option value="ALL">
                  {t('admin.userLocations.filter.all')}
                </option>
                <option value="HAS_LOCATION">
                  {t('admin.userLocations.filter.hasLocation')}
                </option>
                <option value="NO_LOCATION">
                  {t('admin.userLocations.filter.noLocation')}
                </option>
              </select>
              <Button
                disabled={loading}
                onClick={() => void load()}
                variant="secondary"
              >
                <RefreshCw
                  className={`h-4 w-4 ${loading ? 'animate-spin' : ''}`}
                />
                {t('admin.userLocations.refresh')}
              </Button>
            </div>
          }
        />
        <div className="mt-5">
          {loading ? (
            <p className="py-12 text-center text-sm text-slate">
              {t('common.loading')}
            </p>
          ) : error ? (
            <p className="py-12 text-center text-sm text-red-400">
              {error}
            </p>
          ) : (
            <DataTable
              columns={[
                t('admin.users.col.name'),
                t('admin.users.col.email'),
                t('admin.userLocations.col.lat'),
                t('admin.userLocations.col.lng'),
                t('admin.userLocations.col.address'),
                t('admin.users.col.lastLogin'),
              ]}
              rows={displayed.map((u) => [
                u.name,
                u.email,
                u.latitude != null ? (
                  <span className="font-mono text-xs">
                    {coordStr(u.latitude)}
                  </span>
                ) : (
                  <span className="text-xs text-slate">-</span>
                ),
                u.longitude != null ? (
                  <span className="font-mono text-xs">
                    {coordStr(u.longitude)}
                  </span>
                ) : (
                  <span className="text-xs text-slate">-</span>
                ),
                u.locationName ? (
                  <span className="flex items-start gap-1.5">
                    <Globe className="mt-0.5 h-3.5 w-3.5 shrink-0 text-violet" />
                    <span className="text-sm">{u.locationName}</span>
                  </span>
                ) : u.latitude != null ? (
                  <a
                    className="text-xs font-semibold text-violet hover:underline"
                    href={`https://www.google.com/maps?q=${u.latitude},${u.longitude}`}
                    rel="noopener noreferrer"
                    target="_blank"
                  >
                    {t('admin.userLocations.viewOnMap')}
                  </a>
                ) : (
                  <span className="text-xs text-slate">
                    {t('admin.userLocations.notShared')}
                  </span>
                ),
                u.lastLogin,
              ])}
            />
          )}
        </div>
      </Card>
    </DashboardShell>
  );
}

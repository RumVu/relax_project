'use client';

import { create } from 'zustand';

export type AccountProfile = {
  id?: string;
  email?: string;
  name?: string | null;
  displayName?: string | null;
  avatar?: string | null;
  role?: string;
};

type DashboardStore = {
  accountProfile: AccountProfile | null;
  focusMode: boolean;
  refreshNonce: number;
  clearAccountProfile: () => void;
  setAccountProfile: (profile: AccountProfile | null) => void;
  toggleFocusMode: () => void;
  triggerRefresh: () => void;
};

const ACCOUNT_PROFILE_CACHE_KEY = 'relax_account_profile';

function readCachedAccountProfile() {
  if (typeof window === 'undefined') return null;

  try {
    const raw = window.localStorage.getItem(ACCOUNT_PROFILE_CACHE_KEY);
    return raw ? (JSON.parse(raw) as AccountProfile) : null;
  } catch {
    return null;
  }
}

function writeCachedAccountProfile(profile: AccountProfile | null) {
  if (typeof window === 'undefined') return;

  try {
    if (profile) {
      window.localStorage.setItem(ACCOUNT_PROFILE_CACHE_KEY, JSON.stringify(profile));
    } else {
      window.localStorage.removeItem(ACCOUNT_PROFILE_CACHE_KEY);
    }
  } catch {
    // Local cache is only for chrome responsiveness; storage failures are harmless.
  }
}

export const useDashboardStore = create<DashboardStore>((set) => ({
  accountProfile: readCachedAccountProfile(),
  focusMode: false,
  refreshNonce: 0,
  clearAccountProfile: () => {
    writeCachedAccountProfile(null);
    set({ accountProfile: null });
  },
  setAccountProfile: (profile) =>
    set((state) => {
      const next = profile ? { ...(state.accountProfile ?? {}), ...profile } : null;
      writeCachedAccountProfile(next);
      return { accountProfile: next };
    }),
  toggleFocusMode: () => set((state) => ({ focusMode: !state.focusMode })),
  triggerRefresh: () =>
    set((state) => ({
      refreshNonce: state.refreshNonce + 1,
    })),
}));

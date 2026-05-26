'use client';

import { create } from 'zustand';

type DashboardStore = {
  focusMode: boolean;
  refreshNonce: number;
  toggleFocusMode: () => void;
  triggerRefresh: () => void;
};

export const useDashboardStore = create<DashboardStore>((set) => ({
  focusMode: false,
  refreshNonce: 0,
  toggleFocusMode: () => set((state) => ({ focusMode: !state.focusMode })),
  triggerRefresh: () =>
    set((state) => ({
      refreshNonce: state.refreshNonce + 1,
    })),
}));

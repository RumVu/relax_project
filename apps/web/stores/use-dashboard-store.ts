'use client';

import { create } from 'zustand';

type DashboardStore = {
  focusMode: boolean;
  toggleFocusMode: () => void;
};

export const useDashboardStore = create<DashboardStore>((set) => ({
  focusMode: false,
  toggleFocusMode: () => set((state) => ({ focusMode: !state.focusMode })),
}));

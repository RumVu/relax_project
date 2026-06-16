'use client';

import { create } from 'zustand';

export type ToastTone = 'success' | 'error' | 'info';

export type ToastItem = {
  id: string;
  title: string;
  message?: string;
  tone: ToastTone;
};

type UiStore = {
  toasts: ToastItem[];
  pushToast: (toast: Omit<ToastItem, 'id'>) => void;
  removeToast: (id: string) => void;
  tourActive: boolean;
  tourStep: number;
  setTourActive: (active: boolean) => void;
  setTourStep: (step: number) => void;
};

export const useUiStore = create<UiStore>((set) => ({
  toasts: [],
  pushToast: (toast) =>
    set((state) => ({
      toasts: [
        ...state.toasts,
        {
          ...toast,
          id: crypto.randomUUID(),
        },
      ],
    })),
  removeToast: (id) =>
    set((state) => ({
      toasts: state.toasts.filter((toast) => toast.id !== id),
    })),
  tourActive: false,
  tourStep: 0,
  setTourActive: (active) => set({ tourActive: active }),
  setTourStep: (step) => set({ tourStep: step }),
}));

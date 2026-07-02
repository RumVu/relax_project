'use client';

import { CheckCircle2, X } from 'lucide-react';
import { Button } from './button';
import { CatMascot } from '@/components/dashboard/cat-mascot';
import { useTranslation } from '@/lib/i18n/i18n-provider';

type ActionModalProps = {
  open: boolean;
  title: string;
  description: string;
  primaryLabel?: string;
  secondaryLabel?: string;
  onPrimary?: () => void;
  onSecondary?: () => void;
  onClose: () => void;
};

export function ActionModal({
  open,
  title,
  description,
  primaryLabel,
  secondaryLabel,
  onPrimary,
  onSecondary,
  onClose,
}: ActionModalProps) {
  const { t } = useTranslation();
  if (!open) {
    return null;
  }

  const resolvedPrimaryLabel = primaryLabel ?? t('common.confirm');

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-night/55 p-4 backdrop-blur-sm">
      <div className="w-full max-w-md rounded-2xl border border-white/70 bg-white p-6 shadow-panel">
        <div className="flex items-start justify-between gap-3">
          <div className="flex items-center gap-3">
            <div className="flex h-11 w-11 items-center justify-center rounded-xl bg-violet text-white">
              <CheckCircle2 className="h-5 w-5" />
            </div>
            <div>
              <h3 className="text-xl font-extrabold text-ink">{title}</h3>
              <p className="mt-1 text-sm leading-6 text-slate">{description}</p>
            </div>
          </div>
          <button
            className="rounded-lg p-1 text-slate transition hover:bg-cloud hover:text-ink"
            onClick={onClose}
            type="button"
          >
            <X className="h-4 w-4" />
          </button>
        </div>
        <div className="mt-6 flex flex-wrap items-center justify-end gap-2">
          {secondaryLabel ? (
            <Button onClick={onSecondary ?? onClose} variant="secondary">
              {secondaryLabel}
            </Button>
          ) : null}
          <Button onClick={onPrimary ?? onClose}>{resolvedPrimaryLabel}</Button>
          <CatMascot variant="right" size="sm" className="opacity-70" />
        </div>
      </div>
    </div>
  );
}

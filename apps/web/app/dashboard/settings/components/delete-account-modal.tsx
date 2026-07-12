'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { AlertTriangle, X } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { cn } from '@/lib/utils';
import { apiFetch, clearAuthSession } from '@/lib/api';
import { useDashboardStore } from '@/stores/use-dashboard-store';
import { useUiStore } from '@/stores/use-ui-store';
import { useTranslation } from '@/lib/i18n/i18n-provider';

export function DeleteAccountModal({
  isOpen,
  onClose,
  authProvider,
}: {
  isOpen: boolean;
  onClose: () => void;
  authProvider: string;
}) {
  const { locale, t } = useTranslation();
  const router = useRouter();
  const pushToast = useUiStore((state) => state.pushToast);
  const clearAccountProfile = useDashboardStore((state) => state.clearAccountProfile);

  const [mode, setMode] = useState<'SOFT' | 'HARD'>('SOFT');
  const [password, setPassword] = useState('');
  const [deleting, setDeleting] = useState(false);

  const isLocal = authProvider === 'LOCAL';

  const handleDelete = async () => {
    if (isLocal && !password) {
      pushToast({
        tone: 'error',
        title: t('auth.error.required'),
      });
      return;
    }

    setDeleting(true);
    try {
      await apiFetch('/auth/me', {
        method: 'DELETE',
        body: JSON.stringify({
          mode,
          password: isLocal ? password : undefined,
        }),
      });

      pushToast({
        tone: 'success',
        title: t('settings.delete.deleted'),
      });

      // Clear sessions and redirect
      clearAccountProfile();
      await clearAuthSession();
      onClose();
      router.push('/auth/login');
      router.refresh();
    } catch (err: any) {
      pushToast({
        tone: 'error',
        title: locale === 'en' ? 'Delete account failed' : 'Xoá tài khoản thất bại',
        message: err.message || t('settings.toast.serverHint'),
      });
    } finally {
      setDeleting(false);
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center bg-ink/55 p-4 backdrop-blur-sm sm:items-center">
      <div className="w-full max-w-md rounded-2xl border border-[var(--panel-border)] bg-[var(--panel-strong)] p-5 text-[var(--app-text)] shadow-2xl">
        <div className="flex items-start justify-between gap-4">
          <div>
            <p className="text-xs font-bold uppercase tracking-[0.18em] text-coral flex items-center gap-1.5">
              <AlertTriangle className="h-4 w-4" />
              {t('settings.delete.confirmTitle')}
            </p>
            <h2 className="mt-2 text-xl font-extrabold">
              {locale === 'en' ? 'Are you absolutely sure?' : 'Xác nhận xoá tài khoản'}
            </h2>
            <p className="mt-1 text-sm font-medium text-[var(--app-muted)]">
              {t('settings.delete.confirmDescription')}
            </p>
          </div>
          <button
            aria-label="Close"
            className="rounded-full border border-[var(--field-border)] p-2 text-[var(--app-text)] transition hover:bg-coral/10"
            onClick={onClose}
            type="button"
          >
            <X className="h-4 w-4" />
          </button>
        </div>

        {/* Mode Selector */}
        <div className="mt-4 space-y-3">
          <label className="text-xs font-bold text-[var(--app-muted)] uppercase tracking-wider block">
            {locale === 'en' ? 'Deletion Mode' : 'Chế độ xoá'}
          </label>
          <div className="grid grid-cols-2 gap-3">
            <button
              type="button"
              className={cn(
                'flex flex-col items-center justify-center p-3 rounded-xl border text-center transition-all',
                mode === 'SOFT'
                  ? 'border-violet bg-violet/5 text-violet'
                  : 'border-[var(--field-border)] hover:bg-[var(--field-bg)]'
              )}
              onClick={() => setMode('SOFT')}
            >
              <span className="text-sm font-bold">{locale === 'en' ? 'Anonymize' : 'Ẩn danh hoá'}</span>
              <span className="text-[10px] mt-1 opacity-70">
                {locale === 'en' ? 'Keep stats, remove profile' : 'Giữ thống kê, xoá hồ sơ'}
              </span>
            </button>
            <button
              type="button"
              className={cn(
                'flex flex-col items-center justify-center p-3 rounded-xl border text-center transition-all',
                mode === 'HARD'
                  ? 'border-coral bg-coral/5 text-coral'
                  : 'border-[var(--field-border)] hover:bg-[var(--field-bg)]'
              )}
              onClick={() => setMode('HARD')}
            >
              <span className="text-sm font-bold">{locale === 'en' ? 'Delete Permanently' : 'Xoá vĩnh viễn'}</span>
              <span className="text-[10px] mt-1 opacity-70">
                {locale === 'en' ? 'Erase all data' : 'Xoá sạch hoàn toàn dữ liệu'}
              </span>
            </button>
          </div>
        </div>

        {/* Password input for local users */}
        {isLocal && (
          <div className="mt-4">
            <label className="text-xs font-bold text-[var(--app-muted)] uppercase tracking-wider block mb-2">
              {t('auth.password')}
            </label>
            <input
              type="password"
              className="w-full h-10 px-3 rounded-lg border border-[var(--field-border)] bg-[var(--field-bg)] text-sm font-bold text-[var(--app-text)] focus:border-violet focus:outline-none"
              placeholder={locale === 'en' ? 'Enter password to confirm' : 'Nhập mật khẩu để xác nhận'}
              value={password}
              onChange={(e) => setPassword(e.target.value)}
            />
          </div>
        )}

        <div className="mt-6 flex justify-end gap-3">
          <Button onClick={onClose} type="button" variant="secondary" disabled={deleting}>
            {t('common.cancel')}
          </Button>
          <Button
            onClick={handleDelete}
            type="button"
            disabled={deleting || (isLocal && !password)}
            className="bg-coral text-white hover:bg-coral/90 shadow-md shadow-coral/10"
          >
            {deleting ? (locale === 'en' ? 'Deleting...' : 'Đang xoá...') : t('settings.delete.confirm')}
          </Button>
        </div>
      </div>
    </div>
  );
}


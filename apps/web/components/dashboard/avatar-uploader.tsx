'use client';

/**
 * Avatar uploader for /dashboard/settings.
 *
 * Flow:
 *   1. User picks file → local preview
 *   2. POST multipart to /v1/storage/me/avatar
 *   3. Backend uploads to Supabase using service role and returns publicUrl
 *   4. PATCH /v1/user-profiles/me/profile body `{avatar: publicUrl}`
 *   5. Call `onUpdated(publicUrl)` so the parent settings page refreshes
 */

import { useCallback, useRef, useState } from 'react';
import { Camera, Loader2, X } from 'lucide-react';
import { apiFetch } from '@/lib/api';
import { Button } from '@/components/ui/button';
import { useUiStore } from '@/stores/use-ui-store';
import { useTranslation } from '@/lib/i18n/i18n-provider';
import { cn } from '@/lib/utils';

const MAX_BYTES = 5 * 1024 * 1024; // 5 MB — plenty for an avatar PNG/JPEG.
const ACCEPTED_MIME = ['image/png', 'image/jpeg', 'image/webp', 'image/gif'];

interface UploadedAvatar {
  publicUrl: string;
}

export function AvatarUploader({
  currentAvatar,
  displayName,
  onUpdated,
}: {
  currentAvatar?: string | null;
  displayName?: string | null;
  onUpdated?: (publicUrl: string) => void;
}) {
  const { t } = useTranslation();
  const pushToast = useUiStore((state) => state.pushToast);
  const inputRef = useRef<HTMLInputElement | null>(null);
  const [preview, setPreview] = useState<string | null>(currentAvatar ?? null);
  const [busy, setBusy] = useState(false);

  const initials = (displayName ?? '?')
    .trim()
    .split(/[\s.@_-]+/)
    .filter(Boolean)
    .slice(0, 2)
    .map((part) => part[0])
    .join('')
    .toUpperCase() || '?';

  const handleFile = useCallback(
    async (file: File) => {
      if (!ACCEPTED_MIME.includes(file.type)) {
        pushToast({
          tone: 'error',
          title: t('settings.avatar.unsupportedType'),
          message: t('settings.avatar.supportedTypes'),
        });
        return;
      }
      if (file.size > MAX_BYTES) {
        pushToast({
          tone: 'error',
          title: t('settings.avatar.tooLarge'),
          message: t('settings.avatar.maxSize'),
        });
        return;
      }

      setBusy(true);
      // Show local preview immediately while uploading.
      const localPreview = URL.createObjectURL(file);
      setPreview(localPreview);

      try {
        const formData = new FormData();
        formData.append('file', file);

        const uploaded = await apiFetch<UploadedAvatar>('/storage/me/avatar', {
          method: 'POST',
          body: formData,
        });
        const publicUrl = `${uploaded.publicUrl}?v=${Date.now()}`;

        // 4. Save URL on user profile.
        await apiFetch('/user-profiles/me/profile', {
          method: 'PATCH',
          body: JSON.stringify({ avatar: publicUrl }),
        });

        setPreview(publicUrl);
        URL.revokeObjectURL(localPreview);
        pushToast({
          tone: 'success',
          title: t('settings.profile.saved'),
          message: t('settings.avatar.updated'),
        });
        onUpdated?.(publicUrl);
      } catch (cause) {
        // Revert preview on failure.
        setPreview(currentAvatar ?? null);
        URL.revokeObjectURL(localPreview);
        pushToast({
          tone: 'error',
          title: t('settings.avatar.uploadFailed'),
          message: cause instanceof Error ? cause.message : t('common.unknown'),
        });
      } finally {
        setBusy(false);
        if (inputRef.current) inputRef.current.value = '';
      }
    },
    [currentAvatar, onUpdated, pushToast, t],
  );

  const handleRemove = useCallback(async () => {
    setBusy(true);
    try {
      await apiFetch('/user-profiles/me/profile', {
        method: 'PATCH',
        body: JSON.stringify({ avatar: null }),
      });
      setPreview(null);
      pushToast({ tone: 'success', title: t('settings.avatar.removed') });
      onUpdated?.('');
    } catch (cause) {
      pushToast({
        tone: 'error',
        title: t('settings.avatar.removeFailed'),
        message: cause instanceof Error ? cause.message : t('common.unknown'),
      });
    } finally {
      setBusy(false);
    }
  }, [onUpdated, pushToast, t]);

  return (
    <div className="flex flex-wrap items-center gap-4">
      {/* Avatar disc — preview or initials fallback */}
      <div className="relative">
        <div
          className={cn(
            'flex h-20 w-20 items-center justify-center overflow-hidden rounded-full bg-violet text-2xl font-extrabold text-white shadow-panel ring-2 ring-white',
            busy && 'opacity-60',
          )}
        >
          {preview ? (
            // eslint-disable-next-line @next/next/no-img-element
            <img
              alt={t('settings.profile.avatar')}
              className="h-full w-full object-cover"
              src={preview}
            />
          ) : (
            <span aria-hidden="true">{initials}</span>
          )}
        </div>
        {busy ? (
          <div className="absolute inset-0 flex items-center justify-center rounded-full bg-night/40">
            <Loader2 className="h-5 w-5 animate-spin text-white" />
          </div>
        ) : null}
      </div>

      <div className="flex flex-col gap-2">
        <input
          accept={ACCEPTED_MIME.join(',')}
          aria-label={t('settings.profile.uploadAvatar')}
          className="hidden"
          onChange={(event) => {
            const file = event.target.files?.[0];
            if (file) void handleFile(file);
          }}
          ref={inputRef}
          type="file"
        />
        <div className="flex flex-wrap gap-2">
          <Button
            disabled={busy}
            onClick={() => inputRef.current?.click()}
            variant="secondary"
          >
            <Camera className="h-4 w-4" />
            {t('settings.profile.uploadAvatar')}
          </Button>
          {preview ? (
            <Button
              className="h-10"
              disabled={busy}
              onClick={() => void handleRemove()}
              variant="secondary"
            >
              <X className="h-4 w-4" />
              {t('common.cancel')}
            </Button>
          ) : null}
        </div>
        <p className="text-xs font-semibold text-[var(--app-muted)]">
          {t('settings.avatar.help')}
        </p>
      </div>
    </div>
  );
}

'use client';

/**
 * Avatar uploader for /dashboard/settings.
 *
 * Flow:
 *   1. User picks file → onChange
 *   2. POST /v1/storage/signed-upload-url body `{path, upsert:true}`
 *      → backend creates signed URL via Supabase service role
 *   3. PUT the file binary to that signed URL (direct to Supabase,
 *      backend doesn't proxy bytes)
 *   4. Compute public URL: <SUPABASE>/storage/v1/object/public/<bucket>/<path>
 *   5. PATCH /v1/user-profiles/me/profile body `{avatar: publicUrl}`
 *      → backend updates User.avatar (separate from profile upsert)
 *   6. Call `onUpdated(publicUrl)` so the parent settings page refreshes
 */

import { useCallback, useRef, useState } from 'react';
import { Camera, Loader2, X } from 'lucide-react';
import { apiFetch } from '@/lib/api';
import { Button } from '@/components/ui/button';
import { useUiStore } from '@/stores/use-ui-store';
import { useTranslation } from '@/lib/i18n/i18n-provider';
import { cn } from '@/lib/utils';

const SUPABASE_URL =
  process.env.NEXT_PUBLIC_SUPABASE_URL ?? 'https://koshdbyfhivhpmydcgst.supabase.co';

const MAX_BYTES = 5 * 1024 * 1024; // 5 MB — plenty for an avatar PNG/JPEG.
const ACCEPTED_MIME = ['image/png', 'image/jpeg', 'image/webp', 'image/gif'];

interface SignedUpload {
  bucket: string;
  path: string;
  signedUrl: string;
  token: string;
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
          title: 'Định dạng ảnh không hỗ trợ',
          message: 'Chọn PNG, JPEG, WEBP hoặc GIF.',
        });
        return;
      }
      if (file.size > MAX_BYTES) {
        pushToast({
          tone: 'error',
          title: 'Ảnh lớn hơn 5 MB',
          message: 'Em chỉ chấp nhận tối đa 5 MB cho ảnh đại diện.',
        });
        return;
      }

      setBusy(true);
      // Show local preview immediately while uploading.
      const localPreview = URL.createObjectURL(file);
      setPreview(localPreview);

      try {
        // 1. Get a signed upload URL scoped to this user's path.
        // `upsert: true` lets re-uploads overwrite their previous file.
        const ext = file.name.split('.').pop()?.toLowerCase() || 'png';
        const signed = await apiFetch<SignedUpload>('/storage/signed-upload-url', {
          method: 'POST',
          body: JSON.stringify({
            path: `avatar.${ext}`,
            upsert: true,
          }),
        });

        // 2. PUT the file binary directly to Supabase (no proxy through backend).
        const uploadRes = await fetch(signed.signedUrl, {
          method: 'PUT',
          headers: { 'Content-Type': file.type, 'x-upsert': 'true' },
          body: file,
        });
        if (!uploadRes.ok) {
          throw new Error(`Upload failed: HTTP ${uploadRes.status}`);
        }

        // 3. Build the public URL (bucket is public-assets so no signing needed).
        const publicUrl = `${SUPABASE_URL}/storage/v1/object/public/${signed.bucket}/${signed.path}?v=${Date.now()}`;

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
          message: 'Ảnh đại diện đã được cập nhật.',
        });
        onUpdated?.(publicUrl);
      } catch (cause) {
        // Revert preview on failure.
        setPreview(currentAvatar ?? null);
        URL.revokeObjectURL(localPreview);
        pushToast({
          tone: 'error',
          title: 'Không tải được ảnh',
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
      pushToast({ tone: 'success', title: 'Đã xoá ảnh đại diện' });
      onUpdated?.('');
    } catch (cause) {
      pushToast({
        tone: 'error',
        title: 'Không xoá được ảnh',
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
          PNG / JPEG / WEBP / GIF, tối đa 5 MB.
        </p>
      </div>
    </div>
  );
}

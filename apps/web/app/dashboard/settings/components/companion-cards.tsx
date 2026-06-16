'use client';

import { useState } from 'react';
import { useTranslation } from '@/lib/i18n/i18n-provider';
import { VI_SETTINGS_COPY, EN_SETTINGS_COPY } from '../settings-copy';
import type { CompanionAsset } from '../settings-types';

export function CompanionAssetCard({
  asset,
  selected,
  onSelect,
}: {
  asset: CompanionAsset;
  selected: boolean;
  onSelect: () => void;
}) {
  const { locale } = useTranslation();
  const copy = locale === 'en' ? EN_SETTINGS_COPY : VI_SETTINGS_COPY;

  return (
    <button
      className={`overflow-hidden rounded-xl border text-left transition ${
        selected
          ? 'border-violet bg-violet/5 shadow-panel'
          : 'border-lilac/70 bg-white/75 hover:border-violet'
      }`}
      onClick={onSelect}
      type="button"
    >
      <div
        className="h-28 w-full"
        style={{ background: asset.secondaryColor || 'rgba(255,255,255,0.72)' }}
      >
        {asset.previewImageUrl ? (
          <SafeCompanionImage
            alt={asset.name}
            className="h-full w-full object-cover"
            src={asset.previewImageUrl}
          />
        ) : null}
      </div>
      <div className="p-4">
        <p className="font-extrabold text-ink">{asset.name}</p>
        <p className="mt-1 text-sm text-slate">
          {asset.description || copy.assetFallbackDescription}
        </p>
      </div>
    </button>
  );
}

export function SafeCompanionImage({
  alt,
  className,
  src,
}: {
  alt: string;
  className: string;
  src: string;
}) {
  const { locale } = useTranslation();
  const copy = locale === 'en' ? EN_SETTINGS_COPY : VI_SETTINGS_COPY;
  const [failed, setFailed] = useState(false);

  if (failed) {
    return (
      <div
        className={`${className} flex items-center justify-center bg-violet/10 text-xs font-bold text-violet`}
      >
        {copy.previewLoadFailed}
      </div>
    );
  }

  return (
    // eslint-disable-next-line @next/next/no-img-element
    <img
      alt={alt}
      className={className}
      onError={() => setFailed(true)}
      referrerPolicy="no-referrer"
      src={src}
    />
  );
}


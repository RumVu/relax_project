'use client';

import { AdminCatalogPage } from '@/components/dashboard/admin-catalog-page';
import { useTranslation } from '@/lib/i18n/i18n-provider';

export default function AdminCompanionAssetsPage() {
  const { t } = useTranslation();
  return (
    <AdminCatalogPage
      copy={t('admin.companionAssets.copy')}
      endpoint="/companion-assets"
      kind="companion-assets"
      title={t('admin.companionAssets.title')}
    />
  );
}

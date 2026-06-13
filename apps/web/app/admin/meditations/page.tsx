'use client';

import { AdminCatalogPage } from '@/components/dashboard/admin-catalog-page';
import { useTranslation } from '@/lib/i18n/i18n-provider';

export default function AdminMeditationsPage() {
  const { t } = useTranslation();
  return (
    <AdminCatalogPage
      copy={t('admin.meditations.copy')}
      endpoint="/meditations/guides"
      kind="meditations"
      title={t('admin.meditations.title')}
    />
  );
}

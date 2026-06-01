'use client';

import { AdminCatalogPage } from '@/components/dashboard/admin-catalog-page';
import { useTranslation } from '@/lib/i18n/i18n-provider';

export default function AdminThemesPage() {
  const { t } = useTranslation();
  return (
    <AdminCatalogPage
      copy={t('admin.themes.copy')}
      endpoint="/app-themes"
      kind="themes"
      title={t('admin.themes.title')}
    />
  );
}

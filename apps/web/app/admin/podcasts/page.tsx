'use client';

import { AdminCatalogPage } from '@/components/dashboard/admin-catalog-page';
import { useTranslation } from '@/lib/i18n/i18n-provider';

export default function AdminPodcastsPage() {
  const { t } = useTranslation();

  return (
    <AdminCatalogPage
      copy={t('admin.podcasts.copy')}
      endpoint="/ambient-sounds"
      fixedCategory="PODCAST"
      kind="sounds"
      title={t('admin.podcasts.title')}
    />
  );
}

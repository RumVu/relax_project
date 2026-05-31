'use client';

import { AdminCatalogPage } from '@/components/dashboard/admin-catalog-page';
import { useTranslation } from '@/lib/i18n/i18n-provider';

export default function AdminQuotesPage() {
  const { t } = useTranslation();
  return (
    <AdminCatalogPage
      copy={t('admin.quotes.copy')}
      endpoint="/cozy-quotes"
      kind="quotes"
      title={t('admin.quotes.title')}
    />
  );
}

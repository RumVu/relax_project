'use client';

import { AdminCatalogPage } from '@/components/dashboard/admin-catalog-page';
import { useTranslation } from '@/lib/i18n/i18n-provider';

export default function AdminCompanionMessagesPage() {
  const { t } = useTranslation();
  return (
    <AdminCatalogPage
      copy={t('admin.companionMessages.copy')}
      endpoint="/companion-messages"
      kind="companion-messages"
      title={t('admin.companionMessages.title')}
    />
  );
}

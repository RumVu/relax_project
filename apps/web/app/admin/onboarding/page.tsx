'use client';

import { AdminCatalogPage } from '@/components/dashboard/admin-catalog-page';
import { useTranslation } from '@/lib/i18n/i18n-provider';

export default function AdminOnboardingPage() {
  const { t } = useTranslation();
  return (
    <AdminCatalogPage
      copy={t('admin.onboarding.copy')}
      endpoint="/onboarding-slides"
      kind="onboarding"
      title={t('admin.onboarding.title')}
    />
  );
}

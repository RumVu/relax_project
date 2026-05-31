'use client';

import { AdminCatalogPage } from '@/components/dashboard/admin-catalog-page';
import { useTranslation } from '@/lib/i18n/i18n-provider';

export default function AdminExercisesPage() {
  const { t } = useTranslation();
  return (
    <AdminCatalogPage
      copy={t('admin.exercises.copy')}
      endpoint="/breathing-exercises"
      kind="exercises"
      title={t('admin.exercises.title')}
    />
  );
}

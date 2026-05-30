'use client';

import { AdminCatalogPage } from '@/components/dashboard/admin-catalog-page';
import { useTranslation } from '@/lib/i18n/i18n-provider';

export default function AdminOnboardingPage() {
  const { t } = useTranslation();
  return (
    <AdminCatalogPage
      copy="Quản lý nội dung hướng dẫn ban đầu — thứ tự hiển thị, ảnh hoặc hoạt hình và trạng thái xuất bản."
      endpoint="/onboarding-slides"
      kind="onboarding"
      title={t('admin.onboarding.title')}
    />
  );
}

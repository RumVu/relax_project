'use client';

import { AdminCatalogPage } from '@/components/dashboard/admin-catalog-page';
import { useTranslation } from '@/lib/i18n/i18n-provider';

export default function AdminSoundsPage() {
  const { t } = useTranslation();
  return (
    <AdminCatalogPage
      copy="Quản lý âm thanh không gian theo nhóm, thời lượng, đường dẫn tài nguyên và trạng thái xuất bản."
      endpoint="/ambient-sounds"
      kind="sounds"
      title={t('admin.sounds.title')}
    />
  );
}

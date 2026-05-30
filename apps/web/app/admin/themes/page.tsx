'use client';

import { AdminCatalogPage } from '@/components/dashboard/admin-catalog-page';
import { useTranslation } from '@/lib/i18n/i18n-provider';

export default function AdminThemesPage() {
  const { t } = useTranslation();
  return (
    <AdminCatalogPage
      copy="Quản lý bảng màu, chế độ sáng/tối/theo hệ thống, giao diện mặc định và trạng thái xuất bản."
      endpoint="/app-themes"
      kind="themes"
      title={t('admin.themes.title')}
    />
  );
}

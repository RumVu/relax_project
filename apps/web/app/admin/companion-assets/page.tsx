'use client';

import { AdminCatalogPage } from '@/components/dashboard/admin-catalog-page';
import { useTranslation } from '@/lib/i18n/i18n-provider';

export default function AdminCompanionAssetsPage() {
  const { t } = useTranslation();
  return (
    <AdminCatalogPage
      copy="Tải lên và chỉnh sửa người bạn đồng hành — ảnh xem trước, sprite sheet, hoạt hình, bảng màu, mặc định và trạng thái xuất bản."
      endpoint="/companion-assets"
      kind="companion-assets"
      title={t('admin.companionAssets.title')}
    />
  );
}

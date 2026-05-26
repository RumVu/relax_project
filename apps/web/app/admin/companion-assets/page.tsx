import { AdminCatalogPage } from '@/components/dashboard/admin-catalog-page';

export default function AdminCompanionAssetsPage() {
  return (
    <AdminCatalogPage
      copy="Nạp và chỉnh linh thú: preview, sprite sheet, animation, bảng màu, mặc định và publish."
      endpoint="/companion-assets"
      kind="companion-assets"
      title="Companion Assets"
    />
  );
}

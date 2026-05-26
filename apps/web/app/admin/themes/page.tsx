import { AdminCatalogPage } from '@/components/dashboard/admin-catalog-page';

export default function AdminThemesPage() {
  return (
    <AdminCatalogPage
      copy="Quản lý bảng màu, light/dark/system mode, theme mặc định và trạng thái publish."
      endpoint="/app-themes"
      kind="themes"
      title="Themes"
    />
  );
}

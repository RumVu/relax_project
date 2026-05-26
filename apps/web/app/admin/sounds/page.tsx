import { AdminCatalogPage } from '@/components/dashboard/admin-catalog-page';

export default function AdminSoundsPage() {
  return (
    <AdminCatalogPage
      copy="Quản lý ambient sounds, category, duration, asset URL và trạng thái publish."
      endpoint="/ambient-sounds"
      kind="sounds"
      title="Sounds"
    />
  );
}

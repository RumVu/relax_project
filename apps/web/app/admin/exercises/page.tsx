import { AdminCatalogPage } from '@/components/dashboard/admin-catalog-page';

export default function AdminExercisesPage() {
  return (
    <AdminCatalogPage
      copy="Quản lý bài thở/thiền mẫu, nhịp thở, duration, difficulty và hướng dẫn."
      endpoint="/breathing-exercises"
      kind="exercises"
      title="Exercises"
    />
  );
}

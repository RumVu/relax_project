import { AdminCatalogPage } from '@/components/dashboard/admin-catalog-page';

export default function AdminQuotesPage() {
  return (
    <AdminCatalogPage
      copy="CRUD cozy quotes theo mood, weight, trạng thái active và nội dung hiển thị."
      endpoint="/cozy-quotes"
      kind="quotes"
      title="Quotes"
    />
  );
}

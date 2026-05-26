import { AdminCatalogPage } from '@/components/dashboard/admin-catalog-page';

export default function AdminCompanionMessagesPage() {
  return (
    <AdminCatalogPage
      copy="Quản lý tin nhắn linh thú theo trigger, mood người dùng, mood linh thú, giờ hiển thị và weight."
      endpoint="/companion-messages"
      kind="companion-messages"
      title="Companion Messages"
    />
  );
}

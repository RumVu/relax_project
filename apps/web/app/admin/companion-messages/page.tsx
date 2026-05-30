'use client';

import { AdminCatalogPage } from '@/components/dashboard/admin-catalog-page';
import { useTranslation } from '@/lib/i18n/i18n-provider';

export default function AdminCompanionMessagesPage() {
  const { t } = useTranslation();
  return (
    <AdminCatalogPage
      copy="Quản lý tin nhắn của người bạn đồng hành theo bộ kích hoạt, cảm xúc người dùng, cảm xúc đồng hành, giờ hiển thị và trọng số."
      endpoint="/companion-messages"
      kind="companion-messages"
      title={t('admin.companionMessages.title')}
    />
  );
}

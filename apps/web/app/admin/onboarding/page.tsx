import { AdminCatalogPage } from '@/components/dashboard/admin-catalog-page';

export default function AdminOnboardingPage() {
  return (
    <AdminCatalogPage
      copy="Quản lý nội dung onboarding, thứ tự hiển thị, ảnh/animation và trạng thái publish."
      endpoint="/onboarding-slides"
      kind="onboarding"
      title="Onboarding"
    />
  );
}

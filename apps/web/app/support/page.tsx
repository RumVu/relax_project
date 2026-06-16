import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Support — Thi Ái',
  description: 'Hỗ trợ và liên hệ ứng dụng Thi Ái.',
};

export default function SupportPage() {
  return (
    <main className="mx-auto max-w-2xl px-6 py-16 text-[var(--app-text,#1a1a2e)]">
      <h1 className="text-3xl font-extrabold tracking-tight">Hỗ trợ</h1>
      <p className="mt-2 text-[var(--app-muted,#6b7280)]">
        Chúng tôi sẵn sàng giúp đỡ bạn. Vui lòng chọn cách liên hệ phù hợp.
      </p>

      <section className="mt-10 space-y-6">
        <div className="rounded-xl border border-[var(--field-border,#e5e7eb)] p-6">
          <h2 className="text-lg font-bold">📧 Email</h2>
          <p className="mt-2 text-sm text-[var(--app-muted,#6b7280)]">
            Gửi câu hỏi, báo lỗi, hoặc phản hồi đến:
          </p>
          <a
            href="mailto:minhvnq1@welosoft.com"
            className="mt-2 inline-block text-sm font-bold text-violet-600 underline"
          >
            minhvnq1@welosoft.com
          </a>
          <p className="mt-1 text-xs text-[var(--app-muted,#6b7280)]">
            Thời gian phản hồi: trong vòng 48 giờ làm việc.
          </p>
        </div>

        <div className="rounded-xl border border-[var(--field-border,#e5e7eb)] p-6">
          <h2 className="text-lg font-bold">🐛 Báo lỗi</h2>
          <p className="mt-2 text-sm text-[var(--app-muted,#6b7280)]">
            Nếu bạn gặp lỗi trong ứng dụng, vui lòng mô tả chi tiết:
          </p>
          <ul className="mt-2 list-disc space-y-1 pl-5 text-xs text-[var(--app-muted,#6b7280)]">
            <li>Thiết bị và phiên bản hệ điều hành</li>
            <li>Phiên bản app (xem trong Cài đặt)</li>
            <li>Các bước tái tạo lỗi</li>
            <li>Ảnh chụp màn hình (nếu có)</li>
          </ul>
        </div>

        <div className="rounded-xl border border-[var(--field-border,#e5e7eb)] p-6">
          <h2 className="text-lg font-bold">🔒 Quyền riêng tư & Dữ liệu</h2>
          <p className="mt-2 text-sm text-[var(--app-muted,#6b7280)]">
            Để yêu cầu xuất hoặc xoá dữ liệu cá nhân:
          </p>
          <ul className="mt-2 list-disc space-y-1 pl-5 text-xs text-[var(--app-muted,#6b7280)]">
            <li>
              Trong app: <strong>Cài đặt → Dữ liệu & Quyền riêng tư</strong>
            </li>
            <li>
              Xoá tài khoản:{' '}
              <a href="/delete-account" className="underline">
                trang xoá tài khoản
              </a>
            </li>
            <li>
              Xem chính sách:{' '}
              <a href="/privacy" className="underline">
                Chính sách Quyền riêng tư
              </a>
            </li>
          </ul>
        </div>

        <div className="rounded-xl border border-amber-200 bg-amber-50 p-6 dark:border-amber-800 dark:bg-amber-950">
          <h2 className="text-lg font-bold">🆘 Khẩn cấp</h2>
          <p className="mt-2 text-sm text-[var(--app-muted,#6b7280)]">
            Thi Ái <strong>không phải dịch vụ cấp cứu</strong>. Nếu bạn hoặc
            người thân đang trong tình trạng nguy hiểm:
          </p>
          <ul className="mt-2 space-y-1 text-sm font-semibold">
            <li>📞 Đường dây nóng sức khoẻ tâm thần: 1800 599 920</li>
            <li>📞 Cấp cứu: 115</li>
          </ul>
        </div>
      </section>
    </main>
  );
}

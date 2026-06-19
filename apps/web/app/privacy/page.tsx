import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Privacy Policy — Relax Time',
  description: 'Chính sách quyền riêng tư của ứng dụng Relax Time.',
};

export default function PrivacyPage() {
  return (
    <main className="mx-auto max-w-2xl px-6 py-16 text-[var(--app-text,#1a1a2e)]">
      <h1 className="text-3xl font-extrabold tracking-tight">
        Chính sách Quyền riêng tư
      </h1>
      <p className="mt-1 text-sm text-[var(--app-muted,#6b7280)]">
        Cập nhật lần cuối: 16 tháng 6, 2026
      </p>

      <section className="mt-8 space-y-6 text-sm leading-relaxed">
        <div>
          <h2 className="text-lg font-bold">1. Dữ liệu chúng tôi thu thập</h2>
          <ul className="mt-2 list-disc space-y-1 pl-5 text-[var(--app-muted,#6b7280)]">
            <li>
              <strong>Tài khoản:</strong> email, tên hiển thị, ảnh đại diện (nếu
              bạn chọn cung cấp).
            </li>
            <li>
              <strong>Dữ liệu sức khoẻ tinh thần:</strong> mood check-in, nhật
              ký, phiên thư giãn, phiên thiền, bài thở, giấc ngủ.
            </li>
            <li>
              <strong>Vị trí (tuỳ chọn):</strong> chỉ khi bạn cho phép, dùng để
              gợi ý thời tiết và địa điểm thư giãn. Chúng tôi không lưu lịch sử
              vị trí.
            </li>
            <li>
              <strong>Giọng nói (tuỳ chọn):</strong> xử lý cục bộ trên thiết bị
              để chuyển thành văn bản, không gửi lên server dưới dạng audio.
            </li>
            <li>
              <strong>Dữ liệu kỹ thuật:</strong> loại thiết bị, phiên bản app,
              log lỗi ẩn danh.
            </li>
          </ul>
        </div>

        <div>
          <h2 className="text-lg font-bold">2. Cách chúng tôi sử dụng dữ liệu</h2>
          <p className="mt-2 text-[var(--app-muted,#6b7280)]">
            Dữ liệu được dùng để cung cấp và cải thiện trải nghiệm cá nhân hoá
            (gợi ý thư giãn, thống kê mood, linh thú companion). Chúng tôi{' '}
            <strong>không bán</strong> dữ liệu cá nhân cho bên thứ ba. Dữ liệu
            phân tích gộp (aggregate) có thể được dùng để cải thiện sản phẩm.
          </p>
        </div>

        <div>
          <h2 className="text-lg font-bold">3. Lưu trữ & bảo mật</h2>
          <p className="mt-2 text-[var(--app-muted,#6b7280)]">
            Dữ liệu được mã hoá khi truyền (HTTPS/TLS) và lưu trữ trên
            PostgreSQL managed database. Token xác thực sử dụng JWT với thời hạn
            giới hạn. Mật khẩu được hash bằng bcrypt.
          </p>
        </div>

        <div>
          <h2 className="text-lg font-bold">4. Quyền của bạn</h2>
          <ul className="mt-2 list-disc space-y-1 pl-5 text-[var(--app-muted,#6b7280)]">
            <li>
              <strong>Xem dữ liệu:</strong> trong app, mục Dữ liệu & Quyền riêng
              tư.
            </li>
            <li>
              <strong>Xuất dữ liệu:</strong> tải toàn bộ dữ liệu dưới dạng JSON.
            </li>
            <li>
              <strong>Xoá dữ liệu:</strong> xoá từng loại hoặc toàn bộ tài khoản.
            </li>
            <li>
              <strong>Xoá tài khoản:</strong> truy cập{' '}
              <a href="/delete-account" className="underline">
                trang xoá tài khoản
              </a>{' '}
              hoặc liên hệ support.
            </li>
          </ul>
        </div>

        <div>
          <h2 className="text-lg font-bold">5. Dịch vụ bên thứ ba</h2>
          <p className="mt-2 text-[var(--app-muted,#6b7280)]">
            Chúng tôi sử dụng: Google Sign-In (xác thực), Vercel Analytics (thống
            kê truy cập web ẩn danh), Railway (hosting backend). Mỗi dịch vụ có
            chính sách riêng mà bạn nên tham khảo.
          </p>
        </div>

        <div>
          <h2 className="text-lg font-bold">6. Liên hệ</h2>
          <p className="mt-2 text-[var(--app-muted,#6b7280)]">
            Nếu bạn có câu hỏi về quyền riêng tư, vui lòng liên hệ:{' '}
            <a
              href="mailto:minhvnq1@welosoft.com"
              className="font-semibold underline"
            >
              minhvnq1@welosoft.com
            </a>
          </p>
        </div>

        <div className="rounded-xl border border-[var(--field-border,#e5e7eb)] bg-[var(--field-bg,#f9fafb)] p-4 text-xs text-[var(--app-muted,#6b7280)]">
          <strong>Miễn trừ trách nhiệm:</strong> Relax Time không phải là thiết bị y
          tế và không cung cấp chẩn đoán, điều trị hay dịch vụ cấp cứu. Nếu bạn
          đang trong tình trạng khẩn cấp, hãy liên hệ đường dây nóng sức khoẻ
          tâm thần hoặc gọi 115.
        </div>
      </section>
    </main>
  );
}

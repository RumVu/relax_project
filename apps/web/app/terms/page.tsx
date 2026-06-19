import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Terms of Service — Relax Time',
  description: 'Điều khoản sử dụng ứng dụng Relax Time.',
};

export default function TermsPage() {
  return (
    <main className="mx-auto max-w-2xl px-6 py-16 text-[var(--app-text,#1a1a2e)]">
      <h1 className="text-3xl font-extrabold tracking-tight">
        Điều khoản Sử dụng
      </h1>
      <p className="mt-1 text-sm text-[var(--app-muted,#6b7280)]">
        Cập nhật lần cuối: 16 tháng 6, 2026
      </p>

      <section className="mt-8 space-y-6 text-sm leading-relaxed">
        <div>
          <h2 className="text-lg font-bold">1. Chấp nhận điều khoản</h2>
          <p className="mt-2 text-[var(--app-muted,#6b7280)]">
            Khi sử dụng ứng dụng Relax Time (&quot;Dịch vụ&quot;), bạn đồng ý tuân
            thủ các điều khoản này. Nếu bạn không đồng ý, vui lòng ngừng sử dụng
            Dịch vụ.
          </p>
        </div>

        <div>
          <h2 className="text-lg font-bold">2. Mô tả Dịch vụ</h2>
          <p className="mt-2 text-[var(--app-muted,#6b7280)]">
            Relax Time là ứng dụng hỗ trợ chăm sóc sức khoẻ tinh thần cá nhân, bao
            gồm theo dõi cảm xúc, nhật ký, bài tập thư giãn, thiền, âm thanh và
            linh thú đồng hành. Dịch vụ{' '}
            <strong>không phải là dịch vụ y tế</strong> và không thay thế tư vấn
            chuyên môn.
          </p>
        </div>

        <div>
          <h2 className="text-lg font-bold">3. Tài khoản người dùng</h2>
          <ul className="mt-2 list-disc space-y-1 pl-5 text-[var(--app-muted,#6b7280)]">
            <li>Bạn chịu trách nhiệm bảo mật thông tin đăng nhập.</li>
            <li>Bạn phải từ 13 tuổi trở lên để sử dụng Dịch vụ.</li>
            <li>
              Một tài khoản chỉ dành cho một người dùng, không chia sẻ cho người
              khác.
            </li>
          </ul>
        </div>

        <div>
          <h2 className="text-lg font-bold">4. Nội dung người dùng</h2>
          <p className="mt-2 text-[var(--app-muted,#6b7280)]">
            Bạn sở hữu nội dung mình tạo (nhật ký, mood, feedback). Bạn cấp cho
            chúng tôi quyền lưu trữ và xử lý nội dung này nhằm cung cấp Dịch vụ.
            Bạn cam kết không đăng tải nội dung vi phạm pháp luật, quấy rối, hoặc
            xâm phạm quyền người khác thông qua tính năng bạn bè/feed.
          </p>
        </div>

        <div>
          <h2 className="text-lg font-bold">5. Hành vi bị cấm</h2>
          <ul className="mt-2 list-disc space-y-1 pl-5 text-[var(--app-muted,#6b7280)]">
            <li>Lạm dụng, quấy rối người dùng khác qua buddy/feed.</li>
            <li>Cố tình phá hoại hoặc can thiệp hệ thống.</li>
            <li>Sử dụng Dịch vụ cho mục đích bất hợp pháp.</li>
            <li>Tạo nhiều tài khoản để lạm dụng tính năng miễn phí.</li>
          </ul>
        </div>

        <div>
          <h2 className="text-lg font-bold">6. Tính năng Premium</h2>
          <p className="mt-2 text-[var(--app-muted,#6b7280)]">
            Một số tính năng yêu cầu gói Premium. Thanh toán trên mobile tuân
            theo chính sách của Apple App Store hoặc Google Play Store. Việc huỷ
            subscription tuân theo quy định của nền tảng tương ứng.
          </p>
        </div>

        <div>
          <h2 className="text-lg font-bold">7. Miễn trừ trách nhiệm</h2>
          <p className="mt-2 text-[var(--app-muted,#6b7280)]">
            Dịch vụ được cung cấp &quot;nguyên trạng&quot; (as-is). Chúng tôi
            không đảm bảo Dịch vụ hoạt động liên tục không gián đoạn. Relax Time{' '}
            <strong>không phải thiết bị y tế</strong>, không cung cấp chẩn đoán,
            điều trị hoặc dịch vụ cấp cứu.
          </p>
        </div>

        <div>
          <h2 className="text-lg font-bold">8. Chấm dứt</h2>
          <p className="mt-2 text-[var(--app-muted,#6b7280)]">
            Chúng tôi có quyền tạm ngưng hoặc chấm dứt tài khoản vi phạm điều
            khoản. Bạn có thể xoá tài khoản bất cứ lúc nào qua{' '}
            <a href="/delete-account" className="underline">
              trang xoá tài khoản
            </a>
            .
          </p>
        </div>

        <div>
          <h2 className="text-lg font-bold">9. Liên hệ</h2>
          <p className="mt-2 text-[var(--app-muted,#6b7280)]">
            Mọi thắc mắc về điều khoản, vui lòng liên hệ:{' '}
            <a
              href="mailto:minhvnq1@welosoft.com"
              className="font-semibold underline"
            >
              minhvnq1@welosoft.com
            </a>
          </p>
        </div>
      </section>
    </main>
  );
}

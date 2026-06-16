'use client';

import { useState } from 'react';
import type { Metadata } from 'next';

export default function DeleteAccountPage() {
  const [email, setEmail] = useState('');
  const [reason, setReason] = useState('');
  const [submitted, setSubmitted] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitted(true);
  };

  return (
    <main className="mx-auto max-w-2xl px-6 py-16 text-[var(--app-text,#1a1a2e)]">
      <h1 className="text-3xl font-extrabold tracking-tight">
        Xoá tài khoản
      </h1>
      <p className="mt-2 text-sm text-[var(--app-muted,#6b7280)]">
        Bạn có quyền xoá tài khoản và toàn bộ dữ liệu cá nhân bất cứ lúc nào.
      </p>

      <section className="mt-8 space-y-6">
        <div className="rounded-xl border border-red-200 bg-red-50 p-5 dark:border-red-800 dark:bg-red-950">
          <h2 className="font-bold text-red-700 dark:text-red-400">
            ⚠️ Hành động này không thể hoàn tác
          </h2>
          <p className="mt-2 text-sm text-[var(--app-muted,#6b7280)]">
            Khi xoá tài khoản, toàn bộ dữ liệu sau sẽ bị xoá vĩnh viễn:
          </p>
          <ul className="mt-2 list-disc space-y-1 pl-5 text-xs text-[var(--app-muted,#6b7280)]">
            <li>Nhật ký và ghi chép cá nhân</li>
            <li>Lịch sử mood check-in</li>
            <li>Phiên thư giãn, thiền, giấc ngủ</li>
            <li>Linh thú companion và tiến trình</li>
            <li>Danh sách bạn bè và feed</li>
            <li>Cài đặt và tuỳ chỉnh cá nhân</li>
          </ul>
        </div>

        <div className="rounded-xl border border-[var(--field-border,#e5e7eb)] p-5">
          <h2 className="font-bold">Cách xoá nhanh trong app</h2>
          <p className="mt-2 text-sm text-[var(--app-muted,#6b7280)]">
            Mở app Thi Ái → <strong>Cài đặt</strong> →{' '}
            <strong>Dữ liệu & Quyền riêng tư</strong> → chọn loại dữ liệu muốn
            xoá hoặc xuất toàn bộ trước khi xoá.
          </p>
        </div>

        {submitted ? (
          <div className="rounded-xl border border-green-200 bg-green-50 p-6 text-center dark:border-green-800 dark:bg-green-950">
            <p className="text-lg font-bold text-green-700 dark:text-green-400">
              ✓ Yêu cầu đã được ghi nhận
            </p>
            <p className="mt-2 text-sm text-[var(--app-muted,#6b7280)]">
              Chúng tôi sẽ xử lý yêu cầu xoá tài khoản trong vòng 7 ngày làm
              việc và thông báo qua email khi hoàn tất.
            </p>
          </div>
        ) : (
          <form onSubmit={handleSubmit} className="space-y-4">
            <h2 className="font-bold">Yêu cầu xoá qua email</h2>
            <p className="text-xs text-[var(--app-muted,#6b7280)]">
              Nếu bạn không thể truy cập app, hãy gửi yêu cầu tại đây:
            </p>

            <div>
              <label
                htmlFor="email"
                className="block text-sm font-semibold"
              >
                Email đăng ký
              </label>
              <input
                id="email"
                type="email"
                required
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="your@email.com"
                className="mt-1 w-full rounded-lg border border-[var(--field-border,#e5e7eb)] bg-[var(--field-bg,#f9fafb)] px-4 py-2.5 text-sm outline-none focus:border-violet-500 focus:ring-1 focus:ring-violet-500"
              />
            </div>

            <div>
              <label
                htmlFor="reason"
                className="block text-sm font-semibold"
              >
                Lý do (tuỳ chọn)
              </label>
              <textarea
                id="reason"
                value={reason}
                onChange={(e) => setReason(e.target.value)}
                rows={3}
                placeholder="Giúp chúng tôi cải thiện..."
                className="mt-1 w-full rounded-lg border border-[var(--field-border,#e5e7eb)] bg-[var(--field-bg,#f9fafb)] px-4 py-2.5 text-sm outline-none focus:border-violet-500 focus:ring-1 focus:ring-violet-500"
              />
            </div>

            <button
              type="submit"
              className="w-full rounded-lg bg-red-600 px-6 py-3 text-sm font-bold text-white transition hover:bg-red-700"
            >
              Gửi yêu cầu xoá tài khoản
            </button>
          </form>
        )}

        <p className="text-center text-xs text-[var(--app-muted,#6b7280)]">
          Hoặc gửi email trực tiếp đến{' '}
          <a
            href="mailto:minhvnq1@welosoft.com?subject=Delete%20Account%20Request"
            className="font-semibold underline"
          >
            minhvnq1@welosoft.com
          </a>{' '}
          với tiêu đề &quot;Delete Account Request&quot;.
        </p>
      </section>
    </main>
  );
}

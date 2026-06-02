'use client';

import { useEffect, useState } from 'react';
import { CheckCircle2, XCircle, Loader2, ArrowLeft, CreditCard } from 'lucide-react';
import Link from 'next/link';

type PaymentStatus = 'success' | 'error' | 'cancel' | 'loading' | null;

export default function BillingCallbackPage() {
  const [status, setStatus] = useState<PaymentStatus>('loading');

  useEffect(() => {
    if (typeof window === 'undefined') return;
    const params = new URLSearchParams(window.location.search);
    const paymentParam = params.get('status') || params.get('payment');

    if (paymentParam === 'success') {
      setStatus('success');
    } else if (paymentParam === 'error') {
      setStatus('error');
    } else if (paymentParam === 'cancel') {
      setStatus('cancel');
    } else {
      setStatus(null);
    }
  }, []);

  return (
    <div className="flex min-h-screen items-center justify-center bg-gradient-to-br from-mist via-cloud to-mist px-4 py-16">
      <div className="w-full max-w-md text-center">
        {/* Animated icon */}
        <div className="mx-auto mb-8">
          {status === 'loading' && (
            <div className="mx-auto flex h-20 w-20 items-center justify-center rounded-2xl bg-violet/10">
              <Loader2 className="h-10 w-10 animate-spin text-violet" />
            </div>
          )}
          {status === 'success' && (
            <div className="mx-auto flex h-20 w-20 animate-bounce items-center justify-center rounded-2xl bg-mint/15">
              <CheckCircle2 className="h-10 w-10 text-mint" />
            </div>
          )}
          {(status === 'error' || status === 'cancel') && (
            <div className="mx-auto flex h-20 w-20 items-center justify-center rounded-2xl bg-coral/15">
              <XCircle className="h-10 w-10 text-coral" />
            </div>
          )}
          {status === null && (
            <div className="mx-auto flex h-20 w-20 items-center justify-center rounded-2xl bg-violet/10">
              <CreditCard className="h-10 w-10 text-violet" />
            </div>
          )}
        </div>

        {/* Card */}
        <div className="rounded-2xl border border-lilac/60 bg-white/80 p-8 shadow-panel backdrop-blur-sm">
          {status === 'loading' && (
            <>
              <h1 className="text-2xl font-extrabold text-ink">Đang xử lý...</h1>
              <p className="mt-3 text-sm font-medium text-slate">
                Vui lòng đợi trong khi hệ thống xử lý giao dịch của anh.
              </p>
            </>
          )}

          {status === 'success' && (
            <>
              <h1 className="text-2xl font-extrabold text-ink">Thanh toán thành công! 🎉</h1>
              <p className="mt-3 text-sm font-medium text-slate">
                Cảm ơn anh! Giao dịch đã được xác nhận. Gói cước của anh đang được hệ thống kích hoạt tự động.
              </p>
              <div className="mt-6 rounded-xl bg-mint/10 border border-mint/30 p-4">
                <p className="text-sm font-semibold text-mint">
                  ✓ Thanh toán đã được xác nhận qua SePay
                </p>
              </div>
            </>
          )}

          {status === 'error' && (
            <>
              <h1 className="text-2xl font-extrabold text-ink">Thanh toán thất bại</h1>
              <p className="mt-3 text-sm font-medium text-slate">
                Có lỗi xảy ra trong quá trình thanh toán. Vui lòng thử lại hoặc liên hệ hỗ trợ.
              </p>
              <div className="mt-6 rounded-xl bg-coral/10 border border-coral/30 p-4">
                <p className="text-sm font-semibold text-coral">
                  ✗ Giao dịch không thành công
                </p>
              </div>
            </>
          )}

          {status === 'cancel' && (
            <>
              <h1 className="text-2xl font-extrabold text-ink">Đã huỷ thanh toán</h1>
              <p className="mt-3 text-sm font-medium text-slate">
                Anh đã huỷ giao dịch thanh toán. Không có khoản phí nào được tính.
              </p>
              <div className="mt-6 rounded-xl bg-sun/10 border border-sun/30 p-4">
                <p className="text-sm font-semibold text-sun">
                  ⚠ Giao dịch đã bị huỷ bởi người dùng
                </p>
              </div>
            </>
          )}

          {status === null && (
            <>
              <h1 className="text-2xl font-extrabold text-ink">Thanh toán</h1>
              <p className="mt-3 text-sm font-medium text-slate">
                Trang thanh toán SePay. Vui lòng quay về dashboard để thực hiện giao dịch.
              </p>
            </>
          )}

          {/* Action buttons */}
          <div className="mt-8 flex flex-col gap-3">
            <Link
              href="/dashboard/settings"
              className="inline-flex items-center justify-center gap-2 rounded-xl bg-violet px-6 py-3 text-sm font-bold text-white shadow-md transition-all hover:bg-plum hover:shadow-lg"
            >
              <ArrowLeft className="h-4 w-4" />
              Quay về cài đặt
            </Link>
            {(status === 'error' || status === 'cancel') && (
              <Link
                href="/dashboard/settings"
                className="inline-flex items-center justify-center gap-2 rounded-xl border border-lilac bg-white px-6 py-3 text-sm font-bold text-ink transition-all hover:bg-mist"
              >
                <CreditCard className="h-4 w-4" />
                Thử thanh toán lại
              </Link>
            )}
          </div>
        </div>

        {/* Footer note */}
        <p className="mt-6 text-xs font-medium text-slate/70">
          Powered by SePay Payment Gateway • Bảo mật SSL
        </p>
      </div>
    </div>
  );
}

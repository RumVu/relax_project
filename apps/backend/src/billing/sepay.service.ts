import { HttpStatus, Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { AppException } from '../common/errors/app.exception';
import { ErrorCode } from '../common/errors/error-code';

/// SePay (https://sepay.vn) — VN payment gateway dựa trên QR + bank transfer.
///
/// Flow:
///   1. Backend tạo `referenceCode` unique (vd: payment ID rút gọn)
///   2. Trả URL trang QR (qr.sepay.vn/img?...) cho user
///   3. User scan QR bằng banking app, chuyển khoản với memo = referenceCode
///   4. SePay webhook POST tới `/v1/billing/sepay/webhook` khi confirm
///   5. Webhook match referenceCode → activate subscription
///
/// Khi env chưa configure → service báo `configured=false`, caller fallback
/// về simulated mock checkout.
@Injectable()
export class SepayService {
  private readonly logger = new Logger(SepayService.name);

  constructor(private readonly configService: ConfigService) {}

  /// Trả config SePay nếu đầy đủ. Null = chưa configure.
  getConfig() {
    const accountNumber = this.configService.get<string>(
      'SEPAY_ACCOUNT_NUMBER',
    );
    const bankCode = this.configService.get<string>('SEPAY_BANK_CODE');
    if (!accountNumber || !bankCode) {
      return null;
    }
    return {
      accountNumber,
      bankCode,
      // accountName + webhook secret optional
      accountName: this.configService.get<string>('SEPAY_ACCOUNT_NAME'),
      webhookSecret: this.configService.get<string>('SEPAY_WEBHOOK_SECRET'),
    };
  }

  get isConfigured() {
    return this.getConfig() !== null;
  }

  /// Generate QR image URL từ SePay QR API. Format theo SePay docs:
  ///   https://qr.sepay.vn/img?bank=BANK&acc=ACC&template=compact&amount=N&des=MEMO
  buildQrImageUrl(params: { amount: number; reference: string }) {
    const cfg = this.getConfig();
    if (!cfg) {
      throw new AppException(
        ErrorCode.VALIDATION_FAILED,
        'SePay chưa được cấu hình (SEPAY_ACCOUNT_NUMBER + SEPAY_BANK_CODE)',
        HttpStatus.SERVICE_UNAVAILABLE,
      );
    }
    const url = new URL('https://qr.sepay.vn/img');
    url.searchParams.set('bank', cfg.bankCode);
    url.searchParams.set('acc', cfg.accountNumber);
    url.searchParams.set('template', 'compact');
    url.searchParams.set('amount', String(Math.round(params.amount)));
    url.searchParams.set('des', params.reference);
    return url.toString();
  }

  /// Build short reference code từ payment ID + plan name. SePay memo
  /// thường giới hạn 25 ký tự nên rút gọn.
  buildReferenceCode(paymentId: string, planName: string) {
    // 8 ký tự đầu UUID + plan code → "abcdef12 CHILL_PLUS"
    const shortId = paymentId.replace(/-/g, '').slice(0, 8).toUpperCase();
    const planCode = planName.toUpperCase().slice(0, 12);
    return `TAI ${shortId} ${planCode}`;
  }

  /// Verify SePay webhook signature. SePay gửi header `x-sepay-signature` hoặc
  /// body field. Hiện docs SePay không bắt buộc → check secret nếu có.
  verifyWebhook(payload: unknown, signature?: string): boolean {
    const cfg = this.getConfig();
    if (!cfg?.webhookSecret) {
      // Không cấu hình secret → trust webhook (dev mode hoặc IP allowlist
      // ở reverse proxy). Log warning để dev biết.
      this.logger.warn(
        'SePay webhook received without SEPAY_WEBHOOK_SECRET configured — accepting all.',
      );
      return true;
    }
    if (!signature) return false;
    // SePay docs hiện tại không spec HMAC scheme rõ ràng. Placeholder:
    // signature thường là `Apikey <token>` header. Compare straight.
    return signature.includes(cfg.webhookSecret);
  }

  /// Parse SePay webhook body — extract reference + amount + status.
  /// Schema docs: https://docs.sepay.vn/tich-hop-webhooks
  parseWebhook(body: Record<string, unknown>) {
    // SePay fields: content (memo), transferAmount, transferType, gateway,
    // accountNumber, referenceCode, id.
    const content = String(body.content ?? body.description ?? '');
    const amount = Number(body.transferAmount ?? body.amount ?? 0);
    const transferType = String(body.transferType ?? 'in');
    return {
      content,
      amount,
      isIncoming: transferType === 'in',
      gateway: String(body.gateway ?? ''),
      providerTxnId: String(body.id ?? body.referenceCode ?? ''),
    };
  }
}

import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PaymentStatus } from '@prisma/client';
import { SePayPgClient } from 'sepay-pg-node';
import { PrismaService } from '../../prisma/prisma.service';
import { BillingService } from '../billing.service';

export interface SePayWebhookPayload {
  transferType?: string;
  transferAmount?: number | string;
  // SePay thực tế gửi field `content`, không phải `transactionContent`.
  // Giữ cả hai để tương thích lùi (nếu sandbox dùng tên cũ).
  content?: string;
  transactionContent?: string;
  description?: string;
  code?: string;
  referenceCode?: string;
  gateway?: string;
  id?: number | string;
  [key: string]: unknown;
}

@Injectable()
export class SepayBillingService {
  private readonly logger = new Logger(SepayBillingService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly configService: ConfigService,
    private readonly billingService: BillingService,
  ) {}

  verifyWebhookToken(authHeader?: string): boolean {
    if (!authHeader) {
      return false;
    }
    // SePay sends: Authorization: Apikey your_api_key
    const match = authHeader.match(/^Apikey\s+(.+)$/i);
    const apiKey = match ? match[1] : authHeader;
    const configuredKey = this.configService.get<string>(
      'SEPAY_WEBHOOK_API_KEY',
    );

    return Boolean(configuredKey && apiKey === configuredKey);
  }

  async processWebhook(payload: SePayWebhookPayload) {
    const {
      transferType,
      transferAmount,
      transactionContent,
      content: rawContent,
      description,
      code,
      referenceCode,
      id: gatewayTransactionId,
    } = payload;

    // Log đầy đủ payload để debug — webhook xảy ra hiếm, log thoải mái.
    this.logger.log(
      `SePay webhook payload: ${JSON.stringify({
        id: gatewayTransactionId,
        gateway: payload.gateway,
        transferType,
        transferAmount,
        code,
        referenceCode,
        content: rawContent,
        description,
      })}`,
    );

    // We only care about incoming money
    if (transferType !== 'in') {
      return { success: true, message: 'Ignored non-incoming transaction' };
    }

    // SePay gửi memo ở field `content`. Một số sandbox/legacy gửi `transactionContent`.
    // Cộng thêm `description` để tăng khả năng match.
    const content = [rawContent, transactionContent, description]
      .filter(Boolean)
      .join(' ');

    // Thu thập TẤT CẢ candidate IDs có thể là Payment.id của ta hoặc SePay PAY code.
    const candidates: string[] = [];
    const push = (value?: string | null) => {
      if (!value) return;
      const trimmed = String(value).trim();
      if (trimmed && !candidates.includes(trimmed)) candidates.push(trimmed);
    };

    // 1. `code` SePay parsed sẵn (có thể là CUID của ta hoặc PAY code của SePay).
    if (code) {
      const stripped = code.replace(/RELAX/i, '').trim();
      push(stripped);
      push(code);
    }

    // 2. RELAX<cuid> pattern trong content.
    const relaxMatch = content.match(/RELAX([a-zA-Z0-9]+)/i);
    if (relaxMatch) push(relaxMatch[1]);

    // 3. CUID pattern (Prisma CUID: bắt đầu bằng 'c', 25 ký tự).
    const cuidMatches = content.match(/c[a-z0-9]{24}/gi);
    if (cuidMatches) cuidMatches.forEach(push);

    // 4. PAY... pattern (SePay auto-generated memo).
    const payMatches = content.match(/PAY[A-Z0-9]{10,30}/gi);
    if (payMatches) payMatches.forEach(push);

    this.logger.log(`SePay webhook candidates: ${JSON.stringify(candidates)}`);

    // Tìm payment theo từng candidate — match trực tiếp Payment.id hoặc externalPaymentId.
    let payment = null as Awaited<
      ReturnType<typeof this.prisma.payment.findFirst>
    > | null;

    for (const candidate of candidates) {
      payment = await this.prisma.payment.findFirst({
        where: {
          OR: [{ id: candidate }, { externalPaymentId: candidate }],
        },
      });
      if (payment) {
        this.logger.log(
          `SePay webhook matched Payment ${payment.id} via candidate "${candidate}"`,
        );
        break;
      }
    }

    // Fallback A: gọi SePay API map PAY → order_invoice_number.
    if (!payment && candidates.length > 0) {
      const merchantId = this.configService.get<string>('SEPAY_MERCHANT_ID');
      const secretKey = this.configService.get<string>('SEPAY_SECRET_KEY');
      const env = this.configService.get<string>('SEPAY_ENV') || 'sandbox';

      if (merchantId && secretKey) {
        const client = new SePayPgClient({
          env: env as 'sandbox' | 'production',
          merchant_id: merchantId,
          secret_key: secretKey,
        });

        for (const candidate of candidates) {
          try {
            const orderRes = (await client.order.retrieve(candidate)) as {
              data?: { data?: { order_invoice_number?: string } };
            };
            const invoiceNumber = orderRes.data?.data?.order_invoice_number;
            if (invoiceNumber) {
              this.logger.log(
                `SePay API mapped ${candidate} → ${invoiceNumber}`,
              );
              payment = await this.prisma.payment.findUnique({
                where: { id: invoiceNumber },
              });
              if (payment) break;
            }
          } catch (err: unknown) {
            const status = (err as { response?: { status?: number } })?.response
              ?.status;
            const msg = err instanceof Error ? err.message : String(err);
            this.logger.warn(
              `SePay API retrieve("${candidate}") failed: ${status} ${msg}`,
            );
          }
        }
      }
    }

    // Fallback B: match PENDING payment trong 24h gần nhất với cùng amount + provider=SEPAY.
    // Đây là phương án cuối khi SePay PAY code không map được — dựa vào việc mỗi user
    // hiếm khi có hai pending payment cùng amount cùng lúc.
    if (!payment && transferAmount) {
      const amount = Number(transferAmount);
      const since = new Date(Date.now() - 24 * 60 * 60 * 1000);
      const candidatesByAmount = await this.prisma.payment.findMany({
        where: {
          amount,
          status: PaymentStatus.PENDING,
          provider: 'SEPAY',
          createdAt: { gte: since },
        },
        orderBy: { createdAt: 'desc' },
      });
      if (candidatesByAmount.length === 1) {
        payment = candidatesByAmount[0];
        this.logger.log(
          `SePay webhook matched Payment ${payment.id} via amount-fallback`,
        );
      } else if (candidatesByAmount.length > 1) {
        this.logger.warn(
          `SePay amount-fallback ambiguous: ${candidatesByAmount.length} pending payments at ${amount}`,
        );
      }
    }

    if (!payment) {
      // QUAN TRỌNG: trả HTTP 200 với success:false để SePay không retry vô hạn.
      // SePay retry chỉ có ích khi backend tạm chết; với business mismatch, retry chỉ
      // làm bẩn lịch sử webhook.
      this.logger.warn(
        `SePay webhook: payment not found for any candidate (${candidates.join(', ')}); acknowledging to stop retries`,
      );
      return {
        success: false,
        message: `Payment not found for reference ${candidates.join(', ') || 'unknown'}`,
        gatewayTransactionId,
      };
    }

    if (payment.status !== PaymentStatus.PENDING) {
      return {
        success: true,
        message: `Payment ${payment.id} has already been processed with status ${payment.status}`,
      };
    }

    // Verify transfer amount — vẫn ack 200 để SePay khỏi retry, nhưng đánh dấu để admin biết.
    const amount = Number(transferAmount);
    if (amount < payment.amount) {
      this.logger.warn(
        `SePay webhook amount mismatch: transferred ${amount}, expected ${payment.amount} for Payment ${payment.id}`,
      );
      return {
        success: false,
        message: `Transferred amount (${amount}) is less than required (${payment.amount})`,
        paymentId: payment.id,
      };
    }

    // Resolve plan for confirmation
    const plan = await this.billingService.resolvePlanByAmount(payment.amount);

    // Confirm the payment
    await this.billingService.confirmPayment(payment.userId, payment.id, {
      planName: plan.name,
    });

    // Save SePay transaction ID for auditing/traceability
    await this.prisma.payment.update({
      where: { id: payment.id },
      data: {
        externalPaymentId: String(gatewayTransactionId || ''),
        method: 'SEPAY',
      },
    });

    return {
      success: true,
      message: 'Payment confirmed successfully',
      paymentId: payment.id,
      planName: plan.name,
    };
  }
}

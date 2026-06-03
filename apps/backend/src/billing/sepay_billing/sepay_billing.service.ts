import { HttpStatus, Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PaymentStatus } from '@prisma/client';
import { SePayPgClient } from 'sepay-pg-node';
import { AppException } from '../../common/errors/app.exception';
import { ErrorCode } from '../../common/errors/error-code';
import { PrismaService } from '../../prisma/prisma.service';
import { BillingService } from '../billing.service';

export interface SePayWebhookPayload {
  transferType?: string;
  transferAmount?: number | string;
  transactionContent?: string;
  code?: string;
  id?: number | string;
  [key: string]: unknown;
}


@Injectable()
export class SepayBillingService {
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
      code,
      id: gatewayTransactionId,
    } = payload;

    // We only care about incoming money
    if (transferType !== 'in') {
      return { success: true, message: 'Ignored non-incoming transaction' };
    }

    // Try to find the payment ID inside the transaction content
    let paymentId = '';
    const content = transactionContent || '';

    // 1. Try to extract from the 'code' field if SePay parsed it
    if (code && typeof code === 'string' && code.trim().length > 0) {
      paymentId = code.replace(/RELAX/i, '').trim();
    }

    // 2. If code parsing failed, search in transactionContent
    if (!paymentId) {
      const match = content.match(/RELAX([a-zA-Z0-9]+)/i);
      if (match) {
        paymentId = match[1];
      }
    }

    // 3. Fallback: search for any alphanumeric string of length typical for CUID (24-30 chars)
    if (!paymentId) {
      const cuidMatch = content.match(/[a-z0-9]{24,30}/i);
      if (cuidMatch) {
        paymentId = cuidMatch[0];
      }
    }

    if (!paymentId) {
      throw new AppException(
        ErrorCode.VALIDATION_FAILED,
        'Cannot extract payment reference code from transaction content',
        HttpStatus.BAD_REQUEST,
      );
    }

    // Find the pending payment
    let payment = await this.prisma.payment.findUnique({
      where: { id: paymentId },
    });

    // If not found in our database, it might be a SePay order ID (starts with PAY... or similar).
    // Let's try to retrieve the order from SePay's API to find our order_invoice_number.
    if (!payment) {
      try {
        const merchantId = this.configService.get<string>('SEPAY_MERCHANT_ID');
        const secretKey = this.configService.get<string>('SEPAY_SECRET_KEY');
        const env = this.configService.get<string>('SEPAY_ENV') || 'sandbox';

        if (merchantId && secretKey) {
          const client = new SePayPgClient({
            env: env as 'sandbox' | 'production',
            merchant_id: merchantId,
            secret_key: secretKey,
          });

          const orderRes = await client.order.retrieve(paymentId);
          const orderData = orderRes.data?.data;
          
          if (orderData && orderData.order_invoice_number) {
            const actualPaymentId = orderData.order_invoice_number;
            payment = await this.prisma.payment.findUnique({
              where: { id: actualPaymentId },
            });
          }
        }
      } catch (err) {
        console.error('Failed to retrieve order from SePay API:', err);
      }
    }

    if (!payment) {
      throw new AppException(
        ErrorCode.PAYMENT_NOT_FOUND,
        `Payment not found for reference ${paymentId}`,
        HttpStatus.NOT_FOUND,
      );
    }

    if (payment.status !== PaymentStatus.PENDING) {
      return {
        success: true,
        message: `Payment ${paymentId} has already been processed with status ${payment.status}`,
      };
    }

    // Verify transfer amount
    const amount = Number(transferAmount);
    if (amount < payment.amount) {
      throw new AppException(
        ErrorCode.PAYMENT_PLAN_MISMATCH,
        `Transferred amount (${amount}) is less than required payment amount (${payment.amount})`,
        HttpStatus.BAD_REQUEST,
      );
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

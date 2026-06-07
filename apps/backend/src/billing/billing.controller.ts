import {
  Body,
  Controller,
  Get,
  Header,
  Param,
  Post,
  Query,
  Res,
  UseGuards,
} from '@nestjs/common';
import type { Response } from 'express';
import {
  ApiBearerAuth,
  ApiCreatedResponse,
  ApiOkResponse,
  ApiOperation,
  ApiQuery,
  ApiTags,
} from '@nestjs/swagger';
import type { AuthUser } from '../auth/auth.types';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { BillingService } from './billing.service';
import { SepayService } from './sepay.service';
import {
  BillingMeResponseDto,
  BillingPlanResponseDto,
  CheckoutSessionResponseDto,
  ProviderStatusResponseDto,
} from './dto/billing-extras.dto';
import { ConfirmPaymentDto } from './dto/confirm-payment.dto';
import { ConfirmPaymentResponseDto } from './dto/billing-response.dto';
import { CreateCheckoutSessionDto } from './dto/create-checkout-session.dto';

@ApiTags('Billing')
@ApiBearerAuth('access-token')
@Controller('billing')
export class BillingController {
  constructor(
    private readonly billingService: BillingService,
    private readonly sepayService: SepayService,
  ) {}

  @ApiOperation({ summary: 'Get billing/payment provider status' })
  @ApiOkResponse({
    type: ProviderStatusResponseDto,
    description: 'Configured payment providers.',
  })
  @UseGuards(JwtAuthGuard)
  @Get('providers')
  getProviderStatus() {
    return this.billingService.getProviderStatus();
  }

  @ApiOperation({ summary: 'List available subscription plans' })
  @ApiOkResponse({
    type: BillingPlanResponseDto,
    isArray: true,
    description: 'Plan catalog.',
  })
  @Get('plans')
  getPlans() {
    return this.billingService.getPlans();
  }

  @ApiOperation({ summary: 'Get current user billing state' })
  @ApiOkResponse({
    type: BillingMeResponseDto,
    description: 'Current subscription and provider status.',
  })
  @UseGuards(JwtAuthGuard)
  @Get('me')
  getMine(@CurrentUser() user: AuthUser) {
    return this.billingService.getMine(user.id);
  }

  @ApiOperation({ summary: 'Create a checkout session intent' })
  @ApiCreatedResponse({
    type: CheckoutSessionResponseDto,
    description:
      'Pending payment plus provider readiness. Checkout URL appears after real provider wiring.',
  })
  @UseGuards(JwtAuthGuard)
  @Post('me/checkout-session')
  createCheckoutSession(
    @CurrentUser() user: AuthUser,
    @Body() dto: CreateCheckoutSessionDto,
  ) {
    return this.billingService.createCheckoutSession(user.id, dto);
  }

  @ApiOperation({
    summary: 'Confirm a pending payment and activate the subscription',
  })
  @ApiCreatedResponse({
    type: ConfirmPaymentResponseDto,
    description:
      'Settled payment plus the newly activated subscription. Used by the manual/dev flow and by provider webhooks once wired.',
  })
  @UseGuards(JwtAuthGuard)
  @Post('me/payments/:id/confirm')
  confirmPayment(
    @CurrentUser() user: AuthUser,
    @Param('id') id: string,
    @Body() dto: ConfirmPaymentDto,
  ) {
    return this.billingService.confirmPayment(user.id, id, dto);
  }

  // ── Simulated checkout (DEV mode) ──────────────────────────────────────
  //
  // Khi Stripe/SePay SDK chưa wire, backend tự host trang HTML checkout để
  // dashboard có URL thật để redirect. User click "Thanh toán" trên page →
  // POST tới settle → activate subscription → redirect successUrl.
  //
  // KHÔNG yêu cầu auth — payment ID là token (UUID không đoán được). Khi
  // wire xong SDK provider thật, route này có thể giữ làm fallback hoặc
  // ẩn sau env flag.

  @ApiOperation({ summary: 'Render simulated checkout page (DEV)' })
  @ApiQuery({ name: 'paymentId', required: true })
  @ApiQuery({ name: 'planName', required: true })
  @ApiQuery({ name: 'successUrl', required: false })
  @ApiQuery({ name: 'cancelUrl', required: false })
  @ApiQuery({ name: 'errorUrl', required: false })
  @Get('mock-checkout')
  @Header('Content-Type', 'text/html; charset=utf-8')
  async renderMockCheckout(
    @Query('paymentId') paymentId: string,
    @Query('planName') planName: string,
    @Query('successUrl') successUrl?: string,
    @Query('cancelUrl') cancelUrl?: string,
    @Query('errorUrl') errorUrl?: string,
  ): Promise<string> {
    return this.billingService.renderMockCheckoutPage({
      paymentId,
      planName,
      successUrl,
      cancelUrl,
      errorUrl,
    });
  }

  @ApiOperation({ summary: 'Settle simulated checkout (DEV, no auth)' })
  @Post('mock-checkout/settle')
  async settleMockCheckout(
    @Body('paymentId') paymentId: string,
    @Body('planName') planName: string,
    @Body('successUrl') successUrl: string | undefined,
    @Body('errorUrl') errorUrl: string | undefined,
    @Res() res: Response,
  ) {
    try {
      await this.billingService.settleMockCheckout(paymentId, planName);
      if (successUrl) {
        return res.redirect(302, successUrl);
      }
      return res.json({ ok: true });
    } catch (e) {
      if (errorUrl) {
        return res.redirect(302, errorUrl);
      }
      throw e;
    }
  }

  // ── SePay live checkout (production) ───────────────────────────────────

  @ApiOperation({ summary: 'Render SePay QR checkout page (LIVE)' })
  @ApiQuery({ name: 'paymentId', required: true })
  @ApiQuery({ name: 'planName', required: true })
  @ApiQuery({ name: 'successUrl', required: false })
  @ApiQuery({ name: 'cancelUrl', required: false })
  @Get('sepay-checkout')
  @Header('Content-Type', 'text/html; charset=utf-8')
  async renderSepayCheckout(
    @Query('paymentId') paymentId: string,
    @Query('planName') planName: string,
    @Query('successUrl') successUrl?: string,
    @Query('cancelUrl') cancelUrl?: string,
  ): Promise<string> {
    return this.billingService.renderSepayCheckoutPage({
      paymentId,
      planName,
      successUrl,
      cancelUrl,
    });
  }

  @ApiOperation({
    summary: 'Get payment status (public, for SePay QR polling)',
  })
  @Get('payments/:id/status')
  getPaymentStatus(@Param('id') id: string) {
    return this.billingService.getPaymentStatus(id);
  }

  @ApiOperation({
    summary: 'SePay webhook — receive transfer confirmation',
    description:
      'SePay POST khi user chuyển khoản thành công. Backend match reference ' +
      'code trong content → activate subscription. Verify signature qua ' +
      'header `Authorization` (Apikey <SEPAY_WEBHOOK_SECRET>).',
  })
  @Post('sepay/webhook')
  async sepayWebhook(
    @Body() body: Record<string, unknown>,
    @Res() res: Response,
  ) {
    // Verify signature (express raw headers)
    const auth = (res.req.headers['authorization'] ?? '') as string;
    if (!this.sepayService.verifyWebhook(body, auth)) {
      return res.status(401).json({ ok: false, error: 'invalid_signature' });
    }
    const parsed = this.sepayService.parseWebhook(body);
    if (!parsed.isIncoming) {
      // Out transfer → ignore
      return res.json({ ok: true, skipped: 'outgoing_transfer' });
    }
    const payment = await this.billingService.findPaymentBySepayReference(
      parsed.content,
    );
    if (!payment) {
      return res
        .status(404)
        .json({ ok: false, error: 'payment_not_found_for_reference' });
    }
    // Verify amount matches (allow ±1 VND rounding)
    if (Math.abs(payment.amount - parsed.amount) > 1) {
      return res.status(400).json({
        ok: false,
        error: 'amount_mismatch',
        expected: payment.amount,
        received: parsed.amount,
      });
    }
    try {
      await this.billingService.settleBySepayWebhook({
        id: payment.id,
        userId: payment.userId,
        amount: payment.amount,
      });
      return res.json({ ok: true, paymentId: payment.id });
    } catch (e) {
      const msg = e instanceof Error ? e.message : 'unknown_error';
      return res.status(500).json({ ok: false, error: msg });
    }
  }
}

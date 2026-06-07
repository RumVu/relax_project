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
  constructor(private readonly billingService: BillingService) {}

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
}

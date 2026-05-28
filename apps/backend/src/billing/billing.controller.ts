import { Body, Controller, Get, Param, Post, UseGuards } from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiCreatedResponse,
  ApiOkResponse,
  ApiOperation,
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
  @ApiOkResponse({ type: ProviderStatusResponseDto, description: 'Configured payment providers.' })
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
  @ApiOkResponse({ type: BillingMeResponseDto, description: 'Current subscription and provider status.' })
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
}

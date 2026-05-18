import { Body, Controller, Get, Post, UseGuards } from '@nestjs/common';
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
import { CreateCheckoutSessionDto } from './dto/create-checkout-session.dto';

@ApiTags('Billing')
@ApiBearerAuth('access-token')
@Controller('billing')
export class BillingController {
  constructor(private readonly billingService: BillingService) {}

  @ApiOperation({ summary: 'Get billing/payment provider status' })
  @ApiOkResponse({ description: 'Configured payment providers.' })
  @UseGuards(JwtAuthGuard)
  @Get('providers')
  getProviderStatus() {
    return this.billingService.getProviderStatus();
  }

  @ApiOperation({ summary: 'List available subscription plans' })
  @ApiOkResponse({ description: 'Plan catalog.' })
  @Get('plans')
  getPlans() {
    return this.billingService.getPlans();
  }

  @ApiOperation({ summary: 'Get current user billing state' })
  @ApiOkResponse({ description: 'Current subscription and provider status.' })
  @UseGuards(JwtAuthGuard)
  @Get('me')
  getMine(@CurrentUser() user: AuthUser) {
    return this.billingService.getMine(user.id);
  }

  @ApiOperation({ summary: 'Create a checkout session intent' })
  @ApiCreatedResponse({
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
}

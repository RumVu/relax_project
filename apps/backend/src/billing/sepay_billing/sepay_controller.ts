import {
  Body,
  Controller,
  Headers,
  HttpCode,
  HttpStatus,
  Post,
  UnauthorizedException,
} from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { SepayBillingService } from './sepay_billing.service';

@ApiTags('Billing')
@Controller('billing/webhooks/sepay')
export class SepayController {
  constructor(private readonly sepayBillingService: SepayBillingService) {}

  @ApiOperation({ summary: 'SePay webhook payment callback' })
  @Post()
  @HttpCode(HttpStatus.OK)
  async handleWebhook(
    @Headers('authorization') authHeader: string,
    @Body() payload: any,
  ) {
    const isValid = this.sepayBillingService.verifyWebhookToken(authHeader);
    if (!isValid) {
      throw new UnauthorizedException('Invalid SePay signature or token');
    }

    return this.sepayBillingService.processWebhook(payload);
  }
}

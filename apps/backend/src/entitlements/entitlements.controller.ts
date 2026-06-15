import { Controller, Get, Req, UseGuards } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { EntitlementsService } from './entitlements.service';

@Controller('entitlements')
@UseGuards(AuthGuard('jwt'))
export class EntitlementsController {
  constructor(private readonly service: EntitlementsService) {}

  @Get('me')
  getMyEntitlements(@Req() req) {
    return this.service.getUserEntitlements(req.user.id);
  }

  @Get('features')
  getFeatureMap() {
    return this.service.getFeatureMap();
  }
}

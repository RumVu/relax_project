import { Controller, Get, Req, UseGuards } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { Request } from 'express';
import { EntitlementsService } from './entitlements.service';

interface AuthedRequest extends Request {
  user: { id: string };
}

@Controller('entitlements')
@UseGuards(AuthGuard('jwt'))
export class EntitlementsController {
  constructor(private readonly service: EntitlementsService) {}

  @Get('me')
  getMyEntitlements(@Req() req: AuthedRequest) {
    return this.service.getUserEntitlements(req.user.id);
  }

  @Get('features')
  getFeatureMap() {
    return this.service.getFeatureMap();
  }
}

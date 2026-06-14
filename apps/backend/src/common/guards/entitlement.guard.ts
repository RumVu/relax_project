import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { SubscriptionStatus, UserRole } from '@prisma/client';
import { ErrorCode } from '../errors/error-code';
import { PrismaService } from '../../prisma/prisma.service';
import { REQUIRE_PREMIUM_KEY } from '../decorators/require-premium.decorator';
import { AuthUser } from '../../auth/auth.types';

@Injectable()
export class EntitlementGuard implements CanActivate {
  constructor(
    private readonly reflector: Reflector,
    private readonly prisma: PrismaService,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const requirePremium = this.reflector.getAllAndOverride<boolean>(
      REQUIRE_PREMIUM_KEY,
      [context.getHandler(), context.getClass()],
    );

    if (!requirePremium) {
      return true;
    }

    const request = context.switchToHttp().getRequest<{ user?: AuthUser }>();
    if (!request.user) {
      return false;
    }

    if (request.user.role === UserRole.ADMIN) {
      return true;
    }

    const sub = await this.prisma.subscription.findFirst({
      where: {
        userId: request.user.id,
        status: SubscriptionStatus.ACTIVE,
      },
    });

    if (sub) {
      return true;
    }

    throw new ForbiddenException({
      code: ErrorCode.AUTH_FORBIDDEN,
      message: 'This feature is exclusive to Premium members. Please subscribe to unlock.',
    });
  }
}

import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ErrorCode } from '../../common/errors/error-code';
import { PrismaService } from '../../prisma/prisma.service';
import { AuthUser, JwtPayload } from '../auth.types';

@Injectable()
export class JwtAuthGuard implements CanActivate {
  constructor(
    private readonly jwtService: JwtService,
    private readonly prisma: PrismaService,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest<{
      headers: Record<string, string | undefined>;
      user?: AuthUser;
    }>();
    const token = this.extractToken(request.headers.authorization);

    if (!token) {
      throw new UnauthorizedException({
        code: ErrorCode.AUTH_UNAUTHORIZED,
        message: 'Authorization token is required',
      });
    }

    try {
      const payload = await this.jwtService.verifyAsync<JwtPayload>(token);
      if (payload.typ !== 'access' || !payload.sub) {
        throw new Error('JWT is not an access token');
      }

      const user = await this.prisma.user.findUnique({
        where: { id: payload.sub },
        select: { id: true, email: true, role: true, isActive: true },
      });

      if (!user) {
        throw new Error('JWT subject no longer exists');
      }

      if (!user.isActive) {
        throw new UnauthorizedException({
          code: ErrorCode.AUTH_INACTIVE_USER,
          message: 'User account is inactive',
        });
      }

      request.user = {
        id: user.id,
        email: user.email,
        role: user.role,
      };
      return true;
    } catch (error) {
      if (error instanceof UnauthorizedException) {
        throw error;
      }

      throw new UnauthorizedException({
        code:
          error instanceof Error && error.name === 'TokenExpiredError'
            ? ErrorCode.AUTH_TOKEN_EXPIRED
            : ErrorCode.AUTH_TOKEN_INVALID,
        message:
          error instanceof Error && error.name === 'TokenExpiredError'
            ? 'Authorization token is expired'
            : 'Authorization token is invalid',
      });
    }
  }

  private extractToken(authorization?: string) {
    const [type, token] = authorization?.split(' ') ?? [];
    return type === 'Bearer' ? token : undefined;
  }
}

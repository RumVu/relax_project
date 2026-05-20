import {
  ConflictException,
  HttpStatus,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { AccountTokenType, AuthProvider, Prisma } from '@prisma/client';
import * as bcrypt from 'bcrypt';
import { createHash, randomBytes } from 'node:crypto';
import { AppException } from '../common/errors/app.exception';
import { ErrorCode } from '../common/errors/error-code';
import { PrismaService } from '../prisma/prisma.service';
import { userSelect } from '../users/user.select';
import { UsersService } from '../users/users.service';
import { JwtPayload } from './auth.types';
import { DeleteAccountDto, DeleteAccountMode } from './dto/delete-account.dto';
import { LoginDto } from './dto/login.dto';
import { RefreshTokenDto } from './dto/refresh-token.dto';
import { RegisterDto } from './dto/register.dto';
import { RequestPasswordResetDto } from './dto/request-password-reset.dto';
import { ResetPasswordDto } from './dto/reset-password.dto';
import { VerifyEmailDto } from './dto/verify-email.dto';

const DUMMY_PASSWORD_HASH =
  '$2b$12$CwTycUXWue0Thq9StjUM0uJ8GQp/NxYMd6xiDfV3QzL/XU0.D1lu.';

@Injectable()
export class AuthService {
  constructor(
    private readonly jwtService: JwtService,
    private readonly prisma: PrismaService,
    private readonly usersService: UsersService,
    private readonly configService: ConfigService,
  ) {}

  async register(dto: RegisterDto, userAgent?: string, ipAddress?: string) {
    const existing = await this.usersService.findByEmailWithPassword(dto.email);
    if (existing) {
      throw new ConflictException({
        code: ErrorCode.USER_EMAIL_ALREADY_EXISTS,
        message: 'User email already exists',
      });
    }

    const password = await bcrypt.hash(dto.password, 12);
    const user = await this.prisma.user.create({
      data: {
        email: dto.email,
        name: dto.name,
        password,
        authProvider: AuthProvider.LOCAL,
        profile: { create: { displayName: dto.name } },
        preferences: { create: {} },
      },
      select: userSelect,
    });

    return this.createAuthResponse(user, userAgent, ipAddress);
  }

  async login(dto: LoginDto, userAgent?: string, ipAddress?: string) {
    const user = await this.usersService.findByEmailWithPassword(dto.email);
    const passwordHash = user?.password ?? DUMMY_PASSWORD_HASH;
    const validPassword = await bcrypt.compare(dto.password, passwordHash);

    if (!user?.password || !validPassword) {
      this.throwInvalidCredentials();
    }

    if (!user.isActive) {
      throw new UnauthorizedException({
        code: ErrorCode.AUTH_INACTIVE_USER,
        message: 'User account is inactive',
      });
    }

    await this.prisma.user.update({
      where: { id: user.id },
      data: { lastLoginAt: new Date() },
    });

    return this.createAuthResponse(user, userAgent, ipAddress);
  }

  async refresh(dto: RefreshTokenDto, userAgent?: string, ipAddress?: string) {
    const session = await this.prisma.session.findUnique({
      where: { refreshToken: this.hashToken(dto.refreshToken) },
      include: { user: { include: { profile: true, preferences: true } } },
    });

    if (!session || session.expiresAt <= new Date() || !session.user.isActive) {
      throw new UnauthorizedException({
        code: ErrorCode.AUTH_REFRESH_TOKEN_INVALID,
        message: 'Refresh token is invalid or expired',
      });
    }

    await this.prisma.session.delete({ where: { id: session.id } });

    return this.createAuthResponse(session.user, userAgent, ipAddress);
  }

  async logout(refreshToken: string) {
    await this.prisma.session.deleteMany({
      where: { refreshToken: this.hashToken(refreshToken) },
    });
    return { success: true };
  }

  me(userId: string) {
    return this.usersService.findOne(userId);
  }

  async requestEmailVerification(userId: string) {
    const user = await this.usersService.findOne(userId);

    if (user.emailVerified) {
      return {
        success: true,
        alreadyVerified: true,
        delivery: this.buildEmailDelivery('EMAIL_VERIFICATION'),
      };
    }

    const token = await this.createAccountToken(
      user.id,
      AccountTokenType.EMAIL_VERIFICATION,
      this.getEmailVerificationTtlMs(),
      { email: user.email },
    );

    return {
      success: true,
      alreadyVerified: false,
      expiresAt: token.expiresAt,
      delivery: this.buildEmailDelivery('EMAIL_VERIFICATION', token.plainToken),
    };
  }

  async verifyEmail(dto: VerifyEmailDto) {
    const token = await this.consumeAccountToken(
      dto.token,
      AccountTokenType.EMAIL_VERIFICATION,
    );

    const user = await this.prisma.user.update({
      where: { id: token.userId },
      data: { emailVerified: true },
      select: userSelect,
    });

    return { success: true, user };
  }

  async requestPasswordReset(dto: RequestPasswordResetDto) {
    const user = await this.usersService.findByEmailWithPassword(dto.email);

    if (!user || !user.isActive || user.authProvider !== AuthProvider.LOCAL) {
      return {
        success: true,
        delivery: this.buildEmailDelivery('PASSWORD_RESET'),
      };
    }

    const token = await this.createAccountToken(
      user.id,
      AccountTokenType.PASSWORD_RESET,
      this.getPasswordResetTtlMs(),
      { email: user.email },
    );

    return {
      success: true,
      delivery: this.buildEmailDelivery('PASSWORD_RESET', token.plainToken),
    };
  }

  async resetPassword(dto: ResetPasswordDto) {
    const token = await this.consumeAccountToken(
      dto.token,
      AccountTokenType.PASSWORD_RESET,
    );
    const password = await bcrypt.hash(dto.password, 12);

    const user = await this.prisma.$transaction(async (prisma) => {
      await prisma.session.deleteMany({ where: { userId: token.userId } });
      return prisma.user.update({
        where: { id: token.userId },
        data: { password, authProvider: AuthProvider.LOCAL },
        select: userSelect,
      });
    });

    return { success: true, revokedSessions: true, user };
  }

  async deleteMine(userId: string, dto: DeleteAccountDto) {
    const mode = dto.mode ?? DeleteAccountMode.SOFT;
    const user = await this.usersService.findByEmailWithPassword(
      (await this.usersService.findOne(userId)).email,
    );

    if (!user) {
      throw AppException.notFound(ErrorCode.USER_NOT_FOUND, 'User not found');
    }

    if (user.password) {
      if (!dto.password) {
        throw new UnauthorizedException({
          code: ErrorCode.AUTH_INVALID_CREDENTIALS,
          message: 'Password is required to delete this account',
        });
      }

      const validPassword = await bcrypt.compare(dto.password, user.password);
      if (!validPassword) {
        this.throwInvalidCredentials();
      }
    }

    if (mode === DeleteAccountMode.HARD) {
      await this.prisma.user.delete({ where: { id: userId } });
      return { success: true, mode };
    }

    await this.prisma.$transaction([
      this.prisma.session.deleteMany({ where: { userId } }),
      this.prisma.accountToken.deleteMany({ where: { userId } }),
      this.prisma.pushDevice.deleteMany({ where: { userId } }),
      this.prisma.user.update({
        where: { id: userId },
        data: {
          email: `deleted-${userId}@deleted.local`,
          name: null,
          avatar: null,
          password: null,
          emailVerified: false,
          isActive: false,
          deletedAt: new Date(),
        },
      }),
    ]);

    return { success: true, mode, revokedSessions: true, anonymized: true };
  }

  private async createAuthResponse(
    user: JwtPayloadUser,
    userAgent?: string,
    ipAddress?: string,
  ) {
    const payload: JwtPayload = {
      sub: user.id,
      email: user.email,
      role: user.role,
      typ: 'access',
    };
    const accessToken = await this.jwtService.signAsync(payload);
    const refreshToken = randomBytes(32).toString('base64url');
    const expiresAt = new Date(Date.now() + 1000 * 60 * 60 * 24 * 30);

    await this.prisma.session.create({
      data: {
        userId: user.id,
        refreshToken: this.hashToken(refreshToken),
        userAgent,
        ipAddress,
        expiresAt,
      },
    });

    const safeUser = await this.usersService.findOne(user.id);

    return {
      accessToken,
      refreshToken,
      expiresAt,
      user: safeUser,
    };
  }

  private throwInvalidCredentials(): never {
    throw new UnauthorizedException({
      code: ErrorCode.AUTH_INVALID_CREDENTIALS,
      message: 'Email or password is incorrect',
    });
  }

  private async createAccountToken(
    userId: string,
    type: AccountTokenType,
    ttlMs: number,
    metadata?: Record<string, unknown>,
  ) {
    const plainToken = randomBytes(32).toString('base64url');
    const tokenHash = this.hashToken(plainToken);
    const expiresAt = new Date(Date.now() + ttlMs);

    await this.prisma.accountToken.deleteMany({
      where: { userId, type, consumedAt: null },
    });

    const token = await this.prisma.accountToken.create({
      data: {
        userId,
        type,
        tokenHash,
        expiresAt,
        metadata: metadata as Prisma.InputJsonValue,
      },
    });

    return { ...token, plainToken };
  }

  private async consumeAccountToken(
    plainToken: string,
    type: AccountTokenType,
  ) {
    const token = await this.prisma.accountToken.findUnique({
      where: { tokenHash: this.hashToken(plainToken) },
    });

    if (!token || token.type !== type) {
      throw new AppException(
        ErrorCode.AUTH_TOKEN_INVALID,
        'Account token is invalid',
        HttpStatus.UNAUTHORIZED,
      );
    }

    if (token.consumedAt) {
      throw new AppException(
        ErrorCode.AUTH_TOKEN_CONSUMED,
        'Account token has already been used',
        HttpStatus.UNAUTHORIZED,
      );
    }

    if (token.expiresAt <= new Date()) {
      throw new AppException(
        ErrorCode.AUTH_TOKEN_EXPIRED,
        'Account token has expired',
        HttpStatus.UNAUTHORIZED,
      );
    }

    return this.prisma.accountToken.update({
      where: { id: token.id },
      data: { consumedAt: new Date() },
    });
  }

  private hashToken(token: string) {
    return createHash('sha256').update(token).digest('hex');
  }

  private buildEmailDelivery(purpose: string, plainToken?: string) {
    const provider = this.configService.get<string>('EMAIL_PROVIDER') ?? 'none';
    const configured =
      Boolean(this.configService.get<string>('RESEND_API_KEY')) ||
      Boolean(this.configService.get<string>('SENDGRID_API_KEY')) ||
      Boolean(this.configService.get<string>('SMTP_URL'));
    const nodeEnv =
      this.configService.get<string>('app.nodeEnv') ??
      process.env.NODE_ENV ??
      'development';

    return {
      channel: 'email',
      purpose,
      provider,
      configured,
      queued: configured,
      devToken:
        !configured && nodeEnv === 'development' ? plainToken : undefined,
    };
  }

  private getEmailVerificationTtlMs() {
    return Number(
      this.configService.get<string>('EMAIL_VERIFICATION_TTL_MS') ??
        1000 * 60 * 60 * 24,
    );
  }

  private getPasswordResetTtlMs() {
    return Number(
      this.configService.get<string>('PASSWORD_RESET_TTL_MS') ?? 1000 * 60 * 30,
    );
  }
}

type JwtPayloadUser = {
  id: string;
  email: string;
  role: JwtPayload['role'];
};

import {
  ConflictException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import {
  AccountTokenType,
  AuthProvider,
  NotificationType,
} from '@prisma/client';
import * as bcrypt from 'bcrypt';
import { randomBytes } from 'node:crypto';
import { AppException } from '../common/errors/app.exception';
import { ErrorCode } from '../common/errors/error-code';
import { NotificationsService } from '../notifications/notifications.service';
import { PrismaService } from '../prisma/prisma.service';
import { UsersService } from '../users/users.service';
import { JwtPayload } from './auth.types';
import { ChangePasswordDto } from './dto/change-password.dto';
import { DeleteAccountDto, DeleteAccountMode } from './dto/delete-account.dto';
import { GoogleLoginDto } from './dto/google-login.dto';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';
import { RequestPasswordResetDto } from './dto/request-password-reset.dto';
import { ResetPasswordDto } from './dto/reset-password.dto';
import { VerifyEmailDto } from './dto/verify-email.dto';

import {
  DUMMY_PASSWORD_HASH,
  hashToken,
  summariseUserAgent,
  throwInvalidCredentials,
} from './helpers/auth.helpers';
import {
  exchangeGoogleAuthorizationCode,
  verifyGoogleAccessToken,
  verifyGoogleIdToken,
} from './google/google-token-verifier';
import {
  buildEmailDelivery,
  getEmailVerificationTtlMs,
  getPasswordResetTtlMs,
} from './email/email-delivery.helper';
import { AccountTokensService } from './tokens/account-tokens.service';
import { UserExportService } from './export/user-export.service';
import { EmailService } from '../email/email.service';

/**
 * AuthService — orchestrator for register / login / refresh / Google
 * / logout / email-verification / password-reset / delete-account.
 *
 * Heavier responsibilities split out:
 *   - helpers/auth.helpers.ts       — pure (UA parsing, token hash, …)
 *   - google/google-token-verifier  — GIS id_token verification
 *   - email/email-delivery.helper   — delivery descriptor + TTL config
 *   - tokens/account-tokens.service — one-shot hashed token CRUD
 *   - export/user-export.service    — GDPR-style data dump
 */
@Injectable()
export class AuthService {
  constructor(
    private readonly jwtService: JwtService,
    private readonly prisma: PrismaService,
    private readonly usersService: UsersService,
    private readonly configService: ConfigService,
    private readonly notifications: NotificationsService,
    private readonly accountTokens: AccountTokensService,
    private readonly userExport: UserExportService,
    private readonly emailService: EmailService,
  ) {}

  // ============================================================
  // REGISTER / LOGIN / REFRESH / LOGOUT
  // ============================================================

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
      select: { id: true, email: true, role: true, isActive: true },
    });

    return this.createAuthResponse(user, userAgent, ipAddress);
  }

  async login(dto: LoginDto, userAgent?: string, ipAddress?: string) {
    const user = await this.usersService.findByEmailWithPassword(dto.email);
    // Constant-time guard: always bcrypt-compare against *some* hash
    // so attacker can't time-side-channel which emails exist.
    const passwordHash = user?.password ?? DUMMY_PASSWORD_HASH;
    const validPassword = await bcrypt.compare(dto.password, passwordHash);

    if (!user?.password || !validPassword) {
      throwInvalidCredentials();
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

  async demoLogin(userAgent?: string, ipAddress?: string) {
    const demoEmail = 'demo@thiai.app';
    const demoPassword = await bcrypt.hash('demo1234', 12);

    let user = await this.prisma.user.findUnique({
      where: { email: demoEmail },
      select: { id: true, email: true, role: true, isActive: true },
    });

    if (!user) {
      user = await this.prisma.user.create({
        data: {
          email: demoEmail,
          name: 'Demo User',
          password: demoPassword,
          authProvider: AuthProvider.LOCAL,
          emailVerified: true,
          profile: { create: { displayName: 'Demo User' } },
          preferences: { create: {} },
        },
        select: { id: true, email: true, role: true, isActive: true },
      });
      await this.seedDemoData(user.id);
    }

    return this.createAuthResponse(user, userAgent, ipAddress);
  }

  private async seedDemoData(userId: string) {
    const moods = ['HAPPY', 'CALM', 'NEUTRAL', 'ANXIOUS', 'SAD'] as const;
    const tags = [
      ['vui vẻ', 'gia đình'],
      ['bình yên', 'thiên nhiên'],
      ['bình thường'],
      ['lo lắng', 'công việc'],
      ['buồn', 'mệt mỏi'],
    ];
    const triggers = [
      null,
      'Nghe nhạc buổi sáng',
      null,
      'Deadline công việc',
      'Ngủ không đủ giấc',
      null,
      'Gặp bạn cũ',
      null,
      'Tập thể dục',
      null,
      'Mưa cả ngày',
      null,
      'Đọc sách hay',
      'Ăn uống lành mạnh',
    ];

    // 14 mood checkins — one per day for 14 days, alternating moods.
    for (let i = 13; i >= 0; i--) {
      const date = new Date();
      date.setDate(date.getDate() - i);
      const moodIndex = i % moods.length;
      await this.prisma.moodCheckin.create({
        data: {
          userId,
          mood: moods[moodIndex],
          intensity: 2 + (i % 4),
          tags: tags[moodIndex],
          note: triggers[i]
            ? `Demo mood day -${i}: ${triggers[i]}`
            : `Demo mood entry day -${i}`,
          createdAt: date,
        },
      });
    }

    // 5 journals — mix of moods and topics.
    await this.prisma.journal.createMany({
      data: [
        {
          userId,
          title: 'Ngày đầu tiên',
          content:
            'Hôm nay mình bắt đầu dùng Thi Ái. Cảm thấy nhẹ nhõm hơn sau khi viết ra những suy nghĩ.',
          mood: 'CALM',
          tags: ['reflection', 'first-day'],
          isPrivate: true,
        },
        {
          userId,
          title: 'Buổi sáng đẹp trời',
          content:
            'Sáng nay dậy sớm, hít thở và thiền 5 phút. Không ngờ mình lại có thể duy trì được 3 ngày liên tiếp.',
          mood: 'HAPPY',
          tags: ['morning', 'meditation'],
          isPrivate: false,
        },
        {
          userId,
          title: 'Stress công việc',
          content:
            'Deadline dồn dập. Dùng breathing exercise 4-2-4 để bình tĩnh lại. Thấy hiệu quả thật.',
          mood: 'ANXIOUS',
          tags: ['work', 'breathing'],
          isPrivate: true,
        },
        {
          userId,
          title: 'Cuối tuần nhẹ nhàng',
          content:
            'Dành cả ngày ở nhà, nấu ăn và đọc sách. Cảm giác bình yên hiếm có.',
          mood: 'HAPPY',
          tags: ['weekend', 'self-care'],
          isPrivate: false,
        },
        {
          userId,
          title: 'Suy ngẫm đêm khuya',
          content:
            'Không ngủ được, viết ra những điều lộn xộn trong đầu. Sau đó thấy nhẹ hơn nhiều.',
          mood: 'SAD',
          tags: ['night', 'reflection'],
          isPrivate: true,
        },
      ],
    });

    // 5 relax sessions — different activity types with mood tracking.
    await this.prisma.relaxSession.createMany({
      data: [
        {
          userId,
          activityType: 'BREATHING',
          status: 'FINISHED',
          title: 'Hít thở 4-2-4',
          duration: 180,
          moodBefore: 'ANXIOUS',
          moodAfter: 'CALM',
          reliefLevel: 4,
          stressReliefPercent: 72,
        },
        {
          userId,
          activityType: 'MUSIC',
          status: 'FINISHED',
          title: 'Nhạc thư giãn',
          duration: 600,
          moodBefore: 'SAD',
          moodAfter: 'NEUTRAL',
          reliefLevel: 3,
          stressReliefPercent: 55,
        },
        {
          userId,
          activityType: 'MEDITATION',
          status: 'FINISHED',
          title: 'Thiền chánh niệm',
          duration: 300,
          moodBefore: 'NEUTRAL',
          moodAfter: 'HAPPY',
          reliefLevel: 5,
          stressReliefPercent: 85,
        },
        {
          userId,
          activityType: 'BREATHING',
          status: 'FINISHED',
          title: 'Hít thở Box Breathing',
          duration: 240,
          moodBefore: 'ANXIOUS',
          moodAfter: 'CALM',
          reliefLevel: 4,
          stressReliefPercent: 78,
        },
        {
          userId,
          activityType: 'PODCAST',
          status: 'FINISHED',
          title: 'Podcast mindfulness',
          duration: 900,
          moodBefore: 'NEUTRAL',
          moodAfter: 'HAPPY',
          reliefLevel: 4,
          stressReliefPercent: 65,
        },
      ],
    });

    // 3 content ratings.
    try {
      await this.prisma.contentRating.createMany({
        data: [
          {
            userId,
            contentType: 'GUIDE',
            contentId: 'breathing-101',
            rating: 5,
            review: 'Rất hữu ích!',
          },
          {
            userId,
            contentType: 'GUIDE',
            contentId: 'meditation-basics',
            rating: 4,
            review: 'Hay',
          },
          {
            userId,
            contentType: 'SOUND',
            contentId: 'rain-forest',
            rating: 5,
            review: 'Thư giãn tuyệt vời',
          },
        ],
      });
    } catch {
      // Content rating table may not exist — skip silently.
    }

    // 2 achievement unlocks (if table exists).
    try {
      const achievements = await this.prisma.achievement.findMany({ take: 2 });
      if (achievements.length > 0) {
        await this.prisma.userAchievement.createMany({
          data: achievements.map((a) => ({
            userId,
            achievementId: a.id,
          })),
          skipDuplicates: true,
        });
      }
    } catch {
      // Achievement tables may not exist — skip silently.
    }

    // Buddy friend request (find another user or skip).
    try {
      const otherUser = await this.prisma.user.findFirst({
        where: { id: { not: userId }, isActive: true },
        select: { id: true },
      });
      if (otherUser) {
        await this.prisma.friend.create({
          data: {
            userId: userId,
            friendId: otherUser.id,
            status: 'ACCEPTED',
          },
        });
      }
    } catch {
      // Buddy table may not exist or constraint violation — skip.
    }
  }

  async refresh(refreshToken: string, userAgent?: string, ipAddress?: string) {
    const session = await this.prisma.session.findUnique({
      where: { refreshToken: hashToken(refreshToken) },
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

  /**
   * Exchanges a Google auth credential for an app session.
   *
   * Flow:
   *   1. Prefer OAuth authorization-code flow: backend uses
   *      GOOGLE_CLIENT_SECRET to exchange the code with Google.
   *   2. Find-or-create the user by email. LOCAL accounts get upgraded
   *      to GOOGLE so the next login skips straight through.
   *   3. Return the same auth response shape as /auth/login.
   */
  async googleLogin(
    dto: GoogleLoginDto,
    userAgent?: string,
    ipAddress?: string,
  ) {
    const clientId = this.configService.get<string>('app.googleClientId');
    if (!clientId) {
      throw new UnauthorizedException({
        code: ErrorCode.AUTH_INVALID_CREDENTIALS,
        message:
          'Google sign-in is not configured (missing GOOGLE_CLIENT_ID on backend).',
      });
    }

    const payload = await this.resolveGooglePayload(dto, clientId);
    const email = payload.email?.toLowerCase();
    if (!email) {
      throw new UnauthorizedException({
        code: ErrorCode.AUTH_INVALID_CREDENTIALS,
        message: 'Google token does not include an email address.',
      });
    }

    const existing = await this.usersService.findByEmailWithPassword(email);
    let userId: string;
    let userActive: boolean;
    let userRole: JwtPayload['role'];

    if (!existing) {
      // Google has already verified the email → trust emailVerified.
      const created = await this.prisma.user.create({
        data: {
          email,
          name: payload.name ?? null,
          avatar: payload.picture ?? null,
          authProvider: AuthProvider.GOOGLE,
          emailVerified: payload.email_verified === true,
          profile: {
            create: { displayName: payload.name ?? email.split('@')[0] },
          },
          preferences: { create: {} },
        },
        select: { id: true, isActive: true, role: true },
      });
      userId = created.id;
      userActive = created.isActive;
      userRole = created.role;
    } else {
      if (existing.authProvider === AuthProvider.LOCAL) {
        // Upgrade legacy LOCAL accounts so subsequent Google logins go
        // straight through. Password hash kept so they can still email-
        // login if they want to.
        await this.prisma.user.update({
          where: { id: existing.id },
          data: {
            authProvider: AuthProvider.GOOGLE,
            emailVerified: true,
            avatar: existing.avatar ?? payload.picture ?? null,
            name: existing.name ?? payload.name ?? null,
          },
        });
      }
      userId = existing.id;
      userActive = existing.isActive;
      userRole = existing.role;
    }

    if (!userActive) {
      throw new UnauthorizedException({
        code: ErrorCode.AUTH_INACTIVE_USER,
        message: 'User account is inactive',
      });
    }

    await this.prisma.user.update({
      where: { id: userId },
      data: { lastLoginAt: new Date() },
    });

    return this.createAuthResponse(
      { id: userId, email, role: userRole },
      userAgent,
      ipAddress,
    );
  }

  private async resolveGooglePayload(dto: GoogleLoginDto, clientId: string) {
    if (dto.authorizationCode) {
      const clientSecret = this.configService.get<string>(
        'app.googleClientSecret',
      );
      if (!clientSecret) {
        throw new UnauthorizedException({
          code: ErrorCode.AUTH_INVALID_CREDENTIALS,
          message:
            'Google sign-in is not configured (missing GOOGLE_CLIENT_SECRET on backend).',
        });
      }
      const redirectUri =
        this.configService.get<string>('app.googleRedirectUri') ||
        dto.redirectUri ||
        '';
      if (!redirectUri) {
        throw new UnauthorizedException({
          code: ErrorCode.AUTH_INVALID_CREDENTIALS,
          message:
            'Google sign-in is not configured (missing GOOGLE_REDIRECT_URI on backend).',
        });
      }

      return exchangeGoogleAuthorizationCode(
        dto.authorizationCode,
        clientId,
        clientSecret,
        redirectUri,
      );
    }

    if (dto.idToken) {
      return verifyGoogleIdToken(dto.idToken, clientId);
    }

    return verifyGoogleAccessToken(dto.accessToken ?? '', clientId);
  }

  async logout(refreshToken?: string) {
    if (refreshToken) {
      await this.prisma.session.deleteMany({
        where: { refreshToken: hashToken(refreshToken) },
      });
    }
    return { success: true };
  }

  me(userId: string) {
    return this.usersService.findOne(userId);
  }

  async changeMinePassword(userId: string, dto: ChangePasswordDto) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { id: true, password: true },
    });

    if (!user) {
      throw AppException.notFound(ErrorCode.USER_NOT_FOUND, 'User not found');
    }

    if (!user.password) {
      throw new UnauthorizedException({
        code: ErrorCode.AUTH_INVALID_CREDENTIALS,
        message: 'This account does not have a local password yet',
      });
    }

    const validPassword = await bcrypt.compare(
      dto.currentPassword,
      user.password,
    );
    if (!validPassword) {
      throwInvalidCredentials();
    }

    const password = await bcrypt.hash(dto.newPassword, 12);
    await this.prisma.user.update({
      where: { id: user.id },
      data: { password },
    });

    return { success: true };
  }

  // ============================================================
  // EXPORT / DELETE
  // ============================================================

  exportMine(userId: string) {
    return this.userExport.exportForUser(userId);
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
        throwInvalidCredentials();
      }
    }

    if (mode === DeleteAccountMode.HARD) {
      await this.prisma.user.delete({ where: { id: userId } });
      return { success: true, mode };
    }

    // SOFT delete = anonymize + revoke sessions/tokens/devices.
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

  // ============================================================
  // EMAIL VERIFICATION / PASSWORD RESET
  // ============================================================

  async requestEmailVerification(userId: string) {
    const user = await this.usersService.findOne(userId);

    if (user.emailVerified) {
      return {
        success: true,
        alreadyVerified: true,
        delivery: buildEmailDelivery(
          this.configService,
          'EMAIL_VERIFICATION',
          undefined,
          this.emailService,
        ),
      };
    }

    const ttlMs = getEmailVerificationTtlMs(this.configService);
    const token = await this.accountTokens.create(
      user.id,
      AccountTokenType.EMAIL_VERIFICATION,
      ttlMs,
      { email: user.email },
    );

    // Fire-and-await so the failure surfaces in logs, but never block the
    // HTTP response on a slow provider — clients only need the descriptor.
    await this.emailService
      .sendVerifyEmail({
        to: user.email,
        displayName: (user as { name?: string | null }).name ?? null,
        token: token.plainToken,
        ttlMinutes: Math.max(1, Math.round(ttlMs / 60000)),
      })
      .catch((err: unknown) =>
        // Provider already logs internally — swallow so the API stays 200.
        ({
          provider: 'unknown',
          delivered: false,
          error: err instanceof Error ? err.message : String(err),
        }),
      );

    return {
      success: true,
      alreadyVerified: false,
      expiresAt: token.expiresAt,
      delivery: buildEmailDelivery(
        this.configService,
        'EMAIL_VERIFICATION',
        token.plainToken,
        this.emailService,
      ),
    };
  }

  async verifyEmail(dto: VerifyEmailDto) {
    const token = await this.accountTokens.consume(
      dto.token,
      AccountTokenType.EMAIL_VERIFICATION,
    );

    const user = await this.prisma.user.update({
      where: { id: token.userId },
      data: { emailVerified: true },
      select: { id: true, email: true, emailVerified: true, role: true },
    });

    return { success: true, user };
  }

  async requestPasswordReset(dto: RequestPasswordResetDto) {
    const user = await this.usersService.findByEmailWithPassword(dto.email);

    // Always return success so this endpoint can't be used to probe
    // which emails are registered.
    if (!user || !user.isActive || user.authProvider !== AuthProvider.LOCAL) {
      return {
        success: true,
        delivery: buildEmailDelivery(
          this.configService,
          'PASSWORD_RESET',
          undefined,
          this.emailService,
        ),
      };
    }

    const ttlMs = getPasswordResetTtlMs(this.configService);
    const token = await this.accountTokens.create(
      user.id,
      AccountTokenType.PASSWORD_RESET,
      ttlMs,
      { email: user.email },
    );

    await this.emailService
      .sendPasswordReset({
        to: user.email,
        displayName: (user as { name?: string | null }).name ?? null,
        token: token.plainToken,
        ttlMinutes: Math.max(1, Math.round(ttlMs / 60000)),
      })
      .catch((err: unknown) => ({
        provider: 'unknown',
        delivered: false,
        error: err instanceof Error ? err.message : String(err),
      }));

    return {
      success: true,
      delivery: buildEmailDelivery(
        this.configService,
        'PASSWORD_RESET',
        token.plainToken,
        this.emailService,
      ),
    };
  }

  async resetPassword(dto: ResetPasswordDto) {
    const token = await this.accountTokens.consume(
      dto.token,
      AccountTokenType.PASSWORD_RESET,
    );
    const password = await bcrypt.hash(dto.password, 12);

    const user = await this.prisma.$transaction(async (prisma) => {
      await prisma.session.deleteMany({ where: { userId: token.userId } });
      return prisma.user.update({
        where: { id: token.userId },
        data: { password, authProvider: AuthProvider.LOCAL },
        select: { id: true, email: true, role: true },
      });
    });

    return { success: true, revokedSessions: true, user };
  }

  // ============================================================
  // PRIVATE — session issuance + new-device notification
  // ============================================================

  private async createAuthResponse(
    user: JwtPayloadUser,
    userAgent?: string,
    ipAddress?: string,
  ) {
    const refreshToken = randomBytes(32).toString('base64url');
    const expiresAt = new Date(Date.now() + 1000 * 60 * 60 * 24 * 30);

    // Detect "new device" BEFORE inserting the new session — otherwise
    // every login trivially matches itself. A device is "new" when we've
    // never seen this exact userAgent for this user.
    const isNewDevice = await this.isFirstTimeDeviceForUser(user.id, userAgent);

    const session = await this.prisma.session.create({
      data: {
        userId: user.id,
        refreshToken: hashToken(refreshToken),
        userAgent,
        ipAddress,
        expiresAt,
      },
    });

    if (isNewDevice) {
      // Fire-and-forget: notifying the user must never block login.
      void this.notifyNewDeviceLogin(user.id, userAgent, ipAddress).catch(
        () => undefined,
      );
    }

    const payload: JwtPayload = {
      sub: user.id,
      email: user.email,
      role: user.role,
      typ: 'access',
      sessionId: session.id,
    };
    const accessToken = await this.jwtService.signAsync(payload);
    const safeUser = await this.usersService.findOne(user.id);

    return {
      accessToken,
      refreshToken,
      expiresAt,
      sessionId: session.id,
      user: safeUser,
    };
  }

  /**
   * True when this user has never had a session with this exact UA.
   * Missing/blank UA is treated as known so we don't spam users whose
   * browser refuses to send one.
   */
  private async isFirstTimeDeviceForUser(
    userId: string,
    userAgent?: string,
  ): Promise<boolean> {
    if (!userAgent) return false;
    const existing = await this.prisma.session.findFirst({
      where: { userId, userAgent },
      select: { id: true },
    });
    return existing === null;
  }

  /**
   * Surfaces a "đã tìm thấy thiết bị đăng nhập mới" notification with
   * a short device summary so the user can spot strange logins.
   */
  private async notifyNewDeviceLogin(
    userId: string,
    userAgent?: string,
    ipAddress?: string,
  ) {
    const userPref = await this.prisma.userPreference.findUnique({
      where: { userId },
      select: { language: true },
    });
    const lang = userPref?.language || 'vi';

    const deviceLabel = summariseUserAgent(userAgent);
    if (lang === 'en') {
      const ipLabel = ipAddress ? ` from IP ${ipAddress}` : '';
      await this.notifications.createForUser(userId, {
        title: 'New login device detected',
        message: `Detected login from ${deviceLabel}${ipLabel}. If this wasn't you, change your password immediately.`,
        type: NotificationType.IN_APP,
      });
    } else {
      const ipLabel = ipAddress ? ` từ IP ${ipAddress}` : '';
      await this.notifications.createForUser(userId, {
        title: 'Đã tìm thấy thiết bị đăng nhập mới',
        message: `Phát hiện đăng nhập từ ${deviceLabel}${ipLabel}. Nếu không phải anh, hãy đổi mật khẩu ngay.`,
        type: NotificationType.IN_APP,
      });
    }
  }
}

type JwtPayloadUser = {
  id: string;
  email: string;
  role: JwtPayload['role'];
};

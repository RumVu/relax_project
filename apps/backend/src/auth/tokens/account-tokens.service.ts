/**
 * Account tokens — single-use, hashed, time-limited.
 * Used by email-verification + password-reset + OTP codes.
 *
 * Storing only the SHA-256 hash means a database leak can't be turned
 * into a working verification/reset link.
 */
import { HttpStatus, Injectable } from '@nestjs/common';
import { AccountTokenType, Prisma } from '@prisma/client';
import { randomBytes, randomInt } from 'node:crypto';
import { AppException } from '../../common/errors/app.exception';
import { ErrorCode } from '../../common/errors/error-code';
import { PrismaService } from '../../prisma/prisma.service';
import { hashToken } from '../helpers/auth.helpers';

@Injectable()
export class AccountTokensService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Issue a fresh token of the given type. Any outstanding unconsumed
   * tokens of the same type for the same user are revoked first so the
   * latest email is the only one that works.
   */
  async create(
    userId: string,
    type: AccountTokenType,
    ttlMs: number,
    metadata?: Record<string, unknown>,
  ) {
    const plainToken = randomBytes(32).toString('base64url');
    const tokenHash = hashToken(plainToken);
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

  /**
   * Issue a 6-digit numeric OTP code. Same revocation semantics as
   * `create()` — previous unconsumed tokens of the same type are deleted.
   */
  async createOtp(
    userId: string,
    type: AccountTokenType,
    ttlMs: number,
    metadata?: Record<string, unknown>,
  ) {
    const otp = String(randomInt(100_000, 999_999));
    const tokenHash = hashToken(otp);
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
        metadata: { ...metadata, isOtp: true },
      },
    });

    return { ...token, plainToken: otp };
  }

  /**
   * Consume a token of the expected type. Throws if invalid / wrong
   * type / already consumed / expired. Otherwise marks `consumedAt`
   * and returns the row.
   */
  async consume(plainToken: string, type: AccountTokenType) {
    const token = await this.prisma.accountToken.findUnique({
      where: { tokenHash: hashToken(plainToken) },
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
}

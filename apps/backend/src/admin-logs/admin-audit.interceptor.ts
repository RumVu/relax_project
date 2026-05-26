import {
  CallHandler,
  ExecutionContext,
  Injectable,
  Logger,
  NestInterceptor,
} from '@nestjs/common';
import { UserRole } from '@prisma/client';
import type { Request } from 'express';
import { tap } from 'rxjs';
import type { AuthUser } from '../auth/auth.types';
import { PrismaService } from '../prisma/prisma.service';

const AUDITED_METHODS = new Set(['POST', 'PUT', 'PATCH', 'DELETE']);
const REDACTED_KEYS = new Set([
  'authorization',
  'cookie',
  'password',
  'token',
  'refreshToken',
  'accessToken',
  'secret',
  'apiKey',
]);

type AuditedRequest = Request & {
  user?: AuthUser;
  body?: unknown;
  params?: Record<string, string>;
  query?: Record<string, unknown>;
};

@Injectable()
export class AdminAuditInterceptor implements NestInterceptor {
  private readonly logger = new Logger(AdminAuditInterceptor.name);

  constructor(private readonly prisma: PrismaService) {}

  intercept(context: ExecutionContext, next: CallHandler) {
    if (context.getType() !== 'http') {
      return next.handle();
    }

    const request = context.switchToHttp().getRequest<AuditedRequest>();
    const user = request.user;

    if (
      !user ||
      user.role !== UserRole.ADMIN ||
      !AUDITED_METHODS.has(request.method)
    ) {
      return next.handle();
    }

    const startedAt = Date.now();

    return next.handle().pipe(
      tap({
        next: () => {
          void this.writeLog(request, user, startedAt, 'success');
        },
        error: (error: unknown) => {
          void this.writeLog(request, user, startedAt, 'error', error);
        },
      }),
    );
  }

  private async writeLog(
    request: AuditedRequest,
    user: AuthUser,
    startedAt: number,
    outcome: 'success' | 'error',
    error?: unknown,
  ) {
    try {
      await this.prisma.adminLog.create({
        data: {
          adminId: user.id,
          action: `${request.method} ${this.resolveRoutePath(request)}`,
          targetType: this.resolveTargetType(request),
          targetId: this.resolveTargetId(request),
          details: this.stringifyDetails({
            outcome,
            path: request.originalUrl ?? request.url,
            method: request.method,
            params: this.sanitize(request.params ?? {}),
            query: this.sanitize(request.query ?? {}),
            body: this.sanitize(request.body ?? {}),
            durationMs: Date.now() - startedAt,
            error:
              outcome === 'error'
                ? {
                    name: error instanceof Error ? error.name : 'UnknownError',
                    message:
                      error instanceof Error ? error.message : 'Request failed',
                  }
                : undefined,
          }),
        },
      });
    } catch (logError) {
      this.logger.warn(
        logError instanceof Error
          ? logError.message
          : 'Failed to write admin audit log',
      );
    }
  }

  private resolveTargetType(request: AuditedRequest) {
    const path = request.path.split('/').filter(Boolean);
    return path[0] ?? 'unknown';
  }

  private resolveRoutePath(request: AuditedRequest) {
    const route = request.route as { path?: unknown } | undefined;
    return typeof route?.path === 'string' ? route.path : request.path;
  }

  private resolveTargetId(request: AuditedRequest) {
    return (
      request.params?.id ??
      request.params?.userId ??
      request.params?.sessionId ??
      null
    );
  }

  private stringifyDetails(value: Record<string, unknown>) {
    const serialized = JSON.stringify(value);
    return serialized.length > 10000
      ? `${serialized.slice(0, 9997)}...`
      : serialized;
  }

  private sanitize(value: unknown): unknown {
    if (Array.isArray(value)) {
      return value.map((item) => this.sanitize(item));
    }

    if (value && typeof value === 'object') {
      return Object.fromEntries(
        Object.entries(value as Record<string, unknown>).map(([key, item]) => [
          key,
          REDACTED_KEYS.has(key) || REDACTED_KEYS.has(key.toLowerCase())
            ? '[REDACTED]'
            : this.sanitize(item),
        ]),
      );
    }

    return value;
  }
}

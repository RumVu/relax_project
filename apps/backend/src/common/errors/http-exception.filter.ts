import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { Request, Response } from 'express';
import { AppExceptionResponse } from './app.exception';
import { ErrorCode } from './error-code';

interface ErrorPayload {
  success: false;
  statusCode: number;
  code: ErrorCode;
  message: string;
  details?: unknown;
  path: string;
  timestamp: string;
}

@Catch()
export class HttpExceptionFilter implements ExceptionFilter {
  private readonly logger = new Logger(HttpExceptionFilter.name);

  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<Request>();
    const payload = this.toPayload(exception, request.url);

    if (payload.statusCode >= 500) {
      console.error('SERVER ERROR:', exception);
      this.logger.error(
        payload.message,
        exception instanceof Error ? exception.stack : exception,
      );
    }

    response.status(payload.statusCode).json(payload);
  }

  private toPayload(exception: unknown, path: string): ErrorPayload {
    const timestamp = new Date().toISOString();

    if (exception instanceof Prisma.PrismaClientKnownRequestError) {
      const mapped = this.mapPrismaError(exception);

      return {
        success: false,
        statusCode: mapped.statusCode,
        code: mapped.code,
        message: mapped.message,
        details: mapped.details,
        path,
        timestamp,
      };
    }

    if (exception instanceof HttpException) {
      const statusCode = exception.getStatus();
      const body = exception.getResponse();
      const normalized = this.normalizeHttpResponse(body, statusCode);

      return {
        success: false,
        statusCode,
        code: normalized.code,
        message: normalized.message,
        details: normalized.details,
        path,
        timestamp,
      };
    }

    return {
      success: false,
      statusCode: HttpStatus.INTERNAL_SERVER_ERROR,
      code: ErrorCode.INTERNAL_SERVER_ERROR,
      message: 'Unexpected server error',
      path,
      timestamp,
    };
  }

  private normalizeHttpResponse(
    body: string | object,
    statusCode: number,
  ): Pick<ErrorPayload, 'code' | 'message' | 'details'> {
    if (typeof body === 'string') {
      return {
        code: this.defaultCodeForStatus(statusCode),
        message: body,
      };
    }

    const response = body as Partial<AppExceptionResponse> & {
      error?: string;
      message?: string | string[];
    };
    const message = Array.isArray(response.message)
      ? response.message.join('; ')
      : response.message;

    return {
      code: response.code ?? this.defaultCodeForStatus(statusCode),
      message: message ?? response.error ?? 'Request failed',
      details:
        response.details ??
        (Array.isArray(response.message) ? response.message : undefined),
    };
  }

  private defaultCodeForStatus(statusCode: number): ErrorCode {
    if (statusCode === 400) {
      return ErrorCode.VALIDATION_FAILED;
    }

    if (statusCode === 404) {
      return ErrorCode.ROUTE_NOT_FOUND;
    }

    if (statusCode === 401) {
      return ErrorCode.AUTH_UNAUTHORIZED;
    }

    if (statusCode === 403) {
      return ErrorCode.AUTH_FORBIDDEN;
    }

    if (statusCode === 409) {
      return ErrorCode.DATABASE_UNIQUE_CONSTRAINT;
    }

    if (statusCode === 429) {
      return ErrorCode.RATE_LIMIT_EXCEEDED;
    }

    if (statusCode === 502) {
      return ErrorCode.STORAGE_OPERATION_FAILED;
    }

    return ErrorCode.INTERNAL_SERVER_ERROR;
  }

  private mapPrismaError(error: Prisma.PrismaClientKnownRequestError) {
    if (error.code === 'P2002') {
      return {
        statusCode: HttpStatus.CONFLICT,
        code: ErrorCode.DATABASE_UNIQUE_CONSTRAINT,
        message: 'A record with this unique value already exists',
        details: { reason: 'unique_constraint' },
      };
    }

    if (error.code === 'P2003') {
      return {
        statusCode: HttpStatus.CONFLICT,
        code: ErrorCode.DATABASE_FOREIGN_KEY_CONSTRAINT,
        message: 'This record is still referenced by related data',
        details: { reason: 'foreign_key_constraint' },
      };
    }

    if (error.code === 'P2025') {
      return {
        statusCode: HttpStatus.NOT_FOUND,
        code: ErrorCode.DATABASE_RECORD_NOT_FOUND,
        message: 'Database record not found',
        details: { reason: 'record_not_found' },
      };
    }

    return {
      statusCode: HttpStatus.INTERNAL_SERVER_ERROR,
      code: ErrorCode.INTERNAL_SERVER_ERROR,
      message: 'Database request failed',
      details: { reason: 'database_request_failed' },
    };
  }
}

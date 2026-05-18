import { HttpException, HttpStatus } from '@nestjs/common';
import { ErrorCode } from './error-code';

export interface AppExceptionResponse {
  code: ErrorCode;
  message: string;
  details?: unknown;
}

export class AppException extends HttpException {
  constructor(
    code: ErrorCode,
    message: string,
    statusCode = HttpStatus.BAD_REQUEST,
    details?: unknown,
  ) {
    super({ code, message, details }, statusCode);
  }

  static notFound(code: ErrorCode, message: string) {
    return new AppException(code, message, HttpStatus.NOT_FOUND);
  }
}

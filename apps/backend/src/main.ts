import { NestFactory } from '@nestjs/core';
import {
  INestApplication,
  Logger as NestLogger,
  RequestMethod,
  ValidationPipe,
} from '@nestjs/common';
import type {
  CorsOptions,
  CustomOrigin,
} from '@nestjs/common/interfaces/external/cors-options.interface';
import { ConfigService } from '@nestjs/config';
import type { OpenAPIObject } from '@nestjs/swagger';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import helmet from 'helmet';
import { Logger as PinoLogger } from 'nestjs-pino';
import { createHash, timingSafeEqual } from 'node:crypto';
import type { NextFunction, Request, Response } from 'express';
import { AppModule } from './app.module';
import { isAllowedOrigin } from './common/cors';
import { HttpExceptionFilter } from './common/errors/http-exception.filter';
import { ErrorCode } from './common/errors/error-code';
import { applyExampleDocumentation } from './docs/swagger.examples';
import { PrismaService } from './prisma/prisma.service';
import { RedisIoAdapter } from './realtime/redis-io.adapter';
import { RealtimeService } from './realtime/realtime.service';

const HTTP_METHODS = new Set([
  'get',
  'post',
  'put',
  'patch',
  'delete',
  'options',
  'head',
  'trace',
]);

const STANDARD_ERROR_RESPONSES: Record<
  string,
  { description: string; codes: ErrorCode[] }
> = {
  '400': {
    description: 'Bad request or validation failed.',
    codes: [
      ErrorCode.VALIDATION_FAILED,
      ErrorCode.STORAGE_INVALID_PATH,
      ErrorCode.PAYMENT_PLAN_MISMATCH,
    ],
  },
  '401': {
    description: 'Bearer token is missing, invalid, or expired.',
    codes: [
      ErrorCode.AUTH_UNAUTHORIZED,
      ErrorCode.AUTH_TOKEN_INVALID,
      ErrorCode.AUTH_TOKEN_EXPIRED,
      ErrorCode.AUTH_TOKEN_CONSUMED,
      ErrorCode.AUTH_INVALID_CREDENTIALS,
      ErrorCode.AUTH_REFRESH_TOKEN_INVALID,
      ErrorCode.AUTH_INACTIVE_USER,
    ],
  },
  '403': {
    description: 'Authenticated user does not have permission.',
    codes: [ErrorCode.AUTH_FORBIDDEN],
  },
  '404': {
    description: 'Route or requested resource was not found.',
    codes: [
      ErrorCode.ROUTE_NOT_FOUND,
      ErrorCode.USER_NOT_FOUND,
      ErrorCode.USER_PROFILE_NOT_FOUND,
      ErrorCode.USER_PREFERENCE_NOT_FOUND,
      ErrorCode.SESSION_NOT_FOUND,
      ErrorCode.NOTIFICATION_NOT_FOUND,
      ErrorCode.PUSH_DEVICE_NOT_FOUND,
      ErrorCode.REMINDER_NOT_FOUND,
      ErrorCode.MOOD_CHECKIN_NOT_FOUND,
      ErrorCode.JOURNAL_NOT_FOUND,
      ErrorCode.USER_COMPANION_NOT_FOUND,
      ErrorCode.RELAX_SESSION_NOT_FOUND,
      ErrorCode.CATALOG_APP_THEME_NOT_FOUND,
      ErrorCode.CATALOG_DEFAULT_APP_THEME_NOT_FOUND,
      ErrorCode.CATALOG_ONBOARDING_SLIDE_NOT_FOUND,
      ErrorCode.CATALOG_COMPANION_ASSET_NOT_FOUND,
      ErrorCode.CATALOG_DEFAULT_COMPANION_ASSET_NOT_FOUND,
      ErrorCode.CATALOG_COMPANION_MESSAGE_NOT_FOUND,
      ErrorCode.CATALOG_ACTIVE_COMPANION_MESSAGE_NOT_FOUND,
      ErrorCode.CATALOG_AMBIENT_SOUND_NOT_FOUND,
      ErrorCode.CATALOG_BREATHING_EXERCISE_NOT_FOUND,
      ErrorCode.CATALOG_COZY_QUOTE_NOT_FOUND,
      ErrorCode.CATALOG_ACTIVE_COZY_QUOTE_NOT_FOUND,
      ErrorCode.PAYMENT_NOT_FOUND,
      ErrorCode.DATABASE_RECORD_NOT_FOUND,
    ],
  },
  '409': {
    description: 'Conflict with existing or related data.',
    codes: [
      ErrorCode.USER_EMAIL_ALREADY_EXISTS,
      ErrorCode.PAYMENT_NOT_PENDING,
      ErrorCode.DATABASE_UNIQUE_CONSTRAINT,
      ErrorCode.DATABASE_FOREIGN_KEY_CONSTRAINT,
    ],
  },
  '429': {
    description: 'Too many requests in a short period.',
    codes: [ErrorCode.RATE_LIMIT_EXCEEDED],
  },
  '500': {
    description: 'Server, configuration, or database failure.',
    codes: [
      ErrorCode.INTERNAL_SERVER_ERROR,
      ErrorCode.CONFIG_MISSING_REQUIRED_ENV,
      ErrorCode.STORAGE_NOT_CONFIGURED,
    ],
  },
  '502': {
    description: 'External provider or storage operation failed.',
    codes: [ErrorCode.STORAGE_OPERATION_FAILED],
  },
};

interface OpenApiOperation {
  responses?: Record<string, unknown>;
}

interface OpenApiResponse {
  description?: string;
  content?: unknown;
}

function applyErrorDocumentation(document: OpenAPIObject) {
  document.components ??= {};
  document.components.schemas ??= {};
  document.components.schemas.ErrorResponse = {
    type: 'object',
    required: ['success', 'statusCode', 'code', 'message', 'path', 'timestamp'],
    properties: {
      success: { type: 'boolean', example: false },
      statusCode: { type: 'integer', example: 400 },
      code: {
        type: 'string',
        enum: Object.values(ErrorCode),
        example: ErrorCode.VALIDATION_FAILED,
      },
      message: { type: 'string', example: 'Validation failed' },
      details: {
        description:
          'Optional validation messages, Prisma metadata, or provider details.',
      },
      path: { type: 'string', example: '/mood-checkins/me' },
      timestamp: {
        type: 'string',
        format: 'date-time',
        example: '2026-05-16T03:42:00.000Z',
      },
    },
  };

  for (const pathItem of Object.values(document.paths)) {
    for (const [method, operation] of Object.entries(pathItem)) {
      if (!HTTP_METHODS.has(method)) {
        continue;
      }

      const typedOperation = operation as OpenApiOperation;
      typedOperation.responses ??= {};

      for (const [statusCode, response] of Object.entries(
        STANDARD_ERROR_RESPONSES,
      )) {
        const documentedResponse = typedOperation.responses[statusCode] as
          | OpenApiResponse
          | undefined;
        const content = {
          'application/json': {
            schema: { $ref: '#/components/schemas/ErrorResponse' },
            examples: Object.fromEntries(
              response.codes.map((code) => [
                code,
                {
                  summary: code,
                  value: {
                    success: false,
                    statusCode: Number(statusCode),
                    code,
                    message: response.description,
                    path: '/example',
                    timestamp: '2026-05-16T03:42:00.000Z',
                  },
                },
              ]),
            ),
          },
        };

        typedOperation.responses[statusCode] = {
          ...documentedResponse,
          description: `${response.description} Possible codes: ${response.codes.join(', ')}.`,
          content: documentedResponse?.content ?? content,
        };
      }
    }
  }
}

function configureHttpSecurity(
  app: INestApplication,
  configService: ConfigService,
) {
  const nodeEnv = configService.get<string>('app.nodeEnv') ?? 'development';
  const isProduction = nodeEnv === 'production';
  const allowedOrigins = parseCsv(
    configService.get<string>('app.corsOrigins') ?? '',
  );

  const corsOrigin: CustomOrigin = (origin, callback) => {
    if (!origin || isAllowedOrigin(origin, allowedOrigins, isProduction)) {
      callback(null, true);
      return;
    }

    callback(null, false);
  };
  const corsOptions: CorsOptions = {
    credentials: true,
    origin: corsOrigin,
  };

  app.enableCors(corsOptions);

  app.use(
    helmet({
      contentSecurityPolicy: false,
      crossOriginResourcePolicy: { policy: 'cross-origin' },
    }),
  );
}

function configureTrustProxy(
  app: INestApplication,
  configService: ConfigService,
) {
  const trustProxy = parseTrustProxy(
    configService.get<string>('app.trustProxy') ?? 'loopback',
  );
  const httpInstance = app.getHttpAdapter().getInstance() as {
    set?: (setting: string, value: unknown) => void;
  };

  httpInstance.set?.('trust proxy', trustProxy);
}

function setupSwaggerProtection(
  app: INestApplication,
  configService: ConfigService,
) {
  const nodeEnv = configService.get<string>('app.nodeEnv') ?? 'development';
  const isProduction = nodeEnv === 'production';
  const publicSwagger =
    configService.get<string>('app.swaggerPublic') === 'true';
  const username = configService.get<string>('app.swaggerBasicUser');
  const password = configService.get<string>('app.swaggerBasicPassword');

  if (!isProduction || publicSwagger || !username || !password) {
    return;
  }

  app.use(
    ['/docs', '/docs-json'],
    (req: Request, res: Response, next: NextFunction) => {
      const authorization = req.headers.authorization ?? '';
      const [scheme, encoded] = authorization.split(' ');

      if (scheme === 'Basic' && encoded) {
        const [providedUser, providedPassword] = Buffer.from(encoded, 'base64')
          .toString('utf8')
          .split(':');

        if (
          timingSafeStringEqual(providedUser ?? '', username) &&
          timingSafeStringEqual(providedPassword ?? '', password)
        ) {
          next();
          return;
        }
      }

      res.setHeader('WWW-Authenticate', 'Basic realm="API Docs"');
      res.status(401).send('Authentication required');
    },
  );
}

function shouldEnableSwagger(configService: ConfigService) {
  const nodeEnv = configService.get<string>('app.nodeEnv') ?? 'development';
  const configured = configService.get<string>('app.swaggerEnabled');

  if (configured === 'false') {
    return false;
  }

  if (nodeEnv !== 'production') {
    return true;
  }

  return (
    configured === 'true' ||
    configService.get<string>('app.swaggerPublic') === 'true' ||
    Boolean(
      configService.get<string>('app.swaggerBasicUser') &&
      configService.get<string>('app.swaggerBasicPassword'),
    )
  );
}

function parseCsv(value: string) {
  return value
    .split(',')
    .map((item) => item.trim())
    .filter(Boolean);
}

function parseTrustProxy(value: string): boolean | number | string {
  const normalized = value.trim().toLowerCase();

  if (normalized === 'true') {
    return true;
  }

  if (normalized === 'false') {
    return false;
  }

  const numeric = Number(normalized);
  if (Number.isInteger(numeric) && numeric >= 0) {
    return numeric;
  }

  return value;
}

function timingSafeStringEqual(left: string, right: string) {
  const leftDigest = createHash('sha256').update(left).digest();
  const rightDigest = createHash('sha256').update(right).digest();
  return timingSafeEqual(leftDigest, rightDigest);
}

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.useLogger(app.get(PinoLogger));
  const configService = app.get(ConfigService);
  configureTrustProxy(app, configService);
  configureHttpSecurity(app, configService);
  // Version all API routes under /v1 so the contract can evolve without
  // breaking shipped mobile clients. Infra/index routes stay unversioned.
  app.setGlobalPrefix('v1', {
    exclude: [
      { path: '/', method: RequestMethod.GET },
      { path: 'api', method: RequestMethod.GET },
      { path: 'health', method: RequestMethod.GET },
      { path: 'ready', method: RequestMethod.GET },
    ],
  });
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );
  app.useGlobalFilters(new HttpExceptionFilter());

  const swaggerConfig = new DocumentBuilder()
    .setTitle('Digital Cigarette Break API')
    .setDescription(
      'Backend API for auth, users, catalog content, storage, and wellness app configuration.',
    )
    .setVersion('1.0.0')
    .addBearerAuth(
      {
        type: 'http',
        scheme: 'bearer',
        bearerFormat: 'JWT',
        description:
          'Paste an access token from /auth/login or /auth/register.',
      },
      'access-token',
    )
    .addTag(
      'Auth',
      'Xác thực tài khoản: đăng ký, đăng nhập, refresh token, đăng xuất và xem user hiện tại.',
    )
    .addTag('Users', 'Quản lý tài khoản người dùng ở cấp hệ thống/admin.')
    .addTag(
      'User Profiles',
      'Thông tin hồ sơ cá nhân: tên, tuổi, giới tính, ảnh đại diện, cung hoàng đạo và con giáp.',
    )
    .addTag(
      'User Preferences',
      'Tuỳ chỉnh theo người dùng: theme, timezone, vị trí, thông báo và lựa chọn trải nghiệm.',
    )
    .addTag(
      'Sessions',
      'Quản lý phiên đăng nhập và refresh token của người dùng.',
    )
    .addTag(
      'User Companions',
      'Pet/companion hiện tại của người dùng, trạng thái và tương tác cá nhân hoá.',
    )
    .addTag(
      'Mood Check-ins',
      'Check-in cảm xúc, điểm mood, lịch sử theo ngày và dữ liệu feed cho thống kê.',
    )
    .addTag(
      'Journals',
      'Nhật ký cảm xúc, ghi chú sau hoạt động và thống kê journal.',
    )
    .addTag(
      'Relax Activities',
      'Danh sách hoạt động thư giãn, flow play/finish và gợi ý hoạt động tiếp theo.',
    )
    .addTag(
      'Relax Sessions',
      'Vòng đời phiên thư giãn: bắt đầu, hoàn thành, thời lượng và kết quả sau hoạt động.',
    )
    .addTag(
      'Analytics',
      'Tổng hợp thống kê: streak, biểu đồ cảm xúc, hoạt động yêu thích và weekly stats.',
    )
    .addTag(
      'Admin Dashboard',
      'Tổng hợp vận hành cho admin: DAU/WAU/MAU, doanh thu, retention, engagement, search và health widgets.',
    )
    .addTag(
      'Admin Logs',
      'Audit trail cho hành động admin: tạo, sửa, xoá nội dung, user, session và job.',
    )
    .addTag(
      'Weather',
      'Thời tiết hiện tại theo vị trí/timezone để hiển thị lời chào ở màn hình home.',
    )
    .addTag(
      'Notifications',
      'Thông báo trong app, device token push, provider readiness cho FCM/APNs/Expo và mark read.',
    )
    .addTag(
      'Reminders',
      'Nhắc lịch uống nước, nghỉ mắt, thở, journal, ngủ hoặc custom theo người dùng.',
    )
    .addTag(
      'Jobs',
      'Job backend định kỳ hoặc chạy tay, ví dụ materialize WeeklyMoodStat.',
    )
    .addTag(
      'Billing',
      'Nạp thẻ/nâng cấp: subscription, payment pending và trạng thái provider thanh toán.',
    )
    .addTag(
      'Health',
      'Kiểm tra tình trạng backend, database, storage và cấu hình hạ tầng.',
    )
    .addTag(
      'Redis',
      'Redis cache/session/queue infrastructure: kiểm tra cấu hình và kết nối PING.',
    )
    .addTag(
      'Realtime',
      'Socket.IO realtime cho app: namespace /realtime, auth bằng JWT và Redis adapter để scale nhiều instance.',
    )
    .addTag(
      'Queues',
      'BullMQ queue nền Redis cho job nặng, worker sau này và kiểm tra queue health.',
    )
    .addTag(
      'Storage',
      'Supabase Storage: kiểm tra kết nối bucket, tạo URL public/signed và metadata file.',
    )
    .addTag('App Themes', 'Kho theme giao diện light/dark/custom cho app.')
    .addTag(
      'Onboarding Slides',
      'Kho slide onboarding/intro khi người dùng mới vào app.',
    )
    .addTag(
      'Companion Assets',
      'Kho asset pet/companion như pixel cat, icon, ảnh trạng thái và default asset.',
    )
    .addTag(
      'Companion Messages',
      'Kho câu nói của pet, random message và message theo ngữ cảnh.',
    )
    .addTag(
      'Ambient Sounds',
      'Kho âm thanh thư giãn, nhạc nền và lọc theo category.',
    )
    .addTag(
      'Breathing Exercises',
      'Kho bài tập thở mẫu, nhịp thở và hướng dẫn breathing.',
    )
    .addTag(
      'Cozy Quotes',
      'Kho quote chữa lành, quote random và quote theo mood.',
    )
    .build();
  const swaggerEnabled = shouldEnableSwagger(configService);
  if (swaggerEnabled) {
    setupSwaggerProtection(app, configService);
    const swaggerDocument = SwaggerModule.createDocument(app, swaggerConfig);
    applyErrorDocumentation(swaggerDocument);
    applyExampleDocumentation(swaggerDocument);
    SwaggerModule.setup('docs', app, swaggerDocument, {
      jsonDocumentUrl: 'docs-json',
      swaggerUrl: '/docs-json',
      swaggerOptions: {
        persistAuthorization: true,
        operationsSorter: 'method',
      },
      customSiteTitle: 'Digital Cigarette Break API Docs',
    });
  }

  const realtimeService = app.get(RealtimeService);
  const websocketAdapter = new RedisIoAdapter(app, configService);
  const realtimeAdapterStatus = await websocketAdapter.connectToRedis();
  realtimeService.setAdapterStatus(realtimeAdapterStatus);
  app.useWebSocketAdapter(websocketAdapter);

  const prismaService = app.get(PrismaService);
  prismaService.enableShutdownHooks(app);

  const port = configService.get<number>('app.port') ?? 6823;
  await app.listen(port);
  const logger = new NestLogger('Bootstrap');
  logger.log(`Server is running on http://localhost:${port}`);
  if (swaggerEnabled) {
    logger.log(`Swagger docs available at http://localhost:${port}/docs`);
  }
}

void bootstrap();

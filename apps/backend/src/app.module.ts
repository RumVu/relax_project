import { Module } from '@nestjs/common';
import { APP_GUARD, APP_INTERCEPTOR } from '@nestjs/core';
import { minutes, ThrottlerGuard, ThrottlerModule } from '@nestjs/throttler';
import { LoggerModule } from 'nestjs-pino';
import { randomUUID } from 'node:crypto';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { ConfigModule, ConfigService } from '@nestjs/config';
import appConfig from './config/app.config';
import authConfig from './config/auth.config';
import { validateEnv } from './config/env.validation';
import prismaConfig from './config/prisma.config';
import queueConfig from './config/queue.config';
import redisConfig from './config/redis.config';
import storageConfig from './config/storage.config';
import { RedisThrottlerStorage } from './common/rate-limit/redis-throttler-storage';
import { PrismaModule } from './prisma/prisma.module';
import { RedisModule } from './redis/redis.module';
import { EmailModule } from './email/email.module';
import { AiInsightsModule } from './ai-insights/ai-insights.module';
import { AdminPricingModule } from './admin-pricing/admin-pricing.module';
import { QuestsModule } from './quests/quests.module';
import { RedisService } from './redis/redis.service';
import { QueuesModule } from './queues/queues.module';
import { RealtimeModule } from './realtime/realtime.module';
import { AmbientSoundsModule } from './ambient-sounds/ambient-sounds.module';
import { AppThemesModule } from './app-themes/app-themes.module';
import { BreathingExercisesModule } from './breathing-exercises/breathing-exercises.module';
import { CompanionAssetsModule } from './companion-assets/companion-assets.module';
import { CompanionMessagesModule } from './companion-messages/companion-messages.module';
import { CozyQuotesModule } from './cozy-quotes/cozy-quotes.module';
import { OnboardingSlidesModule } from './onboarding-slides/onboarding-slides.module';
import { StorageModule } from './storage/storage.module';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { UserProfilesModule } from './user-profiles/user-profiles.module';
import { UserPreferencesModule } from './user-preferences/user-preferences.module';
import { SessionsModule } from './sessions/sessions.module';
import { MoodCheckinsModule } from './mood-checkins/mood-checkins.module';
import { RelaxActivitiesModule } from './relax-activities/relax-activities.module';
import { RelaxSessionsModule } from './relax-sessions/relax-sessions.module';
import { JournalsModule } from './journals/journals.module';
import { UserCompanionsModule } from './user-companions/user-companions.module';
import { AnalyticsModule } from './analytics/analytics.module';
import { WeatherModule } from './weather/weather.module';
import { NotificationsModule } from './notifications/notifications.module';
import { RemindersModule } from './reminders/reminders.module';
import { JobsModule } from './jobs/jobs.module';
import { BillingModule } from './billing/billing.module';
import { AdminDashboardModule } from './admin-dashboard/admin-dashboard.module';
import { AdminAuditInterceptor } from './admin-logs/admin-audit.interceptor';
import { AdminLogsModule } from './admin-logs/admin-logs.module';

@Module({
  imports: [
    LoggerModule.forRoot({
      pinoHttp: {
        level:
          process.env.LOG_LEVEL ??
          (process.env.NODE_ENV === 'production' ? 'info' : 'debug'),
        genReqId: (req, res) => {
          const existing =
            req.headers['x-request-id'] ?? req.headers['x-correlation-id'];
          const requestId = Array.isArray(existing)
            ? (existing[0] ?? randomUUID())
            : (existing ?? randomUUID());

          res.setHeader('x-request-id', requestId);
          return requestId;
        },
        redact: {
          paths: [
            'req.headers.authorization',
            'req.headers.cookie',
            'req.body.password',
            'req.body.token',
            'req.body.refreshToken',
            'req.body.accessToken',
          ],
          censor: '[REDACTED]',
        },
      },
    }),
    ConfigModule.forRoot({
      isGlobal: true,
      load: [
        appConfig,
        authConfig,
        prismaConfig,
        queueConfig,
        redisConfig,
        storageConfig,
      ],
      envFilePath: ['apps/backend/.env', '.env'],
      validate: validateEnv,
    }),
    PrismaModule,
    RedisModule,
    EmailModule,
    ThrottlerModule.forRootAsync({
      imports: [RedisModule],
      inject: [RedisService, ConfigService],
      useFactory: (
        redisService: RedisService,
        configService: ConfigService,
      ) => ({
        storage: new RedisThrottlerStorage(redisService),
        skipIf: () => configService.get<string>('app.nodeEnv') === 'test',
        throttlers: [
          {
            ttl: minutes(1),
            limit: 300,
            blockDuration: minutes(1),
          },
        ],
      }),
    }),
    QueuesModule,
    RealtimeModule,
    StorageModule,
    UsersModule,
    AuthModule,
    UserProfilesModule,
    UserPreferencesModule,
    SessionsModule,
    MoodCheckinsModule,
    AiInsightsModule,
    RelaxActivitiesModule,
    RelaxSessionsModule,
    JournalsModule,
    UserCompanionsModule,
    AnalyticsModule,
    WeatherModule,
    NotificationsModule,
    RemindersModule,
    JobsModule,
    BillingModule,
    AdminPricingModule,
    QuestsModule,
    AdminDashboardModule,
    AdminLogsModule,
    AppThemesModule,
    OnboardingSlidesModule,
    CompanionAssetsModule,
    CompanionMessagesModule,
    AmbientSoundsModule,
    BreathingExercisesModule,
    CozyQuotesModule,
  ],
  controllers: [AppController],
  providers: [
    AppService,
    {
      provide: APP_GUARD,
      useClass: ThrottlerGuard,
    },
    {
      provide: APP_INTERCEPTOR,
      useClass: AdminAuditInterceptor,
    },
  ],
})
export class AppModule {}

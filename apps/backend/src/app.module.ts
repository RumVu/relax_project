import { Module } from '@nestjs/common';
import { APP_GUARD } from '@nestjs/core';
import { minutes, ThrottlerGuard, ThrottlerModule } from '@nestjs/throttler';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { ConfigModule } from '@nestjs/config';
import appConfig from './config/app.config';
import authConfig from './config/auth.config';
import { validateEnv } from './config/env.validation';
import prismaConfig from './config/prisma.config';
import storageConfig from './config/storage.config';
import { PrismaModule } from './prisma/prisma.module';
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
import { JobsModule } from './jobs/jobs.module';
import { BillingModule } from './billing/billing.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      load: [appConfig, authConfig, prismaConfig, storageConfig],
      envFilePath: ['apps/backend/.env', '.env'],
      validate: validateEnv,
    }),
    ThrottlerModule.forRoot([
      {
        ttl: minutes(1),
        limit: 300,
      },
    ]),
    PrismaModule,
    StorageModule,
    UsersModule,
    AuthModule,
    UserProfilesModule,
    UserPreferencesModule,
    SessionsModule,
    MoodCheckinsModule,
    RelaxActivitiesModule,
    RelaxSessionsModule,
    JournalsModule,
    UserCompanionsModule,
    AnalyticsModule,
    WeatherModule,
    NotificationsModule,
    JobsModule,
    BillingModule,
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
  ],
})
export class AppModule {}

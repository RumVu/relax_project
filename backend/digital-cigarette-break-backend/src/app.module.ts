import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { APP_FILTER } from '@nestjs/core';
import { LoggerModule } from 'nestjs-pino';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { AuthModule } from './auth/auth.module';
import { BreakSessionsModule } from './break-sessions/break-sessions.module';
import { PrismaExceptionFilter } from './common/filters/prisma-exception.filter';
import { validateEnv } from './config/env.validation';
import prismaConfig from './config/prisma.config';
import { HealthModule } from './health/health.module';
import { JournalsModule } from './journals/journals.module';
import { MoodsModule } from './moods/moods.module';
import { PrismaModule } from './prisma/prisma.module';
import { UsersModule } from './users/users.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      load: [prismaConfig],
      envFilePath: ['.env'],
      validate: validateEnv,
    }),
    LoggerModule.forRoot(),
    PrismaModule,
    AuthModule,
    UsersModule,
    MoodsModule,
    BreakSessionsModule,
    JournalsModule,
    HealthModule,
  ],
  controllers: [AppController],
  providers: [
    AppService,
    {
      provide: APP_FILTER,
      useClass: PrismaExceptionFilter,
    },
  ],
})
export class AppModule {}

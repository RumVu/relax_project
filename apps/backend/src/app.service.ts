import { Injectable, Inject, Optional } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from './prisma/prisma.service';
import { RedisService } from './redis/redis.service';
import { QueuesService } from './queues/queues.service';

export interface ApiIndexResponse {
  name: string;
  status: 'ok';
  version: string;
  docs: {
    swagger: string;
    openApiJson: string;
  };
  health: string;
}

export interface HealthResponse {
  status: 'ok';
  timestamp: string;
  uptimeSeconds: number;
}

export interface ReadyResponse {
  status: 'ok' | 'degraded';
  timestamp: string;
  checks: {
    database: {
      ok: boolean;
      latencyMs?: number;
      error?: string;
    };
    storage: {
      configured: boolean;
      bucket?: string;
    };
  };
}

@Injectable()
export class AppService {
  constructor(
    private readonly configService: ConfigService,
    private readonly prisma: PrismaService,
    @Optional() @Inject(RedisService) private readonly redis?: RedisService,
    @Optional() @Inject(QueuesService) private readonly queues?: QueuesService,
  ) {}

  getApiIndex(): ApiIndexResponse {
    return {
      name: 'Digital Cigarette Break API',
      status: 'ok',
      version: this.configService.get<string>('app.version') ?? '1.0.0',
      docs: {
        swagger: '/docs',
        openApiJson: '/docs-json',
      },
      health: '/health',
    };
  }

  getHealth(): HealthResponse {
    return {
      status: 'ok',
      timestamp: new Date().toISOString(),
      uptimeSeconds: Math.round(process.uptime()),
    };
  }

  async getReady(): Promise<ReadyResponse> {
    const startedAt = Date.now();
    const database: ReadyResponse['checks']['database'] = { ok: false };

    try {
      await this.prisma.$queryRaw`SELECT 1`;
      database.ok = true;
      database.latencyMs = Date.now() - startedAt;
    } catch (error) {
      database.error =
        error instanceof Error ? error.message : 'Database check failed';
    }

    const bucket = this.configService.get<string>('storage.supabaseBucket');
    const storageConfigured = Boolean(
      this.configService.get<string>('storage.supabaseUrl') &&
      this.configService.get<string>('storage.supabasePublishableKey') &&
      bucket,
    );

    return {
      status: database.ok ? 'ok' : 'degraded',
      timestamp: new Date().toISOString(),
      checks: {
        database,
        storage: {
          configured: storageConfigured,
          bucket,
        },
      },
    };
  }

  async getOpsStatus() {
    const dbStart = Date.now();
    let dbOk = false;
    let dbLatency = 0;
    try {
      await this.prisma.$queryRaw`SELECT 1`;
      dbOk = true;
      dbLatency = Date.now() - dbStart;
    } catch { /* */ }

    const redisHealth = this.redis ? await this.redis.ping().catch(() => ({
      connected: false, configured: false, enabled: false, latencyMs: null,
    })) : { connected: false, configured: false, enabled: false, latencyMs: null };

    const queueStatus = this.queues ? this.queues.getStatus() : {
      configured: false, enabled: false, registeredQueues: [],
    };

    const bucket = this.configService.get<string>('storage.supabaseBucket');
    const pushConfigured = Boolean(this.configService.get<string>('FCM_SERVER_KEY') || this.configService.get<string>('FIREBASE_SERVICE_ACCOUNT'));
    const emailConfigured = Boolean(this.configService.get<string>('SMTP_HOST') || this.configService.get<string>('SENDGRID_API_KEY'));
    const billingConfigured = Boolean(this.configService.get<string>('STRIPE_SECRET_KEY'));

    let userCount = 0;
    let activeToday = 0;
    let lastWeeklyJob: { success: boolean; processedUsers: number; failedUsers: number; ranAt: string } | null = null;
    try {
      userCount = await this.prisma.user.count({ where: { isActive: true, deletedAt: null } });
      const todayStart = new Date(); todayStart.setHours(0, 0, 0, 0);
      activeToday = await this.prisma.moodCheckin.groupBy({
        by: ['userId'],
        where: { createdAt: { gte: todayStart } },
      }).then(r => r.length);
    } catch { /* */ }

    try {
      const latest = await this.prisma.weeklyMoodStat.findFirst({ orderBy: { createdAt: 'desc' } });
      if (latest) {
        lastWeeklyJob = {
          success: true,
          processedUsers: await this.prisma.weeklyMoodStat.count({ where: { weekStart: latest.weekStart } }),
          failedUsers: 0,
          ranAt: latest.createdAt.toISOString(),
        };
      }
    } catch { /* */ }

    return {
      status: dbOk ? 'ok' : 'degraded',
      timestamp: new Date().toISOString(),
      uptimeSeconds: Math.round(process.uptime()),
      api: { status: 'online' },
      database: { connected: dbOk, latencyMs: dbLatency },
      redis: {
        connected: (redisHealth as any).connected ?? false,
        configured: (redisHealth as any).configured ?? false,
        latencyMs: (redisHealth as any).latencyMs ?? null,
      },
      queue: {
        configured: (queueStatus as any).configured ?? false,
        enabled: (queueStatus as any).enabled ?? false,
        registeredQueues: (queueStatus as any).registeredQueues ?? [],
      },
      providers: {
        push: { ready: pushConfigured },
        email: { ready: emailConfigured },
        billing: { ready: billingConfigured },
        storage: { ready: Boolean(bucket), bucket },
      },
      users: { total: userCount, activeToday },
      lastWeeklyStatsJob: lastWeeklyJob,
    };
  }
}

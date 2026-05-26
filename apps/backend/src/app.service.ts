import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from './prisma/prisma.service';

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
}

import { Logger } from '@nestjs/common';
import type { INestApplicationContext } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { IoAdapter } from '@nestjs/platform-socket.io';
import { createAdapter } from '@socket.io/redis-adapter';
import Redis from 'ioredis';
import type { Server } from 'socket.io';
import type { ServerOptions } from 'socket.io';

export interface RealtimeAdapterStatus {
  provider: 'socket.io';
  namespace: '/realtime';
  mode: 'redis' | 'memory';
  redisConfigured: boolean;
  redisConnected: boolean;
  error?: string;
}

export class RedisIoAdapter extends IoAdapter {
  private readonly logger = new Logger(RedisIoAdapter.name);
  private adapterConstructor?: ReturnType<typeof createAdapter>;
  private pubClient?: Redis;
  private subClient?: Redis;

  constructor(
    app: INestApplicationContext,
    private readonly configService: ConfigService,
  ) {
    super(app);
  }

  async connectToRedis(): Promise<RealtimeAdapterStatus> {
    if (!this.redisEnabled) {
      return {
        provider: 'socket.io',
        namespace: '/realtime',
        mode: 'memory',
        redisConfigured: false,
        redisConnected: false,
        error: 'Redis is disabled by REDIS_ENABLED=false.',
      };
    }

    try {
      this.pubClient = new Redis(this.redisUrl, {
        lazyConnect: true,
        enableOfflineQueue: false,
        maxRetriesPerRequest: 1,
        retryStrategy: (attempt) => Math.min(attempt * 50, 500),
      });
      this.subClient = this.pubClient.duplicate();

      await Promise.all([
        this.withTimeout(this.pubClient.connect(), 1000),
        this.withTimeout(this.subClient.connect(), 1000),
      ]);
      await this.withTimeout(this.pubClient.ping(), 1000);

      this.adapterConstructor = createAdapter(this.pubClient, this.subClient);
      this.logger.log('Socket.IO Redis adapter connected');

      return {
        provider: 'socket.io',
        namespace: '/realtime',
        mode: 'redis',
        redisConfigured: true,
        redisConnected: true,
      };
    } catch (error) {
      this.disconnectRedisClients();
      const message = this.errorMessage(error);
      this.logger.warn(
        `Socket.IO Redis adapter unavailable, falling back to memory adapter: ${message}`,
      );

      return {
        provider: 'socket.io',
        namespace: '/realtime',
        mode: 'memory',
        redisConfigured: true,
        redisConnected: false,
        error: message,
      };
    }
  }

  createIOServer(port: number, options?: ServerOptions): Server {
    const createdServer: unknown = super.createIOServer(port, {
      ...options,
      cors: {
        ...options?.cors,
        origin: (
          origin: string | undefined,
          callback: (err: Error | null, success?: boolean) => void,
        ) => callback(null, this.isAllowedOrigin(origin)),
        credentials: true,
      },
    });
    const server = createdServer as Server;

    if (this.adapterConstructor) {
      server.adapter(this.adapterConstructor);
    }

    return server;
  }

  private get redisEnabled() {
    return this.configService.get<boolean>('redis.enabled') ?? true;
  }

  private get redisUrl() {
    return (
      this.configService.get<string>('redis.url') ?? 'redis://localhost:6379'
    );
  }

  private get nodeEnv() {
    return this.configService.get<string>('app.nodeEnv') ?? 'development';
  }

  private get allowedOrigins() {
    return (this.configService.get<string>('app.corsOrigins') ?? '')
      .split(',')
      .map((origin) => origin.trim())
      .filter(Boolean);
  }

  private isAllowedOrigin(origin?: string) {
    if (!origin) {
      return true;
    }

    if (this.allowedOrigins.includes(origin)) {
      return true;
    }

    return (
      this.nodeEnv !== 'production' &&
      /^https?:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/.test(origin)
    );
  }

  private async withTimeout<T>(promise: Promise<T>, timeoutMs: number) {
    let timeout: NodeJS.Timeout | undefined;
    try {
      return await Promise.race([
        promise,
        new Promise<never>((_, reject) => {
          timeout = setTimeout(
            () => reject(new Error(`Timed out after ${timeoutMs}ms.`)),
            timeoutMs,
          );
        }),
      ]);
    } finally {
      if (timeout) {
        clearTimeout(timeout);
      }
    }
  }

  private disconnectRedisClients() {
    this.pubClient?.disconnect();
    this.subClient?.disconnect();
    this.pubClient = undefined;
    this.subClient = undefined;
    this.adapterConstructor = undefined;
  }

  private errorMessage(error: unknown) {
    if (error instanceof Error) {
      return error.message;
    }
    return String(error);
  }
}

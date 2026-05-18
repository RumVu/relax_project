import { Injectable, Logger, OnModuleDestroy } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import Redis from 'ioredis';

export interface RedisStatus {
  configured: boolean;
  enabled: boolean;
  provider: 'redis';
  url: string;
  keyPrefix: string;
  defaultTtlSeconds: number;
}

export interface RedisHealth extends RedisStatus {
  connected: boolean;
  latencyMs: number | null;
  error?: string;
}

@Injectable()
export class RedisService implements OnModuleDestroy {
  private readonly logger = new Logger(RedisService.name);
  private client: Redis | null = null;

  constructor(private readonly configService: ConfigService) {}

  getStatus(): RedisStatus {
    return {
      configured: Boolean(this.url),
      enabled: this.enabled,
      provider: 'redis',
      url: this.maskUrl(this.url),
      keyPrefix: this.keyPrefix,
      defaultTtlSeconds: this.defaultTtlSeconds,
    };
  }

  async ping(): Promise<RedisHealth> {
    const startedAt = Date.now();

    if (!this.enabled) {
      return {
        ...this.getStatus(),
        connected: false,
        latencyMs: null,
        error: 'Redis is disabled by REDIS_ENABLED=false.',
      };
    }

    try {
      const client = await this.ensureConnected();
      const pong = await this.withTimeout(client.ping(), 1000);

      return {
        ...this.getStatus(),
        connected: pong === 'PONG',
        latencyMs: Date.now() - startedAt,
      };
    } catch (error) {
      return {
        ...this.getStatus(),
        connected: false,
        latencyMs: null,
        error: this.errorMessage(error),
      };
    }
  }

  async get(key: string): Promise<string | null> {
    try {
      const client = await this.ensureConnected();
      return client.get(key);
    } catch (error) {
      this.warn('Redis get failed', error);
      return null;
    }
  }

  async set(
    key: string,
    value: string,
    ttlSeconds = this.defaultTtlSeconds,
  ): Promise<boolean> {
    try {
      const client = await this.ensureConnected();
      if (ttlSeconds > 0) {
        await client.set(key, value, 'EX', ttlSeconds);
      } else {
        await client.set(key, value);
      }
      return true;
    } catch (error) {
      this.warn('Redis set failed', error);
      return false;
    }
  }

  async del(...keys: string[]): Promise<number> {
    if (keys.length === 0) {
      return 0;
    }

    try {
      const client = await this.ensureConnected();
      return client.del(...keys);
    } catch (error) {
      this.warn('Redis delete failed', error);
      return 0;
    }
  }

  async getJson<T>(key: string): Promise<T | null> {
    const value = await this.get(key);
    if (!value) {
      return null;
    }

    try {
      return JSON.parse(value) as T;
    } catch (error) {
      this.warn(`Redis JSON parse failed for key ${key}`, error);
      return null;
    }
  }

  async setJson<T>(
    key: string,
    value: T,
    ttlSeconds = this.defaultTtlSeconds,
  ): Promise<boolean> {
    return this.set(key, JSON.stringify(value), ttlSeconds);
  }

  async remember<T>(
    key: string,
    ttlSeconds: number,
    factory: () => Promise<T>,
  ): Promise<T> {
    const cached = await this.getJson<T>(key);
    if (cached !== null) {
      return cached;
    }

    const value = await factory();
    await this.setJson(key, value, ttlSeconds);
    return value;
  }

  onModuleDestroy() {
    if (this.client) {
      this.client.disconnect();
      this.client = null;
    }
  }

  private get enabled() {
    return this.configService.get<boolean>('redis.enabled') ?? true;
  }

  private get url() {
    return (
      this.configService.get<string>('redis.url') ?? 'redis://localhost:6379'
    );
  }

  private get keyPrefix() {
    return this.configService.get<string>('redis.keyPrefix') ?? 'dcb:';
  }

  private get defaultTtlSeconds() {
    return this.configService.get<number>('redis.defaultTtlSeconds') ?? 300;
  }

  private getClient() {
    if (!this.client) {
      this.client = new Redis(this.url, {
        lazyConnect: true,
        enableOfflineQueue: false,
        maxRetriesPerRequest: 1,
        keyPrefix: this.keyPrefix,
        retryStrategy: (attempt) => Math.min(attempt * 50, 500),
      });
      this.client.on('error', (error) => {
        this.logger.debug(`Redis client error: ${this.errorMessage(error)}`);
      });
    }

    return this.client;
  }

  private async ensureConnected() {
    if (!this.enabled) {
      throw new Error('Redis is disabled by REDIS_ENABLED=false.');
    }

    const client = this.getClient();
    if (client.status === 'ready') {
      return client;
    }

    await this.withTimeout(client.connect(), 1000);
    return client;
  }

  private async withTimeout<T>(promise: Promise<T>, timeoutMs: number) {
    let timeout: NodeJS.Timeout | undefined;
    try {
      return await Promise.race([
        promise,
        new Promise<never>((_, reject) => {
          timeout = setTimeout(
            () => reject(new Error(`Redis timed out after ${timeoutMs}ms.`)),
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

  private maskUrl(value: string) {
    try {
      const parsed = new URL(value);
      const auth = parsed.username || parsed.password ? '***@' : '';
      const db =
        parsed.pathname && parsed.pathname !== '/' ? parsed.pathname : '';
      return `${parsed.protocol}//${auth}${parsed.host}${db}`;
    } catch {
      return 'invalid-url';
    }
  }

  private warn(message: string, error: unknown) {
    this.logger.warn(`${message}: ${this.errorMessage(error)}`);
  }

  private errorMessage(error: unknown) {
    if (error instanceof Error) {
      return error.message;
    }
    return String(error);
  }
}

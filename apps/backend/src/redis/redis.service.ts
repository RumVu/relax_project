import { Injectable, Logger, OnModuleDestroy } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import type { ThrottlerStorageRecord } from '@nestjs/throttler/dist/throttler-storage-record.interface';
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

interface LocalThrottleBucket {
  totalHits: number;
  expiresAt: number;
  blockedUntil: number;
}

@Injectable()
export class RedisService implements OnModuleDestroy {
  private readonly logger = new Logger(RedisService.name);
  private client: Redis | null = null;
  private connectPromise: Promise<Redis> | null = null;
  private readonly localThrottleBuckets = new Map<
    string,
    LocalThrottleBucket
  >();

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

  async acquireLock(
    key: string,
    value: string,
    ttlSeconds = this.defaultTtlSeconds,
  ): Promise<boolean> {
    try {
      const client = await this.ensureConnected();
      const result = await client.set(key, value, 'EX', ttlSeconds, 'NX');
      return result === 'OK';
    } catch (error) {
      this.warn('Redis lock acquire failed', error);
      return false;
    }
  }

  async releaseLock(key: string, value: string): Promise<boolean> {
    try {
      const client = await this.ensureConnected();
      const released = await client.eval(
        "if redis.call('GET', KEYS[1]) == ARGV[1] then return redis.call('DEL', KEYS[1]) else return 0 end",
        1,
        key,
        value,
      );
      return released === 1;
    } catch (error) {
      this.warn('Redis lock release failed', error);
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

  async incrementThrottle(
    key: string,
    ttlMs: number,
    limit: number,
    blockDurationMs: number,
    throttlerName: string,
  ): Promise<ThrottlerStorageRecord> {
    try {
      const client = await this.ensureConnected();
      const baseKey = `throttle:${throttlerName}:${key}`;
      const blockKey = `${baseKey}:blocked`;
      const [totalHits, timeToExpireMs, blocked, timeToBlockExpireMs] =
        (await client.eval(
          [
            'local baseKey = KEYS[1]',
            'local blockKey = KEYS[2]',
            'local ttlMs = tonumber(ARGV[1])',
            'local limit = tonumber(ARGV[2])',
            'local blockDurationMs = tonumber(ARGV[3])',
            "local blockTtl = redis.call('PTTL', blockKey)",
            'if blockTtl > 0 then',
            "  local hits = tonumber(redis.call('GET', baseKey) or (limit + 1))",
            "  local ttl = redis.call('PTTL', baseKey)",
            '  return { hits, ttl, 1, blockTtl }',
            'end',
            "local hits = redis.call('INCR', baseKey)",
            'if hits == 1 then',
            "  redis.call('PEXPIRE', baseKey, ttlMs)",
            'end',
            "local ttl = redis.call('PTTL', baseKey)",
            'if hits > limit then',
            "  redis.call('SET', blockKey, '1', 'PX', blockDurationMs)",
            '  return { hits, ttl, 1, blockDurationMs }',
            'end',
            'return { hits, ttl, 0, 0 }',
          ].join('\n'),
          2,
          baseKey,
          blockKey,
          ttlMs,
          limit,
          blockDurationMs,
        )) as [number, number, 0 | 1, number];

      return {
        totalHits,
        timeToExpire: this.msToSeconds(timeToExpireMs),
        isBlocked: blocked === 1,
        timeToBlockExpire: this.msToSeconds(timeToBlockExpireMs),
      };
    } catch (error) {
      this.warn('Redis throttle increment failed', error);
      return this.incrementLocalThrottle(
        key,
        ttlMs,
        limit,
        blockDurationMs,
        throttlerName,
      );
    }
  }

  onModuleDestroy() {
    if (this.client) {
      this.client.disconnect();
      this.client = null;
      this.connectPromise = null;
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

    if (this.connectPromise) {
      return this.connectPromise;
    }

    if (this.isConnecting(client.status)) {
      await this.waitUntilReady(client, 1000);
      return client;
    }

    this.connectPromise = this.withTimeout(client.connect(), 1000)
      .then(() => client)
      .finally(() => {
        this.connectPromise = null;
      });

    return this.connectPromise;
  }

  private isConnecting(status: string) {
    return (
      status === 'connecting' ||
      status === 'connect' ||
      status === 'reconnecting'
    );
  }

  private waitUntilReady(client: Redis, timeoutMs: number) {
    if (client.status === 'ready') {
      return Promise.resolve();
    }

    return this.withTimeout(
      new Promise<void>((resolve, reject) => {
        const cleanup = () => {
          client.off('ready', onReady);
          client.off('error', onError);
        };
        const onReady = () => {
          cleanup();
          resolve();
        };
        const onError = (error: Error) => {
          cleanup();
          reject(error);
        };

        client.once('ready', onReady);
        client.once('error', onError);
      }),
      timeoutMs,
    );
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

  private incrementLocalThrottle(
    key: string,
    ttlMs: number,
    limit: number,
    blockDurationMs: number,
    throttlerName: string,
  ): ThrottlerStorageRecord {
    this.cleanupLocalThrottleBuckets();

    const now = Date.now();
    const localKey = `${throttlerName}:${key}`;
    const existing = this.localThrottleBuckets.get(localKey);

    if (existing && existing.blockedUntil > now) {
      return {
        totalHits: existing.totalHits,
        timeToExpire: this.msToSeconds(existing.expiresAt - now),
        isBlocked: true,
        timeToBlockExpire: this.msToSeconds(existing.blockedUntil - now),
      };
    }

    const bucket =
      existing && existing.expiresAt > now
        ? existing
        : {
            totalHits: 0,
            expiresAt: now + ttlMs,
            blockedUntil: 0,
          };

    bucket.totalHits += 1;
    if (bucket.totalHits > limit) {
      bucket.blockedUntil = now + blockDurationMs;
    }

    this.localThrottleBuckets.set(localKey, bucket);

    return {
      totalHits: bucket.totalHits,
      timeToExpire: this.msToSeconds(bucket.expiresAt - now),
      isBlocked: bucket.blockedUntil > now,
      timeToBlockExpire: this.msToSeconds(bucket.blockedUntil - now),
    };
  }

  private cleanupLocalThrottleBuckets() {
    const now = Date.now();

    for (const [key, bucket] of this.localThrottleBuckets) {
      if (bucket.expiresAt <= now && bucket.blockedUntil <= now) {
        this.localThrottleBuckets.delete(key);
      }
    }
  }

  private msToSeconds(value: number) {
    return Math.max(0, Math.ceil(value / 1000));
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

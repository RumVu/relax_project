import { Injectable, Logger, OnModuleDestroy } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Job, Queue, Worker } from 'bullmq';
import type { JobsOptions, Processor, WorkerOptions } from 'bullmq';
import Redis from 'ioredis';
import type { RedisOptions } from 'ioredis';

export interface QueueStatus {
  configured: boolean;
  enabled: boolean;
  provider: 'bullmq';
  redisUrl: string;
  prefix: string;
  defaultAttempts: number;
  backoffDelayMs: number;
  registeredQueues: string[];
}

export interface QueueHealth extends QueueStatus {
  connected: boolean;
  latencyMs: number | null;
  error?: string;
}

@Injectable()
export class QueuesService implements OnModuleDestroy {
  private readonly logger = new Logger(QueuesService.name);
  private readonly queues = new Map<string, Queue>();

  constructor(private readonly configService: ConfigService) {}

  getStatus(): QueueStatus {
    return {
      configured: Boolean(this.redisUrl),
      enabled: this.enabled,
      provider: 'bullmq',
      redisUrl: this.maskUrl(this.redisUrl),
      prefix: this.prefix,
      defaultAttempts: this.defaultAttempts,
      backoffDelayMs: this.backoffDelayMs,
      registeredQueues: [...this.queues.keys()],
    };
  }

  async health(deep = false): Promise<QueueStatus | QueueHealth> {
    if (!deep) {
      return this.getStatus();
    }

    const startedAt = Date.now();
    const client = new Redis(this.redisUrl, {
      lazyConnect: true,
      enableOfflineQueue: false,
      maxRetriesPerRequest: 1,
    });

    if (!this.enabled) {
      return {
        ...this.getStatus(),
        connected: false,
        latencyMs: null,
        error: 'Queues are disabled by QUEUE_ENABLED=false.',
      };
    }

    try {
      await this.withTimeout(client.connect(), 1000);
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
    } finally {
      client.disconnect();
    }
  }

  async add<DataType, NameType extends string = string>(
    queueName: string,
    jobName: NameType,
    data: DataType,
    options?: JobsOptions,
  ) {
    if (!this.enabled) {
      return {
        queued: false,
        queue: queueName,
        jobName,
        jobId: null,
        reason: 'Queues are disabled by QUEUE_ENABLED=false.',
      };
    }

    const queue = this.getQueue<DataType, NameType>(queueName);
    const job = await queue.add(jobName, data, options);

    return {
      queued: true,
      queue: queueName,
      jobName,
      jobId: String(job.id),
    };
  }

  createWorker<DataType, ResultType>(
    queueName: string,
    processor: Processor<DataType, ResultType, string>,
    options?: Pick<WorkerOptions, 'concurrency'>,
  ) {
    if (!this.enabled) {
      throw new Error('Queues are disabled by QUEUE_ENABLED=false.');
    }

    const worker = new Worker<DataType, ResultType, string>(
      queueName,
      processor,
      {
        connection: this.connectionOptions,
        prefix: this.prefix,
        ...options,
      },
    );

    worker.on(
      'failed',
      (job: Job<DataType, ResultType, string> | undefined, error) => {
        this.logger.warn(
          `Queue job failed in ${queueName}/${job?.name ?? 'unknown'}: ${this.errorMessage(error)}`,
        );
      },
    );

    return worker;
  }

  async onModuleDestroy() {
    await Promise.all([...this.queues.values()].map((queue) => queue.close()));
    this.queues.clear();
  }

  private getQueue<DataType, NameType extends string = string>(
    queueName: string,
  ) {
    const existingQueue = this.queues.get(queueName);
    if (existingQueue) {
      return existingQueue as Queue<
        DataType,
        unknown,
        NameType,
        DataType,
        unknown,
        NameType
      >;
    }

    const queue = new Queue<
      DataType,
      unknown,
      NameType,
      DataType,
      unknown,
      NameType
    >(queueName, {
      connection: this.connectionOptions,
      prefix: this.prefix,
      defaultJobOptions: {
        attempts: this.defaultAttempts,
        backoff: {
          type: 'exponential',
          delay: this.backoffDelayMs,
        },
        removeOnComplete: 1000,
        removeOnFail: 1000,
      },
    });

    this.queues.set(queueName, queue);
    return queue;
  }

  private get enabled() {
    return this.configService.get<boolean>('queue.enabled') ?? true;
  }

  private get redisUrl() {
    return (
      this.configService.get<string>('redis.url') ?? 'redis://localhost:6379'
    );
  }

  private get prefix() {
    return this.configService.get<string>('queue.prefix') ?? 'dcb';
  }

  private get defaultAttempts() {
    return this.configService.get<number>('queue.defaultAttempts') ?? 3;
  }

  private get backoffDelayMs() {
    return this.configService.get<number>('queue.backoffDelayMs') ?? 1000;
  }

  private get connectionOptions(): RedisOptions {
    const parsed = new URL(this.redisUrl);
    const db = parsed.pathname ? Number(parsed.pathname.slice(1)) : 0;

    return {
      host: parsed.hostname,
      port: Number(parsed.port || 6379),
      username: parsed.username
        ? decodeURIComponent(parsed.username)
        : undefined,
      password: parsed.password
        ? decodeURIComponent(parsed.password)
        : undefined,
      db: Number.isNaN(db) ? 0 : db,
      maxRetriesPerRequest: null,
    };
  }

  private async withTimeout<T>(promise: Promise<T>, timeoutMs: number) {
    let timeout: NodeJS.Timeout | undefined;
    try {
      return await Promise.race([
        promise,
        new Promise<never>((_, reject) => {
          timeout = setTimeout(
            () =>
              reject(new Error(`Queue Redis timed out after ${timeoutMs}ms.`)),
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

  private errorMessage(error: unknown) {
    if (error instanceof Error) {
      return error.message;
    }
    return String(error);
  }
}

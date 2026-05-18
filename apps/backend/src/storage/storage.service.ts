import {
  HttpStatus,
  Injectable,
  ServiceUnavailableException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Prisma } from '@prisma/client';
import { createClient, SupabaseClient } from '@supabase/supabase-js';
import { AppException } from '../common/errors/app.exception';
import { ErrorCode } from '../common/errors/error-code';
import { PrismaService } from '../prisma/prisma.service';
import { RegisterStorageFileDto } from './dto/register-storage-file.dto';

export interface StorageStatus {
  configured: boolean;
  provider: 'supabase';
  bucket?: string;
  missingKeys: string[];
  invalidKeys: string[];
  urlValid: boolean;
  connected?: boolean;
  bucketFound?: boolean;
  error?: string;
}

@Injectable()
export class StorageService {
  private readonly supabaseUrl?: string;
  private readonly supabasePublishableKey?: string;
  private readonly supabaseSecretKey?: string;
  private readonly supabaseBucket?: string;
  private readonly client?: SupabaseClient;

  constructor(
    private readonly configService: ConfigService,
    private readonly prisma: PrismaService,
  ) {
    this.supabaseUrl = this.configService.get<string>('storage.supabaseUrl');
    this.supabasePublishableKey = this.configService.get<string>(
      'storage.supabasePublishableKey',
    );
    this.supabaseSecretKey = this.configService.get<string>(
      'storage.supabaseSecretKey',
    );
    this.supabaseBucket = this.configService.get<string>(
      'storage.supabaseBucket',
    );

    if (this.supabaseUrl && this.supabaseSecretKey) {
      this.client = createClient(this.supabaseUrl, this.supabaseSecretKey, {
        auth: { persistSession: false },
      });
    }
  }

  getStatus(): StorageStatus {
    const missingKeys = (
      [
        ['SUPABASE_URL', this.supabaseUrl],
        ['SUPABASE_PUBLISHABLE_KEY', this.supabasePublishableKey],
        ['SUPABASE_SECRET_KEY', this.supabaseSecretKey],
        ['SUPABASE_BUCKET', this.supabaseBucket],
      ] as const
    )
      .filter(([, value]) => !value)
      .map(([key]) => key);
    const invalidKeys = (
      [
        ['SUPABASE_URL', this.supabaseUrl],
        ['SUPABASE_PUBLISHABLE_KEY', this.supabasePublishableKey],
        ['SUPABASE_SECRET_KEY', this.supabaseSecretKey],
        ['SUPABASE_BUCKET', this.supabaseBucket],
      ] as const
    )
      .filter(([, value]) => this.isPlaceholderValue(value))
      .map(([key]) => key);

    return {
      configured: missingKeys.length === 0 && invalidKeys.length === 0,
      provider: 'supabase',
      bucket: this.supabaseBucket,
      missingKeys,
      invalidKeys,
      urlValid: this.isSupabaseUrlValid(),
    };
  }

  getCdnStrategy() {
    return {
      provider: 'supabase',
      bucket: this.supabaseBucket,
      publicBucket: true,
      defaultSignedUrlExpiresIn: 3600,
      pathConventions: {
        companions: 'companions/{asset-key}/{state}.png',
        onboarding: 'onboarding/{slide-key}.png',
        sounds: 'sounds/{category}/{sound-key}.mp3',
        breathing: 'breathing/{exercise-key}.png',
        quotes: 'quotes/{mood-key}.png',
        avatars: 'avatars/{user-id}.png',
      },
      accessRules: {
        catalogAssets: 'public-url',
        userUploads: 'signed-url-or-owner-metadata',
        adminDeletes: 'admin-only',
      },
      configured: this.getStatus().configured,
    };
  }

  async getStatusDeep(): Promise<StorageStatus> {
    const status = this.getStatus();

    if (!status.configured || !this.client || !this.supabaseBucket) {
      return status;
    }

    try {
      const { data, error } = await this.client.storage.getBucket(
        this.supabaseBucket,
      );

      return {
        ...status,
        connected: !error,
        bucketFound: Boolean(data && !error),
        error: error?.message,
      };
    } catch (error) {
      return {
        ...status,
        connected: false,
        bucketFound: false,
        error: error instanceof Error ? error.message : 'Unknown storage error',
      };
    }
  }

  getClient(): SupabaseClient {
    if (!this.client) {
      throw new ServiceUnavailableException({
        code: ErrorCode.STORAGE_NOT_CONFIGURED,
        message: 'Supabase storage is not configured',
        details: this.getStatus(),
      });
    }

    return this.client;
  }

  getBucket(): string {
    if (!this.supabaseBucket) {
      throw new ServiceUnavailableException({
        code: ErrorCode.STORAGE_NOT_CONFIGURED,
        message: 'Supabase storage bucket is not configured',
        details: this.getStatus(),
      });
    }

    return this.supabaseBucket;
  }

  async createSignedUploadUrl(path: string, upsert = false) {
    const normalizedPath = this.normalizePath(path);
    const { data, error } = await this.getClient()
      .storage.from(this.getBucket())
      .createSignedUploadUrl(normalizedPath, { upsert });

    if (error) {
      this.throwStorageOperationError(error.message);
    }

    return {
      bucket: this.getBucket(),
      path: data.path,
      signedUrl: data.signedUrl,
      token: data.token,
    };
  }

  async createSignedUrl(path: string, expiresIn = 3600) {
    const normalizedPath = this.normalizePath(path);
    const { data, error } = await this.getClient()
      .storage.from(this.getBucket())
      .createSignedUrl(normalizedPath, expiresIn);

    if (error) {
      this.throwStorageOperationError(error.message);
    }

    return {
      bucket: this.getBucket(),
      path: normalizedPath,
      signedUrl: data.signedUrl,
      expiresIn,
    };
  }

  getPublicUrl(path: string) {
    const normalizedPath = this.normalizePath(path);
    const { data } = this.getClient()
      .storage.from(this.getBucket())
      .getPublicUrl(normalizedPath);

    return {
      bucket: this.getBucket(),
      path: normalizedPath,
      publicUrl: data.publicUrl,
    };
  }

  findFiles(userId?: string) {
    return this.prisma.storageFile.findMany({
      where: userId ? { userId } : undefined,
      orderBy: { createdAt: 'desc' },
    });
  }

  registerFile(dto: RegisterStorageFileDto, ownerUserId?: string) {
    const normalizedPath = this.normalizePath(dto.path);
    const isPublic = dto.isPublic ?? true;
    const publicUrl = isPublic
      ? (dto.publicUrl ?? this.getPublicUrl(normalizedPath).publicUrl)
      : dto.publicUrl;

    return this.prisma.storageFile.create({
      data: {
        userId: ownerUserId,
        filename: dto.filename,
        mimetype: dto.mimetype,
        size: dto.size,
        provider: 'supabase',
        bucket: this.supabaseBucket,
        path: normalizedPath,
        url: publicUrl ?? normalizedPath,
        publicUrl,
        isPublic,
        expiresAt: dto.expiresAt,
        metadata: dto.metadata as Prisma.InputJsonValue,
      },
    });
  }

  async removeFileMetadata(id: string) {
    return this.prisma.storageFile.delete({ where: { id } });
  }

  async removeObjects(paths: string[]) {
    const normalizedPaths = paths.map((path) => this.normalizePath(path));
    const { data, error } = await this.getClient()
      .storage.from(this.getBucket())
      .remove(normalizedPaths);

    if (error) {
      this.throwStorageOperationError(error.message);
    }

    return {
      bucket: this.getBucket(),
      removed: data,
    };
  }

  private normalizePath(path: string) {
    const normalizedPath = path.trim().replace(/^\/+/, '');

    if (
      !normalizedPath ||
      normalizedPath.includes('..') ||
      normalizedPath.includes('\\')
    ) {
      throw new AppException(
        ErrorCode.STORAGE_INVALID_PATH,
        'Storage path is invalid',
        HttpStatus.BAD_REQUEST,
      );
    }

    return normalizedPath;
  }

  private throwStorageOperationError(message: string): never {
    throw new AppException(
      ErrorCode.STORAGE_OPERATION_FAILED,
      message,
      HttpStatus.BAD_GATEWAY,
    );
  }

  private isSupabaseUrlValid() {
    if (!this.supabaseUrl) {
      return false;
    }

    try {
      const url = new URL(this.supabaseUrl);
      return url.protocol === 'https:' && url.hostname.includes('supabase.co');
    } catch {
      return false;
    }
  }

  private isPlaceholderValue(value?: string) {
    if (!value) {
      return false;
    }

    return value.includes('your-') || value.includes('example');
  }
}

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

export interface UploadedStorageFile {
  originalname: string;
  mimetype: string;
  size: number;
  buffer: Buffer;
}

@Injectable()
export class StorageService {
  private readonly publicCatalogPrefixes = [
    'companions/',
    'onboarding/',
    'sounds/',
    'ambient-sounds/',
    'podcasts/',
    'podcast-covers/',
    'sound-covers/',
    'breathing/',
    'quotes/',
  ];
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
        ambientSounds: 'ambient-sounds/{sound-key}.mp3',
        podcasts: 'podcasts/{podcast-key}.mp3',
        breathing: 'breathing/{exercise-key}.png',
        quotes: 'quotes/{mood-key}.png',
        userUploads: 'user-uploads/{user-id}/{filename}',
      },
      accessRules: {
        catalogAssets:
          'public-url readable by users; writes and arbitrary path reads are admin-only',
        userUploads:
          'signed/public read URLs are scoped to user-uploads/{authenticatedUserId}/',
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

  createUserSignedUploadUrl(userId: string, path: string, upsert = false) {
    return this.createSignedUploadUrl(
      this.normalizeUserUploadPath(userId, path),
      upsert,
    );
  }

  createAdminSignedUploadUrl(path: string, upsert = false) {
    return this.createSignedUploadUrl(this.normalizePath(path), upsert);
  }

  async uploadUserFile(
    userId: string,
    file: UploadedStorageFile | undefined,
    path: string,
    options: {
      upsert?: boolean;
      isPublic?: boolean;
      metadata?: Record<string, unknown>;
    } = {},
  ) {
    return this.uploadFile(this.normalizeUserUploadPath(userId, path), file, {
      ...options,
      userId,
    });
  }

  async uploadUserAvatar(
    userId: string,
    file: UploadedStorageFile | undefined,
    path: string,
  ) {
    const uploaded = await this.uploadUserFile(userId, file, path, {
      upsert: true,
      isPublic: true,
      metadata: { domain: 'profile-avatar' },
    });

    await this.prisma.user.update({
      where: { id: userId },
      data: { avatar: uploaded.publicUrl },
    });

    return uploaded;
  }

  async uploadAdminFile(
    file: UploadedStorageFile | undefined,
    path: string,
    options: {
      upsert?: boolean;
      isPublic?: boolean;
      metadata?: Record<string, unknown>;
    } = {},
  ) {
    return this.uploadFile(this.normalizePath(path), file, options);
  }

  private async uploadFile(
    normalizedPath: string,
    file: UploadedStorageFile | undefined,
    options: {
      userId?: string;
      upsert?: boolean;
      isPublic?: boolean;
      metadata?: Record<string, unknown>;
    },
  ) {
    if (!file?.buffer?.length) {
      throw new AppException(
        ErrorCode.STORAGE_INVALID_PATH,
        'Upload file is required',
        HttpStatus.BAD_REQUEST,
      );
    }

    const { data, error } = await this.getClient()
      .storage.from(this.getBucket())
      .upload(normalizedPath, file.buffer, {
        contentType: file.mimetype,
        upsert: options.upsert ?? true,
      });

    if (error) {
      this.throwStorageOperationError(error.message);
    }

    const publicUrl = this.getPublicUrl(data.path).publicUrl;

    await this.prisma.storageFile.create({
      data: {
        userId: options.userId,
        filename: file.originalname,
        mimetype: file.mimetype,
        size: file.size,
        provider: 'supabase',
        bucket: this.supabaseBucket,
        path: data.path,
        url: publicUrl,
        publicUrl,
        isPublic: options.isPublic ?? true,
        metadata: (options.metadata ?? {}) as Prisma.InputJsonValue,
      },
    });

    return {
      bucket: this.getBucket(),
      path: data.path,
      publicUrl,
      filename: file.originalname,
      mimetype: file.mimetype,
      size: file.size,
    };
  }

  private async createSignedUploadUrl(path: string, upsert = false) {
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

  createUserSignedUrl(userId: string, path: string, expiresIn = 3600) {
    return this.createSignedUrl(
      this.normalizeUserUploadPath(userId, path),
      expiresIn,
    );
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

  getUserPublicUrl(userId: string, path: string) {
    const normalizedPath = this.normalizeReadablePathForUser(userId, path);
    return this.getPublicUrl(normalizedPath);
  }

  findFiles(userId?: string) {
    return this.prisma.storageFile.findMany({
      where: userId ? { userId } : undefined,
      orderBy: { createdAt: 'desc' },
    });
  }

  async registerFile(dto: RegisterStorageFileDto, ownerUserId?: string) {
    const normalizedPath = ownerUserId
      ? this.normalizeUserUploadPath(ownerUserId, dto.path)
      : this.normalizePath(dto.path);

    if (this.client && this.supabaseBucket) {
      const { data } = await this.getClient()
        .storage.from(this.getBucket())
        .createSignedUrl(normalizedPath, 5);
      if (!data?.signedUrl) {
        throw new AppException(
          ErrorCode.STORAGE_OPERATION_FAILED,
          `Object not found at path: ${normalizedPath}`,
          HttpStatus.NOT_FOUND,
        );
      }
    }

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

  private normalizeUserUploadPath(userId: string, path: string) {
    const normalizedPath = this.normalizePath(path);
    const userPrefix = `user-uploads/${userId}/`;

    if (normalizedPath.startsWith(userPrefix)) {
      return normalizedPath;
    }

    if (normalizedPath.startsWith('user-uploads/')) {
      throw new AppException(
        ErrorCode.STORAGE_INVALID_PATH,
        'Storage path must be scoped to the authenticated user',
        HttpStatus.FORBIDDEN,
      );
    }

    return `${userPrefix}${normalizedPath}`;
  }

  private normalizeReadablePathForUser(userId: string, path: string) {
    const normalizedPath = this.normalizePath(path);

    if (this.isPublicCatalogPath(normalizedPath)) {
      return normalizedPath;
    }

    return this.normalizeUserUploadPath(userId, normalizedPath);
  }

  private isPublicCatalogPath(path: string) {
    return this.publicCatalogPrefixes.some((prefix) => path.startsWith(prefix));
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

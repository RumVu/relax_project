import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Post,
  Query,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { randomUUID } from 'crypto';
import {
  ApiBearerAuth,
  ApiCreatedResponse,
  ApiConsumes,
  ApiForbiddenResponse,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
  ApiUnauthorizedResponse,
} from '@nestjs/swagger';
import { FileInterceptor } from '@nestjs/platform-express';
import { AdminOnly } from '../auth/decorators/admin-only.decorator';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import type { AuthUser } from '../auth/auth.types';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CreateSignedUploadUrlDto } from './dto/create-signed-upload-url.dto';
import { CreateSignedUrlQueryDto } from './dto/create-signed-url-query.dto';
import { GetPublicUrlQueryDto } from './dto/get-public-url-query.dto';
import { RegisterStorageFileDto } from './dto/register-storage-file.dto';
import { RemoveStorageObjectDto } from './dto/remove-storage-object.dto';
import { StorageFileResponseDto } from './dto/storage-file-response.dto';
import { StorageHealthQueryDto } from './dto/storage-health-query.dto';
import { StorageService } from './storage.service';
import type { UploadedStorageFile } from './storage.service';

const AVATAR_MAX_BYTES = 5 * 1024 * 1024;
const ADMIN_UPLOAD_MAX_BYTES = 50 * 1024 * 1024;

@ApiTags('Storage')
@Controller('storage')
export class StorageController {
  constructor(private readonly storageService: StorageService) {}

  @ApiOperation({
    summary: 'Get storage configuration and optional deep connectivity health',
  })
  @ApiOkResponse({ description: 'Storage health payload.' })
  @AdminOnly()
  @Get('health')
  getHealth(@Query() query: StorageHealthQueryDto) {
    if (query.deep) {
      return this.storageService.getStatusDeep();
    }

    return this.storageService.getStatus();
  }

  @ApiOperation({ summary: 'Get upload storage readiness for current user' })
  @ApiOkResponse({ description: 'Storage readiness payload safe for users.' })
  @ApiBearerAuth('access-token')
  @ApiUnauthorizedResponse({ description: 'Bearer token is required.' })
  @UseGuards(JwtAuthGuard)
  @Get('me/health')
  getMyStorageHealth() {
    return this.storageService.getStatus();
  }

  @ApiOperation({ summary: 'Get storage/CDN path and access strategy' })
  @ApiOkResponse({
    description:
      'Storage conventions for public catalog assets, user uploads, and signed URLs.',
  })
  @AdminOnly()
  @Get('cdn-strategy')
  getCdnStrategy() {
    return this.storageService.getCdnStrategy();
  }

  @ApiOperation({ summary: 'Create a signed Supabase upload URL' })
  @ApiCreatedResponse({ description: 'Signed upload URL and storage path.' })
  @ApiBearerAuth('access-token')
  @ApiUnauthorizedResponse({ description: 'Bearer token is required.' })
  @UseGuards(JwtAuthGuard)
  @Post('signed-upload-url')
  createSignedUploadUrl(
    @CurrentUser() user: AuthUser,
    @Body() dto: CreateSignedUploadUrlDto,
  ) {
    return this.storageService.createUserSignedUploadUrl(
      user.id,
      dto.path,
      dto.upsert,
    );
  }

  @ApiOperation({
    summary: 'Create a signed upload URL for catalog/admin paths',
  })
  @ApiCreatedResponse({ description: 'Signed upload URL and storage path.' })
  @AdminOnly()
  @Post('admin/signed-upload-url')
  createAdminSignedUploadUrl(@Body() dto: CreateSignedUploadUrlDto) {
    return this.storageService.createAdminSignedUploadUrl(dto.path, dto.upsert);
  }

  @ApiOperation({ summary: 'Upload the current user avatar through the API' })
  @ApiConsumes('multipart/form-data')
  @ApiCreatedResponse({ description: 'Uploaded avatar storage metadata.' })
  @ApiBearerAuth('access-token')
  @ApiUnauthorizedResponse({ description: 'Bearer token is required.' })
  @UseGuards(JwtAuthGuard)
  @UseInterceptors(
    FileInterceptor('file', { limits: { fileSize: AVATAR_MAX_BYTES } }),
  )
  @Post('me/avatar')
  uploadAvatar(
    @CurrentUser() user: AuthUser,
    @UploadedFile() file?: UploadedStorageFile,
  ) {
    const ext = extensionForMime(file?.mimetype) ?? 'png';
    return this.storageService.uploadUserAvatar(user.id, file, avatarPath(ext));
  }

  @ApiOperation({ summary: 'Upload an admin/catalog file through the API' })
  @ApiConsumes('multipart/form-data')
  @ApiCreatedResponse({ description: 'Uploaded catalog storage metadata.' })
  @AdminOnly()
  @UseInterceptors(
    FileInterceptor('file', { limits: { fileSize: ADMIN_UPLOAD_MAX_BYTES } }),
  )
  @Post('admin/upload')
  uploadAdminFile(
    @UploadedFile() file: UploadedStorageFile | undefined,
    @Body('path') path: string,
    @Body('upsert') upsert?: string,
  ) {
    const resolvedPath = path || `uploads/${Date.now()}-${safeFileName(file?.originalname)}`;
    return this.storageService.uploadAdminFile(file, resolvedPath, {
      upsert: upsert !== 'false',
      isPublic: true,
      metadata: { domain: 'catalog-upload' },
    });
  }

  @ApiOperation({ summary: 'Create a signed read URL for a storage object' })
  @ApiOkResponse({ description: 'Signed read URL.' })
  @ApiBearerAuth('access-token')
  @ApiUnauthorizedResponse({ description: 'Bearer token is required.' })
  @ApiForbiddenResponse({
    description: 'User storage paths must stay scoped to the current user.',
  })
  @UseGuards(JwtAuthGuard)
  @Get('signed-url')
  createSignedUrl(
    @CurrentUser() user: AuthUser,
    @Query() query: CreateSignedUrlQueryDto,
  ) {
    return this.storageService.createUserSignedUrl(
      user.id,
      query.path,
      query.expiresIn,
    );
  }

  @ApiOperation({
    summary: 'Create a signed read URL for an admin/catalog storage object',
  })
  @ApiOkResponse({ description: 'Signed read URL.' })
  @AdminOnly()
  @Get('admin/signed-url')
  createAdminSignedUrl(@Query() query: CreateSignedUrlQueryDto) {
    return this.storageService.createSignedUrl(query.path, query.expiresIn);
  }

  @ApiOperation({ summary: 'Get the public URL for a storage object' })
  @ApiOkResponse({ description: 'Public URL.' })
  @ApiBearerAuth('access-token')
  @ApiUnauthorizedResponse({ description: 'Bearer token is required.' })
  @ApiForbiddenResponse({
    description: 'User storage paths must stay scoped to the current user.',
  })
  @UseGuards(JwtAuthGuard)
  @Get('public-url')
  getPublicUrl(
    @CurrentUser() user: AuthUser,
    @Query() query: GetPublicUrlQueryDto,
  ) {
    return this.storageService.getUserPublicUrl(user.id, query.path);
  }

  @ApiOperation({ summary: 'Get the public URL for an admin/catalog object' })
  @ApiOkResponse({ description: 'Public URL.' })
  @AdminOnly()
  @Get('admin/public-url')
  getAdminPublicUrl(@Query() query: GetPublicUrlQueryDto) {
    return this.storageService.getPublicUrl(query.path);
  }

  @ApiOperation({ summary: 'List registered storage file metadata' })
  @ApiOkResponse({
    type: StorageFileResponseDto,
    isArray: true,
    description: 'Storage file metadata list.',
  })
  @AdminOnly()
  @Get('files')
  findFiles() {
    return this.storageService.findFiles();
  }

  @ApiOperation({ summary: 'List current user storage file metadata' })
  @ApiOkResponse({
    type: StorageFileResponseDto,
    isArray: true,
    description: 'Current user storage file metadata list.',
  })
  @ApiBearerAuth('access-token')
  @ApiUnauthorizedResponse({ description: 'Bearer token is required.' })
  @UseGuards(JwtAuthGuard)
  @Get('me/files')
  findMyFiles(@CurrentUser() user: AuthUser) {
    return this.storageService.findFiles(user.id);
  }

  @ApiOperation({ summary: 'Register storage file metadata' })
  @ApiCreatedResponse({
    type: StorageFileResponseDto,
    description: 'Created storage file metadata.',
  })
  @ApiBearerAuth('access-token')
  @ApiUnauthorizedResponse({ description: 'Bearer token is required.' })
  @UseGuards(JwtAuthGuard)
  @Post('files')
  registerFile(
    @CurrentUser() user: AuthUser,
    @Body() dto: RegisterStorageFileDto,
  ) {
    return this.storageService.registerFile(dto, user.id);
  }

  @ApiOperation({ summary: 'Delete storage file metadata by id' })
  @ApiOkResponse({
    type: StorageFileResponseDto,
    description: 'Deleted storage file metadata.',
  })
  @AdminOnly()
  @Delete('files/:id')
  removeFileMetadata(@Param('id') id: string) {
    return this.storageService.removeFileMetadata(id);
  }

  @ApiOperation({ summary: 'Delete one or more objects from Supabase storage' })
  @ApiOkResponse({ description: 'Supabase remove operation result.' })
  @AdminOnly()
  @Delete('objects')
  removeObjects(@Body() dto: RemoveStorageObjectDto) {
    return this.storageService.removeObjects(dto.paths);
  }
}

function extensionForMime(mimetype?: string) {
  if (mimetype === 'image/jpeg') return 'jpg';
  if (mimetype === 'image/png') return 'png';
  if (mimetype === 'image/webp') return 'webp';
  if (mimetype === 'image/gif') return 'gif';
  return undefined;
}

function avatarPath(ext: string) {
  return `avatars/avatar-${Date.now()}-${randomUUID()}.${ext}`;
}

function safeFileName(name = 'upload.bin') {
  return name
    .toLowerCase()
    .replace(/[^a-z0-9.]+/g, '-')
    .replace(/^-+|-+$/g, '')
    .slice(0, 100) || 'upload.bin';
}

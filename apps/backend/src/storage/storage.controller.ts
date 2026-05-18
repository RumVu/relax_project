import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiCreatedResponse,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
  ApiUnauthorizedResponse,
} from '@nestjs/swagger';
import { AdminOnly } from '../auth/decorators/admin-only.decorator';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import type { AuthUser } from '../auth/auth.types';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CreateSignedUploadUrlDto } from './dto/create-signed-upload-url.dto';
import { CreateSignedUrlQueryDto } from './dto/create-signed-url-query.dto';
import { GetPublicUrlQueryDto } from './dto/get-public-url-query.dto';
import { RegisterStorageFileDto } from './dto/register-storage-file.dto';
import { RemoveStorageObjectDto } from './dto/remove-storage-object.dto';
import { StorageHealthQueryDto } from './dto/storage-health-query.dto';
import { StorageService } from './storage.service';

@ApiTags('Storage')
@Controller('storage')
export class StorageController {
  constructor(private readonly storageService: StorageService) {}

  @ApiOperation({
    summary: 'Get storage configuration and optional deep connectivity health',
  })
  @ApiOkResponse({ description: 'Storage health payload.' })
  @Get('health')
  getHealth(@Query() query: StorageHealthQueryDto) {
    if (query.deep) {
      return this.storageService.getStatusDeep();
    }

    return this.storageService.getStatus();
  }

  @ApiOperation({ summary: 'Get storage/CDN path and access strategy' })
  @ApiOkResponse({
    description:
      'Storage conventions for public catalog assets, user uploads, and signed URLs.',
  })
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
  createSignedUploadUrl(@Body() dto: CreateSignedUploadUrlDto) {
    return this.storageService.createSignedUploadUrl(dto.path, dto.upsert);
  }

  @ApiOperation({ summary: 'Create a signed read URL for a storage object' })
  @ApiOkResponse({ description: 'Signed read URL.' })
  @ApiBearerAuth('access-token')
  @ApiUnauthorizedResponse({ description: 'Bearer token is required.' })
  @UseGuards(JwtAuthGuard)
  @Get('signed-url')
  createSignedUrl(@Query() query: CreateSignedUrlQueryDto) {
    return this.storageService.createSignedUrl(query.path, query.expiresIn);
  }

  @ApiOperation({ summary: 'Get the public URL for a storage object' })
  @ApiOkResponse({ description: 'Public URL.' })
  @Get('public-url')
  getPublicUrl(@Query() query: GetPublicUrlQueryDto) {
    return this.storageService.getPublicUrl(query.path);
  }

  @ApiOperation({ summary: 'List registered storage file metadata' })
  @ApiOkResponse({ description: 'Storage file metadata list.' })
  @AdminOnly()
  @Get('files')
  findFiles() {
    return this.storageService.findFiles();
  }

  @ApiOperation({ summary: 'List current user storage file metadata' })
  @ApiOkResponse({ description: 'Current user storage file metadata list.' })
  @ApiBearerAuth('access-token')
  @ApiUnauthorizedResponse({ description: 'Bearer token is required.' })
  @UseGuards(JwtAuthGuard)
  @Get('me/files')
  findMyFiles(@CurrentUser() user: AuthUser) {
    return this.storageService.findFiles(user.id);
  }

  @ApiOperation({ summary: 'Register storage file metadata' })
  @ApiCreatedResponse({ description: 'Created storage file metadata.' })
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
  @ApiOkResponse({ description: 'Deleted storage file metadata.' })
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

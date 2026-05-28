import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
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
} from '@nestjs/swagger';
import type { AuthUser } from '../auth/auth.types';
import { AdminOnly } from '../auth/decorators/admin-only.decorator';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CreateNotificationDto } from './dto/create-notification.dto';
import {
  NotificationPageDto,
  NotificationResponseDto,
  PushDeviceResponseDto,
  UnreadCountResponseDto,
} from './dto/notification-response.dto';
import { NotificationQueryDto } from './dto/notification-query.dto';
import { RegisterPushDeviceDto } from './dto/register-push-device.dto';
import { NotificationsService } from './notifications.service';

@ApiTags('Notifications')
@ApiBearerAuth('access-token')
@Controller('notifications')
export class NotificationsController {
  constructor(private readonly notificationsService: NotificationsService) {}

  @ApiOperation({ summary: 'Get push/email provider configuration status' })
  @ApiOkResponse({ description: 'Notification provider readiness.' })
  @UseGuards(JwtAuthGuard)
  @Get('providers')
  getProviderStatus() {
    return this.notificationsService.getProviderStatus();
  }

  @ApiOperation({ summary: 'List current user notifications' })
  @ApiOkResponse({ type: NotificationPageDto, description: 'Current user notification list.' })
  @UseGuards(JwtAuthGuard)
  @Get('me')
  listMine(
    @CurrentUser() user: AuthUser,
    @Query() query: NotificationQueryDto,
  ) {
    return this.notificationsService.listMine(user.id, query);
  }

  @ApiOperation({ summary: 'Get unread notification count' })
  @ApiOkResponse({ type: UnreadCountResponseDto, description: 'Unread notification count.' })
  @UseGuards(JwtAuthGuard)
  @Get('me/unread-count')
  getUnreadCount(@CurrentUser() user: AuthUser) {
    return this.notificationsService.getUnreadCount(user.id);
  }

  @ApiOperation({ summary: 'Register or update current user push device' })
  @ApiCreatedResponse({ type: PushDeviceResponseDto, description: 'Registered push device.' })
  @UseGuards(JwtAuthGuard)
  @Post('me/devices')
  registerDevice(
    @CurrentUser() user: AuthUser,
    @Body() dto: RegisterPushDeviceDto,
  ) {
    return this.notificationsService.registerDevice(user.id, dto);
  }

  @ApiOperation({ summary: 'List current user push devices' })
  @ApiOkResponse({
    type: PushDeviceResponseDto,
    isArray: true,
    description: 'Registered push devices.',
  })
  @UseGuards(JwtAuthGuard)
  @Get('me/devices')
  listDevices(@CurrentUser() user: AuthUser) {
    return this.notificationsService.listDevices(user.id);
  }

  @ApiOperation({ summary: 'Remove a current user push device' })
  @ApiOkResponse({ description: 'Push device removal result.' })
  @UseGuards(JwtAuthGuard)
  @Delete('me/devices/:id')
  removeDevice(@CurrentUser() user: AuthUser, @Param('id') id: string) {
    return this.notificationsService.removeDevice(user.id, id);
  }

  @ApiOperation({ summary: 'Create a test notification for current user' })
  @ApiCreatedResponse({
    description:
      'Notification row plus delivery readiness. Real push/email queues only when provider keys are configured.',
  })
  @UseGuards(JwtAuthGuard)
  @Post('me/test')
  createTest(
    @CurrentUser() user: AuthUser,
    @Body() dto: CreateNotificationDto,
  ) {
    return this.notificationsService.createForUser(user.id, dto);
  }

  @ApiOperation({ summary: 'Mark one notification as read' })
  @ApiOkResponse({ type: NotificationResponseDto, description: 'Updated notification.' })
  @UseGuards(JwtAuthGuard)
  @Patch('me/:id/read')
  markRead(@CurrentUser() user: AuthUser, @Param('id') id: string) {
    return this.notificationsService.markRead(user.id, id);
  }

  @ApiOperation({ summary: 'Mark all current user notifications as read' })
  @ApiOkResponse({ description: 'Bulk mark-read result.' })
  @UseGuards(JwtAuthGuard)
  @Patch('me/read-all')
  markAllRead(@CurrentUser() user: AuthUser) {
    return this.notificationsService.markAllRead(user.id);
  }

  @ApiOperation({ summary: 'Create a notification for any user (admin)' })
  @ApiCreatedResponse({ description: 'Notification row plus delivery status.' })
  @AdminOnly()
  @Post('user/:userId')
  createForUser(
    @Param('userId') userId: string,
    @Body() dto: CreateNotificationDto,
  ) {
    return this.notificationsService.createForUser(userId, dto);
  }
}

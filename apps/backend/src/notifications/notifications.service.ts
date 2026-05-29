import { HttpStatus, Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { NotificationType, PushProvider } from '@prisma/client';
import { AppException } from '../common/errors/app.exception';
import { ErrorCode } from '../common/errors/error-code';
import { buildPage } from '../common/pagination/page';
import { PrismaService } from '../prisma/prisma.service';
import { RealtimeService } from '../realtime/realtime.service';
import { UsersService } from '../users/users.service';
import { CreateNotificationDto } from './dto/create-notification.dto';
import { NotificationQueryDto } from './dto/notification-query.dto';
import { RegisterPushDeviceDto } from './dto/register-push-device.dto';

@Injectable()
export class NotificationsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly usersService: UsersService,
    private readonly configService: ConfigService,
    private readonly realtime: RealtimeService,
  ) {}

  getProviderStatus() {
    const fcmConfigured =
      Boolean(this.configService.get<string>('FCM_SERVER_KEY')) ||
      Boolean(this.configService.get<string>('FIREBASE_SERVICE_ACCOUNT_JSON'));
    const apnsConfigured =
      Boolean(this.configService.get<string>('APNS_KEY_ID')) &&
      Boolean(this.configService.get<string>('APNS_TEAM_ID')) &&
      Boolean(this.configService.get<string>('APNS_BUNDLE_ID')) &&
      Boolean(this.configService.get<string>('APNS_PRIVATE_KEY'));
    const expoConfigured = Boolean(
      this.configService.get<string>('EXPO_ACCESS_TOKEN'),
    );
    const emailConfigured =
      Boolean(this.configService.get<string>('RESEND_API_KEY')) ||
      Boolean(this.configService.get<string>('SENDGRID_API_KEY')) ||
      Boolean(this.configService.get<string>('SMTP_URL'));

    return {
      push: {
        configured: fcmConfigured || apnsConfigured || expoConfigured,
        providers: {
          FCM: {
            configured: fcmConfigured,
            missingKeys: this.missingKeys([
              ['FCM_SERVER_KEY', this.configService.get('FCM_SERVER_KEY')],
              [
                'FIREBASE_SERVICE_ACCOUNT_JSON',
                this.configService.get('FIREBASE_SERVICE_ACCOUNT_JSON'),
              ],
            ]),
            note: 'FCM chỉ cần một trong hai key.',
          },
          APNS: {
            configured: apnsConfigured,
            missingKeys: this.missingKeys([
              ['APNS_KEY_ID', this.configService.get('APNS_KEY_ID')],
              ['APNS_TEAM_ID', this.configService.get('APNS_TEAM_ID')],
              ['APNS_BUNDLE_ID', this.configService.get('APNS_BUNDLE_ID')],
              ['APNS_PRIVATE_KEY', this.configService.get('APNS_PRIVATE_KEY')],
            ]),
          },
          EXPO: {
            configured: expoConfigured,
            missingKeys: this.missingKeys([
              [
                'EXPO_ACCESS_TOKEN',
                this.configService.get('EXPO_ACCESS_TOKEN'),
              ],
            ]),
          },
        },
      },
      email: {
        configured: emailConfigured,
        provider: this.configService.get<string>('EMAIL_PROVIDER') ?? 'none',
        missingKeys: this.missingKeys([
          ['RESEND_API_KEY', this.configService.get('RESEND_API_KEY')],
          ['SENDGRID_API_KEY', this.configService.get('SENDGRID_API_KEY')],
          ['SMTP_URL', this.configService.get('SMTP_URL')],
        ]),
        note: 'Email chỉ cần một provider thật khi deploy.',
      },
    };
  }

  async registerDevice(userId: string, dto: RegisterPushDeviceDto) {
    await this.usersService.findOne(userId);
    const existing = await this.prisma.pushDevice.findUnique({
      where: { token: dto.token },
    });

    if (existing && existing.userId !== userId) {
      throw new AppException(
        ErrorCode.AUTH_FORBIDDEN,
        'Push device token is already bound to another user',
        HttpStatus.FORBIDDEN,
      );
    }

    if (existing) {
      return this.prisma.pushDevice.update({
        where: { id: existing.id },
        data: {
          platform: dto.platform,
          provider: dto.provider ?? existing.provider,
          deviceId: dto.deviceId,
          deviceName: dto.deviceName,
          appVersion: dto.appVersion,
          timezone: dto.timezone,
          enabled: dto.enabled ?? true,
          lastSeenAt: new Date(),
        },
      });
    }

    return this.prisma.pushDevice.create({
      data: {
        userId,
        token: dto.token,
        platform: dto.platform,
        provider: dto.provider ?? PushProvider.FCM,
        deviceId: dto.deviceId,
        deviceName: dto.deviceName,
        appVersion: dto.appVersion,
        timezone: dto.timezone,
        enabled: dto.enabled ?? true,
      },
    });
  }

  async listDevices(userId: string) {
    await this.usersService.findOne(userId);

    return this.prisma.pushDevice.findMany({
      where: { userId },
      orderBy: { lastSeenAt: 'desc' },
    });
  }

  async removeDevice(userId: string, id: string) {
    const result = await this.prisma.pushDevice.deleteMany({
      where: { id, userId },
    });

    if (result.count === 0) {
      throw AppException.notFound(
        ErrorCode.PUSH_DEVICE_NOT_FOUND,
        'Push device not found',
      );
    }

    return { success: true, id };
  }

  async listMine(userId: string, query: NotificationQueryDto) {
    await this.usersService.findOne(userId);
    const where = {
      userId,
      type: query.type,
      isRead: query.isRead,
    };
    const [items, total] = await Promise.all([
      this.prisma.notification.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip: query.skip,
        take: query.limit ?? 50,
      }),
      this.prisma.notification.count({ where }),
    ]);

    return buildPage(items, total, query);
  }

  async getUnreadCount(userId: string) {
    await this.usersService.findOne(userId);
    const count = await this.prisma.notification.count({
      where: { userId, isRead: false },
    });

    return { count };
  }

  async createForUser(userId: string, dto: CreateNotificationDto) {
    await this.usersService.findOne(userId);
    const type = dto.type ?? NotificationType.IN_APP;
    const notification = await this.prisma.notification.create({
      data: {
        userId,
        title: dto.title,
        message: dto.message,
        type,
      },
    });

    this.realtime.emitToUser(userId, 'notification.created', {
      id: notification.id,
      title: notification.title,
      message: notification.message,
      type: notification.type,
      createdAt: notification.createdAt,
    });

    return {
      notification,
      delivery: await this.resolveDelivery(userId, type),
    };
  }

  async markRead(userId: string, id: string) {
    const result = await this.prisma.notification.updateMany({
      where: { id, userId },
      data: { isRead: true, readAt: new Date() },
    });

    if (result.count === 0) {
      throw AppException.notFound(
        ErrorCode.NOTIFICATION_NOT_FOUND,
        'Notification not found',
      );
    }

    return this.prisma.notification.findUnique({ where: { id } });
  }

  async markAllRead(userId: string) {
    await this.usersService.findOne(userId);
    const result = await this.prisma.notification.updateMany({
      where: { userId, isRead: false },
      data: { isRead: true, readAt: new Date() },
    });

    return { success: true, count: result.count };
  }

  private async resolveDelivery(userId: string, type: NotificationType) {
    if (type === NotificationType.IN_APP) {
      return { channel: 'in_app', configured: true, queued: true };
    }

    if (type === NotificationType.EMAIL) {
      const status = this.getProviderStatus().email;
      return {
        channel: 'email',
        configured: status.configured,
        queued: status.configured,
        provider: status.provider,
      };
    }

    const status = this.getProviderStatus().push;
    const enabledDeviceCount = await this.prisma.pushDevice.count({
      where: { userId, enabled: true },
    });

    if (enabledDeviceCount === 0) {
      throw new AppException(
        ErrorCode.PUSH_DEVICE_NOT_FOUND,
        'No enabled push device registered for this user',
        HttpStatus.BAD_REQUEST,
      );
    }

    return {
      channel: 'push',
      configured: status.configured,
      queued: status.configured,
      enabledDeviceCount,
      providers: status.providers,
    };
  }

  private missingKeys(keys: Array<[string, string | undefined]>) {
    return keys.filter(([, value]) => !value).map(([key]) => key);
  }
}

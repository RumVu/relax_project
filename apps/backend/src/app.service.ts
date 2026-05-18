import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { StorageService } from './storage/storage.service';

export type ApiAuthMode = 'PUBLIC' | 'BEARER' | 'ADMIN';

export interface ApiEndpointSummary {
  method: string;
  path: string;
  auth: ApiAuthMode;
  purpose: string;
}

export interface ApiResourceSummary {
  group: string;
  description: string;
  endpoints: ApiEndpointSummary[];
}

export interface ApiIndexResponse {
  name: string;
  status: 'ok';
  version: string;
  port: number | undefined;
  docs: {
    swagger: string;
    openApiJson: string;
  };
  health: string;
  database: {
    configured: boolean;
  };
  storage: ReturnType<StorageService['getStatus']>;
  resources: ApiResourceSummary[];
}

const API_RESOURCES: ApiResourceSummary[] = [
  {
    group: 'Auth',
    description:
      'Đăng ký, đăng nhập, refresh token, verify email, reset mật khẩu.',
    endpoints: [
      {
        method: 'POST',
        path: '/auth/register',
        auth: 'PUBLIC',
        purpose: 'Tạo tài khoản, profile, preferences và session đầu tiên.',
      },
      {
        method: 'POST',
        path: '/auth/login',
        auth: 'PUBLIC',
        purpose: 'Đăng nhập bằng email/password.',
      },
      {
        method: 'GET',
        path: '/auth/me',
        auth: 'BEARER',
        purpose: 'Lấy user hiện tại từ access token.',
      },
    ],
  },
  {
    group: 'Users',
    description: 'Quản lý user, profile, preferences và session.',
    endpoints: [
      {
        method: 'GET',
        path: '/users',
        auth: 'ADMIN',
        purpose: 'Danh sách user cho admin.',
      },
      {
        method: 'GET',
        path: '/user-profiles/me/profile',
        auth: 'BEARER',
        purpose: 'Hồ sơ cá nhân, birthday, zodiac và chinese zodiac.',
      },
      {
        method: 'PATCH',
        path: '/user-preferences/me/preferences',
        auth: 'BEARER',
        purpose: 'Timezone, vị trí, theme, thông báo và tuỳ chỉnh app.',
      },
      {
        method: 'GET',
        path: '/sessions/me',
        auth: 'BEARER',
        purpose: 'Các phiên đăng nhập của user hiện tại.',
      },
    ],
  },
  {
    group: 'Mood & Relax',
    description:
      'Mood check-in, scoring, journal, relax session và weekly stats.',
    endpoints: [
      {
        method: 'GET',
        path: '/mood-checkins/options',
        auth: 'PUBLIC',
        purpose: 'Option mood cho màn home/onboarding.',
      },
      {
        method: 'POST',
        path: '/mood-checkins/me',
        auth: 'BEARER',
        purpose: 'Tạo mood check-in với rawScore/finalScore.',
      },
      {
        method: 'GET',
        path: '/mood-checkins/me/weekly-stats',
        auth: 'BEARER',
        purpose: 'Dữ liệu thống kê tuần materialized.',
      },
      {
        method: 'POST',
        path: '/relax-activities/sessions/start',
        auth: 'BEARER',
        purpose: 'Bắt đầu phiên thư giãn.',
      },
      {
        method: 'POST',
        path: '/relax-activities/sessions/:id/finish',
        auth: 'BEARER',
        purpose: 'Kết thúc phiên, cập nhật relief và stats.',
      },
      {
        method: 'POST',
        path: '/journals/me',
        auth: 'BEARER',
        purpose: 'Tạo journal theo mood/tags/activity.',
      },
    ],
  },
  {
    group: 'Companion',
    description:
      'Pet cá nhân hoá theo default, zodiac, chinese zodiac hoặc custom.',
    endpoints: [
      {
        method: 'GET',
        path: '/user-companions/me',
        auth: 'BEARER',
        purpose: 'Companion hiện tại của user.',
      },
      {
        method: 'GET',
        path: '/user-companions/me/personalization-options',
        auth: 'BEARER',
        purpose: 'Các lựa chọn companion theo default/zodiac/con giáp/custom.',
      },
      {
        method: 'PATCH',
        path: '/user-companions/me/personalization-mode',
        auth: 'BEARER',
        purpose: 'Đổi mode linh thú và mapping asset.',
      },
      {
        method: 'POST',
        path: '/user-companions/me/interactions',
        auth: 'BEARER',
        purpose: 'Ghi nhận tương tác với companion.',
      },
    ],
  },
  {
    group: 'Analytics',
    description:
      'Overview, timeline, mood, relax, journal và companion analytics.',
    endpoints: [
      {
        method: 'GET',
        path: '/analytics/me/overview',
        auth: 'BEARER',
        purpose: 'Payload tổng hợp cho dashboard/home/setup.',
      },
      {
        method: 'GET',
        path: '/analytics/contracts',
        auth: 'PUBLIC',
        purpose: 'Contract response ổn định cho chart/card phía app.',
      },
    ],
  },
  {
    group: 'External Services',
    description:
      'Weather, Supabase Storage, notifications, billing và backend jobs.',
    endpoints: [
      {
        method: 'GET',
        path: '/weather/current',
        auth: 'PUBLIC',
        purpose: 'Thời tiết theo lat/lng/timezone client gửi lên.',
      },
      {
        method: 'GET',
        path: '/weather/me/current',
        auth: 'BEARER',
        purpose: 'Thời tiết theo vị trí đã lưu trong preferences.',
      },
      {
        method: 'GET',
        path: '/storage/health',
        auth: 'PUBLIC',
        purpose: 'Kiểm tra cấu hình Supabase Storage.',
      },
      {
        method: 'POST',
        path: '/jobs/weekly-mood-stats/run',
        auth: 'ADMIN',
        purpose: 'Chạy tay job tính WeeklyMoodStat.',
      },
    ],
  },
  {
    group: 'Catalog',
    description:
      'Content catalog cho app, theme, onboarding, asset, quote và âm thanh.',
    endpoints: [
      {
        method: 'GET',
        path: '/app-themes',
        auth: 'PUBLIC',
        purpose: 'Danh sách theme app.',
      },
      {
        method: 'GET',
        path: '/onboarding-slides',
        auth: 'PUBLIC',
        purpose: 'Slide intro app.',
      },
      {
        method: 'GET',
        path: '/companion-assets',
        auth: 'PUBLIC',
        purpose: 'Kho asset companion.',
      },
      {
        method: 'GET',
        path: '/ambient-sounds',
        auth: 'PUBLIC',
        purpose: 'Kho âm thanh thư giãn.',
      },
      {
        method: 'GET',
        path: '/cozy-quotes/random',
        auth: 'PUBLIC',
        purpose: 'Quote chữa lành random.',
      },
    ],
  },
];

@Injectable()
export class AppService {
  constructor(
    private readonly configService: ConfigService,
    private readonly storageService: StorageService,
  ) {}

  getApiIndex(): ApiIndexResponse {
    return {
      name: 'Digital Cigarette Break API',
      status: 'ok',
      version: '1.0.0',
      port: this.configService.get<number>('app.port'),
      docs: {
        swagger: '/docs',
        openApiJson: '/docs-json',
      },
      health: '/health',
      database: {
        configured: Boolean(
          this.configService.get<string>('prisma.databaseUrl'),
        ),
      },
      storage: this.storageService.getStatus(),
      resources: API_RESOURCES,
    };
  }

  getHealth() {
    return {
      status: 'ok',
      port: this.configService.get<number>('app.port'),
      database: {
        configured: Boolean(
          this.configService.get<string>('prisma.databaseUrl'),
        ),
      },
      storage: this.storageService.getStatus(),
    };
  }
}

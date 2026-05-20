import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

export interface ApiIndexResponse {
  name: string;
  status: 'ok';
  version: string;
  docs: {
    swagger: string;
    openApiJson: string;
  };
  health: string;
}

export interface HealthResponse {
  status: 'ok';
  timestamp: string;
  uptimeSeconds: number;
}

@Injectable()
export class AppService {
  constructor(private readonly configService: ConfigService) {}

  getApiIndex(): ApiIndexResponse {
    return {
      name: 'Digital Cigarette Break API',
      status: 'ok',
      version: this.configService.get<string>('app.version') ?? '1.0.0',
      docs: {
        swagger: '/docs',
        openApiJson: '/docs-json',
      },
      health: '/health',
    };
  }

  getHealth(): HealthResponse {
    return {
      status: 'ok',
      timestamp: new Date().toISOString(),
      uptimeSeconds: Math.round(process.uptime()),
    };
  }
}

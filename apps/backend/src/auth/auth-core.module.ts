import { Module } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtModule } from '@nestjs/jwt';
import type { JwtSignOptions } from '@nestjs/jwt';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { RolesGuard } from './guards/roles.guard';

@Module({
  imports: [
    JwtModule.registerAsync({
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => {
        const issuer = configService.get<string>('auth.jwtIssuer');
        const audience = configService.get<string>('auth.jwtAudience');

        return {
          secret: configService.get<string>('auth.jwtSecret'),
          signOptions: {
            expiresIn: (configService.get<string>('auth.jwtExpiresIn') ??
              '15m') as JwtSignOptions['expiresIn'],
            issuer,
            audience,
          },
          verifyOptions: {
            issuer,
            audience,
          },
        };
      },
    }),
  ],
  providers: [JwtAuthGuard, RolesGuard],
  exports: [JwtAuthGuard, RolesGuard, JwtModule],
})
export class AuthCoreModule {}

import { Module } from '@nestjs/common';
import { AuthCoreModule } from '../auth/auth-core.module';
import { AppThemesController } from './app-themes.controller';
import { AppThemesService } from './app-themes.service';

@Module({
  imports: [AuthCoreModule],
  controllers: [AppThemesController],
  providers: [AppThemesService],
})
export class AppThemesModule {}

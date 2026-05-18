import { Module } from '@nestjs/common';
import { AuthCoreModule } from '../auth/auth-core.module';
import { CompanionAssetsController } from './companion-assets.controller';
import { CompanionAssetsService } from './companion-assets.service';

@Module({
  imports: [AuthCoreModule],
  controllers: [CompanionAssetsController],
  providers: [CompanionAssetsService],
})
export class CompanionAssetsModule {}

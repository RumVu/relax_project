import { Module } from '@nestjs/common';
import { AuthCoreModule } from '../auth/auth-core.module';
import { QuestsController } from './quests.controller';
import { QuestsService } from './quests.service';

@Module({
  imports: [AuthCoreModule],
  controllers: [QuestsController],
  providers: [QuestsService],
  exports: [QuestsService],
})
export class QuestsModule {}

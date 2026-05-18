import { Module } from '@nestjs/common';
import { AuthCoreModule } from '../auth/auth-core.module';
import { CompanionMessagesController } from './companion-messages.controller';
import { CompanionMessagesService } from './companion-messages.service';

@Module({
  imports: [AuthCoreModule],
  controllers: [CompanionMessagesController],
  providers: [CompanionMessagesService],
})
export class CompanionMessagesModule {}

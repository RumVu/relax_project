import { Module } from '@nestjs/common';
import { AuthCoreModule } from '../auth/auth-core.module';
import { BreathingExercisesController } from './breathing-exercises.controller';
import { BreathingExercisesService } from './breathing-exercises.service';

@Module({
  imports: [AuthCoreModule],
  controllers: [BreathingExercisesController],
  providers: [BreathingExercisesService],
})
export class BreathingExercisesModule {}

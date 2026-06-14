import { PartialType } from '@nestjs/swagger';
import { CreateMeditationGuideDto } from './create-meditation-guide.dto';

export class UpdateMeditationGuideDto extends PartialType(
  CreateMeditationGuideDto,
) {}

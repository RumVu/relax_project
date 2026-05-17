import { PartialType } from '@nestjs/swagger';
import { CreateBreakSessionDto } from './create-break-session.dto';

export class UpdateBreakSessionDto extends PartialType(CreateBreakSessionDto) {}

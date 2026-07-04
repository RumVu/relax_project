import { ApiProperty } from '@nestjs/swagger';
import { PaginatedDto } from '../../common/dto/paginated.dto';

export class AmbientSoundResponseDto {
  @ApiProperty() id!: string;
  @ApiProperty() title!: string;
  @ApiProperty({ nullable: true }) description!: string | null;
  @ApiProperty() category!: string;
  @ApiProperty() soundUrl!: string;
  @ApiProperty({ nullable: true }) imageUrl!: string | null;
  @ApiProperty({ nullable: true, type: 'integer' }) duration!: number | null;
  @ApiProperty() isActive!: boolean;
  @ApiProperty({ type: 'string', format: 'date-time' }) createdAt!: Date;
  @ApiProperty({ type: 'string', format: 'date-time' }) updatedAt!: Date;
}

export class AmbientSoundPageDto extends PaginatedDto {
  @ApiProperty({ type: () => [AmbientSoundResponseDto] })
  items!: AmbientSoundResponseDto[];
}

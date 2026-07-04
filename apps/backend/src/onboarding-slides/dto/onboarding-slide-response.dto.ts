import { ApiProperty } from '@nestjs/swagger';
import { PaginatedDto } from '../../common/dto/paginated.dto';

export class OnboardingSlideResponseDto {
  @ApiProperty() id!: string;
  @ApiProperty() title!: string;
  @ApiProperty({ nullable: true }) subtitle!: string | null;
  @ApiProperty({ nullable: true }) description!: string | null;
  @ApiProperty({ nullable: true }) imageUrl!: string | null;
  @ApiProperty({ nullable: true }) animationUrl!: string | null;
  @ApiProperty({ type: 'integer' }) displayOrder!: number;
  @ApiProperty() isActive!: boolean;
  @ApiProperty({ type: 'string', format: 'date-time' }) createdAt!: Date;
  @ApiProperty({ type: 'string', format: 'date-time' }) updatedAt!: Date;
}

export class OnboardingSlidePageDto extends PaginatedDto {
  @ApiProperty({ type: () => [OnboardingSlideResponseDto] })
  items!: OnboardingSlideResponseDto[];
}

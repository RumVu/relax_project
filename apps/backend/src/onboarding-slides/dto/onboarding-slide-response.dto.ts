import { PaginatedDto } from '../../common/dto/paginated.dto';

export class OnboardingSlideResponseDto {
  id!: string;
  title!: string;
  subtitle!: string | null;
  description!: string | null;
  imageUrl!: string | null;
  animationUrl!: string | null;
  displayOrder!: number;
  isActive!: boolean;
  createdAt!: Date;
  updatedAt!: Date;
}

export class OnboardingSlidePageDto extends PaginatedDto {
  items!: OnboardingSlideResponseDto[];
}

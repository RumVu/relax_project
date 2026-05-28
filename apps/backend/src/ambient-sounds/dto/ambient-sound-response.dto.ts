import { PaginatedDto } from '../../common/dto/paginated.dto';

export class AmbientSoundResponseDto {
  id!: string;
  title!: string;
  description!: string | null;
  category!: string;
  soundUrl!: string;
  imageUrl!: string | null;
  duration!: number | null;
  isActive!: boolean;
  createdAt!: Date;
  updatedAt!: Date;
}

export class AmbientSoundPageDto extends PaginatedDto {
  items!: AmbientSoundResponseDto[];
}

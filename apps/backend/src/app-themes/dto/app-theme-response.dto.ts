import { ThemeMode } from '@prisma/client';
import { PaginatedDto } from '../../common/dto/paginated.dto';

export class AppThemeResponseDto {
  id!: string;
  name!: string;
  mode!: ThemeMode;
  backgroundColor!: string;
  surfaceColor!: string;
  primaryColor!: string;
  secondaryColor!: string | null;
  accentColor!: string | null;
  textColor!: string;
  mutedTextColor!: string | null;
  isDefault!: boolean;
  isActive!: boolean;
  createdAt!: Date;
  updatedAt!: Date;
}

export class AppThemePageDto extends PaginatedDto {
  items!: AppThemeResponseDto[];
}

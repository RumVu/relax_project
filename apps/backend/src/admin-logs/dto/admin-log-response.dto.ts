import { UserRole } from '@prisma/client';
import { PaginatedDto } from '../../common/dto/paginated.dto';

export class AdminLogActorDto {
  id!: string;
  email!: string;
  name!: string | null;
  role!: UserRole;
}

export class AdminLogResponseDto {
  id!: string;
  adminId!: string;
  action!: string;
  targetId!: string | null;
  targetType!: string | null;
  details!: string;
  createdAt!: Date;
  admin?: AdminLogActorDto;
}

export class AdminLogPageDto extends PaginatedDto {
  items!: AdminLogResponseDto[];
}

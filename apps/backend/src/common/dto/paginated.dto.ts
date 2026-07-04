import { ApiProperty } from '@nestjs/swagger';

/**
 * Shared shape for paginated list responses ({ items, total, skip, limit,
 * hasMore }). Concrete page DTOs extend this and declare the typed `items`
 * array so the OpenAPI document (and generated clients) get a real schema.
 */
export class PaginatedDto {
  @ApiProperty({ type: 'integer' }) total!: number;
  @ApiProperty({ type: 'integer' }) skip!: number;
  @ApiProperty({ type: 'integer' }) limit!: number;
  @ApiProperty() hasMore!: boolean;
}

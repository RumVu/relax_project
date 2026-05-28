/**
 * Shared shape for paginated list responses ({ items, total, skip, limit,
 * hasMore }). Concrete page DTOs extend this and declare the typed `items`
 * array so the OpenAPI document (and generated clients) get a real schema.
 */
export class PaginatedDto {
  total!: number;
  skip!: number;
  limit!: number;
  hasMore!: boolean;
}

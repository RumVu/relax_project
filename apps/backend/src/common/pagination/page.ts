export interface Page<T> {
  items: T[];
  total: number;
  skip: number;
  limit: number;
  hasMore: boolean;
}

export interface PaginationQuery {
  skip?: number;
  limit?: number;
}

export function buildPage<T>(
  items: T[],
  total: number,
  query: PaginationQuery,
): Page<T> {
  const skip = query.skip ?? 0;
  const limit = query.limit ?? 50;

  return {
    items,
    total,
    skip,
    limit,
    hasMore: skip + items.length < total,
  };
}

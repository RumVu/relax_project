export function pickWeighted<T extends { weight?: number | null }>(
  items: T[],
): T | null {
  if (items.length === 0) {
    return null;
  }

  const totalWeight = items.reduce(
    (sum, item) => sum + Math.max(item.weight ?? 1, 1),
    0,
  );
  let ticket = Math.random() * totalWeight;

  for (const item of items) {
    ticket -= Math.max(item.weight ?? 1, 1);
    if (ticket <= 0) {
      return item;
    }
  }

  return items[items.length - 1];
}

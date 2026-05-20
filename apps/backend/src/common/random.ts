export function pickWeighted<T extends { weight?: number | null }>(
  items: T[],
): T | null {
  if (items.length === 0) {
    return null;
  }

  const weightedItems = items
    .map((item) => ({
      item,
      weight: Math.max(item.weight ?? 1, 0),
    }))
    .filter(({ weight }) => weight > 0);

  if (weightedItems.length === 0) {
    return null;
  }

  const totalWeight = weightedItems.reduce(
    (sum, { weight }) => sum + weight,
    0,
  );
  let ticket = Math.random() * totalWeight;

  for (const { item, weight } of weightedItems) {
    ticket -= weight;
    if (ticket <= 0) {
      return item;
    }
  }

  return weightedItems[weightedItems.length - 1].item;
}

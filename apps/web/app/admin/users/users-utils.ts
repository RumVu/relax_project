export function randomPassword(): string {
  // 12-char password — at least 1 upper, 1 lower, 1 digit, 1 symbol. Good
  // enough to satisfy the backend's StrongPassword validator.
  const upper = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
  const lower = 'abcdefghijkmnpqrstuvwxyz';
  const digit = '23456789';
  const symbol = '!@#$%^&*()_+-=';
  const pick = (set: string) => set[Math.floor(Math.random() * set.length)];
  const base = [pick(upper), pick(lower), pick(digit), pick(symbol)];
  while (base.length < 12) {
    base.push(pick(upper + lower + digit + symbol));
  }
  return base.sort(() => Math.random() - 0.5).join('');
}

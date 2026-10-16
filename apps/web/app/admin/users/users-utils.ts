export function randomPassword(): string {
  // 12-char password — at least 1 upper, 1 lower, 1 digit, 1 symbol. Good
  // enough to satisfy the backend's StrongPassword validator.
  const upper = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
  const lower = 'abcdefghijkmnpqrstuvwxyz';
  const digit = '23456789';
  const symbol = '!@#$%^&*()_+-=';
  const pick = (set: string) => set[secureRandomInt(set.length)];
  const base = [pick(upper), pick(lower), pick(digit), pick(symbol)];
  while (base.length < 12) {
    base.push(pick(upper + lower + digit + symbol));
  }
  // Fisher–Yates so the guaranteed characters don't sit at fixed positions.
  for (let i = base.length - 1; i > 0; i--) {
    const j = secureRandomInt(i + 1);
    [base[i], base[j]] = [base[j], base[i]];
  }
  return base.join('');
}

/** Uniform integer in [0, max) from the Web Crypto CSPRNG (no modulo bias). */
function secureRandomInt(max: number): number {
  const limit = Math.floor(0x1_0000_0000 / max) * max;
  const buf = new Uint32Array(1);
  do {
    crypto.getRandomValues(buf);
  } while (buf[0] >= limit);
  return buf[0] % max;
}

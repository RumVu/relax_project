import { describe, expect, it } from 'vitest';
import { cn } from './utils';

describe('cn', () => {
  it('joins truthy class names', () => {
    expect(cn('a', 'b')).toBe('a b');
  });

  it('drops falsy values', () => {
    expect(cn('a', false, undefined, null, '', 'b')).toBe('a b');
  });

  it('lets tailwind-merge resolve conflicting tailwind classes', () => {
    // twMerge keeps the last conflicting utility — `p-4` wins over `p-2`.
    expect(cn('p-2', 'p-4')).toBe('p-4');
  });

  it('accepts object syntax via clsx', () => {
    expect(cn({ a: true, b: false, c: true })).toBe('a c');
  });

  it('handles nested arrays', () => {
    expect(cn(['a', ['b', 'c']], 'd')).toBe('a b c d');
  });
});

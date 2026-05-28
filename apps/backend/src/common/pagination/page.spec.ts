import { buildPage } from './page';

describe('buildPage', () => {
  it('defaults skip to 0 and limit to 50 when not provided', () => {
    const page = buildPage([{ id: '1' }, { id: '2' }], 2, {});

    expect(page.items).toHaveLength(2);
    expect(page.total).toBe(2);
    expect(page.skip).toBe(0);
    expect(page.limit).toBe(50);
    expect(page.hasMore).toBe(false);
  });

  it('echoes the requested skip and limit', () => {
    const page = buildPage([{ id: 'a' }], 5, { skip: 4, limit: 1 });

    expect(page.skip).toBe(4);
    expect(page.limit).toBe(1);
  });

  it('flags hasMore when the current window does not reach total', () => {
    const page = buildPage([{ id: '1' }, { id: '2' }], 10, {
      skip: 0,
      limit: 2,
    });

    expect(page.hasMore).toBe(true);
  });

  it('does not flag hasMore when the window covers the remainder', () => {
    const page = buildPage([{ id: '9' }, { id: '10' }], 10, {
      skip: 8,
      limit: 5,
    });

    expect(page.hasMore).toBe(false);
  });

  it('handles an empty page gracefully', () => {
    const page = buildPage<{ id: string }>([], 0, { skip: 0, limit: 20 });

    expect(page.items).toEqual([]);
    expect(page.total).toBe(0);
    expect(page.hasMore).toBe(false);
  });

  it('treats skip beyond total as no more results', () => {
    const page = buildPage<{ id: string }>([], 7, { skip: 100, limit: 10 });

    expect(page.items).toEqual([]);
    expect(page.hasMore).toBe(false);
  });
});

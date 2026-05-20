import {
  createTimezoneContext,
  getLocalWeekStart,
  getTimezoneOffsetMinutes,
  startOfLocalDay,
  toLocalDateKey,
} from './timezone';

describe('timezone helpers', () => {
  it('uses the offset for the target date instead of a global current offset', () => {
    const timezone = 'America/New_York';

    expect(
      getTimezoneOffsetMinutes(timezone, new Date('2026-01-01T12:00:00Z')),
    ).toBe(-300);
    expect(
      getTimezoneOffsetMinutes(timezone, new Date('2026-07-01T12:00:00Z')),
    ).toBe(-240);
  });

  it('keeps winter near-midnight check-ins on the correct local day during DST season', () => {
    const context = createTimezoneContext('America/New_York');
    const winterCheckin = new Date('2026-01-02T04:30:00.000Z');

    expect(toLocalDateKey(winterCheckin, context)).toBe('2026-01-01');
    expect(startOfLocalDay(winterCheckin, context).toISOString()).toBe(
      '2026-01-01T05:00:00.000Z',
    );
  });

  it('materializes week starts with the date-specific DST offset', () => {
    const context = createTimezoneContext('America/New_York');

    expect(
      getLocalWeekStart(
        new Date('2026-01-02T04:30:00.000Z'),
        context,
      ).toISOString(),
    ).toBe('2025-12-29T05:00:00.000Z');
    expect(
      getLocalWeekStart(
        new Date('2026-07-02T04:30:00.000Z'),
        context,
      ).toISOString(),
    ).toBe('2026-06-29T04:00:00.000Z');
  });
});

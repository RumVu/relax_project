import { PrismaService } from '../prisma/prisma.service';
import { ContentService } from './content.service';

type CsvParser = { parseCsv(csv: string): Record<string, string>[] };

describe('ContentService — parseCsv', () => {
  const parser = new ContentService(
    {} as PrismaService,
  ) as unknown as CsvParser;

  it('maps header columns to row values', () => {
    const rows = parser.parseCsv('Title,Category\nRain,"Nature, calm"');
    expect(rows).toEqual([{ title: 'Rain', category: 'Nature, calm' }]);
  });

  it('ignores prototype-polluting headers', () => {
    const rows = parser.parseCsv('__proto__,constructor,title\nx,y,Rain');
    expect(rows[0].title).toBe('Rain');
    expect(Object.keys(rows[0])).toEqual(['title']);
    expect(({} as Record<string, unknown>).x).toBeUndefined();
  });

  it('caps the number of columns', () => {
    const header = Array.from({ length: 500 }, (_, i) => `c${i}`).join(',');
    const rows = parser.parseCsv(`${header}\n1`);
    expect(Object.keys(rows[0])).toHaveLength(50);
  });
});

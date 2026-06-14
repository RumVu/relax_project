import { Injectable } from '@nestjs/common';
import { MoodType } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class ContentService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Parse CSV data and upsert CozyQuote records.
   * Expected columns: content,author,mood,lang
   */
  async bulkImportQuotes(csvData: string) {
    const rows = this.parseCsv(csvData);
    let imported = 0;
    let skipped = 0;

    for (const row of rows) {
      const content = row['content']?.trim();
      if (!content) {
        skipped++;
        continue;
      }

      const author = row['author']?.trim() || null;
      const moodRaw = row['mood']?.trim().toUpperCase();
      const mood =
        moodRaw && Object.values(MoodType).includes(moodRaw as MoodType)
          ? (moodRaw as MoodType)
          : null;
      const lang = row['lang']?.trim() || 'vi';

      const existing = await this.prisma.cozyQuote.findFirst({
        where: { content, author: author ?? undefined, lang },
        select: { id: true },
      });

      if (existing) {
        await this.prisma.cozyQuote.update({
          where: { id: existing.id },
          data: { mood, isActive: true },
        });
      } else {
        await this.prisma.cozyQuote.create({
          data: { content, author, mood, lang, isActive: true },
        });
      }
      imported++;
    }

    return { imported, skipped, total: rows.length };
  }

  /**
   * Parse CSV data and upsert AmbientSound records.
   * Expected columns: title,category,soundUrl,imageUrl
   */
  async bulkImportSounds(csvData: string) {
    const rows = this.parseCsv(csvData);
    let imported = 0;
    let skipped = 0;

    for (const row of rows) {
      const title = row['title']?.trim();
      if (!title) {
        skipped++;
        continue;
      }

      const category = row['category']?.trim().toUpperCase() || 'NATURE';
      const soundUrl =
        row['soundUrl']?.trim() || row['sound_url']?.trim() || '';
      const imageUrl =
        row['imageUrl']?.trim() || row['image_url']?.trim() || null;

      const existing = await this.prisma.ambientSound.findFirst({
        where: { title, category },
        select: { id: true },
      });

      if (existing) {
        await this.prisma.ambientSound.update({
          where: { id: existing.id },
          data: { soundUrl, imageUrl, isActive: true },
        });
      } else {
        await this.prisma.ambientSound.create({
          data: { title, category, soundUrl, imageUrl, isActive: true },
        });
      }
      imported++;
    }

    return { imported, skipped, total: rows.length };
  }

  /**
   * Parse CSV data and upsert MeditationGuide records.
   * Expected columns: title,description,type,durationMinutes,audioUrl,imageUrl,difficulty,instructor
   */
  async bulkImportMeditations(csvData: string) {
    const rows = this.parseCsv(csvData);
    let imported = 0;
    let skipped = 0;

    for (const row of rows) {
      const title = row['title']?.trim();
      if (!title) {
        skipped++;
        continue;
      }

      const description = row['description']?.trim() || null;
      const type = row['type']?.trim() || row['focusarea']?.trim() || 'GUIDED';
      const durationMinutes = parseInt(
        row['durationminutes']?.trim() || row['duration']?.trim() || '5',
        10,
      );
      const audioUrl = row['audiourl']?.trim() || null;
      const imageUrl = row['imageurl']?.trim() || null;
      const difficulty = row['difficulty']?.trim().toUpperCase() || 'BEGINNER';
      const instructor = row['instructor']?.trim() || 'Admin';

      const existing = await this.prisma.meditationGuide.findFirst({
        where: { title },
        select: { id: true },
      });

      if (existing) {
        await this.prisma.meditationGuide.update({
          where: { id: existing.id },
          data: {
            description,
            focusArea: type,
            duration: isNaN(durationMinutes) ? 5 : durationMinutes,
            audioUrl,
            imageUrl,
            difficulty,
            instructor,
            isActive: true,
          },
        });
      } else {
        await this.prisma.meditationGuide.create({
          data: {
            title,
            description,
            focusArea: type,
            duration: isNaN(durationMinutes) ? 5 : durationMinutes,
            audioUrl,
            imageUrl,
            difficulty,
            instructor,
            isActive: true,
          },
        });
      }
      imported++;
    }

    return { imported, skipped, total: rows.length };
  }

  /**
   * Get content statistics by type and status.
   */
  async getContentStats() {
    const [
      quotesActive,
      quotesInactive,
      soundsActive,
      soundsInactive,
      meditationsActive,
      meditationsInactive,
      exercisesActive,
      exercisesInactive,
      themesActive,
      themesInactive,
    ] = await Promise.all([
      this.prisma.cozyQuote.count({ where: { isActive: true } }),
      this.prisma.cozyQuote.count({ where: { isActive: false } }),
      this.prisma.ambientSound.count({ where: { isActive: true } }),
      this.prisma.ambientSound.count({ where: { isActive: false } }),
      this.prisma.meditationGuide.count({ where: { isActive: true } }),
      this.prisma.meditationGuide.count({ where: { isActive: false } }),
      this.prisma.breathingExercise.count({ where: { isActive: true } }),
      this.prisma.breathingExercise.count({ where: { isActive: false } }),
      this.prisma.appTheme.count({ where: { isActive: true } }),
      this.prisma.appTheme.count({ where: { isActive: false } }),
    ]);

    return {
      quotes: {
        active: quotesActive,
        inactive: quotesInactive,
        total: quotesActive + quotesInactive,
      },
      sounds: {
        active: soundsActive,
        inactive: soundsInactive,
        total: soundsActive + soundsInactive,
      },
      meditations: {
        active: meditationsActive,
        inactive: meditationsInactive,
        total: meditationsActive + meditationsInactive,
      },
      exercises: {
        active: exercisesActive,
        inactive: exercisesInactive,
        total: exercisesActive + exercisesInactive,
      },
      themes: {
        active: themesActive,
        inactive: themesInactive,
        total: themesActive + themesInactive,
      },
    };
  }

  /**
   * Simple CSV parser — handles quoted fields and newlines within quotes.
   */
  private parseCsv(csvData: string): Record<string, string>[] {
    const lines = csvData
      .split('\n')
      .map((l) => l.trim())
      .filter(Boolean);
    if (lines.length < 2) return [];

    const headers = this.splitCsvLine(lines[0]).map((h) =>
      h.trim().toLowerCase(),
    );
    const rows: Record<string, string>[] = [];

    for (let i = 1; i < lines.length; i++) {
      const values = this.splitCsvLine(lines[i]);
      const row: Record<string, string> = {};
      for (let j = 0; j < headers.length; j++) {
        row[headers[j]] = values[j]?.trim() ?? '';
      }
      rows.push(row);
    }

    return rows;
  }

  private splitCsvLine(line: string): string[] {
    const result: string[] = [];
    let current = '';
    let inQuotes = false;

    for (let i = 0; i < line.length; i++) {
      const char = line[i];
      if (inQuotes) {
        if (char === '"') {
          if (i + 1 < line.length && line[i + 1] === '"') {
            current += '"';
            i++;
          } else {
            inQuotes = false;
          }
        } else {
          current += char;
        }
      } else if (char === '"') {
        inQuotes = true;
      } else if (char === ',') {
        result.push(current);
        current = '';
      } else {
        current += char;
      }
    }
    result.push(current);
    return result;
  }
}

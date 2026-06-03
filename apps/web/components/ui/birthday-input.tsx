'use client';

/**
 * BirthdayInput — three locked DD / MM / YYYY fields.
 *
 * Why not <input type="date">?
 *   - The browser renders it using the OS locale: en-US shows MM/DD/YYYY,
 *     vi-VN shows DD/MM/YYYY, etc. A user typing "12/01/2003" on an
 *     en-US machine thinking "12 Jan" actually picks December 1 and the
 *     zodiac sign comes out wrong (the bug we saw in the screenshot).
 *   - Forcing three labelled boxes makes the order unambiguous regardless
 *     of language/locale.
 *
 * Value contract: ISO 8601 date string (YYYY-MM-DD) in/out, the same shape
 * the backend Profile stores. An empty string clears the field.
 */

import { useEffect, useMemo, useState } from 'react';
import { useTranslation } from '@/lib/i18n/i18n-provider';

interface BirthdayInputProps {
  label: string;
  /** ISO YYYY-MM-DD or empty string. */
  value: string;
  /** Emits ISO YYYY-MM-DD when all three parts are filled and valid; otherwise emits ''. */
  onChange?: (iso: string) => void;
}

function splitIso(iso: string): { day: string; month: string; year: string } {
  if (!iso) return { day: '', month: '', year: '' };
  const m = iso.match(/^(\d{4})-(\d{2})-(\d{2})$/);
  if (!m) return { day: '', month: '', year: '' };
  return { year: m[1], month: m[2], day: m[3] };
}

/** True only when the three parts form a real calendar date. Guards against
 *  things like 31/02 silently rolling over to March 3 in Date(). */
function isValidDate(day: number, month: number, year: number): boolean {
  if (year < 1900 || year > 2100) return false;
  if (month < 1 || month > 12) return false;
  if (day < 1 || day > 31) return false;
  const d = new Date(Date.UTC(year, month - 1, day));
  return (
    d.getUTCFullYear() === year &&
    d.getUTCMonth() === month - 1 &&
    d.getUTCDate() === day
  );
}

export function BirthdayInput({ label, value, onChange }: BirthdayInputProps) {
  const { t } = useTranslation();
  const initial = useMemo(() => splitIso(value), [value]);
  const [day, setDay] = useState(initial.day);
  const [month, setMonth] = useState(initial.month);
  const [year, setYear] = useState(initial.year);

  // Re-sync local state whenever the parent prop changes (eg. server load).
  useEffect(() => {
    const next = splitIso(value);
    setDay(next.day);
    setMonth(next.month);
    setYear(next.year);
  }, [value]);

  const emit = (d: string, m: string, y: string) => {
    if (!onChange) return;
    if (!d || !m || !y) {
      onChange('');
      return;
    }
    const dn = Number(d);
    const mn = Number(m);
    const yn = Number(y);
    if (!isValidDate(dn, mn, yn)) {
      // Keep parent's previous value rather than emitting garbage —
      // the local inputs still show what the user is typing so they
      // can fix the mistake.
      return;
    }
    const iso = `${String(yn).padStart(4, '0')}-${String(mn).padStart(2, '0')}-${String(dn).padStart(2, '0')}`;
    onChange(iso);
  };

  const handle = (
    setter: (s: string) => void,
    next: string,
    maxLen: number,
    cb: (cleaned: string) => void,
  ) => {
    // Strip anything that isn't a digit so paste / IME doesn't break.
    const cleaned = next.replace(/[^\d]/g, '').slice(0, maxLen);
    setter(cleaned);
    cb(cleaned);
  };

  // Live preview of the invalid state so the user gets immediate feedback.
  const invalid =
    Boolean(day && month && year) &&
    !isValidDate(Number(day), Number(month), Number(year));

  return (
    <div>
      <span className="text-sm font-semibold text-slate">{label}</span>
      <div
        className={`mt-2 grid grid-cols-[1fr_1fr_1.2fr] gap-2 rounded-lg border bg-white/85 p-1.5 ${
          invalid ? 'border-coral' : 'border-lilac focus-within:border-violet'
        }`}
        role="group"
      >
        <input
          aria-label={t('birthday.day')}
          className="h-9 w-full rounded-md bg-transparent px-2 text-center text-sm font-semibold text-ink outline-none"
          inputMode="numeric"
          maxLength={2}
          onChange={(e) =>
            handle(setDay, e.target.value, 2, (v) => emit(v, month, year))
          }
          placeholder={t('birthday.placeholder.day')}
          value={day}
        />
        <input
          aria-label={t('birthday.month')}
          className="h-9 w-full rounded-md bg-transparent px-2 text-center text-sm font-semibold text-ink outline-none"
          inputMode="numeric"
          maxLength={2}
          onChange={(e) =>
            handle(setMonth, e.target.value, 2, (v) => emit(day, v, year))
          }
          placeholder={t('birthday.placeholder.month')}
          value={month}
        />
        <input
          aria-label={t('birthday.year')}
          className="h-9 w-full rounded-md bg-transparent px-2 text-center text-sm font-semibold text-ink outline-none"
          inputMode="numeric"
          maxLength={4}
          onChange={(e) =>
            handle(setYear, e.target.value, 4, (v) => emit(day, month, v))
          }
          placeholder={t('birthday.placeholder.year')}
          value={year}
        />
      </div>
      <p
        className={`mt-1 text-xs ${
          invalid ? 'text-coral' : 'text-[var(--app-muted,#94a3b8)]'
        }`}
      >
        {invalid ? t('birthday.invalid') : t('birthday.format')}
      </p>
    </div>
  );
}

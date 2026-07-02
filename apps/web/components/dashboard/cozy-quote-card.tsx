'use client';

/**
 * CozyQuoteCard — "Lời nhắn chữa lành hôm nay" widget for the dashboard
 * overview. Calls /v1/cozy-quotes/random by default, or
 * /v1/cozy-quotes/mood/{mood} when a current mood is known.
 *
 * Wired up so the dashboard always shows something even if the API is
 * unreachable (silent fallback to a default quote).
 */

import { useCallback, useEffect, useState } from 'react';
import { Quote, RefreshCcw } from 'lucide-react';
import { apiFetch } from '@/lib/api';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { CatMascot } from '@/components/dashboard/cat-mascot';
import { useTranslation } from '@/lib/i18n/i18n-provider';

interface CozyQuote {
  id: string;
  content: string;
  author?: string | null;
  mood?: string | null;
  imageUrl?: string | null;
}

const FALLBACK: CozyQuote = {
  id: 'fallback',
  content:
    'Hôm nay không cần phải hoàn hảo. Chỉ cần bạn đang ở đây là đã đủ rồi.',
  author: 'Relax',
};

export function CozyQuoteCard({ currentMood }: { currentMood?: string | null }) {
  const { t } = useTranslation();
  const [quote, setQuote] = useState<CozyQuote | null>(null);
  const [loading, setLoading] = useState(false);

  const fetchOne = useCallback(async () => {
    setLoading(true);
    try {
      // Prefer mood-matched quote when we know the user's current mood —
      // the API returns an array; otherwise hit /random which returns one row.
      if (currentMood && /^[A-Z_]+$/.test(currentMood)) {
        const list = await apiFetch<CozyQuote[]>(
          `/cozy-quotes/mood/${currentMood}`,
        );
        if (Array.isArray(list) && list.length > 0) {
          setQuote(list[Math.floor(Math.random() * list.length)]);
          return;
        }
      }
      const random = await apiFetch<CozyQuote>('/cozy-quotes/random');
      setQuote(random);
    } catch {
      setQuote(FALLBACK);
    } finally {
      setLoading(false);
    }
  }, [currentMood]);

  useEffect(() => {
    const timer = setTimeout(() => {
      void fetchOne();
    }, 0);
    return () => clearTimeout(timer);
  }, [fetchOne]);

  const display = quote ?? FALLBACK;
  const hasImage = Boolean(display.imageUrl);

  const bgStyle = hasImage
    ? {
        backgroundImage: `linear-gradient(135deg, rgba(115,87,246,0.78), rgba(20,18,46,0.86)), url(${display.imageUrl})`,
        backgroundSize: 'cover',
        backgroundPosition: 'center',
      }
    : { background: 'linear-gradient(135deg, #7357f6, #14122e)' };

  return (
    <Card className="relative overflow-hidden p-0">
      <div className="flex gap-4 p-5 text-white" style={bgStyle}>
        <div className="flex min-w-0 flex-1 flex-col gap-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2 text-xs font-semibold uppercase tracking-wider text-mist/80">
              <Quote className="h-4 w-4" />
              {t('quote.widget.eyebrow')}
            </div>
            <Button
              disabled={loading}
              onClick={fetchOne}
              variant="ghost"
            >
              <RefreshCcw className={`h-4 w-4 ${loading ? 'animate-spin' : ''}`} />
              <span className="sr-only">{t('quote.widget.refresh')}</span>
            </Button>
          </div>
          <p className="text-lg font-semibold leading-snug md:text-xl">
            {'“'}{display.content}{'”'}
          </p>
          {display.author ? (
            <p className="text-sm font-medium text-mist/70">{'—'} {display.author}</p>
          ) : null}
        </div>
        <div className="flex shrink-0 items-end">
          <CatMascot variant="stand" size="md" className="opacity-90 sm:h-20 sm:w-20" />
        </div>
      </div>
    </Card>
  );
}

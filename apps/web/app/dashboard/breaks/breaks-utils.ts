import { CheckCircle2, Headphones, PenLine, Shuffle, Wind } from 'lucide-react';

export const activityIcons = {
  MUSIC: Headphones,
  PODCAST: Headphones,
  JOURNAL: PenLine,
  BREATHING: Wind,
  MYSTERY: Shuffle,
  MEDITATION: CheckCircle2,
};

export function formatTrackDuration(seconds?: number | null) {
  if (!seconds) return '';
  const minutes = Math.floor(seconds / 60);
  const rest = seconds % 60;
  return `${minutes}:${String(rest).padStart(2, '0')}`;
}

/**
 * Build dashboard recommendation cards (Meditation/Breathing/Journal/Music).
 * Pure: nhận action + mood + 3 resource records (đã fetch sẵn) → trả card object.
 */
import { AmbientSound, BreathingExercise, CozyQuote, MoodType } from '@prisma/client';
import { MoodActionType } from '../mood-options';

const TITLES: Record<MoodActionType, string> = {
  MEDITATION: 'Thiền định',
  BREATHING: 'Hít thở',
  JOURNAL: 'Viết nhật ký',
  MUSIC: 'Nghe nhạc',
};

const ICON_KEYS: Record<MoodActionType, string> = {
  MEDITATION: 'lotus',
  BREATHING: 'breath-cloud',
  JOURNAL: 'journal',
  MUSIC: 'headphones',
};

const BASE_LINKS: Record<MoodActionType, string> = {
  MEDITATION: 'relax://meditation',
  BREATHING: 'relax://breathing-exercises',
  JOURNAL: 'relax://journals/new',
  MUSIC: 'relax://ambient-sounds',
};

export function buildRecommendation(
  action: MoodActionType,
  mood: MoodType,
  breathingExercise: BreathingExercise | null,
  ambientSound: AmbientSound | null,
  cozyQuote: CozyQuote | null,
) {
  const linkedResource =
    action === 'BREATHING'
      ? breathingExercise
      : action === 'MUSIC'
        ? ambientSound
        : action === 'JOURNAL'
          ? cozyQuote
          : null;

  return {
    type: action,
    title: TITLES[action],
    iconKey: ICON_KEYS[action],
    reason: getRecommendationReason(action, mood),
    deepLink: getRecommendationDeepLink(action, linkedResource?.id),
    linkedResource,
  };
}

export function getRecommendationReason(
  action: MoodActionType,
  mood: MoodType,
): string {
  if (action === 'BREATHING') {
    return mood === MoodType.STRESSED || mood === MoodType.ANXIOUS
      ? 'Giúp hạ nhịp căng thẳng nhanh hơn.'
      : 'Giữ nhịp cơ thể nhẹ và đều hơn.';
  }

  if (action === 'JOURNAL') {
    return 'Ghi vài dòng để nhìn rõ cảm xúc hiện tại.';
  }

  if (action === 'MUSIC') {
    return 'Một nền âm thanh mềm sẽ giúp mood dễ dịu lại.';
  }

  return 'Một khoảng lặng nhỏ để quay về với mình.';
}

export function getRecommendationDeepLink(
  action: MoodActionType,
  resourceId?: string,
): string {
  return resourceId ? `${BASE_LINKS[action]}/${resourceId}` : BASE_LINKS[action];
}

/**
 * Map mood → list of AmbientSound categories ordered by preference.
 * Used to query `prisma.ambientSound.findFirst({ where: { category: { in } } })`.
 */
export function getSoundCategoriesForMood(mood: MoodType): string[] {
  const tenseMoods: MoodType[] = [MoodType.STRESSED, MoodType.ANXIOUS];
  const lowEnergyMoods: MoodType[] = [
    MoodType.SAD,
    MoodType.LONELY,
    MoodType.TIRED,
  ];

  if (tenseMoods.includes(mood)) {
    return ['RAIN', 'NATURE', 'MEDITATION', 'CALM'];
  }

  if (lowEnergyMoods.includes(mood)) {
    return ['PIANO', 'LOFI', 'AMBIENT', 'CALM'];
  }

  return ['LOFI', 'NATURE', 'AMBIENT', 'RAIN'];
}

/**
 * Quest catalogue.
 *
 * Each template describes ONE mission a user can be assigned. The metric
 * gets evaluated by `evaluateQuest()` against the user's actual activity
 * since the quest was assigned (or since start-of-day, for daily ones)
 * — so the same template can either be "do once today" or "do N times
 * this week" depending on the `scope` and `target`.
 *
 * IMPORTANT: `code` is the stable id stored on `UserQuest.templateCode`.
 * Renaming it would orphan existing assignments — add a new template
 * instead, leave the old one in place.
 */

export type QuestScope = 'today' | 'week' | 'all-time';

export type QuestMetric =
  /** Distinct day-buckets where the action happened. */
  | 'mood_checkins'
  | 'journal_entries'
  | 'breathing_sessions'
  | 'sound_minutes'
  | 'relax_sessions'
  | 'companion_interactions'
  | 'favorite_journals'
  | 'distinct_mood_types'
  | 'distinct_journal_tags';

export interface QuestTemplate {
  code: string;
  scope: QuestScope;
  target: number;
  metric: QuestMetric;
  /** Bilingual copy — picked at API time based on caller locale. */
  title: { vi: string; en: string };
  description: { vi: string; en: string };
  /** Category for the UI badge / icon — keep small. */
  category: 'journal' | 'mood' | 'breathing' | 'sound' | 'companion' | 'streak';
}

export const QUEST_TEMPLATES: QuestTemplate[] = [
  {
    code: 'JOURNAL_TODAY',
    scope: 'today',
    target: 1,
    metric: 'journal_entries',
    category: 'journal',
    title: { vi: 'Viết nhật ký hôm nay', en: 'Write a journal entry today' },
    description: {
      vi: 'Ghi lại một vài dòng trong nhật ký — đủ ngắn để không tốn thời gian, đủ dài để bạn nhìn lại sau này.',
      en: 'Jot down a few lines — short enough not to feel like work, long enough to look back on.',
    },
  },
  {
    code: 'JOURNAL_WEEK_3',
    scope: 'week',
    target: 3,
    metric: 'journal_entries',
    category: 'journal',
    title: { vi: 'Viết 3 nhật ký trong tuần', en: 'Write 3 journal entries this week' },
    description: {
      vi: 'Mỗi lần 2 phút thôi cũng đủ để duy trì thói quen.',
      en: 'Two minutes per entry is plenty to keep the habit alive.',
    },
  },
  {
    code: 'JOURNAL_FAVORITE',
    scope: 'all-time',
    target: 1,
    metric: 'favorite_journals',
    category: 'journal',
    title: { vi: 'Đánh dấu yêu thích một nhật ký', en: 'Favourite a journal entry' },
    description: {
      vi: 'Lưu lại một dòng tự hào để đọc lại vào ngày buồn.',
      en: 'Pin a proud line so a low day has something to come back to.',
    },
  },
  {
    code: 'JOURNAL_TAGS',
    scope: 'all-time',
    target: 3,
    metric: 'distinct_journal_tags',
    category: 'journal',
    title: { vi: 'Dùng 3 thẻ khác nhau', en: 'Use 3 different tags' },
    description: {
      vi: 'Đa dạng chủ đề giúp bạn nhìn xu hướng cảm xúc rõ hơn theo thời gian.',
      en: 'Varied tags reveal mood patterns when you scroll back later.',
    },
  },
  {
    code: 'MOOD_TODAY',
    scope: 'today',
    target: 1,
    metric: 'mood_checkins',
    category: 'mood',
    title: { vi: 'Ghi cảm xúc hôm nay', en: 'Check in your mood today' },
    description: {
      vi: 'Một giây để chọn icon — đủ để hệ thống vẽ biểu đồ cho bạn.',
      en: 'One tap to pick an emoji — enough for the charts to draw your week.',
    },
  },
  {
    code: 'MOOD_WEEK_3',
    scope: 'week',
    target: 3,
    metric: 'mood_checkins',
    category: 'mood',
    title: { vi: 'Ghi cảm xúc 3 ngày trong tuần', en: 'Mood check-ins on 3 different days' },
    description: {
      vi: 'Cách nhanh nhất để cải thiện chuỗi (streak) là bắt đầu nhịp 3 ngày.',
      en: 'A 3-day rhythm is the fastest path to a real streak.',
    },
  },
  {
    code: 'MOOD_DIVERSE',
    scope: 'week',
    target: 3,
    metric: 'distinct_mood_types',
    category: 'mood',
    title: { vi: 'Ghi nhận 3 loại cảm xúc khác nhau', en: 'Log 3 distinct mood types' },
    description: {
      vi: 'Cảm xúc nào cũng có chỗ đứng — đừng chỉ ghi khi vui.',
      en: 'Every mood counts — not just the happy ones.',
    },
  },
  {
    code: 'BREATHING_TODAY',
    scope: 'today',
    target: 1,
    metric: 'breathing_sessions',
    category: 'breathing',
    title: { vi: 'Hít thở một phiên hôm nay', en: 'Do one breathing session today' },
    description: {
      vi: 'Mỗi bài thở 2-5 phút giúp nhịp tim chậm lại rõ rệt.',
      en: 'Two to five minutes is enough to slow your heart-rate noticeably.',
    },
  },
  {
    code: 'BREATHING_WEEK_3',
    scope: 'week',
    target: 3,
    metric: 'breathing_sessions',
    category: 'breathing',
    title: { vi: 'Hít thở 3 phiên trong tuần', en: '3 breathing sessions this week' },
    description: {
      vi: 'Bài tập dễ làm nhất khi bạn cảm thấy quá tải.',
      en: 'The easiest exercise to reach for when you feel overloaded.',
    },
  },
  {
    code: 'SOUND_10MIN',
    scope: 'today',
    target: 10,
    metric: 'sound_minutes',
    category: 'sound',
    title: { vi: 'Nghe 10 phút âm thanh thư giãn', en: 'Listen to 10 min of ambient sound' },
    description: {
      vi: 'Mở mưa rơi, lofi hoặc tiếng mèo trong lúc làm việc cũng tính.',
      en: 'Rain, lofi or cat purrs in the background while you work all count.',
    },
  },
  {
    code: 'RELAX_TODAY',
    scope: 'today',
    target: 1,
    metric: 'relax_sessions',
    category: 'breathing',
    title: { vi: 'Hoàn thành một phiên thư giãn', en: 'Finish one relax session today' },
    description: {
      vi: 'Bắt đầu → kết thúc một phiên ở trang Nghỉ ngơi để hệ thống ghi nhận.',
      en: 'Start → finish a session on the Breaks page so it counts.',
    },
  },
  {
    code: 'COMPANION_TODAY',
    scope: 'today',
    target: 1,
    metric: 'companion_interactions',
    category: 'companion',
    title: { vi: 'Tương tác với linh thú hôm nay', en: 'Greet your companion today' },
    description: {
      vi: 'Vuốt ve, cho ăn hoặc chơi — chọn cái nào cũng được.',
      en: 'Pet, feed or play — any of the three keeps the bond up.',
    },
  },
];

export function pickQuestTemplate(code: string): QuestTemplate | undefined {
  return QUEST_TEMPLATES.find((t) => t.code === code);
}

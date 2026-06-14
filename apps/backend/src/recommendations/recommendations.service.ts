import { Injectable } from '@nestjs/common';
import {
  MoodType,
  TriggerType,
  RelaxSession,
  ContentRating,
  RelaxActivityType,
} from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';

interface RecentTriggerInfo {
  trigger: TriggerType | null;
  mood: MoodType;
  createdAt: Date;
}

@Injectable()
export class RecommendationsService {
  constructor(private readonly prisma: PrismaService) {}

  async getTodayRecommendations(userId: string) {
    // 1. Get latest mood checkin
    const latestMood = await this.prisma.moodCheckin.findFirst({
      where: { userId },
      orderBy: { createdAt: 'desc' },
    });

    // 2. Get user's top-rated content
    const topRated = await this.prisma.contentRating.findMany({
      where: { userId, rating: { gte: 4 } },
      orderBy: { rating: 'desc' },
      take: 10,
    });

    // 3. Get session history with best relief
    const bestSessions = await this.prisma.relaxSession.findMany({
      where: {
        userId,
        status: 'FINISHED',
        stressReliefPercent: { not: null },
      },
      orderBy: { stressReliefPercent: 'desc' },
      take: 20,
    });

    // 4. Get user preferences for timezone (to determine time of day)
    const prefs = await this.prisma.userPreference.findUnique({
      where: { userId },
    });

    // 5. Get trigger patterns
    const recentTriggers = await this.prisma.moodCheckin.findMany({
      where: {
        userId,
        trigger: { not: null },
        createdAt: { gte: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000) },
      },
      select: { trigger: true, mood: true, createdAt: true },
    });

    const currentMood = latestMood?.mood ?? MoodType.NEUTRAL;
    const currentTrigger = latestMood?.trigger;
    const hour = this.getUserHour(prefs?.timezone);

    // Build 3 smart recommendations
    const recommendations = this.buildSmartRecommendations(
      currentMood,
      currentTrigger,
      hour,
      bestSessions,
      topRated,
      recentTriggers,
    );

    return {
      recommendations,
      currentMood,
      generatedAt: new Date().toISOString(),
    };
  }

  private buildSmartRecommendations(
    mood: MoodType,
    trigger: TriggerType | null | undefined,
    hour: number,
    bestSessions: RelaxSession[],
    topRated: ContentRating[],
    recentTriggers: RecentTriggerInfo[],
  ) {
    const items: Array<{
      type: string;
      title: string;
      reason: string;
      score: number;
      deepLink: string;
    }> = [];

    // Rule 1: Mood-based primary recommendation
    const moodRec = this.getMoodBasedRec(mood);
    items.push({ ...moodRec, score: 100 });

    // Rule 2: History-based — find what worked best for similar mood
    const historyRec = this.getHistoryBasedRec(mood, bestSessions, topRated);
    if (historyRec) items.push({ ...historyRec, score: 90 });

    // Rule 3: Time/trigger contextual recommendation
    const contextRec = this.getContextualRec(
      mood,
      trigger,
      hour,
      recentTriggers,
    );
    if (contextRec) items.push({ ...contextRec, score: 80 });

    // Fill to 3 if needed
    const fallbacks = this.getFallbackRecs();
    while (items.length < 3 && fallbacks.length > 0) {
      const fb = fallbacks.shift()!;
      if (!items.find((i) => i.type === fb.type)) {
        items.push({ ...fb, score: 70 - items.length * 10 });
      }
    }

    return items.slice(0, 3);
  }

  private getMoodBasedRec(mood: MoodType) {
    const map: Record<
      string,
      { type: string; title: string; reason: string; deepLink: string }
    > = {
      ANXIOUS: {
        type: 'BREATHING',
        title: 'Box Breathing 3 phút',
        reason: 'Mood đang anxious — breathing giúp hạ nhịp tim nhanh nhất',
        deepLink: 'relax://breathing-exercises',
      },
      STRESSED: {
        type: 'BREATHING',
        title: 'Hít thở sâu',
        reason: 'Đang stressed — kỹ thuật thở giúp giảm cortisol',
        deepLink: 'relax://breathing-exercises',
      },
      SAD: {
        type: 'MUSIC',
        title: 'Nhạc nhẹ nhàng',
        reason: 'Mood đang buồn — âm thanh dịu giúp nâng tâm trạng',
        deepLink: 'relax://ambient-sounds',
      },
      LONELY: {
        type: 'JOURNAL',
        title: 'Viết vài dòng',
        reason: 'Đang cô đơn — journal giúp nhìn rõ cảm xúc hơn',
        deepLink: 'relax://journals/new',
      },
      TIRED: {
        type: 'MEDITATION',
        title: 'Thiền nghỉ ngơi',
        reason: 'Đang mệt — 5 phút thiền giúp phục hồi năng lượng',
        deepLink: 'relax://meditation',
      },
      HAPPY: {
        type: 'JOURNAL',
        title: 'Ghi lại khoảnh khắc vui',
        reason: 'Đang vui — viết lại để nhớ mãi',
        deepLink: 'relax://journals/new',
      },
      CALM: {
        type: 'MEDITATION',
        title: 'Thiền chánh niệm',
        reason: 'Đang bình yên — thiền giúp giữ trạng thái này',
        deepLink: 'relax://meditation',
      },
      EXCITED: {
        type: 'BREATHING',
        title: 'Breathing cân bằng',
        reason: 'Đang hào hứng — breathing giúp giữ focus',
        deepLink: 'relax://breathing-exercises',
      },
      GRATEFUL: {
        type: 'JOURNAL',
        title: 'Nhật ký biết ơn',
        reason: 'Đang biết ơn — viết ra để cảm xúc này sâu hơn',
        deepLink: 'relax://journals/new',
      },
      NEUTRAL: {
        type: 'MEDITATION',
        title: 'Thiền 5 phút',
        reason: 'Một khoảng lặng nhỏ giúp bắt đầu ngày nhẹ hơn',
        deepLink: 'relax://meditation',
      },
    };
    return map[mood] ?? map.NEUTRAL;
  }

  private getHistoryBasedRec(
    mood: MoodType,
    sessions: RelaxSession[],
    ratings: ContentRating[],
  ) {
    // Find sessions where moodBefore matches current mood and had good relief
    const matching = sessions.filter(
      (s) => s.moodBefore === mood && (s.stressReliefPercent ?? 0) >= 50,
    );
    if (matching.length > 0) {
      const best = matching[0];
      const activityLabels: Record<RelaxActivityType, string> = {
        BREATHING: 'Hít thở',
        MEDITATION: 'Thiền',
        MUSIC: 'Nghe nhạc',
        JOURNAL: 'Nhật ký',
        PODCAST: 'Podcast',
        MYSTERY: 'Khám phá',
      };
      const deepLinks: Record<RelaxActivityType, string> = {
        BREATHING: 'relax://breathing-exercises',
        MEDITATION: 'relax://meditation',
        MUSIC: 'relax://ambient-sounds',
        JOURNAL: 'relax://journals/new',
        PODCAST: 'relax://ambient-sounds',
        MYSTERY: 'relax://calm-now',
      };
      return {
        type: best.activityType,
        title: `${activityLabels[best.activityType] ?? best.activityType}${best.title ? ': ' + best.title : ''}`,
        reason: `Lần trước mood ${mood.toLowerCase()} cải thiện ${best.stressReliefPercent}% sau hoạt động này`,
        deepLink: deepLinks[best.activityType] ?? 'relax://calm-now',
      };
    }

    // Fallback: use top-rated content
    if (ratings.length > 0) {
      const top = ratings[0];
      return {
        type: top.contentType,
        title: `Nội dung bạn đánh giá cao`,
        reason: `Bạn đã đánh giá ${top.rating}/5 sao — chắc chắn sẽ giúp`,
        deepLink: `relax://${top.contentType.toLowerCase()}/${top.contentId}`,
      };
    }

    return null;
  }

  private getContextualRec(
    mood: MoodType,
    trigger: TriggerType | null | undefined,
    hour: number,
    recentTriggers: RecentTriggerInfo[],
  ) {
    // Time-based
    if (hour >= 22 || hour < 6) {
      return {
        type: 'MUSIC',
        title: 'Brown noise + Rain',
        reason: 'Đêm khuya — âm thanh này giúp ngủ ngon hơn',
        deepLink: 'relax://ambient-sounds',
      };
    }

    // Trigger-based
    if (trigger) {
      const triggerRecs: Record<
        string,
        { type: string; title: string; reason: string; deepLink: string }
      > = {
        DEADLINE: {
          type: 'BREATHING',
          title: 'Box Breathing',
          reason: `Bạn stress vì deadline — breathing giúp tỉnh táo hơn`,
          deepLink: 'relax://breathing-exercises',
        },
        WORK: {
          type: 'BREATHING',
          title: 'Nghỉ thở 3 phút',
          reason: 'Công việc gây áp lực — tạm dừng 3 phút',
          deepLink: 'relax://breathing-exercises',
        },
        FAMILY: {
          type: 'JOURNAL',
          title: 'Viết ra suy nghĩ',
          reason: 'Gia đình đang là trigger — journal giúp nhìn rõ hơn',
          deepLink: 'relax://journals/new',
        },
        MONEY: {
          type: 'MEDITATION',
          title: 'Thiền bình tĩnh',
          reason: 'Áp lực tài chính — thiền giúp giảm lo lắng',
          deepLink: 'relax://meditation',
        },
        SLEEP: {
          type: 'MUSIC',
          title: 'White noise nhẹ',
          reason: 'Thiếu ngủ — âm thanh nền giúp thư giãn',
          deepLink: 'relax://ambient-sounds',
        },
        RELATIONSHIP: {
          type: 'JOURNAL',
          title: 'Journal suy ngẫm',
          reason: 'Mối quan hệ đang gây stress — viết ra để nhìn rõ',
          deepLink: 'relax://journals/new',
        },
        HEALTH: {
          type: 'MEDITATION',
          title: 'Thiền body scan',
          reason: 'Sức khỏe đang là lo lắng — thiền giúp kết nối cơ thể',
          deepLink: 'relax://meditation',
        },
        SOCIAL_MEDIA: {
          type: 'BREATHING',
          title: 'Digital detox breathing',
          reason: 'Social media gây bất an — tạm ngắt kết nối',
          deepLink: 'relax://breathing-exercises',
        },
        CRAVING: {
          type: 'BREATHING',
          title: 'Craving break',
          reason: 'Cơn thèm đang đến — breathing giúp vượt qua',
          deepLink: 'relax://breathing-exercises',
        },
      };
      if (triggerRecs[trigger]) return triggerRecs[trigger];
    }

    // Pattern-based: find most common trigger and what helps
    if (recentTriggers.length >= 3) {
      const triggerCounts: Record<string, number> = {};
      for (const t of recentTriggers) {
        if (t.trigger)
          triggerCounts[t.trigger] = (triggerCounts[t.trigger] ?? 0) + 1;
      }
      const topTrigger = Object.entries(triggerCounts).sort(
        (a, b) => b[1] - a[1],
      )[0];
      if (topTrigger && topTrigger[1] >= 3) {
        return {
          type: 'JOURNAL',
          title: 'Journal prompt',
          reason: `Bạn hay stress vì ${topTrigger[0].toLowerCase().replace('_', ' ')} (${topTrigger[1]} lần gần đây)`,
          deepLink: 'relax://journals/new',
        };
      }
    }

    // Morning recommendation
    if (hour >= 6 && hour < 10) {
      return {
        type: 'MEDITATION',
        title: 'Thiền buổi sáng',
        reason: 'Buổi sáng — 5 phút thiền giúp bắt đầu ngày nhẹ hơn',
        deepLink: 'relax://meditation',
      };
    }

    return null;
  }

  private getFallbackRecs() {
    return [
      {
        type: 'BREATHING',
        title: 'Hít thở 3 phút',
        reason: 'Luôn hữu ích bất kể tâm trạng',
        deepLink: 'relax://breathing-exercises',
      },
      {
        type: 'JOURNAL',
        title: 'Viết vài dòng',
        reason: 'Ghi chép giúp nhìn rõ cảm xúc hơn',
        deepLink: 'relax://journals/new',
      },
      {
        type: 'MEDITATION',
        title: 'Thiền ngắn',
        reason: 'Một khoảng lặng nhỏ luôn tốt',
        deepLink: 'relax://meditation',
      },
      {
        type: 'MUSIC',
        title: 'Nghe nhạc thư giãn',
        reason: 'Âm thanh nhẹ giúp mood tốt hơn',
        deepLink: 'relax://ambient-sounds',
      },
    ];
  }

  async refreshRecommendations(userId: string) {
    // Delete old recommendations for this user
    await this.prisma.recommendation.deleteMany({ where: { userId } });

    // Generate fresh ones
    const result = await this.getTodayRecommendations(userId);

    // Persist to DB
    for (const rec of result.recommendations) {
      await this.prisma.recommendation.create({
        data: {
          userId,
          contentType: rec.type,
          contentId: rec.deepLink,
          reason: rec.reason,
          score: rec.score,
        },
      });
    }

    return result;
  }

  async rateContent(
    userId: string,
    dto: {
      contentType: string;
      contentId: string;
      rating: number;
      review?: string;
    },
  ) {
    return this.prisma.contentRating.upsert({
      where: {
        userId_contentType_contentId: {
          userId,
          contentType: dto.contentType,
          contentId: dto.contentId,
        },
      },
      update: { rating: dto.rating, review: dto.review },
      create: {
        userId,
        contentType: dto.contentType,
        contentId: dto.contentId,
        rating: dto.rating,
        review: dto.review,
      },
    });
  }

  async getMyRatings(userId: string) {
    return this.prisma.contentRating.findMany({
      where: { userId },
      orderBy: { updatedAt: 'desc' },
    });
  }

  // Trigger analytics: frequency + effective activity per trigger
  async getTriggerAnalytics(userId: string) {
    const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);

    const checkins = await this.prisma.moodCheckin.findMany({
      where: {
        userId,
        trigger: { not: null },
        createdAt: { gte: thirtyDaysAgo },
      },
      select: { trigger: true, mood: true, createdAt: true },
      orderBy: { createdAt: 'desc' },
    });

    const sessions = await this.prisma.relaxSession.findMany({
      where: {
        userId,
        status: 'FINISHED',
        createdAt: { gte: thirtyDaysAgo },
        stressReliefPercent: { not: null },
      },
      select: {
        activityType: true,
        stressReliefPercent: true,
        moodBefore: true,
        createdAt: true,
      },
      orderBy: { stressReliefPercent: 'desc' },
    });

    // Group by trigger
    const triggerMap: Record<
      string,
      {
        count: number;
        moods: string[];
        bestActivity?: string;
        bestRelief?: number;
      }
    > = {};
    for (const c of checkins) {
      const t = c.trigger!;
      if (!triggerMap[t]) triggerMap[t] = { count: 0, moods: [] };
      triggerMap[t].count++;
      triggerMap[t].moods.push(c.mood);
    }

    // Find best activity for each trigger's mood
    for (const [, data] of Object.entries(triggerMap)) {
      const dominantMood = this.getDominantMood(data.moods);
      const matchingSessions = sessions.filter(
        (s) => s.moodBefore === dominantMood,
      );
      if (matchingSessions.length > 0) {
        const best = matchingSessions[0];
        data.bestActivity = best.activityType;
        data.bestRelief = best.stressReliefPercent ?? undefined;
      }
    }

    return Object.entries(triggerMap)
      .map(([trigger, data]) => ({
        trigger,
        frequency: data.count,
        dominantMood: this.getDominantMood(data.moods),
        bestActivity: data.bestActivity ?? null,
        bestRelief: data.bestRelief ?? null,
      }))
      .sort((a, b) => b.frequency - a.frequency);
  }

  private getDominantMood(moods: string[]): string {
    const counts: Record<string, number> = {};
    for (const m of moods) counts[m] = (counts[m] ?? 0) + 1;
    return (
      Object.entries(counts).sort((a, b) => b[1] - a[1])[0]?.[0] ?? 'NEUTRAL'
    );
  }

  private getUserHour(timezone?: string | null): number {
    try {
      const now = new Date();
      const formatter = new Intl.DateTimeFormat('en-US', {
        hour: 'numeric',
        hour12: false,
        timeZone: timezone ?? 'Asia/Ho_Chi_Minh',
      });
      return parseInt(formatter.format(now), 10);
    } catch {
      return new Date().getHours();
    }
  }

  async getPersonalToolkit(userId: string) {
    const latestMood = await this.prisma.moodCheckin.findFirst({
      where: { userId },
      orderBy: { createdAt: 'desc' },
    });
    const currentMood = latestMood?.mood ?? MoodType.NEUTRAL;

    const toolkits: Record<string, { mood: MoodType; title: string; description: string; activities: Array<{ type: string; title: string; deepLink: string }> }> = {
      STRESSED: {
        mood: MoodType.STRESSED,
        title: 'Bộ xoa dịu Căng thẳng',
        description: '3 phút hít thở sâu và âm thanh mưa rơi sẽ giúp giảm cortisol nhanh chóng.',
        activities: [
          { type: 'BREATHING', title: 'Box Breathing 3 phút', deepLink: 'relax://breathing-exercises' },
          { type: 'MUSIC', title: 'Rain sound', deepLink: 'relax://ambient-sounds?preset=rain' },
        ],
      },
      ANXIOUS: {
        mood: MoodType.ANXIOUS,
        title: 'Bộ kiểm soát Lo âu',
        description: 'Thực hiện kỹ thuật tiếp đất Grounding 5-4-3-2-1 để neo giữ tâm trí vào hiện tại.',
        activities: [
          { type: 'BREATHING', title: 'Grounding 5-4-3-2-1', deepLink: 'relax://calm-now' },
        ],
      },
      TIRED: {
        mood: MoodType.TIRED,
        title: 'Bộ tái tạo Năng lượng',
        description: 'Tạm dừng công việc và lắng nghe những âm điệu nhẹ nhàng từ thiên nhiên.',
        activities: [
          { type: 'MEDITATION', title: 'Thiền body scan', deepLink: 'relax://meditation' },
          { type: 'MUSIC', title: 'Nhạc rừng xanh', deepLink: 'relax://ambient-sounds?preset=forest' },
        ],
      },
      SAD: {
        mood: MoodType.SAD,
        title: 'Bộ vỗ về Nỗi buồn',
        description: 'Viết ra những suy nghĩ của bạn và đọc một câu trích dẫn ấm áp.',
        activities: [
          { type: 'JOURNAL', title: 'Nhật ký tự do', deepLink: 'relax://journals/new' },
          { type: 'QUOTE', title: 'Cozy Quote', deepLink: 'relax://home?tab=0' },
        ],
      },
      HAPPY: {
        mood: MoodType.HAPPY,
        title: 'Bộ lưu giữ Niềm vui',
        description: 'Ghi lại khoảnh khắc tích cực hôm nay để trân trọng sau này.',
        activities: [
          { type: 'JOURNAL', title: 'Nhật ký biết ơn', deepLink: 'relax://journals/new' },
        ],
      },
      CALM: {
        mood: MoodType.CALM,
        title: 'Bộ giữ vững Bình yên',
        description: 'Tiếp tục duy trì sự cân bằng của tâm trí.',
        activities: [
          { type: 'MEDITATION', title: 'Thiền sâu', deepLink: 'relax://meditation' },
        ],
      },
      EXCITED: {
        mood: MoodType.EXCITED,
        title: 'Bộ giữ vững Tập trung',
        description: 'Nhịp thở cân bằng giúp chuyển hoá sự phấn khích thành năng lượng làm việc.',
        activities: [
          { type: 'BREATHING', title: 'Hít thở cân bằng', deepLink: 'relax://breathing-exercises' },
        ],
      },
      GRATEFUL: {
        mood: MoodType.GRATEFUL,
        title: 'Bộ lan toả Lòng biết ơn',
        description: 'Cảm nhận sâu sắc hơn nữa sự trân quý cuộc sống bằng một vài dòng nhật ký.',
        activities: [
          { type: 'JOURNAL', title: 'Ghi chép lòng biết ơn', deepLink: 'relax://journals/new' },
        ],
      },
      NEUTRAL: {
        mood: MoodType.NEUTRAL,
        title: 'Bộ cân bằng Hàng ngày',
        description: 'Duy trì sự tập trung và chánh niệm với 5 phút thiền nhẹ nhàng.',
        activities: [
          { type: 'MEDITATION', title: 'Thiền chánh niệm', deepLink: 'relax://meditation' },
        ],
      },
      LONELY: {
        mood: MoodType.LONELY,
        title: 'Bộ kết nối Yêu thương',
        description: 'Trò chuyện cùng linh thú Mon Leo hoặc gửi lời nhắc ấm áp tới nhóm bạn.',
        activities: [
          { type: 'COMPANION', title: 'Companion Chat', deepLink: 'relax://companion-chat' },
          { type: 'BUDDY', title: 'Nudge bạn bè', deepLink: 'relax://buddies' },
        ],
      },
    };

    return toolkits[currentMood] ?? toolkits.NEUTRAL;
  }
}

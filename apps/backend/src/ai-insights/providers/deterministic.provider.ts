import {
  InsightDraft,
  InsightGenerationResult,
  InsightProvider,
  InsightProviderContext,
  RecommendationDraft,
} from '../ai-insights.types';

/**
 * Heuristic provider — used when no Gemini key is configured, or when the
 * Gemini call fails. The output is deterministic so test snapshots stay
 * stable, and the prose is in Vietnamese to match the rest of the app.
 */
export class DeterministicInsightProvider implements InsightProvider {
  readonly name = 'deterministic';

  generate(ctx: InsightProviderContext): Promise<InsightGenerationResult> {
    const insights = this.buildInsights(ctx);
    const recommendations = this.buildRecommendations(ctx);
    return Promise.resolve({ provider: this.name, insights, recommendations });
  }

  private buildInsights(ctx: InsightProviderContext): InsightDraft[] {
    const { aggregate } = ctx;
    const result: InsightDraft[] = [];

    if (aggregate.total === 0) {
      result.push({
        type: 'weekly-summary',
        title: 'Tuần này chưa có dữ liệu cảm xúc',
        content:
          'Hãy ghi lại cảm xúc ít nhất một lần mỗi ngày. Chỉ vài giây thôi nhưng giúp bạn nhận ra xu hướng theo thời gian.',
      });
      return result;
    }

    const avg = Math.round(aggregate.averageScore);
    const dominant = aggregate.topMood ?? 'NEUTRAL';
    result.push({
      type: 'weekly-summary',
      title: `Tổng kết ${aggregate.total} lần ghi cảm xúc tuần qua`,
      content: `Điểm cảm xúc trung bình của bạn là ${avg}/100, với trạng thái phổ biến nhất là ${this.viMood(dominant)}. Đây là nền tảng tốt để bạn nhìn lại tuần vừa rồi.`,
    });

    if (avg < 45) {
      result.push({
        type: 'mood-pattern',
        title: 'Tuần qua khá nặng nề',
        content:
          'Điểm cảm xúc dưới trung bình cho thấy bạn đang chịu áp lực. Thử dành 10 phút sáng cho hít thở chậm và 10 phút tối cho viết nhật ký — hai thói quen nhỏ có hiệu ứng cộng dồn rõ rệt sau 2-3 tuần.',
      });
    } else if (avg >= 65) {
      result.push({
        type: 'mood-pattern',
        title: 'Bạn đang giữ nhịp rất tốt',
        content:
          'Điểm trung bình cao cho thấy lối sống hiện tại phù hợp với bạn. Đừng quên duy trì những thứ đang work: ngủ đủ, vận động nhẹ, và kết nối với người thân.',
      });
    } else {
      result.push({
        type: 'mood-pattern',
        title: 'Cảm xúc ổn định ở mức trung bình',
        content:
          'Tuần này không quá tệ cũng không bùng nổ. Có thể thử thêm 1 hoạt động mới: nghe nhạc lofi khi làm việc, hoặc đi bộ 15 phút sau bữa tối.',
      });
    }

    // Streak of stress / anxiety call-out.
    const stressLike = aggregate.breakdown
      .filter((b) => ['STRESSED', 'ANXIOUS', 'SAD'].includes(b.mood))
      .reduce((sum, b) => sum + b.count, 0);
    if (stressLike >= 3) {
      result.push({
        type: 'risk-flag',
        title: 'Cảnh báo căng thẳng kéo dài',
        content: `Có ${stressLike} lần ghi nhận trạng thái căng thẳng/lo lắng/buồn trong tuần. Nếu kéo dài thêm 1-2 tuần nữa, bạn nên cân nhắc nói chuyện với người thân hoặc chuyên gia tâm lý.`,
      });
    }

    return result;
  }

  private buildRecommendations(
    ctx: InsightProviderContext,
  ): RecommendationDraft[] {
    const { aggregate, catalog } = ctx;
    const result: RecommendationDraft[] = [];

    const breathingPick = catalog.breathing[0];
    const ambientPick = this.pickAmbient(catalog.ambient, aggregate.topMood);

    if (breathingPick) {
      result.push({
        contentType: 'BreathingExercise',
        contentId: breathingPick.id,
        reason: `Bài thở "${breathingPick.title}" phù hợp với nhịp cảm xúc tuần này.`,
        score: 0.7,
      });
    }
    if (ambientPick) {
      result.push({
        contentType: 'AmbientSound',
        contentId: ambientPick.id,
        reason: `Âm thanh "${ambientPick.title}" giúp bạn tái tạo năng lượng.`,
        score: 0.65,
      });
    }
    return result;
  }

  private pickAmbient(
    list: Array<{ id: string; title: string; category?: string | null }>,
    mood: string | null,
  ) {
    if (list.length === 0) return null;
    const preferred =
      mood === 'STRESSED' || mood === 'ANXIOUS'
        ? ['MEDITATION', 'NATURE', 'RAIN']
        : mood === 'TIRED' || mood === 'SAD'
          ? ['LOFI', 'PIANO']
          : ['FOCUS', 'LOFI'];
    return (
      list.find((s) =>
        preferred.includes(String(s.category ?? '').toUpperCase()),
      ) ?? list[0]
    );
  }

  private viMood(mood: string): string {
    const map: Record<string, string> = {
      HAPPY: 'vui vẻ',
      SAD: 'buồn',
      STRESSED: 'căng thẳng',
      TIRED: 'mệt mỏi',
      ANXIOUS: 'lo lắng',
      NEUTRAL: 'bình thường',
      CALM: 'bình yên',
      EXCITED: 'hào hứng',
      LONELY: 'cô đơn',
      GRATEFUL: 'biết ơn',
    };
    return map[mood] ?? mood.toLowerCase();
  }
}

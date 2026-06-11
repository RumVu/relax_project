import { Logger } from '@nestjs/common';
import { GoogleGenerativeAI, SchemaType } from '@google/generative-ai';
import {
  InsightDraft,
  InsightGenerationResult,
  InsightProvider,
  InsightProviderContext,
  RecommendationDraft,
} from '../ai-insights.types';

/**
 * Gemini provider — asks gemini-1.5-flash (default) for personalized
 * insights + recommendations. Output is constrained via `responseSchema`
 * (Structured Outputs) so the model is guaranteed to return valid JSON
 * matching our exact schema — no regex/manual parsing needed.
 *
 * Fallback behavior: if the model errors, AiInsightsService catches
 * and falls back to the deterministic provider automatically.
 */
export class GeminiInsightProvider implements InsightProvider {
  readonly name = 'gemini';
  private readonly logger = new Logger('AiInsights:gemini');
  private readonly client: GoogleGenerativeAI;
  private readonly modelName: string;

  constructor(apiKey: string, modelName?: string) {
    this.client = new GoogleGenerativeAI(apiKey);
    this.modelName = modelName ?? 'gemini-1.5-flash';
  }

  async generate(
    ctx: InsightProviderContext,
  ): Promise<InsightGenerationResult> {
    const model = this.client.getGenerativeModel({
      model: this.modelName,
      generationConfig: {
        responseMimeType: 'application/json',
        temperature: 0.6,
        // Structured Outputs: ép buộc model trả về đúng schema JSON —
        // không cần regex/parse thủ công, không lo hallucination sai format.
        responseSchema: {
          type: SchemaType.OBJECT,
          properties: {
            insights: {
              type: SchemaType.ARRAY,
              description:
                'Danh sách 3 nhận định cảm xúc cho người dùng (tiếng Việt tự nhiên).',
              items: {
                type: SchemaType.OBJECT,
                properties: {
                  type: {
                    type: SchemaType.STRING,
                    format: 'enum',
                    description:
                      'Loại insight: weekly-summary | mood-pattern | risk-flag | celebration',
                    enum: [
                      'weekly-summary',
                      'mood-pattern',
                      'risk-flag',
                      'celebration',
                    ],
                  },
                  title: {
                    type: SchemaType.STRING,
                    description: 'Tiêu đề ngắn gọn (tối đa 60 ký tự).',
                  },
                  content: {
                    type: SchemaType.STRING,
                    description:
                      'Nội dung nhận định, 2-3 câu, giọng ấm áp không phán xét.',
                  },
                },
                required: ['type', 'title', 'content'],
              },
              minItems: 3,
              maxItems: 3,
            },
            recommendations: {
              type: SchemaType.ARRAY,
              description:
                'Danh sách 2-3 gợi ý hoạt động dựa trên dữ liệu cảm xúc.',
              items: {
                type: SchemaType.OBJECT,
                properties: {
                  contentType: {
                    type: SchemaType.STRING,
                    format: 'enum',
                    description:
                      'Loại nội dung: BreathingExercise | AmbientSound',
                    enum: ['BreathingExercise', 'AmbientSound'],
                  },
                  contentId: {
                    type: SchemaType.STRING,
                    description:
                      'ID phải lấy chính xác từ danh sách catalog được cung cấp trong prompt.',
                  },
                  reason: {
                    type: SchemaType.STRING,
                    description: 'Lý do gợi ý, 1 câu ngắn gọn bằng tiếng Việt.',
                  },
                  score: {
                    type: SchemaType.NUMBER,
                    description: 'Điểm phù hợp từ 0.0 đến 1.0.',
                  },
                },
                required: ['contentType', 'contentId', 'reason', 'score'],
              },
              minItems: 2,
              maxItems: 3,
            },
          },
          required: ['insights', 'recommendations'],
        },
      },
    });

    const prompt = this.buildPrompt(ctx);
    const res = await model.generateContent(prompt);
    const text = res.response.text();

    // Với Structured Outputs, JSON đã được đảm bảo hợp lệ từ phía Gemini.
    // Vẫn parse để lấy typed object, nhưng không cần fallback regex nữa.
    let parsed: { insights?: unknown[]; recommendations?: unknown[] };
    try {
      parsed = JSON.parse(text) as {
        insights?: unknown[];
        recommendations?: unknown[];
      };
    } catch (err) {
      throw new Error(
        `Gemini Structured Output parse failed (unexpected): ${(err as Error).message}`,
      );
    }

    const insights = this.normaliseInsights(parsed.insights);
    const recommendations = this.normaliseRecommendations(
      parsed.recommendations,
      ctx,
    );

    if (insights.length === 0) {
      throw new Error(
        'Gemini returned 0 valid insights after normalisation — triggering fallback.',
      );
    }

    return { provider: this.name, insights, recommendations };
  }

  private buildPrompt(ctx: InsightProviderContext): string {
    const { aggregate, catalog, displayName } = ctx;
    const name = displayName?.trim() || 'người dùng';

    const breakdownStr = aggregate.breakdown
      .map((b) => `${b.mood}:${b.count}`)
      .join(', ');

    const breathingList = catalog.breathing
      .slice(0, 8)
      .map((b) => `- id=${b.id} | "${b.title}"`)
      .join('\n');
    const ambientList = catalog.ambient
      .slice(0, 12)
      .map((s) => `- id=${s.id} | "${s.title}" | ${s.category ?? 'NA'}`)
      .join('\n');

    return [
      `Bạn là chuyên gia phân tích cảm xúc thân thiện cho ứng dụng Relax.`,
      `Người dùng: ${name}.`,
      `Khoảng phân tích: ${aggregate.windowStartIso} → ${aggregate.windowEndIso}.`,
      `Tổng số lần ghi cảm xúc: ${aggregate.total}.`,
      `Cảm xúc phổ biến nhất: ${aggregate.topMood ?? 'không đủ dữ liệu'}.`,
      `Điểm cảm xúc trung bình (0..100): ${Math.round(aggregate.averageScore)}.`,
      `Phân bố: ${breakdownStr || 'trống'}.`,
      ``,
      `Danh sách bài thở khả dụng (chọn contentId chính xác từ đây — KHÔNG được bịa id):`,
      breathingList || '(không có bài thở nào đang hoạt động)',
      ``,
      `Danh sách âm thanh thư giãn khả dụng (chọn contentId chính xác từ đây — KHÔNG được bịa id):`,
      ambientList || '(không có âm thanh nào đang hoạt động)',
      ``,
      `Yêu cầu bắt buộc:`,
      `- Viết bằng tiếng Việt tự nhiên, KHÔNG dùng từ viết tắt, KHÔNG chêm tiếng Anh.`,
      `- Đúng 3 insights, 2-3 recommendations.`,
      `- Giọng văn ấm áp, không phán xét, không sáo rỗng.`,
      `- contentId PHẢI là id lấy từ danh sách trên — nếu danh sách trống, bỏ qua recommendations loại đó.`,
      `- Nếu dữ liệu ít (total < 3) thì insight đầu tiên nên động viên người dùng ghi thêm cảm xúc.`,
    ].join('\n');
  }

  private normaliseInsights(raw: unknown): InsightDraft[] {
    if (!Array.isArray(raw)) return [];
    return raw
      .map((item) => {
        if (!item || typeof item !== 'object') return null;
        const r = item as Record<string, unknown>;
        const type = typeof r.type === 'string' ? r.type : 'weekly-summary';
        const title = typeof r.title === 'string' ? r.title : null;
        const content = typeof r.content === 'string' ? r.content : null;
        if (!title || !content) return null;
        return { type, title, content };
      })
      .filter((x): x is InsightDraft => x !== null)
      .slice(0, 6);
  }

  private normaliseRecommendations(
    raw: unknown,
    ctx: InsightProviderContext,
  ): RecommendationDraft[] {
    if (!Array.isArray(raw)) return [];
    const validBreathingIds = new Set(ctx.catalog.breathing.map((b) => b.id));
    const validAmbientIds = new Set(ctx.catalog.ambient.map((s) => s.id));

    return raw
      .map((item) => {
        if (!item || typeof item !== 'object') return null;
        const r = item as Record<string, unknown>;
        const contentType =
          typeof r.contentType === 'string' ? r.contentType : null;
        const contentId = typeof r.contentId === 'string' ? r.contentId : null;
        const reason = typeof r.reason === 'string' ? r.reason : null;
        const score = typeof r.score === 'number' ? r.score : 0.5;
        if (!contentType || !contentId || !reason) return null;
        // Xác minh lại id từ catalog dù Structured Outputs đã giảm thiểu hallucination.
        if (
          contentType === 'BreathingExercise' &&
          !validBreathingIds.has(contentId)
        )
          return null;
        if (contentType === 'AmbientSound' && !validAmbientIds.has(contentId))
          return null;
        return {
          contentType,
          contentId,
          reason,
          score: Math.max(0, Math.min(1, score)),
        };
      })
      .filter((x): x is RecommendationDraft => x !== null)
      .slice(0, 5);
  }
}

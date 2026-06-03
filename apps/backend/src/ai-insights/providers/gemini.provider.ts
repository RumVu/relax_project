import { Logger } from '@nestjs/common';
import { GoogleGenerativeAI } from '@google/generative-ai';
import {
  InsightDraft,
  InsightGenerationResult,
  InsightProvider,
  InsightProviderContext,
  RecommendationDraft,
} from '../ai-insights.types';

/**
 * Gemini provider — asks gemini-1.5-flash (default) for personalized
 * insights + recommendations. Output is constrained to JSON via the
 * `responseMimeType: 'application/json'` flag so we can parse it
 * deterministically.
 *
 * If the model returns invalid JSON or the API errors, the AiInsightsService
 * catches and falls back to the deterministic provider.
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
      },
    });

    const prompt = this.buildPrompt(ctx);
    const res = await model.generateContent(prompt);
    const text = res.response.text();
    const parsed = this.parseJson(text);
    if (!parsed) {
      throw new Error('Gemini returned non-JSON response');
    }

    const insights = this.normaliseInsights(parsed.insights);
    const recommendations = this.normaliseRecommendations(
      parsed.recommendations,
      ctx,
    );

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
      `Danh sách bài thở khả dụng (chọn id từ đây):`,
      breathingList || '(trống)',
      ``,
      `Danh sách âm thanh thư giãn khả dụng (chọn id từ đây):`,
      ambientList || '(trống)',
      ``,
      `Hãy trả về JSON đúng schema sau, viết bằng tiếng Việt tự nhiên, KHÔNG dùng từ viết tắt, KHÔNG chêm tiếng Anh:`,
      `{`,
      `  "insights": [`,
      `    { "type": "weekly-summary" | "mood-pattern" | "risk-flag" | "celebration", "title": "tiêu đề ngắn", "content": "2-3 câu" }`,
      `  ],`,
      `  "recommendations": [`,
      `    { "contentType": "BreathingExercise" | "AmbientSound", "contentId": "id-có-trong-danh-sách", "reason": "1 câu vì sao gợi ý", "score": 0.0..1.0 }`,
      `  ]`,
      `}`,
      ``,
      `Yêu cầu:`,
      `- Đúng 3 insights, 2-3 recommendations.`,
      `- Giọng văn ấm áp, không phán xét.`,
      `- contentId PHẢI lấy từ danh sách trên, không bịa.`,
      `- Nếu dữ liệu ít (total < 3) thì viết động viên người dùng ghi thêm.`,
    ].join('\n');
  }

  private parseJson(raw: string): {
    insights?: unknown[];
    recommendations?: unknown[];
  } | null {
    try {
      return JSON.parse(raw);
    } catch {
      // Try to extract the first {...} block.
      const match = raw.match(/\{[\s\S]*\}/);
      if (!match) return null;
      try {
        return JSON.parse(match[0]);
      } catch (err) {
        this.logger.warn(`Failed to parse Gemini JSON: ${(err as Error).message}`);
        return null;
      }
    }
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
        const contentId =
          typeof r.contentId === 'string' ? r.contentId : null;
        const reason = typeof r.reason === 'string' ? r.reason : null;
        const score = typeof r.score === 'number' ? r.score : 0.5;
        if (!contentType || !contentId || !reason) return null;
        // Drop hallucinated ids.
        if (contentType === 'BreathingExercise' && !validBreathingIds.has(contentId))
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

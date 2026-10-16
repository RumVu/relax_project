import type { ConfigService } from '@nestjs/config';
import { GoogleGenAI } from '@google/genai';

/**
 * Single source of truth for the Gemini model + Vertex location.
 *
 * gemini-2.5-* was retired on Vertex AI (2026-10-20). Gemini 3.x models are
 * only served from the `global` location — regional endpoints such as
 * `us-central1` return 404 for them.
 */
export const DEFAULT_GEMINI_MODEL = 'gemini-3.8-flash';
export const DEFAULT_VERTEX_LOCATION = 'global';

export function resolveGeminiModel(config: ConfigService): string {
  return config.get<string>('GEMINI_MODEL') || DEFAULT_GEMINI_MODEL;
}

/**
 * Builds a GenAI client: Vertex AI when VERTEX_PROJECT_ID is set, otherwise
 * the Gemini API via GEMINI_API_KEY. Returns null when neither is configured
 * so callers can fall back to their deterministic path.
 */
export function createGenAIClient(config: ConfigService): GoogleGenAI | null {
  const projectId = config.get<string>('VERTEX_PROJECT_ID');
  if (projectId) {
    const location =
      config.get<string>('VERTEX_LOCATION') || DEFAULT_VERTEX_LOCATION;
    return new GoogleGenAI({ vertexai: true, project: projectId, location });
  }
  const apiKey = config.get<string>('GEMINI_API_KEY');
  if (apiKey) {
    return new GoogleGenAI({ apiKey });
  }
  return null;
}

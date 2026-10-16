import type { ConfigService } from '@nestjs/config';
import { GoogleGenAI } from '@google/genai';
import {
  createGenAIClient,
  DEFAULT_GEMINI_MODEL,
  resolveGeminiModel,
} from './gemini';

jest.mock('@google/genai', () => ({ GoogleGenAI: jest.fn() }));

function configWith(values: Record<string, string | undefined>) {
  return {
    get: (key: string) => values[key],
  } as unknown as ConfigService;
}

describe('resolveGeminiModel', () => {
  it('falls back to the default model when GEMINI_MODEL is unset or empty', () => {
    expect(resolveGeminiModel(configWith({}))).toBe(DEFAULT_GEMINI_MODEL);
    expect(resolveGeminiModel(configWith({ GEMINI_MODEL: '' }))).toBe(
      DEFAULT_GEMINI_MODEL,
    );
  });

  it('uses GEMINI_MODEL when provided', () => {
    expect(
      resolveGeminiModel(configWith({ GEMINI_MODEL: 'gemini-custom' })),
    ).toBe('gemini-custom');
  });
});

describe('createGenAIClient', () => {
  beforeEach(() => jest.mocked(GoogleGenAI).mockClear());

  it('returns null when neither Vertex nor API key is configured', () => {
    expect(createGenAIClient(configWith({}))).toBeNull();
  });

  it('uses Vertex AI with the global location by default', () => {
    expect(
      createGenAIClient(configWith({ VERTEX_PROJECT_ID: 'p' })),
    ).not.toBeNull();
    expect(GoogleGenAI).toHaveBeenCalledWith({
      vertexai: true,
      project: 'p',
      location: 'global',
    });
  });

  it('falls back to the Gemini API key when no Vertex project is set', () => {
    expect(
      createGenAIClient(configWith({ GEMINI_API_KEY: 'k' })),
    ).not.toBeNull();
    expect(GoogleGenAI).toHaveBeenCalledWith({ apiKey: 'k' });
  });
});

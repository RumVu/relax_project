/**
 * Crisis keyword patterns for detecting self-harm, suicide, and severe
 * distress content. Used for client-side pre-screening and server-side
 * validation to trigger safety responses.
 */

/** High-severity patterns — immediate danger signals. */
export const HIGH_SEVERITY_PATTERNS: string[] = [
  // Vietnamese
  'tự tử',
  'muốn chết',
  'kết thúc cuộc sống',
  'tự hại',
  // English
  'kill myself',
  'end my life',
  'suicide',
  'self harm',
];

/** Medium-severity patterns — significant distress. */
export const MEDIUM_SEVERITY_PATTERNS: string[] = [
  // Vietnamese
  'không muốn sống',
  'thế giới sẽ tốt hơn nếu không có mình',
  'muốn biến mất',
  // English
  'want to die',
  'better off dead',
  'no reason to live',
];

/** Low-severity patterns — general distress that warrants gentle check-in. */
export const LOW_SEVERITY_PATTERNS: string[] = [
  // Vietnamese
  'không ai quan tâm',
  'chán sống',
  // English
  "can't go on",
  'cant go on',
];

/** All patterns combined for simple boolean checks. */
export const CRISIS_KEYWORDS: string[] = [
  ...HIGH_SEVERITY_PATTERNS,
  ...MEDIUM_SEVERITY_PATTERNS,
  ...LOW_SEVERITY_PATTERNS,
];

export interface CrisisDetectionResult {
  detected: boolean;
  severity: 'low' | 'medium' | 'high';
  matchedPatterns: string[];
}

/**
 * Analyse free-text input for crisis indicators.
 *
 * Severity logic:
 *   - Any HIGH pattern match → high
 *   - Any MEDIUM pattern match (no HIGH) → medium
 *   - Any LOW pattern match only → low
 *   - No match → detected: false, severity: 'low' (unused)
 */
export function detectCrisisContent(text: string): CrisisDetectionResult {
  const normalised = text.toLowerCase();
  const matched: string[] = [];

  let hasHigh = false;
  let hasMedium = false;

  for (const pattern of HIGH_SEVERITY_PATTERNS) {
    if (normalised.includes(pattern.toLowerCase())) {
      matched.push(pattern);
      hasHigh = true;
    }
  }

  for (const pattern of MEDIUM_SEVERITY_PATTERNS) {
    if (normalised.includes(pattern.toLowerCase())) {
      matched.push(pattern);
      hasMedium = true;
    }
  }

  for (const pattern of LOW_SEVERITY_PATTERNS) {
    if (normalised.includes(pattern.toLowerCase())) {
      matched.push(pattern);
    }
  }

  if (matched.length === 0) {
    return { detected: false, severity: 'low', matchedPatterns: [] };
  }

  let severity: 'low' | 'medium' | 'high' = 'low';
  if (hasHigh) severity = 'high';
  else if (hasMedium) severity = 'medium';

  return { detected: true, severity, matchedPatterns: matched };
}

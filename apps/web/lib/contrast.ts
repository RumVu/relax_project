/**
 * Picks a readable foreground colour given a background. If the caller-provided
 * `preferred` text colour has enough contrast against the background it is
 * returned as-is; otherwise the helper falls back to pure white or near-black
 * (whichever wins the WCAG luminance check). Keeps theme gallery cards
 * readable when an admin uploads a dark-on-dark or light-on-light palette.
 */
export function getReadableTextColor(
  background: string | null | undefined,
  preferred?: string | null,
): string {
  const bg = parseColor(background);
  if (!bg) {
    return preferred || '#0f172a';
  }

  if (preferred) {
    const fg = parseColor(preferred);
    if (fg && contrastRatio(bg, fg) >= 4.5) {
      return preferred;
    }
  }

  // WCAG relative luminance — dark backgrounds get light text and vice-versa.
  return relativeLuminance(bg) < 0.45 ? '#f8fafc' : '#0f172a';
}

/**
 * True when `foreground` has *enough* contrast on `background` to be readable
 * for body text (WCAG 4.5:1). Useful for conditional rendering.
 */
export function isReadable(background: string, foreground: string): boolean {
  const bg = parseColor(background);
  const fg = parseColor(foreground);
  if (!bg || !fg) {
    return true;
  }
  return contrastRatio(bg, fg) >= 4.5;
}

type RGB = { r: number; g: number; b: number };

function parseColor(input: string | null | undefined): RGB | undefined {
  if (!input) {
    return undefined;
  }
  const value = input.trim().toLowerCase();
  if (value.startsWith('#')) {
    return parseHex(value.slice(1));
  }
  const rgbMatch = value.match(
    /^rgba?\(\s*(\d+)[,\s]+(\d+)[,\s]+(\d+)(?:[,\s/]+[\d.]+)?\s*\)$/,
  );
  if (rgbMatch) {
    return {
      r: clamp255(Number(rgbMatch[1])),
      g: clamp255(Number(rgbMatch[2])),
      b: clamp255(Number(rgbMatch[3])),
    };
  }
  return undefined;
}

function parseHex(hex: string): RGB | undefined {
  if (/^[0-9a-f]{3}$/.test(hex)) {
    return {
      r: parseInt(hex[0]! + hex[0]!, 16),
      g: parseInt(hex[1]! + hex[1]!, 16),
      b: parseInt(hex[2]! + hex[2]!, 16),
    };
  }
  if (/^[0-9a-f]{6}$/.test(hex)) {
    return {
      r: parseInt(hex.slice(0, 2), 16),
      g: parseInt(hex.slice(2, 4), 16),
      b: parseInt(hex.slice(4, 6), 16),
    };
  }
  return undefined;
}

function clamp255(value: number) {
  if (Number.isNaN(value)) return 0;
  return Math.max(0, Math.min(255, Math.round(value)));
}

function relativeLuminance({ r, g, b }: RGB): number {
  const channel = (raw: number) => {
    const v = raw / 255;
    return v <= 0.03928 ? v / 12.92 : Math.pow((v + 0.055) / 1.055, 2.4);
  };
  return 0.2126 * channel(r) + 0.7152 * channel(g) + 0.0722 * channel(b);
}

function contrastRatio(a: RGB, b: RGB): number {
  const la = relativeLuminance(a);
  const lb = relativeLuminance(b);
  const lighter = Math.max(la, lb);
  const darker = Math.min(la, lb);
  return (lighter + 0.05) / (darker + 0.05);
}

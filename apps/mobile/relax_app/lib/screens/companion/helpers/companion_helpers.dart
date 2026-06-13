// Helper functions for the Companion screen.

/// Returns a fallback emoji for the given companion [type], key, or zodiac sign.
String fallbackEmoji(String? type, {String? assetKey, String? chineseZodiac}) {
  final t = (chineseZodiac ?? assetKey ?? type ?? '').toUpperCase();
  if (t.isEmpty) return '🐾';
  
  if (t.contains('SNAKE')) return '🐍';
  if (t.contains('CAT')) return '🐱';
  if (t.contains('DOG')) return '🐶';
  if (t.contains('PANDA')) return '🐼';
  if (t.contains('DRAGON')) return '🐉';
  if (t.contains('RABBIT')) return '🐰';
  if (t.contains('FOX')) return '🦊';
  if (t.contains('BEAR')) return '🐻';
  
  if (t.contains('RAT')) return '🐭';
  if (t.contains('OX')) return '🐂';
  if (t.contains('TIGER')) return '🐯';
  if (t.contains('HORSE')) return '🐎';
  if (t.contains('GOAT')) return '🐐';
  if (t.contains('MONKEY')) return '🐒';
  if (t.contains('ROOSTER')) return '🐓';
  if (t.contains('PIG')) return '🐖';
  
  if (t.contains('RAM')) return '🐏';
  if (t.contains('BULL')) return '🐂';
  if (t.contains('GEMINI') || t.contains('TWIN')) return '👥';
  if (t.contains('CRAB')) return '🦀';
  if (t.contains('LION') || t.contains('LEO')) return '🦁';
  if (t.contains('SWAN')) return '🦢';
  if (t.contains('SCORPION')) return '🦂';
  if (t.contains('DEER')) return '🦌';
  if (t.contains('OTTER')) return '🦦';
  if (t.contains('FISH')) return '🐟';
  
  return '🐾';
}

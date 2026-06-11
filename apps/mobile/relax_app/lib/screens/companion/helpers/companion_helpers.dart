// Helper functions for the Companion screen.

/// Returns a fallback emoji for the given companion [type].
String fallbackEmoji(String? type) {
  switch (type?.toUpperCase()) {
    case 'CAT':
      return '🐱';
    case 'DOG':
      return '🐶';
    case 'PANDA':
      return '🐼';
    case 'DRAGON':
      return '🐉';
    case 'RABBIT':
      return '🐰';
    case 'FOX':
      return '🦊';
    case 'BEAR':
      return '🐻';
    default:
      return '🐾';
  }
}

String formatBadgeCount(int count) {
  if (count > 99) return '99+';
  if (count <= 0) return '';
  return '$count';
}

bool shouldShowBadge(int count) => count > 0;

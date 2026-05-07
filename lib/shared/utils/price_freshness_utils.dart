import 'dart:ui';

enum PriceFreshness { fresh, moderate, stale, unknown }

PriceFreshness getPriceFreshness(DateTime? updatedAt) {
  if (updatedAt == null) return PriceFreshness.unknown;

  final now = DateTime.now();
  final difference = now.difference(updatedAt);

  if (difference.inHours < 24) {
    return PriceFreshness.fresh;
  } else if (difference.inDays <= 7) {
    return PriceFreshness.moderate;
  } else {
    return PriceFreshness.stale;
  }
}

Color getPriceFreshnessColor(DateTime? updatedAt) {
  switch (getPriceFreshness(updatedAt)) {
    case PriceFreshness.fresh:
      return const Color(0xFF10B981);
    case PriceFreshness.moderate:
      return const Color(0xFFF59E0B);
    case PriceFreshness.stale:
      return const Color(0xFFEF4444);
    case PriceFreshness.unknown:
      return const Color(0xFF9CA3AF);
  }
}

String getPriceFreshnessLabel(DateTime? updatedAt) {
  if (updatedAt == null) return 'Sem data';

  final now = DateTime.now();
  final difference = now.difference(updatedAt);

  if (difference.inMinutes < 60) {
    return 'Agora';
  } else if (difference.inHours < 24) {
    return 'Hoje';
  } else if (difference.inDays == 1) {
    return 'Ontem';
  } else if (difference.inDays < 7) {
    return '${difference.inDays} dias';
  } else if (difference.inDays < 30) {
    final weeks = (difference.inDays / 7).floor();
    return '$weeks sem.';
  } else if (difference.inDays < 365) {
    final months = (difference.inDays / 30).floor();
    return '$months ${months == 1 ? 'mês' : 'meses'}';
  } else {
    return '+1 ano';
  }
}

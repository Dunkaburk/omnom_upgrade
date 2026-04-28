import 'package:intl/intl.dart';

/// Formats a price in GBP. Returns `null` so callers can branch on absence.
String? fmtPrice(double? price) {
  if (price == null) return null;
  if (price == price.roundToDouble()) {
    return '£${price.toStringAsFixed(0)}';
  }
  return '£${price.toStringAsFixed(2)}';
}

/// Formats minutes as e.g. "10m", "1h", "1h 20m". Returns null when both
/// inputs are null/zero.
String? fmtTime(int? activeMinutes, int? passiveMinutes) {
  final total = (activeMinutes ?? 0) + (passiveMinutes ?? 0);
  if (total <= 0) return null;
  final hours = total ~/ 60;
  final minutes = total % 60;
  if (hours == 0) return '${minutes}m';
  if (minutes == 0) return '${hours}h';
  return '${hours}h ${minutes}m';
}

/// Formats an ISO "YYYY-MM-DD" date as "20 Apr 2026" — matches the
/// prototype's `toLocaleDateString('en-GB', {day:'numeric', month:'short',
/// year:'numeric'})`.
String fmtDate(String iso) {
  try {
    final dt = DateTime.parse(iso);
    return DateFormat('d MMM yyyy').format(dt);
  } catch (_) {
    return iso;
  }
}

/// Returns the average rating display string. Mirrors the prototype's `avg()`.
/// Both present → mean to 1 decimal; one present → that score; neither → null.
String? avgRating(int? a, int? b) {
  if (a != null && b != null) {
    return ((a + b) / 2).toStringAsFixed(1);
  }
  if (a != null) return a.toString();
  if (b != null) return b.toString();
  return null;
}

/// Numeric average rating for sort comparisons. Returns -1 when both null
/// (so missing-rating entries fall to the end of "highest" sorts and to
/// the front of "lowest" sorts — matching the prototype's behaviour where
/// `avg()` returns null and Number(null)===0; we use -1 for clearer ordering).
double avgRatingValue(int? a, int? b) {
  if (a != null && b != null) return (a + b) / 2;
  if (a != null) return a.toDouble();
  if (b != null) return b.toDouble();
  return -1;
}

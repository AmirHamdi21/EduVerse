/// Global JSON parsing utilities for safe, crash-proof deserialization.
///
/// All model `fromJson` factories should use these helpers for fields
/// that may be missing, null, or of an unexpected type from the backend.
class JsonParser {
  /// Safely parse an int from a dynamic value.
  /// Returns [defaultValue] if parsing fails.
  static int parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  /// Safely parse a nullable int.
  static int? parseIntOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Safely parse a double from a dynamic value.
  static double parseDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  /// Safely parse a num (int or double).
  static num? parseNumOrNull(dynamic value) {
    if (value == null) return null;
    if (value is num) return value;
    if (value is String) return num.tryParse(value);
    return null;
  }

  /// Safely parse a String with fallback.
  static String parseString(dynamic value, {String defaultValue = ''}) {
    if (value == null) return defaultValue;
    if (value is String) return value;
    return value.toString();
  }

  /// Safely parse a nullable String.
  static String? parseStringOrNull(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }

  /// Safely parse a bool from a dynamic value.
  /// Handles int (0/1) and String ('true'/'false') coercion.
  static bool parseBool(dynamic value, {bool defaultValue = false}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true';
    return defaultValue;
  }

  /// Safely parse a DateTime from a String.
  static DateTime? parseDateTimeOrNull(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Safely parse a DateTime with a required fallback.
  static DateTime parseDateTime(dynamic value, {DateTime? defaultValue}) {
    final parsed = parseDateTimeOrNull(value);
    return parsed ?? defaultValue ?? DateTime.now();
  }

  /// Safely parse a List from a dynamic value.
  /// Handles both direct arrays and `{ "data": [...] }` wrappers.
  static List<T> parseList<T>(
    dynamic value,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    try {
      final List raw;
      if (value is List) {
        raw = value;
      } else if (value is Map && value.containsKey('data')) {
        raw = value['data'] as List? ?? [];
      } else {
        return [];
      }
      return raw
          .whereType<Map<String, dynamic>>()
          .map((e) {
            try {
              return fromJson(e);
            } catch (_) {
              return null;
            }
          })
          .whereType<T>()
          .toList();
    } catch (_) {
      return [];
    }
  }
}

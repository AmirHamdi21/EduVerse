import 'dart:ui';

/// Deterministic gradient generator for courses missing thumbnail images.
///
/// Generates consistent, visually appealing gradients based on a hash
/// of the course ID, so the same course always gets the same gradient
/// across app restarts —— as specified by Research Decision 2.
class CourseUiUtils {
  CourseUiUtils._();

  /// Pre-defined gradient color pairs (curated for visual harmony).
  static const List<List<Color>> _gradientPalette = [
    [Color(0xFF667EEA), Color(0xFF764BA2)], // Indigo → Purple
    [Color(0xFFF093FB), Color(0xFFF5576C)], // Pink → Rose
    [Color(0xFF4FACFE), Color(0xFF00F2FE)], // Blue → Cyan
    [Color(0xFF43E97B), Color(0xFF38F9D7)], // Green → Teal
    [Color(0xFFFA709A), Color(0xFFFEE140)], // Rose → Yellow
    [Color(0xFF30CFD0), Color(0xFF330867)], // Teal → Dark Purple
    [Color(0xFFA18CD1), Color(0xFFFBC2EB)], // Lavender → Light Pink
    [Color(0xFF89F7FE), Color(0xFF66A6FF)], // Light Cyan → Blue
    [Color(0xFFFDDB92), Color(0xFFD1FDFF)], // Gold → Ice
    [Color(0xFF96FBC4), Color(0xFFF9F586)], // Mint → Lemon
    [Color(0xFFFF9A9E), Color(0xFFFECFEF)], // Coral → Soft Pink
    [Color(0xFFFBC8D4), Color(0xFF9795EF)], // Blush → Iris
  ];

  /// Returns a deterministic gradient for a given [courseId].
  ///
  /// The gradient is chosen by hashing [courseId] into the palette.
  static List<Color> gradientForCourseId(dynamic courseId) {
    final hash = courseId.hashCode.abs();
    return _gradientPalette[hash % _gradientPalette.length];
  }

  /// Extracts initials from a course name for placeholder avatars.
  ///
  /// Examples:
  /// - "Introduction to AI" → "IA"
  /// - "Data Structures" → "DS"
  /// - "Calculus II" → "CI"
  static String initialsFromCourseName(String courseName) {
    final words = courseName.trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return '?';
    if (words.length == 1) {
      return words[0].substring(0, words[0].length.clamp(0, 2)).toUpperCase();
    }
    return '${words.first[0]}${words.last[0]}'.toUpperCase();
  }

  /// Safe accessor for instructor name with null-coalescing (SC-003).
  static String safeInstructorName(String? name) {
    if (name == null || name.trim().isEmpty) return 'Unknown Instructor';
    return name;
  }

  /// Safe accessor for course title with null-coalescing (SC-003).
  static String safeCourseTitle(String? title) {
    if (title == null || title.trim().isEmpty) return 'Untitled Course';
    return title;
  }

  /// Safe accessor for course code with null-coalescing (SC-003).
  static String safeCourseCode(String? code) {
    if (code == null || code.trim().isEmpty) return '---';
    return code;
  }
}

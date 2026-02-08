import 'instructor_course_model.dart';

/// View type enum for course display
enum CourseViewType { grid, list, compact }

/// Sort options for courses
enum CourseSortOption {
  newest,
  oldest,
  mostStudents,
  leastStudents,
  alphabetical,
  reverseAlphabetical,
  mostEngagement,
}

/// Extended course model with additional fields for rich UI display
class ExtendedCourse {
  final InstructorCourseModel course;
  final String? thumbnailUrl;
  final double completionRate;
  final double revenue;
  final int engagementScore;
  final String status; // published, draft, archived
  final String category;
  final DateTime createdAt;
  final List<double> enrollmentTrend; // Last 7 days enrollment trend
  final bool hasMilestone;
  final String? milestoneText;

  ExtendedCourse({
    required this.course,
    this.thumbnailUrl,
    this.completionRate = 0.0,
    this.revenue = 0.0,
    this.engagementScore = 0,
    this.status = 'published',
    this.category = 'Programming',
    DateTime? createdAt,
    List<double>? enrollmentTrend,
    this.hasMilestone = false,
    this.milestoneText,
  })  : createdAt = createdAt ?? DateTime.now(),
        enrollmentTrend = enrollmentTrend ?? [0.2, 0.3, 0.5, 0.4, 0.6, 0.8, 0.7];

  /// Get status color based on course status
  static int getStatusColorValue(String status) {
    switch (status) {
      case 'published':
        return 0xFF00C853; // Green
      case 'draft':
        return 0xFFFFAB00; // Amber
      case 'archived':
        return 0xFF94A3B8; // Gray
      default:
        return 0xFF0D47A1; // Primary
    }
  }
}

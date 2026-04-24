import '../../models/core/enrollment_model.dart';
import '../../models/registration/registration_available_course_model.dart';

class StudentRegistrationStats {
  final int enrolledCredits;
  final int registeredCoursesCount;
  final int waitlistCount;
  final int availableCoursesCount;

  const StudentRegistrationStats({
    required this.enrolledCredits,
    required this.registeredCoursesCount,
    required this.waitlistCount,
    required this.availableCoursesCount,
  });
}

class StudentRegistrationFilters {
  static const String allFilterValue = 'all';

  static List<RegistrationAvailableCourseModel> applyFilters({
    required List<RegistrationAvailableCourseModel> courses,
    required String searchQuery,
    required String selectedDepartment,
    required String selectedLevel,
  }) {
    final String normalizedQuery = searchQuery.trim().toLowerCase();
    final String normalizedDepartment = selectedDepartment.trim().toLowerCase();
    final String normalizedLevel = selectedLevel.trim().toLowerCase();

    return courses
        .where((course) {
          final bool matchesSearch =
              normalizedQuery.isEmpty ||
              _matchesSearch(course, normalizedQuery);
          final bool matchesDepartment =
              normalizedDepartment == allFilterValue ||
              _normalize(course.departmentName) == normalizedDepartment;
          final bool matchesLevel =
              normalizedLevel == allFilterValue ||
              _normalize(course.level) == normalizedLevel;

          return matchesSearch && matchesDepartment && matchesLevel;
        })
        .toList(growable: false);
  }

  static List<String> deriveDepartmentOptions(
    List<RegistrationAvailableCourseModel> courses,
  ) {
    final Set<String> departments = courses
        .map((course) => course.departmentName.trim())
        .where((name) => name.isNotEmpty)
        .where((name) => name.toLowerCase() != 'unknown')
        .toSet();

    final List<String> options = <String>[allFilterValue];
    if (departments.isNotEmpty) {
      options.addAll(departments.toList()..sort());
    }
    return options;
  }

  static List<String> deriveLevelOptions(
    List<RegistrationAvailableCourseModel> courses,
  ) {
    final Set<String> levels = courses
        .map((course) => course.level.trim().toLowerCase())
        .where((level) => level.isNotEmpty)
        .toSet();

    final List<String> options = <String>[allFilterValue];
    if (levels.isNotEmpty) {
      options.addAll(levels.toList()..sort());
    }
    return options;
  }

  static StudentRegistrationStats buildStats({
    required List<CourseEnrollmentModel> enrolledCourses,
    required List<RegistrationAvailableCourseModel> availableCourses,
  }) {
    int enrolledCredits = 0;
    int registeredCoursesCount = 0;
    int waitlistCount = 0;

    for (final enrollment in enrolledCourses) {
      final String status = enrollment.status.trim().toLowerCase();
      if (status == 'enrolled') {
        enrolledCredits += enrollment.course?.credits ?? 0;
        registeredCoursesCount += 1;
      }
      if (status == 'waitlisted' || status == 'waitlist') {
        waitlistCount += 1;
      }
    }

    return StudentRegistrationStats(
      enrolledCredits: enrolledCredits,
      registeredCoursesCount: registeredCoursesCount,
      waitlistCount: waitlistCount,
      availableCoursesCount: availableCourses.length,
    );
  }

  static String normalizeAvailableEnrollmentStatus(String? value) {
    final String normalized = value?.trim().toLowerCase() ?? '';
    if (normalized.isEmpty) {
      return 'not_enrolled';
    }
    return normalized;
  }

  static bool _matchesSearch(
    RegistrationAvailableCourseModel course,
    String normalizedQuery,
  ) {
    return _normalize(course.name).contains(normalizedQuery) ||
        _normalize(course.code).contains(normalizedQuery) ||
        _normalize(course.departmentName).contains(normalizedQuery);
  }

  static String _normalize(String value) => value.trim().toLowerCase();
}

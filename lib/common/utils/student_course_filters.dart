import '../../models/core/enrollment_model.dart';

class SemesterFilterOption {
  final int id;
  final String label;

  const SemesterFilterOption({required this.id, required this.label});

  @override
  bool operator ==(Object other) {
    return other is SemesterFilterOption &&
        other.id == id &&
        other.label == label;
  }

  @override
  int get hashCode => Object.hash(id, label);
}

class StudentCourseFilters {
  static List<CourseEnrollmentModel> applyCourseFiltersAndSort({
    required List<CourseEnrollmentModel> enrollments,
    required String query,
    required String selectedStatus,
    required String sortKey,
    int? selectedSemesterId,
  }) {
    final String normalizedQuery = query.trim().toLowerCase();

    final Iterable<CourseEnrollmentModel> semesterFiltered =
        selectedSemesterId == null
        ? enrollments
        : enrollments.where(
            (CourseEnrollmentModel enrollment) =>
                enrollment.semester?.id == selectedSemesterId,
          );

    final Iterable<CourseEnrollmentModel> statusFiltered = semesterFiltered
        .where(
          (CourseEnrollmentModel enrollment) =>
              _matchesStatus(enrollment, selectedStatus),
        );

    final List<CourseEnrollmentModel> searched = normalizedQuery.isEmpty
        ? statusFiltered.toList(growable: false)
        : _searchWithPrecedence(
            statusFiltered.toList(growable: false),
            normalizedQuery,
          );

    final List<CourseEnrollmentModel> sorted = List<CourseEnrollmentModel>.from(
      searched,
    );
    _sortEnrollments(sorted, sortKey);
    return sorted;
  }

  static List<SemesterFilterOption> deriveSemesterOptions(
    List<CourseEnrollmentModel> enrollments,
  ) {
    final Map<int, String> byId = <int, String>{};

    for (final CourseEnrollmentModel enrollment in enrollments) {
      final int? semesterId = enrollment.semester?.id;
      final String semesterName = (enrollment.semester?.name ?? '').trim();
      if (semesterId != null && semesterId > 0 && semesterName.isNotEmpty) {
        byId[semesterId] = semesterName;
      }
    }

    final List<SemesterFilterOption> options = byId.entries
        .map(
          (MapEntry<int, String> entry) =>
              SemesterFilterOption(id: entry.key, label: entry.value),
        )
        .toList(growable: false);

    options.sort(
      (SemesterFilterOption a, SemesterFilterOption b) =>
          a.label.toLowerCase().compareTo(b.label.toLowerCase()),
    );

    return options;
  }

  static String instructorFullName(CourseEnrollmentModel enrollment) {
    final UserLite? instructor = enrollment.instructor;
    if (instructor == null) {
      return '';
    }

    final String fullName = '${instructor.firstName} ${instructor.lastName}'
        .trim();
    if (fullName.isNotEmpty) {
      return fullName;
    }

    return instructor.email;
  }

  static bool _matchesStatus(
    CourseEnrollmentModel enrollment,
    String selected,
  ) {
    if (selected == 'all') {
      return true;
    }

    final String normalized = normalizeEnrollmentStatus(enrollment.status);
    return normalized == selected;
  }

  static String normalizeEnrollmentStatus(String rawStatus) {
    final String normalized = rawStatus.toLowerCase();
    if (normalized == 'enrolled' || normalized == 'active') {
      return 'active';
    }
    if (normalized == 'completed') {
      return 'completed';
    }
    if (normalized == 'dropped' || normalized == 'withdrawn') {
      return 'dropped';
    }
    return 'active';
  }

  static List<CourseEnrollmentModel> _searchWithPrecedence(
    List<CourseEnrollmentModel> enrollments,
    String normalizedQuery,
  ) {
    final List<_RankedEnrollment> ranked = <_RankedEnrollment>[];

    for (int index = 0; index < enrollments.length; index++) {
      final CourseEnrollmentModel enrollment = enrollments[index];
      final int? rank = _searchRank(enrollment, normalizedQuery);
      if (rank != null) {
        ranked.add(_RankedEnrollment(enrollment, rank, index));
      }
    }

    ranked.sort((_RankedEnrollment a, _RankedEnrollment b) {
      final int byRank = a.rank.compareTo(b.rank);
      if (byRank != 0) {
        return byRank;
      }
      return a.originalIndex.compareTo(b.originalIndex);
    });

    return ranked
        .map(((_RankedEnrollment item) => item.enrollment))
        .toList(growable: false);
  }

  static int? _searchRank(CourseEnrollmentModel enrollment, String query) {
    final String code = (enrollment.course?.courseCode ?? '').toLowerCase();
    final String title = (enrollment.course?.courseName ?? '').toLowerCase();
    final String section = (enrollment.section?.sectionNumber ?? '')
        .toLowerCase();
    final String semester = (enrollment.semester?.name ?? '').toLowerCase();
    final String instructor = instructorFullName(enrollment).toLowerCase();

    if (code == query || code.startsWith(query)) {
      return 0;
    }

    if (title.contains(query)) {
      return 1;
    }

    if (section.contains(query) ||
        semester.contains(query) ||
        instructor.contains(query)) {
      return 2;
    }

    return null;
  }

  static void _sortEnrollments(
    List<CourseEnrollmentModel> enrollments,
    String sortKey,
  ) {
    switch (sortKey) {
      case 'title_desc':
        enrollments.sort(
          (CourseEnrollmentModel a, CourseEnrollmentModel b) =>
              (b.course?.courseName ?? '').toLowerCase().compareTo(
                (a.course?.courseName ?? '').toLowerCase(),
              ),
        );
        return;
      case 'credits_desc':
        enrollments.sort(
          (CourseEnrollmentModel a, CourseEnrollmentModel b) =>
              (b.course?.credits ?? 0).compareTo(a.course?.credits ?? 0),
        );
        return;
      case 'credits_asc':
        enrollments.sort(
          (CourseEnrollmentModel a, CourseEnrollmentModel b) =>
              (a.course?.credits ?? 0).compareTo(b.course?.credits ?? 0),
        );
        return;
      case 'date':
        enrollments.sort(
          (CourseEnrollmentModel a, CourseEnrollmentModel b) =>
              b.enrollmentDate.compareTo(a.enrollmentDate),
        );
        return;
      case 'title_asc':
      default:
        enrollments.sort(
          (CourseEnrollmentModel a, CourseEnrollmentModel b) =>
              (a.course?.courseName ?? '').toLowerCase().compareTo(
                (b.course?.courseName ?? '').toLowerCase(),
              ),
        );
    }
  }
}

class _RankedEnrollment {
  final CourseEnrollmentModel enrollment;
  final int rank;
  final int originalIndex;

  const _RankedEnrollment(this.enrollment, this.rank, this.originalIndex);
}

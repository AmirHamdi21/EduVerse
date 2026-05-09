import '../../../bloc/assignments/assignment_state.dart';
import '../../../bloc/courses/courses_state.dart';
import '../../../models/assignments/assignment_model.dart';
import '../../../models/core/enrollment_model.dart';
import '../../../models/core/semester_model.dart';

class StudentDashboardMetrics {
  const StudentDashboardMetrics._();

  static List<CourseEnrollmentModel> enrollmentsFromState(CoursesState state) {
    final List<CourseEnrollmentModel> source;
    if (state is CoursesLoaded) {
      source = state.enrollments;
    } else if (state is CoursesLoading) {
      source = state.cachedData.whereType<CourseEnrollmentModel>().toList();
    } else {
      source = const <CourseEnrollmentModel>[];
    }

    final enrollments = source.where((enrollment) {
      return enrollment.course != null;
    }).toList();

    enrollments.sort((a, b) {
      final progressCompare = courseProgress(b).compareTo(courseProgress(a));
      if (progressCompare != 0) return progressCompare;
      return b.enrollmentDate.compareTo(a.enrollmentDate);
    });

    return enrollments;
  }

  static double courseProgress(CourseEnrollmentModel enrollment) {
    final progressPercentage = enrollment.progressPercentage;
    if (progressPercentage != null && progressPercentage.isFinite) {
      return progressPercentage.clamp(0.0, 100.0).toDouble() / 100;
    }

    final viewed = enrollment.materialsViewed;
    final total = enrollment.totalMaterials;
    if (viewed != null && total != null && total > 0) {
      return (viewed / total).clamp(0.0, 1.0);
    }

    return 0;
  }

  static int courseCount(CoursesState state) {
    return enrollmentsFromState(state).length;
  }

  static int averageProgressPercent(CoursesState state) {
    final enrollments = enrollmentsFromState(state);
    if (enrollments.isEmpty) return 0;

    final total = enrollments.fold<double>(
      0,
      (sum, enrollment) => sum + courseProgress(enrollment),
    );
    return ((total / enrollments.length) * 100).round().clamp(0, 100);
  }

  static List<AssignmentModel> pendingAssignments(AssignmentState state) {
    final assignments =
        state.assignments
            .where(
              (assignment) => assignment.submissionFilterStatus != 'submitted',
            )
            .toList()
          ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return assignments;
  }

  static int pendingAssignmentCount(AssignmentState state) {
    return pendingAssignments(state).length;
  }

  static DateTime? nextDueDate(AssignmentState state) {
    final pending = pendingAssignments(state);
    return pending.isEmpty ? null : pending.first.dueDate;
  }

  static int? termProgressPercent(CoursesState state) {
    final semester = _activeSemester(enrollmentsFromState(state));
    if (semester?.startDate == null || semester?.endDate == null) {
      return null;
    }

    final start = semester!.startDate!;
    final end = semester.endDate!;
    final total = end.difference(start).inSeconds;
    if (total <= 0) return null;

    final elapsed = DateTime.now().difference(start).inSeconds;
    return ((elapsed / total) * 100).round().clamp(0, 100);
  }

  static SemesterModel? _activeSemester(
    List<CourseEnrollmentModel> enrollments,
  ) {
    final semesters = enrollments
        .map((enrollment) => enrollment.semester)
        .whereType<SemesterModel>()
        .toList();
    if (semesters.isEmpty) return null;

    final now = DateTime.now();
    for (final semester in semesters) {
      final start = semester.startDate;
      final end = semester.endDate;
      if (start != null &&
          end != null &&
          !now.isBefore(start) &&
          !now.isAfter(end)) {
        return semester;
      }
    }

    for (final semester in semesters) {
      final status = semester.status.trim().toLowerCase();
      if (status == 'active' || status == 'current') {
        return semester;
      }
    }

    return semesters.first;
  }
}

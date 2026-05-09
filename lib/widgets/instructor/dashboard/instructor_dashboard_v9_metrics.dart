import 'package:edu_verse/bloc/instructor/instructor_courses_state.dart';
import 'package:edu_verse/bloc/schedule/schedule_item_builder.dart';
import 'package:edu_verse/models/assignments/assignment_model.dart';
import 'package:edu_verse/models/assignments/assignment_submission_model.dart';
import 'package:edu_verse/models/core/enums/assignment_enums.dart' as api;
import 'package:edu_verse/models/instructor/instructor_course_model.dart'
    hide AssignmentModel;
import 'package:edu_verse/models/instructor/teaching_course_model.dart';
import 'package:edu_verse/models/schedule/schedule_helpers.dart';
import 'package:edu_verse/models/schedule/schedule_models.dart';
import 'package:edu_verse/services/api/assignment_service.dart';
import 'package:edu_verse/services/api/enrollment_service.dart';
import 'package:edu_verse/services/api/schedule_api_service.dart';

class InstructorDashboardV9Metrics {
  const InstructorDashboardV9Metrics._();

  static List<TeachingCourseModel> teachingCoursesFromState(
    InstructorCoursesState state,
  ) {
    if (state is InstructorCoursesLoaded) {
      return state.courses;
    }
    return const <TeachingCourseModel>[];
  }

  static int courseCount(List<TeachingCourseModel> courses) => courses.length;

  static int totalStudents(List<TeachingCourseModel> courses) {
    return courses.fold<int>(0, (sum, course) => sum + course.enrolledCount);
  }

  static int messageCount(List<InstructorV9CourseMetrics> courses) {
    return courses.fold<int>(0, (sum, course) => sum + course.unreadMessages);
  }

  static double? weightedAverageGrade(List<TeachingCourseModel> courses) {
    var weightedTotal = 0.0;
    var totalWeight = 0;

    for (final course in courses) {
      final grade = course.averageGrade;
      if (grade == null) continue;
      final weight = course.enrolledCount > 0 ? course.enrolledCount : 1;
      weightedTotal += grade.clamp(0, 100) * weight;
      totalWeight += weight;
    }

    if (totalWeight == 0) return null;
    return weightedTotal / totalWeight;
  }

  static double courseAverage(TeachingCourseModel course) {
    return (course.averageGrade ?? course.attendanceRate ?? 0)
        .clamp(0, 100)
        .toDouble();
  }

  static String courseTitle(TeachingCourseModel course) {
    final code = course.course.code.trim();
    final name = course.course.name.trim();
    if (code.isEmpty) return name.isEmpty ? 'Course' : name;
    if (name.isEmpty) return code;
    return '$code - $name';
  }

  static InstructorCourseModel toLegacyCourse(TeachingCourseModel course) {
    return InstructorCourseModel(
      id: course.courseId.toString(),
      code: course.course.code,
      name: course.course.name,
      description: course.course.description ?? '',
      totalStudents: course.enrolledCount,
      capacity: course.capacity,
      progress: courseAverage(course).round(),
      colorValue: 0xFFA855F7,
      semester: course.semester.name,
      isActive: true,
    );
  }

  static InstructorV9Snapshot snapshotFromCourses(
    List<TeachingCourseModel> courses,
  ) {
    final courseMetrics = courses
        .map(
          (course) => InstructorV9CourseMetrics(
            course: course,
            pendingGrading: 0,
            atRisk: 0,
            newItems: 0,
            activeQuizzes: 0,
            unreadMessages: 0,
          ),
        )
        .toList();

    courseMetrics.sort((a, b) {
      return b.course.enrolledCount.compareTo(a.course.enrolledCount);
    });

    return InstructorV9Snapshot(
      courses: courseMetrics,
      pendingGrading: const <InstructorV9PendingGradingItem>[],
      atRiskCount: 0,
      averageGrade: weightedAverageGrade(courses),
      totalStudents: totalStudents(courses),
    );
  }

  static Future<InstructorV9Snapshot> loadSnapshot({
    required List<TeachingCourseModel> courses,
    required AssignmentService assignmentService,
    required EnrollmentService enrollmentService,
  }) async {
    if (courses.isEmpty) return InstructorV9Snapshot.empty;

    final courseMetrics = <InstructorV9CourseMetrics>[];
    final pendingRows = <InstructorV9PendingGradingItem>[];
    final atRiskByCourse = <int, int>{};

    final atRiskFuture = _runWithConcurrency<MapEntry<int, int>>(
      courses
          .map((course) {
            return () async {
              final atRiskCount = await _loadAtRiskCount(
                enrollmentService: enrollmentService,
                course: course,
              );
              return MapEntry<int, int>(course.courseId, atRiskCount);
            };
          })
          .toList(growable: false),
      maxConcurrent: 4,
    );

    final assignmentsFuture = _runWithConcurrency<_CourseAssignments>(
      courses
          .map((course) {
            return () async {
              final assignments = await _loadAssignmentsForCourse(
                assignmentService: assignmentService,
                courseId: course.courseId,
              );
              return _CourseAssignments(course, assignments);
            };
          })
          .toList(growable: false),
      maxConcurrent: 4,
    );

    final atRiskEntries = await atRiskFuture;
    for (final entry in atRiskEntries) {
      atRiskByCourse[entry.key] = entry.value;
    }

    final assignmentsByCourse = await assignmentsFuture;
    final pendingByCourse = <int, int>{
      for (final course in courses) course.courseId: 0,
    };

    final submissionLoaders = <Future<_AssignmentSubmissions> Function()>[];
    for (final courseAssignments in assignmentsByCourse) {
      for (final assignment in courseAssignments.assignments) {
        submissionLoaders.add(() async {
          final submissions = await _loadSubmissionsForAssignment(
            assignmentService: assignmentService,
            assignmentId: assignment.assignmentId,
          );
          return _AssignmentSubmissions(
            courseAssignments.course,
            assignment,
            submissions,
          );
        });
      }
    }

    final submissionsByAssignment =
        await _runWithConcurrency<_AssignmentSubmissions>(
          submissionLoaders,
          maxConcurrent: 6,
        );

    for (final assignmentSubmissions in submissionsByAssignment) {
      for (final submission in assignmentSubmissions.submissions) {
        if (!_isPendingGrading(submission)) continue;
        final courseId = assignmentSubmissions.course.courseId;
        pendingByCourse[courseId] = (pendingByCourse[courseId] ?? 0) + 1;
        pendingRows.add(
          InstructorV9PendingGradingItem(
            assignment: assignmentSubmissions.assignment,
            submission: submission,
            course: assignmentSubmissions.course,
          ),
        );
      }
    }

    for (final courseAssignments in assignmentsByCourse) {
      courseMetrics.add(
        InstructorV9CourseMetrics(
          course: courseAssignments.course,
          pendingGrading:
              pendingByCourse[courseAssignments.course.courseId] ?? 0,
          atRisk: atRiskByCourse[courseAssignments.course.courseId] ?? 0,
          newItems: courseAssignments.assignments
              .where(
                (assignment) => assignment.createdAt.isAfter(
                  DateTime.now().subtract(const Duration(days: 7)),
                ),
              )
              .length,
          activeQuizzes: 0,
          unreadMessages: 0,
        ),
      );
    }

    pendingRows.sort((a, b) {
      return b.submission.submittedAt.compareTo(a.submission.submittedAt);
    });

    courseMetrics.sort((a, b) {
      final byPending = b.pendingGrading.compareTo(a.pendingGrading);
      if (byPending != 0) return byPending;
      final byRisk = b.atRisk.compareTo(a.atRisk);
      if (byRisk != 0) return byRisk;
      return b.course.enrolledCount.compareTo(a.course.enrolledCount);
    });

    return InstructorV9Snapshot(
      courses: courseMetrics,
      pendingGrading: pendingRows,
      atRiskCount: atRiskByCourse.values.fold<int>(
        0,
        (sum, count) => sum + count,
      ),
      averageGrade: weightedAverageGrade(courses),
      totalStudents: totalStudents(courses),
    );
  }

  static Future<List<InstructorV9EventItem>> loadUpcomingEvents({
    required ScheduleApiService scheduleService,
  }) async {
    final result = await scheduleService.getWeeklySchedule(
      startDate: toISODate(startOfWeek(DateTime.now())),
    );
    if (!result.isSuccess || result.data == null) {
      return const <InstructorV9EventItem>[];
    }

    final items = ScheduleItemBuilder.upcoming(
      ScheduleItemBuilder.build(days: result.data!.days),
    );

    return items
        .take(3)
        .map((item) {
          return InstructorV9EventItem(
            title: item.title,
            date: DateTime.tryParse(item.date) ?? DateTime.now(),
            time: item.startTime,
            type: item.subtitle ?? item.kind.toJson(),
          );
        })
        .toList(growable: false);
  }

  static String relativeSubmittedTime(DateTime submittedAt) {
    final difference = DateTime.now().difference(submittedAt);
    if (difference.inMinutes < 1) return 'now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${submittedAt.month}/${submittedAt.day}/${submittedAt.year}';
  }

  static Future<int> _loadAtRiskCount({
    required EnrollmentService enrollmentService,
    required TeachingCourseModel course,
  }) async {
    if (course.sectionId <= 0) return 0;
    final result = await enrollmentService.getSectionStudentsLite(
      course.sectionId,
    );
    if (!result.isSuccess || result.data == null) return 0;

    return result.data!.where((student) {
      final score = student.finalScore ?? student.grade;
      return score != null && score < 60;
    }).length;
  }

  static Future<List<AssignmentModel>> _loadAssignmentsForCourse({
    required AssignmentService assignmentService,
    required int courseId,
  }) async {
    final result = await assignmentService.getAll(
      courseId: courseId,
      limit: 100,
    );
    if (!result.isSuccess || result.data == null) {
      return const <AssignmentModel>[];
    }
    return result.data!.data;
  }

  static Future<List<AssignmentSubmissionModel>> _loadSubmissionsForAssignment({
    required AssignmentService assignmentService,
    required int assignmentId,
  }) async {
    if (assignmentId <= 0) return const <AssignmentSubmissionModel>[];
    final result = await assignmentService.getSubmissions(assignmentId);
    if (!result.isSuccess || result.data == null) {
      return const <AssignmentSubmissionModel>[];
    }
    return result.data!;
  }

  static bool _isPendingGrading(AssignmentSubmissionModel submission) {
    return submission.submissionStatus == api.SubmissionStatus.submitted ||
        submission.submissionStatus == api.SubmissionStatus.resubmit;
  }

  static Future<List<T>> _runWithConcurrency<T>(
    List<Future<T> Function()> tasks, {
    required int maxConcurrent,
  }) async {
    if (tasks.isEmpty) return <T>[];

    final results = List<T?>.filled(tasks.length, null);
    var nextIndex = 0;
    final workerCount = tasks.length < maxConcurrent
        ? tasks.length
        : maxConcurrent;

    Future<void> runWorker() async {
      while (true) {
        final index = nextIndex;
        nextIndex += 1;
        if (index >= tasks.length) return;
        results[index] = await tasks[index]();
      }
    }

    await Future.wait<void>(
      List<Future<void>>.generate(workerCount, (_) => runWorker()),
    );

    return results.cast<T>();
  }
}

class _CourseAssignments {
  final TeachingCourseModel course;
  final List<AssignmentModel> assignments;

  const _CourseAssignments(this.course, this.assignments);
}

class _AssignmentSubmissions {
  final TeachingCourseModel course;
  final AssignmentModel assignment;
  final List<AssignmentSubmissionModel> submissions;

  const _AssignmentSubmissions(this.course, this.assignment, this.submissions);
}

class InstructorV9Snapshot {
  final List<InstructorV9CourseMetrics> courses;
  final List<InstructorV9PendingGradingItem> pendingGrading;
  final int atRiskCount;
  final double? averageGrade;
  final int totalStudents;

  const InstructorV9Snapshot({
    required this.courses,
    required this.pendingGrading,
    required this.atRiskCount,
    required this.averageGrade,
    required this.totalStudents,
  });

  static const empty = InstructorV9Snapshot(
    courses: <InstructorV9CourseMetrics>[],
    pendingGrading: <InstructorV9PendingGradingItem>[],
    atRiskCount: 0,
    averageGrade: null,
    totalStudents: 0,
  );
}

class InstructorV9CourseMetrics {
  final TeachingCourseModel course;
  final int pendingGrading;
  final int atRisk;
  final int newItems;
  final int activeQuizzes;
  final int unreadMessages;

  const InstructorV9CourseMetrics({
    required this.course,
    required this.pendingGrading,
    required this.atRisk,
    required this.newItems,
    required this.activeQuizzes,
    required this.unreadMessages,
  });
}

class InstructorV9PendingGradingItem {
  final AssignmentModel assignment;
  final AssignmentSubmissionModel submission;
  final TeachingCourseModel course;

  const InstructorV9PendingGradingItem({
    required this.assignment,
    required this.submission,
    required this.course,
  });

  String get studentName {
    final user = submission.user;
    final name = '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim();
    if (name.isNotEmpty) return name;
    if ((user?.email ?? '').trim().isNotEmpty) return user!.email;
    return 'Student #${submission.userId}';
  }

  String get taskLine {
    final code = assignment.courseCode.trim().isNotEmpty
        ? assignment.courseCode
        : course.course.code;
    if (code.trim().isEmpty) return assignment.title;
    return '$code · ${assignment.title}';
  }
}

class InstructorV9EventItem {
  final String title;
  final DateTime date;
  final String time;
  final String type;

  const InstructorV9EventItem({
    required this.title,
    required this.date,
    required this.time,
    required this.type,
  });
}

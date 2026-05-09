import 'package:edu_verse/bloc/schedule/schedule_item_builder.dart';
import 'package:edu_verse/bloc/ta/ta_courses_state.dart';
import 'package:edu_verse/models/assignments/assignment_model.dart';
import 'package:edu_verse/models/assignments/assignment_submission_model.dart';
import 'package:edu_verse/models/core/enums/assignment_enums.dart' as api;
import 'package:edu_verse/models/instructor/teaching_course_model.dart';
import 'package:edu_verse/models/labs/lab_model.dart';
import 'package:edu_verse/models/labs/lab_submission_model.dart';
import 'package:edu_verse/models/schedule/schedule_helpers.dart';
import 'package:edu_verse/services/api/assignment_service.dart';
import 'package:edu_verse/services/api/lab_service.dart';
import 'package:edu_verse/services/api/schedule_api_service.dart';

class TADashboardV9Metrics {
  const TADashboardV9Metrics._();

  static List<TeachingCourseModel> coursesFromState(TACoursesState state) {
    final status = state.coursesStatus;
    if (status is TASubTabLoaded<List<TeachingCourseModel>>) {
      return status.data;
    }
    return const <TeachingCourseModel>[];
  }

  static int studentCountFor(TACoursesState state, TeachingCourseModel course) {
    return state.sectionStudentCounts[course.sectionId] ?? course.enrolledCount;
  }

  static int totalStudents(
    TACoursesState state,
    List<TeachingCourseModel> courses,
  ) {
    return courses.fold<int>(
      0,
      (sum, course) => sum + studentCountFor(state, course),
    );
  }

  static String courseTitle(TeachingCourseModel course) {
    final code = course.course.code.trim();
    final name = course.course.name.trim();
    if (code.isEmpty) return name.isEmpty ? 'Course' : name;
    if (name.isEmpty) return code;
    return '$code - $name';
  }

  static TAV9Snapshot snapshotFromCourses(
    List<TeachingCourseModel> courses, {
    Map<int, int> sectionStudentCounts = const <int, int>{},
  }) {
    final metrics = courses
        .map(
          (course) => TAV9CourseMetrics(
            course: course,
            openTasks: 0,
            pendingGrading: 0,
            pendingLabs: 0,
            students:
                sectionStudentCounts[course.sectionId] ?? course.enrolledCount,
          ),
        )
        .toList();

    metrics.sort((a, b) => b.students.compareTo(a.students));

    return TAV9Snapshot(
      courses: metrics,
      tasks: const <TAV9TaskItem>[],
      pendingGrading: 0,
      assignmentsGradedThisWeek: 0,
      labsReviewedThisWeek: 0,
      weeklySessions: null,
      questionsAnswered: null,
      aiTimeSaved: null,
      totalStudents: metrics.fold<int>(0, (sum, item) => sum + item.students),
    );
  }

  static Future<TAV9Snapshot> loadSnapshot({
    required List<TeachingCourseModel> courses,
    required Map<int, int> sectionStudentCounts,
    required AssignmentService assignmentService,
    required LabService labService,
    required ScheduleApiService scheduleService,
  }) async {
    if (courses.isEmpty) return TAV9Snapshot.empty;

    final assignmentsFuture = _runWithConcurrency<_CourseAssignments>(
      courses
          .map((course) {
            return () async {
              final result = await assignmentService.getAll(
                courseId: course.courseId,
                limit: 100,
              );
              return _CourseAssignments(
                course,
                result.isSuccess && result.data != null
                    ? result.data!.data
                    : const <AssignmentModel>[],
              );
            };
          })
          .toList(growable: false),
      maxConcurrent: 4,
    );

    final labsFuture = _runWithConcurrency<_CourseLabs>(
      courses
          .map((course) {
            return () async {
              final result = await labService.getAll(
                courseId: course.courseId,
                limit: 100,
              );
              return _CourseLabs(
                course,
                result.isSuccess && result.data != null
                    ? result.data!
                    : const <LabModel>[],
              );
            };
          })
          .toList(growable: false),
      maxConcurrent: 4,
    );

    final sessionsFuture = _loadWeeklySessionCount(scheduleService);

    final assignmentsByCourse = await assignmentsFuture;
    final labsByCourse = await labsFuture;

    final assignmentSubmissionLoaders =
        <Future<_AssignmentSubmissions> Function()>[];
    for (final courseAssignments in assignmentsByCourse) {
      for (final assignment in courseAssignments.assignments) {
        if (assignment.assignmentId <= 0) continue;
        assignmentSubmissionLoaders.add(() async {
          final result = await assignmentService.getSubmissions(
            assignment.assignmentId,
          );
          return _AssignmentSubmissions(
            courseAssignments.course,
            assignment,
            result.isSuccess && result.data != null
                ? result.data!
                : const <AssignmentSubmissionModel>[],
          );
        });
      }
    }

    final labSubmissionLoaders = <Future<_LabSubmissions> Function()>[];
    for (final courseLabs in labsByCourse) {
      for (final lab in courseLabs.labs) {
        final labId = lab.labId ?? int.tryParse(lab.id);
        if (labId == null || labId <= 0) continue;
        labSubmissionLoaders.add(() async {
          final result = await labService.getSubmissions(labId);
          return _LabSubmissions(
            courseLabs.course,
            lab,
            result.isSuccess && result.data != null
                ? result.data!
                : const <LabSubmissionModel>[],
          );
        });
      }
    }

    final assignmentSubmissions =
        await _runWithConcurrency<_AssignmentSubmissions>(
          assignmentSubmissionLoaders,
          maxConcurrent: 6,
        );
    final labSubmissions = await _runWithConcurrency<_LabSubmissions>(
      labSubmissionLoaders,
      maxConcurrent: 6,
    );

    final pendingByCourse = <int, int>{
      for (final course in courses) course.courseId: 0,
    };
    final labPendingByCourse = <int, int>{
      for (final course in courses) course.courseId: 0,
    };
    final tasks = <TAV9TaskItem>[];
    var assignmentsGradedThisWeek = 0;
    var labsReviewedThisWeek = 0;

    for (final item in assignmentSubmissions) {
      for (final submission in item.submissions) {
        if (_isPendingGrading(submission.submissionStatus)) {
          pendingByCourse[item.course.courseId] =
              (pendingByCourse[item.course.courseId] ?? 0) + 1;
          tasks.add(
            TAV9TaskItem(
              title: 'Grade ${item.assignment.title}',
              courseLabel: _courseLabel(item.course),
              dueLabel: relativeTime(submission.submittedAt),
              category: TAV9TaskCategory.grading,
              priority: _priorityForDate(item.assignment.dueDate),
              route: '/ta/assignments/${item.assignment.assignmentId}',
            ),
          );
        }
        if (_isThisWeek(submission.gradedAt) ||
            (submission.submissionStatus == api.SubmissionStatus.graded &&
                _isThisWeek(submission.submittedAt))) {
          assignmentsGradedThisWeek += 1;
        }
      }
    }

    for (final item in labSubmissions) {
      for (final submission in item.submissions) {
        if (_isPendingGrading(submission.submissionStatus)) {
          labPendingByCourse[item.course.courseId] =
              (labPendingByCourse[item.course.courseId] ?? 0) + 1;
          tasks.add(
            TAV9TaskItem(
              title: 'Review ${item.lab.title}',
              courseLabel: _courseLabel(item.course),
              dueLabel: relativeTime(submission.submittedAt),
              category: TAV9TaskCategory.review,
              priority: _priorityForDate(item.lab.dueDate),
              route: '/ta/lab/${item.lab.labId ?? item.lab.id}',
            ),
          );
        }
        if (_isThisWeek(submission.gradedAt) ||
            (submission.submissionStatus == api.SubmissionStatus.graded &&
                _isThisWeek(submission.submittedAt))) {
          labsReviewedThisWeek += 1;
        }
      }
    }

    tasks.sort((a, b) {
      final byPriority = a.priority.index.compareTo(b.priority.index);
      if (byPriority != 0) return byPriority;
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });

    final labsByCourseId = <int, List<LabModel>>{
      for (final item in labsByCourse) item.course.courseId: item.labs,
    };

    final courseMetrics = courses.map((course) {
      final pendingAssignments = pendingByCourse[course.courseId] ?? 0;
      final pendingLabs = labPendingByCourse[course.courseId] ?? 0;
      final upcomingLabs =
          (labsByCourseId[course.courseId] ?? const <LabModel>[])
              .where(
                (lab) =>
                    lab.dueDate != null && lab.dueDate!.isAfter(DateTime.now()),
              )
              .length;
      final openTasks = pendingAssignments + pendingLabs + upcomingLabs;

      return TAV9CourseMetrics(
        course: course,
        openTasks: openTasks,
        pendingGrading: pendingAssignments,
        pendingLabs: pendingLabs,
        students:
            sectionStudentCounts[course.sectionId] ?? course.enrolledCount,
      );
    }).toList();

    courseMetrics.sort((a, b) {
      final byTasks = b.openTasks.compareTo(a.openTasks);
      if (byTasks != 0) return byTasks;
      return b.students.compareTo(a.students);
    });

    final pendingGrading =
        pendingByCourse.values.fold<int>(0, (sum, count) => sum + count) +
        labPendingByCourse.values.fold<int>(0, (sum, count) => sum + count);

    return TAV9Snapshot(
      courses: courseMetrics,
      tasks: tasks,
      pendingGrading: pendingGrading,
      assignmentsGradedThisWeek: assignmentsGradedThisWeek,
      labsReviewedThisWeek: labsReviewedThisWeek,
      weeklySessions: await sessionsFuture,
      questionsAnswered: null,
      aiTimeSaved: null,
      totalStudents: courseMetrics.fold<int>(
        0,
        (sum, item) => sum + item.students,
      ),
    );
  }

  static String relativeTime(DateTime value) {
    final now = DateTime.now();
    final difference = value.difference(now);
    if (difference.inDays == 0 && value.day == now.day) return 'Today';
    if (difference.inDays == 1 ||
        DateTime(value.year, value.month, value.day) ==
            DateTime(now.year, now.month, now.day + 1)) {
      return 'Tomorrow';
    }
    if (difference.isNegative) {
      final age = now.difference(value);
      if (age.inDays < 1) return '${age.inHours}h ago';
      return '${age.inDays}d ago';
    }
    if (difference.inDays < 7) return '${difference.inDays + 1}d';
    return '${value.month}/${value.day}/${value.year}';
  }

  static String _courseLabel(TeachingCourseModel course) {
    final code = course.course.code.trim();
    if (code.isNotEmpty) return code;
    final name = course.course.name.trim();
    return name.isNotEmpty ? name : 'Course';
  }

  static TAV9TaskPriority _priorityForDate(DateTime? dueDate) {
    if (dueDate == null) return TAV9TaskPriority.low;
    final hours = dueDate.difference(DateTime.now()).inHours;
    if (hours <= 24) return TAV9TaskPriority.high;
    if (hours <= 72) return TAV9TaskPriority.medium;
    return TAV9TaskPriority.low;
  }

  static bool _isPendingGrading(api.SubmissionStatus status) {
    return status == api.SubmissionStatus.submitted ||
        status == api.SubmissionStatus.resubmit;
  }

  static bool _isThisWeek(DateTime? value) {
    if (value == null) return false;
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    return value.isAfter(cutoff);
  }

  static Future<int?> _loadWeeklySessionCount(
    ScheduleApiService scheduleService,
  ) async {
    final result = await scheduleService.getWeeklySchedule(
      startDate: toISODate(startOfWeek(DateTime.now())),
    );
    if (!result.isSuccess || result.data == null) return null;
    return ScheduleItemBuilder.build(days: result.data!.days).length;
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

class TAV9Snapshot {
  final List<TAV9CourseMetrics> courses;
  final List<TAV9TaskItem> tasks;
  final int pendingGrading;
  final int assignmentsGradedThisWeek;
  final int labsReviewedThisWeek;
  final int? weeklySessions;
  final int? questionsAnswered;
  final String? aiTimeSaved;
  final int totalStudents;

  const TAV9Snapshot({
    required this.courses,
    required this.tasks,
    required this.pendingGrading,
    required this.assignmentsGradedThisWeek,
    required this.labsReviewedThisWeek,
    required this.weeklySessions,
    required this.questionsAnswered,
    required this.aiTimeSaved,
    required this.totalStudents,
  });

  static const empty = TAV9Snapshot(
    courses: <TAV9CourseMetrics>[],
    tasks: <TAV9TaskItem>[],
    pendingGrading: 0,
    assignmentsGradedThisWeek: 0,
    labsReviewedThisWeek: 0,
    weeklySessions: null,
    questionsAnswered: null,
    aiTimeSaved: null,
    totalStudents: 0,
  );
}

class TAV9CourseMetrics {
  final TeachingCourseModel course;
  final int openTasks;
  final int pendingGrading;
  final int pendingLabs;
  final int students;

  const TAV9CourseMetrics({
    required this.course,
    required this.openTasks,
    required this.pendingGrading,
    required this.pendingLabs,
    required this.students,
  });
}

class TAV9TaskItem {
  final String title;
  final String courseLabel;
  final String dueLabel;
  final TAV9TaskCategory category;
  final TAV9TaskPriority priority;
  final String route;

  const TAV9TaskItem({
    required this.title,
    required this.courseLabel,
    required this.dueLabel,
    required this.category,
    required this.priority,
    required this.route,
  });
}

enum TAV9TaskCategory { grading, review, discussion }

enum TAV9TaskPriority { high, medium, low }

class _CourseAssignments {
  final TeachingCourseModel course;
  final List<AssignmentModel> assignments;

  const _CourseAssignments(this.course, this.assignments);
}

class _CourseLabs {
  final TeachingCourseModel course;
  final List<LabModel> labs;

  const _CourseLabs(this.course, this.labs);
}

class _AssignmentSubmissions {
  final TeachingCourseModel course;
  final AssignmentModel assignment;
  final List<AssignmentSubmissionModel> submissions;

  const _AssignmentSubmissions(this.course, this.assignment, this.submissions);
}

class _LabSubmissions {
  final TeachingCourseModel course;
  final LabModel lab;
  final List<LabSubmissionModel> submissions;

  const _LabSubmissions(this.course, this.lab, this.submissions);
}

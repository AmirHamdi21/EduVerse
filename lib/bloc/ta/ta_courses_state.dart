import 'package:equatable/equatable.dart';

import '../../models/assignments/assignment_model.dart';
import '../../models/assignments/assignment_submission_model.dart';
import '../../models/core/section_model.dart';
import '../../models/instructor/teaching_course_model.dart';
import '../../models/labs/lab_model.dart';

// ──────────────────────────────────────────────────────────────
// Per-tab sub-state: sealed hierarchy with Equatable
// ──────────────────────────────────────────────────────────────

sealed class TASubTabState<T> extends Equatable {
  const TASubTabState();
}

class TASubTabInitial<T> extends TASubTabState<T> {
  const TASubTabInitial();

  @override
  List<Object?> get props => const <Object?>[];
}

class TASubTabLoading<T> extends TASubTabState<T> {
  const TASubTabLoading();

  @override
  List<Object?> get props => const <Object?>[];
}

class TASubTabLoaded<T> extends TASubTabState<T> {
  const TASubTabLoaded(this.data);

  final T data;

  @override
  List<Object?> get props => <Object?>[data];
}

class TASubTabError<T> extends TASubTabState<T> {
  const TASubTabError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

// ──────────────────────────────────────────────────────────────
// Helper models for aggregated sub-tab data
// ──────────────────────────────────────────────────────────────

/// Overview sub-tab aggregated data.
class TACourseOverview extends Equatable {
  const TACourseOverview({
    required this.totalStudents,
    required this.totalAssignments,
    required this.totalLabs,
    required this.pendingGrading,
  });

  final int totalStudents;
  final int totalAssignments;
  final int totalLabs;
  final int pendingGrading;

  @override
  List<Object?> get props => <Object?>[
    totalStudents,
    totalAssignments,
    totalLabs,
    pendingGrading,
  ];
}

/// Sections & Labs sub-tab combined data.
class TACourseSectionsLabs extends Equatable {
  const TACourseSectionsLabs({
    required this.sections,
    required this.labs,
  });

  final List<SectionModel> sections;
  final List<LabModel> labs;

  @override
  List<Object?> get props => <Object?>[sections, labs];
}

/// Per-lab attendance summary for aggregated attendance sub-tab.
class TALabAttendanceSummary extends Equatable {
  const TALabAttendanceSummary({
    required this.labId,
    required this.labTitle,
    required this.presentCount,
    required this.absentCount,
    required this.excusedCount,
    required this.lateCount,
  });

  final int labId;
  final String labTitle;
  final int presentCount;
  final int absentCount;
  final int excusedCount;
  final int lateCount;

  int get totalCount => presentCount + absentCount + excusedCount + lateCount;

  @override
  List<Object?> get props => <Object?>[
    labId,
    labTitle,
    presentCount,
    absentCount,
    excusedCount,
    lateCount,
  ];
}

// ──────────────────────────────────────────────────────────────
// Compound state: single immutable class with per-tab slices
// ──────────────────────────────────────────────────────────────

class TACoursesState extends Equatable {
  const TACoursesState({
    this.coursesStatus = const TASubTabInitial<List<TeachingCourseModel>>(),
    this.overviewData = const TASubTabInitial<TACourseOverview>(),
    this.sectionsLabsData = const TASubTabInitial<TACourseSectionsLabs>(),
    this.structureData = const TASubTabInitial<dynamic>(),
    this.materialsData = const TASubTabInitial<List<dynamic>>(),
    this.assignmentsData = const TASubTabInitial<List<AssignmentModel>>(),
    this.pendingGradingData = const TASubTabInitial<List<AssignmentSubmissionModel>>(),
    this.attendanceSummaryData = const TASubTabInitial<List<TALabAttendanceSummary>>(),
    this.studentsData = const TASubTabInitial<List<dynamic>>(),
  });

  /// Sub-tab 0: TA courses list
  final TASubTabState<List<TeachingCourseModel>> coursesStatus;

  /// Sub-tab 1: Course overview
  final TASubTabState<TACourseOverview> overviewData;

  /// Sub-tab 2: Sections & Labs
  final TASubTabState<TACourseSectionsLabs> sectionsLabsData;

  /// Sub-tab 3: Lectures / Course structure
  final TASubTabState<dynamic> structureData;

  /// Sub-tab 4: Materials
  final TASubTabState<List<dynamic>> materialsData;

  /// Sub-tab 5: Assignments
  final TASubTabState<List<AssignmentModel>> assignmentsData;

  /// Sub-tab 6: Pending grading
  final TASubTabState<List<AssignmentSubmissionModel>> pendingGradingData;

  /// Sub-tab 7: Attendance summary
  final TASubTabState<List<TALabAttendanceSummary>> attendanceSummaryData;

  /// Sub-tab 8: Students
  final TASubTabState<List<dynamic>> studentsData;

  TACoursesState copyWith({
    TASubTabState<List<TeachingCourseModel>>? coursesStatus,
    TASubTabState<TACourseOverview>? overviewData,
    TASubTabState<TACourseSectionsLabs>? sectionsLabsData,
    TASubTabState<dynamic>? structureData,
    TASubTabState<List<dynamic>>? materialsData,
    TASubTabState<List<AssignmentModel>>? assignmentsData,
    TASubTabState<List<AssignmentSubmissionModel>>? pendingGradingData,
    TASubTabState<List<TALabAttendanceSummary>>? attendanceSummaryData,
    TASubTabState<List<dynamic>>? studentsData,
  }) {
    return TACoursesState(
      coursesStatus: coursesStatus ?? this.coursesStatus,
      overviewData: overviewData ?? this.overviewData,
      sectionsLabsData: sectionsLabsData ?? this.sectionsLabsData,
      structureData: structureData ?? this.structureData,
      materialsData: materialsData ?? this.materialsData,
      assignmentsData: assignmentsData ?? this.assignmentsData,
      pendingGradingData: pendingGradingData ?? this.pendingGradingData,
      attendanceSummaryData: attendanceSummaryData ?? this.attendanceSummaryData,
      studentsData: studentsData ?? this.studentsData,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    coursesStatus,
    overviewData,
    sectionsLabsData,
    structureData,
    materialsData,
    assignmentsData,
    pendingGradingData,
    attendanceSummaryData,
    studentsData,
  ];
}

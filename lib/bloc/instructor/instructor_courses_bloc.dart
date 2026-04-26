import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/instructor/instructor_course_model.dart';
import '../../models/instructor/teaching_course_model.dart';
import '../../services/api/assignment_service.dart';
import '../../services/api/enrollment_service.dart';
import '../../services/api/lab_service.dart';
import '../../services/api/material_service.dart';
import 'instructor_courses_event.dart';
import 'instructor_courses_state.dart';

class InstructorCoursesBloc
    extends Bloc<InstructorCoursesEvent, InstructorCoursesState> {
  final EnrollmentService _enrollmentService;
  final AssignmentService _assignmentService;
  final LabService _labService;
  final MaterialService? _materialService;

  InstructorCoursesBloc({
    required EnrollmentService enrollmentService,
    required AssignmentService assignmentService,
    required LabService labService,
    MaterialService? materialService,
  }) : _enrollmentService = enrollmentService,
       _assignmentService = assignmentService,
       _labService = labService,
       _materialService = materialService,
       super(const InstructorCoursesInitial()) {
    on<LoadTeachingCourses>(_onLoadTeachingCourses);
    on<SelectCourse>(_onSelectCourse);
    on<LoadDeadlines>(_onLoadDeadlines);
    on<LoadSectionStudents>(_onLoadSectionStudents);
    on<LoadCourseStudents>(_onLoadCourseStudents);
    on<LoadEngagementMetrics>(_onLoadEngagementMetrics);
  }

  Future<void> _onLoadTeachingCourses(
    LoadTeachingCourses event,
    Emitter<InstructorCoursesState> emit,
  ) async {
    emit(const InstructorCoursesLoading());

    final result = await _enrollmentService.getTeachingCourses();
    if (!result.isSuccess || result.data == null) {
      emit(
        InstructorCoursesError(
          result.error?.message ?? 'Failed to load teaching courses',
        ),
      );
      return;
    }

    emit(InstructorCoursesLoaded(result.data!));
  }

  void _onSelectCourse(
    SelectCourse event,
    Emitter<InstructorCoursesState> emit,
  ) {
    final current = state;
    if (current is InstructorCoursesLoaded) {
      TeachingCourseModel? teachingCourse;
      for (final course in current.courses) {
        if (course.courseId == event.courseId) {
          teachingCourse = course;
          break;
        }
      }

      final resolvedSectionId =
          teachingCourse?.sectionId ?? current.selectedSectionId;
      final isSameSection = resolvedSectionId == current.selectedSectionId;

      emit(
        InstructorCoursesLoaded(
          current.courses,
          selectedCourseId: event.courseId,
          selectedSectionId: resolvedSectionId,
          deadlines: current.deadlines,
          sectionStudents: isSameSection
              ? current.sectionStudents
              : const <SectionStudentModel>[],
          studentsStatus: isSameSection
              ? current.studentsStatus
              : CourseStudentsStatus.initial,
          studentsErrorMessage: isSameSection
              ? current.studentsErrorMessage
              : null,
          engagementMetrics: current.engagementMetrics,
        ),
      );
    }
  }

  Future<void> _onLoadDeadlines(
    LoadDeadlines event,
    Emitter<InstructorCoursesState> emit,
  ) async {
    final assignmentsFuture = _assignmentService.getAll(
      courseId: event.courseId,
      limit: 20,
    );
    final labsFuture = _labService.getAll(courseId: event.courseId);

    final results = await Future.wait<dynamic>(<Future<dynamic>>[
      assignmentsFuture,
      labsFuture,
    ]);

    final deadlines = <DeadlineCardModel>[];

    final assignmentResult = results[0];
    if (assignmentResult.isSuccess && assignmentResult.data != null) {
      final assignmentItems = assignmentResult.data!.data;
      for (final item in assignmentItems) {
        final dueDate = item.dueDate;
        if (dueDate == null || dueDate.isBefore(DateTime.now())) {
          continue;
        }

        deadlines.add(
          DeadlineCardModel(
            id: item.id,
            title: item.title,
            type: DeadlineType.assignment,
            dueDate: dueDate,
            status: _resolveStatus(dueDate),
            courseId: event.courseId,
          ),
        );
      }
    }

    final labResult = results[1];
    if (labResult.isSuccess && labResult.data != null) {
      for (final lab in labResult.data!) {
        final dueDate = lab.dueDate;
        if (dueDate == null || dueDate.isBefore(DateTime.now())) {
          continue;
        }

        deadlines.add(
          DeadlineCardModel(
            id: lab.id,
            title: lab.title,
            type: DeadlineType.lab,
            dueDate: dueDate,
            status: _resolveStatus(dueDate),
            courseId: event.courseId,
          ),
        );
      }
    }

    deadlines.sort((a, b) {
      final left = a.dueDate ?? DateTime.fromMillisecondsSinceEpoch(0);
      final right = b.dueDate ?? DateTime.fromMillisecondsSinceEpoch(0);
      return left.compareTo(right);
    });

    final current = state;
    if (current is InstructorCoursesLoaded) {
      emit(
        InstructorCoursesLoaded(
          current.courses,
          selectedCourseId: current.selectedCourseId,
          selectedSectionId: current.selectedSectionId,
          deadlines: deadlines,
          sectionStudents: current.sectionStudents,
          studentsStatus: current.studentsStatus,
          studentsErrorMessage: current.studentsErrorMessage,
          engagementMetrics: current.engagementMetrics,
        ),
      );
    }
  }

  Future<void> _onLoadSectionStudents(
    LoadSectionStudents event,
    Emitter<InstructorCoursesState> emit,
  ) async {
    final current = state;
    if (current is! InstructorCoursesLoaded) {
      return;
    }

    emit(
      InstructorCoursesLoaded(
        current.courses,
        selectedCourseId: current.selectedCourseId,
        selectedSectionId: event.sectionId,
        deadlines: current.deadlines,
        sectionStudents: current.sectionStudents,
        studentsStatus: CourseStudentsStatus.loading,
        engagementMetrics: current.engagementMetrics,
      ),
    );

    final result = await _enrollmentService.getSectionStudentsLite(
      event.sectionId,
    );
    final latest = state;
    if (latest is! InstructorCoursesLoaded) {
      return;
    }

    if (!result.isSuccess || result.data == null) {
      emit(
        InstructorCoursesLoaded(
          latest.courses,
          selectedCourseId: latest.selectedCourseId,
          selectedSectionId: latest.selectedSectionId,
          deadlines: latest.deadlines,
          sectionStudents: latest.sectionStudents,
          studentsStatus: CourseStudentsStatus.error,
          studentsErrorMessage:
              result.error?.message ?? 'Failed to load section students',
          engagementMetrics: latest.engagementMetrics,
        ),
      );
      return;
    }

    emit(
      InstructorCoursesLoaded(
        latest.courses,
        selectedCourseId: latest.selectedCourseId,
        selectedSectionId: event.sectionId,
        deadlines: latest.deadlines,
        sectionStudents: result.data!,
        studentsStatus: CourseStudentsStatus.loaded,
        engagementMetrics: latest.engagementMetrics,
      ),
    );
  }

  Future<void> _onLoadCourseStudents(
    LoadCourseStudents event,
    Emitter<InstructorCoursesState> emit,
  ) async {
    final current = state;
    if (current is! InstructorCoursesLoaded) {
      return;
    }

    int? sectionId;
    for (final course in current.courses) {
      if (course.courseId == event.courseId) {
        sectionId = course.sectionId;
        break;
      }
    }
    sectionId ??= current.selectedSectionId;

    emit(
      InstructorCoursesLoaded(
        current.courses,
        selectedCourseId: current.selectedCourseId ?? event.courseId,
        selectedSectionId: sectionId,
        deadlines: current.deadlines,
        sectionStudents: current.sectionStudents,
        studentsStatus: CourseStudentsStatus.loading,
        engagementMetrics: current.engagementMetrics,
      ),
    );

    if (sectionId == null || sectionId <= 0) {
      final latest = state;
      if (latest is! InstructorCoursesLoaded) {
        return;
      }

      emit(
        InstructorCoursesLoaded(
          latest.courses,
          selectedCourseId: latest.selectedCourseId,
          selectedSectionId: latest.selectedSectionId,
          deadlines: latest.deadlines,
          sectionStudents: latest.sectionStudents,
          studentsStatus: CourseStudentsStatus.error,
          studentsErrorMessage: 'No valid section selected',
          engagementMetrics: latest.engagementMetrics,
        ),
      );
      return;
    }

    final result = await _enrollmentService.getSectionStudentsLite(sectionId);
    final latest = state;
    if (latest is! InstructorCoursesLoaded) {
      return;
    }

    if (!result.isSuccess || result.data == null) {
      emit(
        InstructorCoursesLoaded(
          latest.courses,
          selectedCourseId: latest.selectedCourseId,
          selectedSectionId: latest.selectedSectionId,
          deadlines: latest.deadlines,
          sectionStudents: latest.sectionStudents,
          studentsStatus: CourseStudentsStatus.error,
          studentsErrorMessage:
              result.error?.message ?? 'Failed to load enrolled students',
          engagementMetrics: latest.engagementMetrics,
        ),
      );
      return;
    }

    emit(
      InstructorCoursesLoaded(
        latest.courses,
        selectedCourseId: latest.selectedCourseId,
        selectedSectionId: sectionId,
        deadlines: latest.deadlines,
        sectionStudents: result.data!,
        studentsStatus: CourseStudentsStatus.loaded,
        engagementMetrics: latest.engagementMetrics,
      ),
    );
  }

  Future<void> _onLoadEngagementMetrics(
    LoadEngagementMetrics event,
    Emitter<InstructorCoursesState> emit,
  ) async {
    final current = state;
    if (current is! InstructorCoursesLoaded) {
      return;
    }

    var totalMaterialViews = 0;
    var totalMaterialDownloads = 0;
    var totalSubmissions = 0;
    final uniqueSubmitters = <int>{};

    try {
      final materials =
          await _materialService?.getMaterials(event.courseId) ?? const [];
      totalMaterialViews = materials.fold<int>(
        0,
        (sum, item) => sum + (item.viewCount ?? 0),
      );
      totalMaterialDownloads = materials.fold<int>(
        0,
        (sum, item) => sum + (item.downloadCount ?? 0),
      );
    } catch (_) {
      totalMaterialViews = 0;
      totalMaterialDownloads = 0;
    }

    final assignmentsResult = await _assignmentService.getAll(
      courseId: event.courseId,
      limit: 20,
    );

    if (assignmentsResult.isSuccess && assignmentsResult.data != null) {
      final assignments = assignmentsResult.data!.data;
      final submissionsResults = await Future.wait(
        assignments.map((item) => _assignmentService.getSubmissions(item.id)),
      );

      for (final submissionResult in submissionsResults) {
        if (!submissionResult.isSuccess || submissionResult.data == null) {
          continue;
        }

        totalSubmissions += submissionResult.data!.length;
        uniqueSubmitters.addAll(
          submissionResult.data!
              .map((submission) => submission.userId)
              .where((userId) => userId > 0),
        );
      }
    }

    final rate = event.totalEnrolledStudents <= 0
        ? 0.0
        : (uniqueSubmitters.length / event.totalEnrolledStudents) * 100;

    final metrics = EngagementMetricsModel(
      totalMaterialViews: totalMaterialViews,
      totalMaterialDownloads: totalMaterialDownloads,
      assignmentSubmissionRate: rate.clamp(0, 100).toDouble(),
      totalSubmissions: totalSubmissions,
      totalEnrolledStudents: event.totalEnrolledStudents,
    );

    emit(
      InstructorCoursesLoaded(
        current.courses,
        selectedCourseId: current.selectedCourseId,
        selectedSectionId: current.selectedSectionId,
        deadlines: current.deadlines,
        sectionStudents: current.sectionStudents,
        studentsStatus: current.studentsStatus,
        studentsErrorMessage: current.studentsErrorMessage,
        engagementMetrics: metrics,
      ),
    );
  }

  DeadlineStatus _resolveStatus(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);

    if (dueDay.isBefore(today)) {
      return DeadlineStatus.overdue;
    }

    if (dueDay == today) {
      return DeadlineStatus.dueToday;
    }

    return DeadlineStatus.upcoming;
  }
}

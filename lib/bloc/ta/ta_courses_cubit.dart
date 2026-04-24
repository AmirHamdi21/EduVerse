import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/assignments/assignment_model.dart';
import '../../models/assignments/assignment_submission_model.dart';
import '../../models/core/enums/assignment_enums.dart' as api;
import '../../models/core/enums/lab_enums.dart';
import '../../models/instructor/teaching_course_model.dart';
import '../../models/materials/course_material_model.dart';
import '../../services/api/assignment_service.dart';
import '../../services/api/course_service.dart';
import '../../services/api/enrollment_service.dart';
import '../../services/api/lab_service.dart';
import '../../services/api/material_service.dart';
import '../../services/api/section_service.dart';
import 'ta_courses_state.dart';

/// Cubit managing TA course list and all 9 course detail sub-tabs.
///
/// Uses a compound [TACoursesState] — each method updates only its
/// own sub-tab slice via `copyWith`, never resetting sibling data.
class TACoursesCubit extends Cubit<TACoursesState> {
  TACoursesCubit({
    required EnrollmentService enrollmentService,
    required SectionService sectionService,
    required LabService labService,
    required CourseService courseService,
    required MaterialService materialService,
    required AssignmentService assignmentService,
  }) : _enrollmentService = enrollmentService,
       _sectionService = sectionService,
       _labService = labService,
       _courseService = courseService,
       _materialService = materialService,
       _assignmentService = assignmentService,
       super(const TACoursesState());

  final EnrollmentService _enrollmentService;
  final SectionService _sectionService;
  final LabService _labService;
  final CourseService _courseService;
  final MaterialService _materialService;
  final AssignmentService _assignmentService;

  // ── Course list ──────────────────────────────────────────────

  /// Fetches the TA's assigned teaching courses.
  Future<void> fetchTACourses() async {
    emit(
      state.copyWith(
        coursesStatus: const TASubTabLoading<List<TeachingCourseModel>>(),
      ),
    );

    final result = await _enrollmentService.getTeachingCourses();

    if (!result.isSuccess || result.data == null) {
      emit(
        state.copyWith(
          coursesStatus: TASubTabError<List<TeachingCourseModel>>(
            result.error?.message ?? 'Failed to load teaching courses',
          ),
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        coursesStatus: TASubTabLoaded<List<TeachingCourseModel>>(result.data!),
      ),
    );

    // Fetch student counts for all sections in parallel
    final sectionIds = result.data!
        .map((tc) => tc.sectionId)
        .where((id) => id > 0)
        .toList();

    if (sectionIds.isNotEmpty) {
      await fetchAllSectionStudentsCounts(sectionIds);
    }
  }

  // ── Sub-tab 1: Overview ──────────────────────────────────────

  /// Aggregates course overview statistics.
  Future<void> fetchCourseOverview(int courseId) async {
    emit(
      state.copyWith(overviewData: const TASubTabLoading<TACourseOverview>()),
    );

    try {
      // Fetch assignments count
      final assignmentsResult = await _assignmentService.getAll(
        courseId: courseId,
        limit: 1,
      );
      final totalAssignments = assignmentsResult.isSuccess
          ? (assignmentsResult.data?.total ?? 0)
          : 0;

      // Fetch labs count
      final labsResult = await _labService.getAll(courseId: courseId);
      final totalLabs = labsResult.isSuccess
          ? (labsResult.data?.length ?? 0)
          : 0;

      // Approximate pending grading from assignments
      int pendingGrading = 0;
      if (assignmentsResult.isSuccess && assignmentsResult.data != null) {
        final allAssignments = await _assignmentService.getAll(
          courseId: courseId,
          limit: 100,
        );
        if (allAssignments.isSuccess && allAssignments.data != null) {
          for (final assignment in allAssignments.data!.data) {
            final subsResult = await _assignmentService.getSubmissions(
              assignment.assignmentId,
            );
            if (subsResult.isSuccess && subsResult.data != null) {
              pendingGrading += subsResult.data!
                  .where((s) => s.submissionStatus.value == 'submitted')
                  .length;
            }
          }
        }
      }

      emit(
        state.copyWith(
          overviewData: TASubTabLoaded<TACourseOverview>(
            TACourseOverview(
              totalStudents: 0,
              totalAssignments: totalAssignments,
              totalLabs: totalLabs,
              pendingGrading: pendingGrading,
            ),
          ),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          overviewData: TASubTabError<TACourseOverview>(
            'Failed to load course overview: $e',
          ),
        ),
      );
    }
  }

  // ── Sub-tab 2: Sections & Labs ───────────────────────────────

  /// Loads sections and labs for a course.
  Future<void> fetchCourseSectionsAndLabs(int courseId) async {
    emit(
      state.copyWith(
        sectionsLabsData: const TASubTabLoading<TACourseSectionsLabs>(),
      ),
    );

    try {
      final sectionsResult = await _sectionService.getByCourse(courseId);
      final labsResult = await _labService.getAll(courseId: courseId);

      if (!sectionsResult.isSuccess) {
        emit(
          state.copyWith(
            sectionsLabsData: TASubTabError<TACourseSectionsLabs>(
              sectionsResult.error?.message ?? 'Failed to load sections',
            ),
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          sectionsLabsData: TASubTabLoaded<TACourseSectionsLabs>(
            TACourseSectionsLabs(
              sections: sectionsResult.data ?? const [],
              labs: labsResult.data ?? const [],
            ),
          ),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          sectionsLabsData: TASubTabError<TACourseSectionsLabs>(
            'Failed to load sections & labs: $e',
          ),
        ),
      );
    }
  }

  // ── Sub-tab 3: Lectures / Structure ──────────────────────────

  /// Loads week-based course structure.
  Future<void> fetchCourseStructure(int courseId) async {
    emit(state.copyWith(structureData: const TASubTabLoading<dynamic>()));

    try {
      final structure = await _courseService.getCourseStructure(courseId);
      emit(state.copyWith(structureData: TASubTabLoaded<dynamic>(structure)));
    } catch (e) {
      emit(
        state.copyWith(
          structureData: TASubTabError<dynamic>(
            'Failed to load course structure: $e',
          ),
        ),
      );
    }
  }

  // ── Sub-tab 4: Materials ─────────────────────────────────────

  /// Loads published course materials.
  Future<void> fetchCourseMaterials(int courseId) async {
    emit(
      state.copyWith(
        materialsData: const TASubTabLoading<List<CourseMaterialModel>>(),
      ),
    );

    try {
      final materials = await _materialService.getMaterials(courseId);
      emit(
        state.copyWith(
          materialsData: TASubTabLoaded<List<CourseMaterialModel>>(materials),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          materialsData: TASubTabError<List<CourseMaterialModel>>(
            'Failed to load materials: $e',
          ),
        ),
      );
    }
  }

  // ── Sub-tab 5: Assignments ───────────────────────────────────

  /// Loads all assignments for a course.
  Future<void> fetchCourseAssignments(int courseId) async {
    emit(
      state.copyWith(
        assignmentsData: const TASubTabLoading<List<AssignmentModel>>(),
      ),
    );

    try {
      final result = await _assignmentService.getAll(
        courseId: courseId,
        limit: 100,
      );

      if (!result.isSuccess || result.data == null) {
        emit(
          state.copyWith(
            assignmentsData: TASubTabError<List<AssignmentModel>>(
              result.error?.message ?? 'Failed to load assignments',
            ),
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          assignmentsData: TASubTabLoaded<List<AssignmentModel>>(
            result.data!.data,
          ),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          assignmentsData: TASubTabError<List<AssignmentModel>>(
            'Failed to load assignments: $e',
          ),
        ),
      );
    }
  }

  // ── Sub-tab 6: Pending Grading ───────────────────────────────

  /// Fetches ungraded assignment submissions across all course assignments.
  Future<void> fetchPendingGrading(int courseId) async {
    emit(
      state.copyWith(
        pendingGradingData:
            const TASubTabLoading<List<AssignmentSubmissionModel>>(),
      ),
    );

    try {
      final assignmentsResult = await _assignmentService.getAll(
        courseId: courseId,
        limit: 100,
      );

      if (!assignmentsResult.isSuccess || assignmentsResult.data == null) {
        emit(
          state.copyWith(
            pendingGradingData: TASubTabError<List<AssignmentSubmissionModel>>(
              assignmentsResult.error?.message ?? 'Failed to load assignments',
            ),
          ),
        );
        return;
      }

      final pending = <AssignmentSubmissionModel>[];

      for (final assignment in assignmentsResult.data!.data) {
        final subsResult = await _assignmentService.getSubmissions(
          assignment.assignmentId,
        );
        if (subsResult.isSuccess && subsResult.data != null) {
          pending.addAll(
            subsResult.data!.where(
              (sub) => sub.submissionStatus.value == 'submitted',
            ),
          );
        }
      }

      emit(
        state.copyWith(
          pendingGradingData: TASubTabLoaded<List<AssignmentSubmissionModel>>(
            pending,
          ),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          pendingGradingData: TASubTabError<List<AssignmentSubmissionModel>>(
            'Failed to load pending grading: $e',
          ),
        ),
      );
    }
  }

  // ── Sub-tab 7: Attendance Summary ────────────────────────────

  /// Aggregates attendance per-lab (N sequential calls, client-side).
  Future<void> fetchAttendanceSummary(int courseId) async {
    emit(
      state.copyWith(
        attendanceSummaryData:
            const TASubTabLoading<List<TALabAttendanceSummary>>(),
      ),
    );

    try {
      final labsResult = await _labService.getAll(courseId: courseId);

      if (!labsResult.isSuccess || labsResult.data == null) {
        emit(
          state.copyWith(
            attendanceSummaryData: TASubTabError<List<TALabAttendanceSummary>>(
              labsResult.error?.message ?? 'Failed to load labs for attendance',
            ),
          ),
        );
        return;
      }

      final summaries = <TALabAttendanceSummary>[];

      for (final lab in labsResult.data!) {
        final labId = lab.labId ?? int.tryParse(lab.id);
        if (labId == null) continue;

        final attendanceResult = await _labService.getAttendance(labId);

        int present = 0, absent = 0, excused = 0, lateCount = 0;
        if (attendanceResult.isSuccess && attendanceResult.data != null) {
          for (final record in attendanceResult.data!) {
            switch (record.attendanceStatus) {
              case LabAttendanceStatus.present:
                present++;
              case LabAttendanceStatus.absent:
                absent++;
              case LabAttendanceStatus.excused:
                excused++;
              // ignore: constant_identifier_names
              case LabAttendanceStatus.late:
                lateCount++;
              case LabAttendanceStatus.unknown:
                break;
            }
          }
        }

        summaries.add(
          TALabAttendanceSummary(
            labId: labId,
            labTitle: lab.title,
            presentCount: present,
            absentCount: absent,
            excusedCount: excused,
            lateCount: lateCount,
          ),
        );
      }

      emit(
        state.copyWith(
          attendanceSummaryData: TASubTabLoaded<List<TALabAttendanceSummary>>(
            summaries,
          ),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          attendanceSummaryData: TASubTabError<List<TALabAttendanceSummary>>(
            'Failed to load attendance summary: $e',
          ),
        ),
      );
    }
  }

  // ── Sub-tab 8: Students ──────────────────────────────────────

  /// Loads students for a specific section.
  Future<void> fetchSectionStudents(int sectionId) async {
    emit(state.copyWith(studentsData: const TASubTabLoading<List<dynamic>>()));

    try {
      final result = await _enrollmentService.getSectionStudentsLite(sectionId);

      if (!result.isSuccess || result.data == null) {
        emit(
          state.copyWith(
            studentsData: TASubTabError<List<dynamic>>(
              result.error?.message ?? 'Failed to load section students',
            ),
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          studentsData: TASubTabLoaded<List<dynamic>>(result.data!),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          studentsData: TASubTabError<List<dynamic>>(
            'Failed to load students: $e',
          ),
        ),
      );
    }
  }

  /// Fetches student counts for all sections in parallel.
  Future<void> fetchAllSectionStudentsCounts(List<int> sectionIds) async {
    if (sectionIds.isEmpty) return;

    // Fetch all counts in parallel
    final futures = sectionIds.map((sectionId) async {
      final result = await _enrollmentService.getSectionStudentsCount(
        sectionId,
      );
      if (result.isSuccess && result.data != null) {
        return MapEntry(sectionId, result.data!);
      }
      return MapEntry(sectionId, 0);
    }).toList();

    final entries = await Future.wait<MapEntry<int, int>>(futures);
    final counts = Map<int, int>.fromEntries(entries);

    emit(state.copyWith(sectionStudentCounts: counts));
  }

  // ── Assignment Deletion (Principle I) ────────────────────────

  /// Deletes an assignment and refreshes the assignments list.
  Future<void> deleteAssignment(int courseId, dynamic assignmentId) async {
    final result = await _assignmentService.delete(assignmentId);

    if (!result.isSuccess) {
      emit(
        state.copyWith(
          assignmentsData: TASubTabError<List<AssignmentModel>>(
            result.error?.message ?? 'Failed to delete assignment',
          ),
        ),
      );
      return;
    }

    // Refresh the assignments list after successful deletion.
    await fetchCourseAssignments(courseId);
  }

  Future<void> updateAssignmentStatus(
    int courseId,
    int assignmentId,
    api.AssignmentStatus status,
  ) async {
    final result = await _assignmentService.updateStatus(assignmentId, status);

    if (!result.isSuccess) {
      emit(
        state.copyWith(
          assignmentsData: TASubTabError<List<AssignmentModel>>(
            result.error?.message ?? 'Failed to update assignment status',
          ),
        ),
      );
      return;
    }

    await fetchCourseAssignments(courseId);
  }
}

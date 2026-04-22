import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/api/lab_service.dart';
import 'ta_labs_state.dart';

/// Cubit managing TA labs list, lab detail, grading, and attendance.
///
/// All mutations (delete, grade) flow through this cubit — no direct
/// service calls from the widget layer (Constitution Principle I).
class TALabsCubit extends Cubit<TALabsState> {
  TALabsCubit({required LabService labService})
    : _labService = labService,
      super(const TALabsInitial());

  final LabService _labService;

  // ── Labs List ────────────────────────────────────────────────

  /// Fetches all TA labs (optionally filtered by [courseId]).
  ///
  /// When [courseId] is null, fetches ALL labs across all assigned courses
  /// (used by the main TA Labs list screen).
  ///
  /// Preserves previously loaded labs during refresh to avoid showing
  /// a full-screen loading spinner when the user navigates back.
  Future<void> fetchTALabs({int? courseId}) async {
    final currentState = state;

    // If we have previous data, emit loading-with-cache instead of full loading
    if (currentState is TALabsLoaded && currentState.labs.isNotEmpty) {
      emit(TALabsLoadingWithCache(currentState.labs));
    } else {
      emit(const TALabsLoading());
    }

    final result = await _labService.getAll(courseId: courseId);

    if (!result.isSuccess || result.data == null) {
      // If loading fails but we have cache, restore cached data
      if (currentState is TALabsLoaded && currentState.labs.isNotEmpty) {
        emit(TALabsLoaded(currentState.labs));
      } else {
        emit(TALabsError(result.error?.message ?? 'Failed to load labs'));
      }
      return;
    }

    emit(TALabsLoaded(result.data!));
  }

  // ── Lab Detail ───────────────────────────────────────────────

  /// Loads complete lab detail: info + submissions + attendance.
  ///
  /// The resulting [TALabDetailLoaded.submissions] and
  /// [TALabDetailLoaded.attendance] are reused by T036 and T041
  /// without re-fetching.
  Future<void> fetchLabDetail(dynamic labId) async {
    emit(const TALabDetailLoading());

    try {
      final labResult = await _labService.getById(labId);
      if (!labResult.isSuccess || labResult.data == null) {
        emit(
          TALabDetailError(labResult.error?.message ?? 'Failed to load lab'),
        );
        return;
      }

      final subsResult = await _labService.getSubmissions(labId);
      final attendanceResult = await _labService.getAttendance(labId);

      emit(
        TALabDetailLoaded(
          lab: labResult.data!,
          submissions: subsResult.data ?? const [],
          attendance: attendanceResult.data ?? const [],
        ),
      );
    } catch (e) {
      emit(TALabDetailError('Failed to load lab detail: $e'));
    }
  }

  // ── Partial Refreshes ────────────────────────────────────────

  /// Refreshes only the submissions list without re-fetching lab info
  /// or attendance. Called after a grade is saved (T037).
  Future<void> refreshLabSubmissions(dynamic labId) async {
    final current = state;
    if (current is! TALabDetailLoaded) return;

    final subsResult = await _labService.getSubmissions(labId);
    if (subsResult.isSuccess && subsResult.data != null) {
      emit(current.copyWith(submissions: subsResult.data!));
    }
  }

  /// Refreshes only the attendance list. Emits
  /// [TALabAttendanceRefreshing] during the refresh so UI can show
  /// a subtle indicator without clearing existing data.
  Future<void> refreshLabAttendance(dynamic labId) async {
    final current = state;
    if (current is! TALabDetailLoaded) return;

    emit(
      TALabAttendanceRefreshing(
        lab: current.lab,
        submissions: current.submissions,
        attendance: current.attendance,
      ),
    );

    final attendanceResult = await _labService.getAttendance(labId);

    if (attendanceResult.isSuccess && attendanceResult.data != null) {
      emit(current.copyWith(attendance: attendanceResult.data!));
    } else {
      // Re-emit current data if refresh fails.
      emit(current);
    }
  }

  // ── Lab Deletion (Principle I) ───────────────────────────────

  /// Deletes a lab and refreshes the labs list.
  Future<void> deleteLab(dynamic labId) async {
    final result = await _labService.delete(labId);

    if (!result.isSuccess) {
      emit(TALabsError(result.error?.message ?? 'Failed to delete lab'));
      return;
    }

    // Refresh the labs list after successful deletion.
    await fetchTALabs();
  }

  // ── Lab Submission Grading (Principle I) ─────────────────────

  /// Grades a lab submission.
  ///
  /// **Emission order**: current → [TALabGrading] → (PATCH success) →
  /// [TALabGradeSuccess] → [refreshLabSubmissions] → updated
  /// [TALabDetailLoaded]. The [TALabGradeSuccess] MUST be emitted
  /// **before** [refreshLabSubmissions] so BlocListener can show
  /// the success toast before the list reloads.
  Future<void> gradeLabSubmission(
    dynamic labId,
    dynamic submissionId,
    double score,
    String? feedback,
    String status,
  ) async {
    emit(const TALabGrading());

    final result = await _labService.gradeSubmission(
      labId,
      submissionId,
      score,
      status: status,
      feedback: feedback,
    );

    if (!result.isSuccess) {
      emit(
        TALabGradeError(
          result.error?.message ?? 'Failed to grade lab submission',
        ),
      );
      return;
    }

    // Emit success FIRST so BlocListener can show toast.
    emit(const TALabGradeSuccess());

    // Then refresh submissions list.
    await refreshLabSubmissions(labId);
  }
}

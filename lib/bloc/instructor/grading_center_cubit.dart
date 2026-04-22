import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/assignments/assignment_submission_model.dart';
import '../../models/core/enums/assignment_enums.dart' as api;
import '../../models/instructor/grading_model.dart';
import '../../services/api/assignment_service.dart';
import 'grading_center_state.dart';

class GradingCenterCubit extends Cubit<GradingCenterState> {
  final AssignmentService _assignmentService;
  int? _activeAssignmentId;

  GradingCenterCubit({required AssignmentService assignmentService})
    : _assignmentService = assignmentService,
      super(const GradingCenterState());

  Future<void> loadGradingData({required int assignmentId}) async {
    _activeAssignmentId = assignmentId;
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _assignmentService.getSubmissions(assignmentId);
    if (!result.isSuccess || result.data == null) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: result.error?.message ?? 'Failed to load grading data',
        ),
      );
      return;
    }

    final submissions = result.data!;
    final statistics = _calculateStatistics(submissions);

    emit(
      state.copyWith(
        submissions: submissions,
        statistics: statistics,
        isLoading: false,
        clearError: true,
      ),
    );
  }

  Future<void> refreshGradingData() async {
    if (_activeAssignmentId == null) {
      return;
    }
    await loadGradingData(assignmentId: _activeAssignmentId!);
  }

  void setSelectedTab(int index) {
    emit(state.copyWith(selectedTabIndex: index));
  }

  void setFilter(GradingFilter filter) {
    emit(state.copyWith(filter: filter));
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void setSelectedCourse(String? courseId) {
    emit(
      state.copyWith(selectedCourseId: courseId, clearCourse: courseId == null),
    );
  }

  Future<void> gradeSubmission(
    int submissionId,
    double grade,
    String feedback,
  ) async {
    final assignmentId = _activeAssignmentId;
    if (assignmentId == null) {
      emit(state.copyWith(errorMessage: 'No assignment selected for grading'));
      return;
    }

    emit(state.copyWith(isGrading: true, clearError: true));

    final result = await _assignmentService.gradeSubmission(
      assignmentId,
      submissionId,
      grade,
      feedback: feedback,
    );

    if (!result.isSuccess) {
      emit(
        state.copyWith(
          isGrading: false,
          errorMessage: result.error?.message ?? 'Failed to grade submission',
        ),
      );
      return;
    }

    final updated = state.submissions.map((s) {
      if (s.id != submissionId) {
        return s;
      }

      return AssignmentSubmissionModel(
        id: s.id,
        assignmentId: s.assignmentId,
        userId: s.userId,
        submissionText: s.submissionText,
        submissionLink: s.submissionLink,
        fileId: s.fileId,
        submissionStatus: api.SubmissionStatus.graded,
        isLate: s.isLate,
        attemptNumber: s.attemptNumber,
        submittedAt: s.submittedAt,
        score: grade,
        feedback: feedback,
        gradedBy: s.gradedBy,
        gradedAt: DateTime.now(),
        user: s.user,
        driveFile: s.driveFile,
      );
    }).toList();

    emit(
      state.copyWith(
        submissions: updated,
        statistics: _calculateStatistics(updated),
        isGrading: false,
        clearError: true,
      ),
    );
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  GradingStatistics _calculateStatistics(
    List<AssignmentSubmissionModel> submissions,
  ) {
    final total = submissions.length;
    final pending = submissions
        .where(
          (s) =>
              s.submissionStatus == api.SubmissionStatus.submitted ||
              s.submissionStatus == api.SubmissionStatus.resubmit,
        )
        .length;
    final graded = submissions
        .where((s) => s.submissionStatus == api.SubmissionStatus.graded)
        .length;
    final late = submissions.where((s) => s.isLate).length;

    final gradedSubmissions = submissions.where(
      (s) =>
          s.submissionStatus == api.SubmissionStatus.graded && s.score != null,
    );
    double avgGrade = 0;
    if (gradedSubmissions.isNotEmpty) {
      avgGrade =
          gradedSubmissions.map((s) => s.score!).reduce((a, b) => a + b) /
          gradedSubmissions.length;
    }

    return GradingStatistics(
      totalSubmissions: total,
      pendingSubmissions: pending,
      gradedSubmissions: graded,
      lateSubmissions: late,
      averageGrade: avgGrade,
      completionRate: total > 0 ? graded / total : 0,
    );
  }
}

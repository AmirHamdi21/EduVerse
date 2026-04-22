import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/assignments/assignment_model.dart';
import '../../models/assignments/assignment_submission_model.dart';
import '../../models/core/enums/assignment_enums.dart' as api;
import '../../services/api/assignment_service.dart';
import 'assignment_event.dart';
import 'assignment_state.dart';

class AssignmentBloc extends Bloc<AssignmentEvent, AssignmentState> {
  final AssignmentService _assignmentService;

  AssignmentBloc({required AssignmentService assignmentService})
    : _assignmentService = assignmentService,
      super(const AssignmentState()) {
    on<FetchAssignments>(_onFetchAssignments);
    on<RefreshAssignments>(_onRefreshAssignments);
    on<SelectAssignment>(_onSelectAssignment);
    on<FetchMySubmission>(_onFetchMySubmission);
    on<SubmitTextAssignment>(_onSubmitTextAssignment);
    on<SubmitFileAssignment>(_onSubmitFileAssignment);
    on<SetAssignmentFilterStatus>(_onSetAssignmentFilterStatus);
    on<SetAssignmentSearchQuery>(_onSetAssignmentSearchQuery);
    on<ClearError>(_onClearError);
  }

  Future<void> _onFetchAssignments(
    FetchAssignments event,
    Emitter<AssignmentState> emit,
  ) async {
    await _loadAssignments(
      emit: emit,
      showLoading: true,
      courseId: event.courseId,
    );
  }

  Future<void> _onRefreshAssignments(
    RefreshAssignments event,
    Emitter<AssignmentState> emit,
  ) async {
    await _loadAssignments(
      emit: emit,
      showLoading: false,
      courseId: event.courseId ?? state.selectedCourseId,
    );
  }

  Future<void> _onSelectAssignment(
    SelectAssignment event,
    Emitter<AssignmentState> emit,
  ) async {
    emit(
      state.copyWith(
        selectedAssignment: event.assignment,
        clearSubmission: true,
        clearSubmitError: true,
        isLoading: true,
        clearError: true,
      ),
    );

    AssignmentModel selectedAssignment = event.assignment;

    final detailResult = await _assignmentService.getById(
      event.assignment.assignmentId,
    );
    if (detailResult.isSuccess && detailResult.data != null) {
      selectedAssignment = detailResult.data!;
    }

    final submissionResult = await _assignmentService.getMySubmission(
      selectedAssignment.assignmentId,
    );

    AssignmentSubmissionModel? submission;
    if (submissionResult.isSuccess && submissionResult.data != null) {
      submission = submissionResult.data;
      selectedAssignment = _applySubmissionToAssignment(
        selectedAssignment,
        submission!,
      );
    } else if (submissionResult.error?.statusCode != 404) {
      emit(
        state.copyWith(
          selectedAssignment: selectedAssignment,
          isLoading: false,
          error: submissionResult.error?.message ?? 'Failed to load submission',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        selectedAssignment: selectedAssignment,
        mySubmission: submission,
        clearSubmission: submission == null,
        isLoading: false,
        clearError: true,
      ),
    );
  }

  Future<void> _onFetchMySubmission(
    FetchMySubmission event,
    Emitter<AssignmentState> emit,
  ) async {
    final result = await _assignmentService.getMySubmission(event.assignmentId);

    if (result.isSuccess && result.data != null) {
      final submission = result.data!;
      final selected = state.selectedAssignment;
      emit(
        state.copyWith(
          mySubmission: submission,
          selectedAssignment: selected == null
              ? null
              : _applySubmissionToAssignment(selected, submission),
          clearError: true,
        ),
      );
      return;
    }

    if (result.error?.statusCode == 404) {
      emit(state.copyWith(mySubmission: null, clearError: true));
      return;
    }

    emit(
      state.copyWith(
        error: result.error?.message ?? 'Failed to load submission',
      ),
    );
  }

  Future<void> _onSubmitTextAssignment(
    SubmitTextAssignment event,
    Emitter<AssignmentState> emit,
  ) async {
    emit(
      state.copyWith(
        isSubmitting: true,
        submitProgress: 0,
        clearSubmitError: true,
      ),
    );

    final submitResult = await _assignmentService.submit(
      event.assignmentId,
      submissionText: event.submissionText,
      submissionLink: event.submissionLink,
    );

    if (!submitResult.isSuccess) {
      emit(
        state.copyWith(
          isSubmitting: false,
          submitError:
              submitResult.error?.message ?? 'Failed to submit assignment',
        ),
      );
      return;
    }

    await _updateStateAfterSubmission(
      assignmentId: event.assignmentId,
      emit: emit,
    );
  }

  Future<void> _onSubmitFileAssignment(
    SubmitFileAssignment event,
    Emitter<AssignmentState> emit,
  ) async {
    emit(
      state.copyWith(
        isSubmitting: true,
        submitProgress: 0,
        clearSubmitError: true,
      ),
    );

    final submitResult = await _assignmentService.submitFile(
      event.assignmentId,
      event.file,
      submissionText: event.submissionText,
      submissionLink: event.submissionLink,
      onSendProgress: (int sent, int total) {
        if (total <= 0) {
          return;
        }
        emit(
          state.copyWith(
            submitProgress: sent / total,
            isSubmitting: true,
            clearSubmitError: true,
          ),
        );
      },
    );

    if (!submitResult.isSuccess) {
      emit(
        state.copyWith(
          isSubmitting: false,
          submitError:
              submitResult.error?.message ??
              'Failed to upload assignment submission file',
        ),
      );
      return;
    }

    await _updateStateAfterSubmission(
      assignmentId: event.assignmentId,
      emit: emit,
      forceProgressComplete: true,
    );
  }

  void _onSetAssignmentFilterStatus(
    SetAssignmentFilterStatus event,
    Emitter<AssignmentState> emit,
  ) {
    emit(state.copyWith(filterStatus: event.filterStatus));
  }

  void _onSetAssignmentSearchQuery(
    SetAssignmentSearchQuery event,
    Emitter<AssignmentState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
  }

  void _onClearError(ClearError event, Emitter<AssignmentState> emit) {
    emit(state.copyWith(clearError: true, clearSubmitError: true));
  }

  Future<void> _loadAssignments({
    required Emitter<AssignmentState> emit,
    required bool showLoading,
    int? courseId,
  }) async {
    emit(
      state.copyWith(
        isLoading: true,
        clearError: true,
        selectedCourseId: courseId,
      ),
    );

    final result = await _assignmentService.getAll(
      courseId: courseId,
      sortBy: 'dueDate',
      sortOrder: 'ASC',
      limit: 100,
    );

    if (!result.isSuccess || result.data == null) {
      emit(
        state.copyWith(
          isLoading: false,
          error: result.error?.message ?? 'Failed to load assignments',
        ),
      );
      return;
    }

    final rawAssignments = result.data!.data
        .where(
          (assignment) =>
              assignment.apiStatus != api.AssignmentStatus.draft &&
              assignment.apiStatus != api.AssignmentStatus.archived,
        )
        .toList();

    final enrichedAssignments = await _enrichAssignments(rawAssignments);

    final selected = state.selectedAssignment;
    AssignmentModel? updatedSelected;
    if (selected != null) {
      updatedSelected = _findAssignment(
        assignments: enrichedAssignments,
        assignmentId: selected.assignmentId,
      );
    }

    final counters = _countBySubmissionState(enrichedAssignments);

    emit(
      state.copyWith(
        selectedCourseId: courseId,
        assignments: enrichedAssignments,
        selectedAssignment: updatedSelected,
        mySubmission: updatedSelected?.submission == null
            ? state.mySubmission
            : _toSubmissionModel(
                updatedSelected!.submission!,
                updatedSelected.maxGrade,
              ),
        isLoading: false,
        totalCount: enrichedAssignments.length,
        submittedCount: counters.submitted,
        pendingCount: counters.pending,
        overdueCount: counters.overdue,
        clearError: true,
      ),
    );
  }

  Future<List<AssignmentModel>> _enrichAssignments(
    List<AssignmentModel> assignments,
  ) async {
    return Future.wait(
      assignments.map((assignment) async {
        final submissionResult = await _assignmentService.getMySubmission(
          assignment.assignmentId,
        );

        if (submissionResult.isSuccess && submissionResult.data != null) {
          return _applySubmissionToAssignment(
            assignment,
            submissionResult.data!,
          );
        }

        return _applyNoSubmissionStatus(assignment);
      }),
    );
  }

  Future<void> _updateStateAfterSubmission({
    required int assignmentId,
    required Emitter<AssignmentState> emit,
    bool forceProgressComplete = false,
  }) async {
    final submissionResult = await _assignmentService.getMySubmission(
      assignmentId,
    );
    AssignmentSubmissionModel? submission;
    if (submissionResult.isSuccess) {
      submission = submissionResult.data;
    }

    final updatedAssignments = state.assignments.map((assignment) {
      if (assignment.assignmentId != assignmentId) {
        return assignment;
      }
      if (submission == null) {
        return assignment;
      }
      return _applySubmissionToAssignment(assignment, submission);
    }).toList();

    final selected = state.selectedAssignment;
    final selectedAssignment = selected == null
        ? null
        : _findAssignment(
            assignments: updatedAssignments,
            assignmentId: selected.assignmentId,
          );

    final counters = _countBySubmissionState(updatedAssignments);

    emit(
      state.copyWith(
        assignments: updatedAssignments,
        selectedAssignment: selectedAssignment,
        mySubmission: submission ?? state.mySubmission,
        isSubmitting: false,
        submitProgress: forceProgressComplete ? 1 : 0,
        clearSubmitError: true,
        totalCount: updatedAssignments.length,
        submittedCount: counters.submitted,
        pendingCount: counters.pending,
        overdueCount: counters.overdue,
      ),
    );
  }

  AssignmentModel _applySubmissionToAssignment(
    AssignmentModel assignment,
    AssignmentSubmissionModel submission,
  ) {
    return assignment.copyWith(
      submission: _toLegacySubmission(submission, assignment.maxGrade),
      status: _legacyStatusFromSubmission(submission),
    );
  }

  AssignmentModel _applyNoSubmissionStatus(AssignmentModel assignment) {
    return assignment.copyWith(
      submission: null,
      status: assignment.dueDate.isBefore(DateTime.now())
          ? AssignmentStatus.overdue
          : AssignmentStatus.pending,
    );
  }

  AssignmentStatus _legacyStatusFromSubmission(
    AssignmentSubmissionModel submission,
  ) {
    if (submission.submissionStatus == api.SubmissionStatus.graded) {
      return AssignmentStatus.graded;
    }
    if (submission.isLate) {
      return AssignmentStatus.late;
    }
    return AssignmentStatus.submitted;
  }

  SubmissionModel _toLegacySubmission(
    AssignmentSubmissionModel submission,
    double maxGrade,
  ) {
    final attachment = submission.driveFile;
    return SubmissionModel(
      id: submission.id.toString(),
      submittedAt: submission.submittedAt,
      attachments: attachment == null
          ? const <AssignmentAttachment>[]
          : <AssignmentAttachment>[
              AssignmentAttachment(
                id: attachment.driveFileId.toString(),
                name: attachment.fileName,
                url: attachment.downloadUrl,
                fileType: _resolveFileType(attachment.fileName),
              ),
            ],
      comments: submission.submissionText ?? submission.submissionLink,
      grade: submission.score,
      maxGrade: maxGrade,
      feedback: submission.feedback,
      gradedAt: submission.gradedAt,
    );
  }

  AssignmentSubmissionModel _toSubmissionModel(
    SubmissionModel submission,
    double maxGrade,
  ) {
    return AssignmentSubmissionModel(
      id: int.tryParse(submission.id) ?? 0,
      assignmentId: state.selectedAssignment?.assignmentId ?? 0,
      userId: 0,
      submissionText: submission.comments,
      submissionLink: null,
      fileId: null,
      submissionStatus: submission.grade == null
          ? api.SubmissionStatus.submitted
          : api.SubmissionStatus.graded,
      isLate: false,
      attemptNumber: 1,
      submittedAt: submission.submittedAt,
      score: submission.grade,
      feedback: submission.feedback,
      gradedBy: null,
      gradedAt: submission.gradedAt,
      user: null,
      driveFile: null,
    );
  }

  AssignmentModel? _findAssignment({
    required List<AssignmentModel> assignments,
    required int assignmentId,
  }) {
    for (final assignment in assignments) {
      if (assignment.assignmentId == assignmentId) {
        return assignment;
      }
    }
    return null;
  }

  String? _resolveFileType(String? fileName) {
    if (fileName == null || !fileName.contains('.')) {
      return null;
    }
    return fileName.split('.').last.toLowerCase();
  }

  ({int submitted, int pending, int overdue}) _countBySubmissionState(
    List<AssignmentModel> assignments,
  ) {
    var submitted = 0;
    var pending = 0;
    var overdue = 0;

    for (final assignment in assignments) {
      switch (assignment.submissionFilterStatus) {
        case 'submitted':
          submitted += 1;
          break;
        case 'overdue':
          overdue += 1;
          break;
        default:
          pending += 1;
          break;
      }
    }

    return (submitted: submitted, pending: pending, overdue: overdue);
  }
}

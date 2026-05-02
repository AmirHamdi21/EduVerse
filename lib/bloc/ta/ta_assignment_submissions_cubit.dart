import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/bloc/route_request_controller.dart';
import '../../models/assignments/assignment_submission_model.dart';
import '../../services/api/assignment_service.dart';

// ── States ─────────────────────────────────────────────────────

sealed class TASubsState extends Equatable {
  const TASubsState();
  @override
  List<Object?> get props => [];
}

final class TASubsInitial extends TASubsState {
  const TASubsInitial();
}

final class TASubsLoading extends TASubsState {
  const TASubsLoading();
}

final class TASubsLoaded extends TASubsState {
  final List<AssignmentSubmissionModel> submissions;
  const TASubsLoaded(this.submissions);
  @override
  List<Object?> get props => [submissions];
}

final class TASubsError extends TASubsState {
  final String message;
  const TASubsError(this.message);
  @override
  List<Object?> get props => [message];
}

final class TASubsGrading extends TASubsState {
  const TASubsGrading();
}

final class TASubsGradeSuccess extends TASubsState {
  const TASubsGradeSuccess();
}

final class TASubsGradeError extends TASubsState {
  final String message;
  const TASubsGradeError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── Cubit ──────────────────────────────────────────────────────

class TAAssignmentSubmissionsCubit extends Cubit<TASubsState>
    with SafeRouteCubitMixin<TASubsState> {
  final AssignmentService _assignmentService;
  late final RouteRequestController _submissionsRequest = trackRouteRequest(
    RouteRequestController(),
  );
  late final RouteRequestController _gradingRequest = trackRouteRequest(
    RouteRequestController(),
  );

  TAAssignmentSubmissionsCubit({required AssignmentService assignmentService})
    : _assignmentService = assignmentService,
      super(const TASubsInitial());

  Future<void> fetchSubmissions(int assignmentId) async {
    final requestId = _submissionsRequest.begin();
    emitIfOpen(const TASubsLoading());
    try {
      final result = await _assignmentService.getSubmissions(
        assignmentId,
        cancelToken: _submissionsRequest.token,
      );
      if (!isRequestCurrent(_submissionsRequest, requestId)) {
        return;
      }
      if (result.isSuccess && result.data != null) {
        emitIfOpen(TASubsLoaded(result.data!));
      } else {
        emitIfOpen(
          TASubsError(result.error?.toString() ?? 'Failed to load submissions'),
        );
      }
    } catch (e) {
      if (isRequestCurrent(_submissionsRequest, requestId)) {
        emitIfOpen(TASubsError(e.toString()));
      }
    }
  }

  Future<void> gradeSubmission(
    int assignmentId,
    int submissionId,
    double score,
    String? feedback,
  ) async {
    final requestId = _gradingRequest.begin();
    emitIfOpen(const TASubsGrading());
    try {
      final result = await _assignmentService.gradeSubmission(
        assignmentId,
        submissionId,
        score,
        feedback: feedback,
        cancelToken: _gradingRequest.token,
      );
      if (!isRequestCurrent(_gradingRequest, requestId)) {
        return;
      }
      if (result.isSuccess) {
        // T023: Emit success BEFORE refreshing so BlocListener captures it
        emitIfOpen(const TASubsGradeSuccess());
        await fetchSubmissions(assignmentId);
      } else {
        emitIfOpen(
          TASubsGradeError(
            result.error?.toString() ?? 'Failed to grade submission',
          ),
        );
      }
    } catch (e) {
      if (isRequestCurrent(_gradingRequest, requestId)) {
        emitIfOpen(TASubsGradeError(e.toString()));
      }
    }
  }
}

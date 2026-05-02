import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/bloc/route_request_controller.dart';
import '../../models/core/enums/assignment_enums.dart' as assignment_api;
import '../../models/core/enums/lab_enums.dart';
import '../../models/core/lab_instruction_model.dart';
import '../../models/labs/lab_submission_model.dart';
import '../../services/api/lab_service.dart';
import 'lab_detail_state.dart';

class AttendanceData {
  const AttendanceData({
    required this.userId,
    required this.attendanceStatus,
    this.notes,
  });

  final int userId;
  final LabAttendanceStatus attendanceStatus;
  final String? notes;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'userId': userId,
      'attendanceStatus': attendanceStatus.toJson(),
      if (notes != null && notes!.trim().isNotEmpty) 'notes': notes,
    };
  }
}

class LabDetailCubit extends Cubit<LabDetailState>
    with SafeRouteCubitMixin<LabDetailState> {
  LabDetailCubit({required LabService labService})
    : _labService = labService,
      super(const LabDetailInitial());

  final LabService _labService;
  late final RouteRequestController _labRequest = trackRouteRequest(
    RouteRequestController(),
  );
  late final RouteRequestController _instructionsRequest = trackRouteRequest(
    RouteRequestController(),
  );
  late final RouteRequestController _submissionsRequest = trackRouteRequest(
    RouteRequestController(),
  );
  late final RouteRequestController _attendanceRequest = trackRouteRequest(
    RouteRequestController(),
  );
  late final RouteRequestController _instructionMutationRequest =
      trackRouteRequest(RouteRequestController());
  late final RouteRequestController _gradeRequest = trackRouteRequest(
    RouteRequestController(),
  );
  late final RouteRequestController _attendanceMutationRequest =
      trackRouteRequest(RouteRequestController());

  Future<void> initialize(String labId) async {
    await loadLabDetail(labId);
    final loaded = _loadedOrNull;
    if (loaded == null) {
      return;
    }

    await Future.wait<void>(<Future<void>>[
      loadInstructions(labId),
      loadSubmissions(labId),
      loadAttendance(labId),
    ]);
  }

  Future<void> loadLabDetail(String labId) async {
    final cached = _cachedLabOrNull;
    final requestId = _labRequest.begin();
    emitIfOpen(LabDetailLoading(cachedLab: cached));

    final result = await _labService.getById(
      labId,
      cancelToken: _labRequest.token,
    );
    if (!isRequestCurrent(_labRequest, requestId)) {
      return;
    }

    if (!result.isSuccess || result.data == null) {
      emitIfOpen(
        LabDetailError(
          message: result.error?.message ?? 'Failed to load lab details',
          statusCode: result.error?.statusCode,
          cachedLab: cached,
        ),
      );
      return;
    }

    emitIfOpen(LabDetailLoaded(lab: result.data!));
  }

  Future<void> loadInstructions(String labId) async {
    final current = _loadedOrNull;
    if (current == null) {
      return;
    }

    final requestId = _instructionsRequest.begin();
    final result = await _labService.getInstructions(
      labId,
      cancelToken: _instructionsRequest.token,
    );
    if (!isRequestCurrent(_instructionsRequest, requestId)) {
      return;
    }
    final refreshed = _loadedOrNull;
    if (refreshed == null) {
      return;
    }

    if (!result.isSuccess || result.data == null) {
      emitIfOpen(
        refreshed.copyWith(
          errorMessage: result.error?.message ?? 'Failed to load instructions',
          clearMessage: true,
        ),
      );
      return;
    }

    final sorted = List<LabInstructionModel>.from(result.data!)
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    emitIfOpen(
      refreshed.copyWith(instructions: sorted, clearErrorMessage: true),
    );
  }

  Future<void> loadSubmissions(String labId) async {
    final current = _loadedOrNull;
    if (current == null) {
      return;
    }

    final requestId = _submissionsRequest.begin();
    final result = await _labService.getSubmissions(
      labId,
      cancelToken: _submissionsRequest.token,
    );
    if (!isRequestCurrent(_submissionsRequest, requestId)) {
      return;
    }
    final refreshed = _loadedOrNull;
    if (refreshed == null) {
      return;
    }

    if (!result.isSuccess || result.data == null) {
      emitIfOpen(
        refreshed.copyWith(
          errorMessage: result.error?.message ?? 'Failed to load submissions',
          clearMessage: true,
        ),
      );
      return;
    }

    final sorted = List<LabSubmissionModel>.from(result.data!)
      ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));

    emitIfOpen(
      refreshed.copyWith(submissions: sorted, clearErrorMessage: true),
    );
  }

  Future<void> loadAttendance(String labId) async {
    final current = _loadedOrNull;
    if (current == null) {
      return;
    }

    final requestId = _attendanceRequest.begin();
    final result = await _labService.getAttendance(
      labId,
      cancelToken: _attendanceRequest.token,
    );
    if (!isRequestCurrent(_attendanceRequest, requestId)) {
      return;
    }
    final refreshed = _loadedOrNull;
    if (refreshed == null) {
      return;
    }

    if (!result.isSuccess || result.data == null) {
      emitIfOpen(
        refreshed.copyWith(
          errorMessage: result.error?.message ?? 'Failed to load attendance',
          clearMessage: true,
        ),
      );
      return;
    }

    emitIfOpen(
      refreshed.copyWith(attendance: result.data, clearErrorMessage: true),
    );
  }

  Future<void> addTextInstruction(
    String labId,
    String text,
    int orderIndex,
  ) async {
    final current = _loadedOrNull;
    if (current == null) {
      return;
    }

    emitIfOpen(
      LabInstructionUpdating(
        lab: current.lab,
        instructions: current.instructions,
        submissions: current.submissions,
        attendance: current.attendance,
      ),
    );

    final requestId = _instructionMutationRequest.begin();
    final result = await _labService.addInstruction(labId, <String, dynamic>{
      'instructionText': text,
      'orderIndex': orderIndex,
    }, cancelToken: _instructionMutationRequest.token);
    if (!isRequestCurrent(_instructionMutationRequest, requestId)) {
      return;
    }

    if (!result.isSuccess || result.data == null) {
      final refreshed = _loadedOrNull;
      if (refreshed != null) {
        emitIfOpen(
          refreshed.copyWith(
            errorMessage: result.error?.message ?? 'Failed to add instruction',
            clearMessage: true,
          ),
        );
      }
      return;
    }

    await loadInstructions(labId);
    _emitMessage('Instruction added successfully.');
  }

  Future<void> uploadInstructionFile(
    String labId,
    File file,
    int orderIndex, {
    void Function(double progress)? onProgress,
  }) async {
    final current = _loadedOrNull;
    if (current == null) {
      return;
    }

    emitIfOpen(
      LabInstructionUpdating(
        lab: current.lab,
        instructions: current.instructions,
        submissions: current.submissions,
        attendance: current.attendance,
      ),
    );

    final requestId = _instructionMutationRequest.begin();
    final result = await _labService.uploadInstructionFile(
      labId,
      file,
      orderIndex: orderIndex,
      cancelToken: _instructionMutationRequest.token,
      onSendProgress: (sent, total) {
        if (total <= 0 ||
            onProgress == null ||
            !isRequestCurrent(_instructionMutationRequest, requestId)) {
          return;
        }
        onProgress((sent / total).clamp(0, 1).toDouble());
      },
    );
    if (!isRequestCurrent(_instructionMutationRequest, requestId)) {
      return;
    }

    if (!result.isSuccess || result.data == null) {
      final refreshed = _loadedOrNull;
      if (refreshed != null) {
        emitIfOpen(
          refreshed.copyWith(
            errorMessage: result.error?.message ?? 'Failed to upload file',
            clearMessage: true,
          ),
        );
      }
      return;
    }

    await loadInstructions(labId);
    _emitMessage('Instruction file uploaded.');
  }

  Future<void> updateInstruction(
    String labId,
    String instructionId,
    String text,
  ) async {
    final current = _loadedOrNull;
    if (current == null) {
      return;
    }

    final parsedInstructionId = int.tryParse(instructionId);

    emitIfOpen(
      LabInstructionUpdating(
        lab: current.lab,
        instructions: current.instructions,
        submissions: current.submissions,
        attendance: current.attendance,
        updatingInstructionId: parsedInstructionId,
      ),
    );

    final requestId = _instructionMutationRequest.begin();
    final result = await _labService.updateInstruction(
      labId,
      instructionId,
      <String, dynamic>{'instructionText': text},
      cancelToken: _instructionMutationRequest.token,
    );
    if (!isRequestCurrent(_instructionMutationRequest, requestId)) {
      return;
    }

    if (!result.isSuccess || result.data == null) {
      final refreshed = _loadedOrNull;
      if (refreshed != null) {
        emitIfOpen(
          refreshed.copyWith(
            errorMessage:
                result.error?.message ?? 'Failed to update instruction',
            clearMessage: true,
          ),
        );
      }
      return;
    }

    await loadInstructions(labId);
    _emitMessage('Instruction updated.');
  }

  Future<void> deleteInstruction(String labId, String instructionId) async {
    final current = _loadedOrNull;
    if (current == null) {
      return;
    }

    emitIfOpen(
      LabInstructionUpdating(
        lab: current.lab,
        instructions: current.instructions,
        submissions: current.submissions,
        attendance: current.attendance,
        updatingInstructionId: int.tryParse(instructionId),
      ),
    );

    final requestId = _instructionMutationRequest.begin();
    final result = await _labService.deleteInstruction(
      labId,
      instructionId,
      cancelToken: _instructionMutationRequest.token,
    );
    if (!isRequestCurrent(_instructionMutationRequest, requestId)) {
      return;
    }
    if (!result.isSuccess) {
      final refreshed = _loadedOrNull;
      if (refreshed != null) {
        emitIfOpen(
          refreshed.copyWith(
            errorMessage:
                result.error?.message ?? 'Failed to delete instruction',
            clearMessage: true,
          ),
        );
      }
      return;
    }

    await loadInstructions(labId);
    _emitMessage('Instruction deleted.');
  }

  Future<void> reorderInstructions(
    String labId,
    List<String> orderedInstructionIds,
  ) async {
    final current = _loadedOrNull;
    final currentInstructions = current?.instructions;
    if (current == null || currentInstructions == null) {
      return;
    }

    final byId = <String, LabInstructionModel>{
      for (final item in currentInstructions) item.id.toString(): item,
    };

    final reordered = <LabInstructionModel>[];
    for (final id in orderedInstructionIds) {
      final item = byId[id];
      if (item != null) {
        reordered.add(item);
      }
    }

    for (final item in currentInstructions) {
      if (!orderedInstructionIds.contains(item.id.toString())) {
        reordered.add(item);
      }
    }

    emitIfOpen(
      LabInstructionUpdating(
        lab: current.lab,
        instructions: current.instructions,
        submissions: current.submissions,
        attendance: current.attendance,
      ),
    );

    final requestId = _instructionMutationRequest.begin();
    var failedCount = 0;
    for (var index = 0; index < reordered.length; index++) {
      if (!isRequestCurrent(_instructionMutationRequest, requestId)) {
        return;
      }
      final instruction = reordered[index];
      final result = await _labService.updateInstruction(
        labId,
        instruction.id,
        <String, dynamic>{'orderIndex': index},
        cancelToken: _instructionMutationRequest.token,
      );
      if (!result.isSuccess) {
        failedCount++;
      }
    }

    if (failedCount > 0) {
      final refreshed = _loadedOrNull;
      if (refreshed != null) {
        emitIfOpen(
          refreshed.copyWith(
            errorMessage: 'Failed to reorder some instructions. Please retry.',
            clearMessage: true,
          ),
        );
      }
      return;
    }

    await loadInstructions(labId);
    _emitMessage('Instruction order updated.');
  }

  Future<void> gradeSubmission(
    String labId,
    String submissionId,
    double score, {
    String? feedback,
    assignment_api.SubmissionStatus status =
        assignment_api.SubmissionStatus.graded,
    double? latePenaltyPercent,
  }) async {
    final current = _loadedOrNull;
    if (current == null) {
      return;
    }

    if (score < 0 || score > current.lab.maxScore) {
      emitIfOpen(
        current.copyWith(
          errorMessage:
              'Score must be between 0 and ${current.lab.maxScore.toStringAsFixed(1)}.',
          clearMessage: true,
        ),
      );
      return;
    }

    final requestId = _gradeRequest.begin();
    emitIfOpen(
      current.copyWith(
        isSubmittingGrade: true,
        clearMessage: true,
        clearErrorMessage: true,
      ),
    );

    final result = await _labService.gradeSubmission(
      labId,
      submissionId,
      score,
      status: status.toJson(),
      feedback: feedback,
      cancelToken: _gradeRequest.token,
    );
    if (!isRequestCurrent(_gradeRequest, requestId)) {
      return;
    }

    final refreshed = _loadedOrNull;
    if (refreshed == null) {
      return;
    }

    if (!result.isSuccess) {
      emitIfOpen(
        refreshed.copyWith(
          isSubmittingGrade: false,
          errorMessage: result.error?.message ?? 'Failed to save grade',
          clearMessage: true,
        ),
      );
      return;
    }

    final updatedSubmissions =
        (refreshed.submissions ?? const <LabSubmissionModel>[])
            .map((submission) {
              if (submission.id.toString() != submissionId) {
                return submission;
              }
              return submission.copyWith(
                score: score,
                feedback: feedback,
                submissionStatus: status,
                gradedAt: DateTime.now(),
                latePenaltyPercent: latePenaltyPercent,
              );
            })
            .toList(growable: false);

    emitIfOpen(
      refreshed.copyWith(
        submissions: updatedSubmissions,
        isSubmittingGrade: false,
        message:
            'Grade recorded. Grade has been added to the central gradebook.',
        clearErrorMessage: true,
      ),
    );
  }

  Future<void> markAttendance(
    String labId,
    List<AttendanceData> attendanceList,
  ) async {
    final current = _loadedOrNull;
    if (current == null || attendanceList.isEmpty) {
      return;
    }

    final requestId = _attendanceMutationRequest.begin();
    emitIfOpen(
      current.copyWith(
        isSubmittingAttendance: true,
        clearMessage: true,
        clearErrorMessage: true,
      ),
    );

    var failedCount = 0;
    for (final entry in attendanceList) {
      if (!isRequestCurrent(_attendanceMutationRequest, requestId)) {
        return;
      }
      final result = await _labService.markAttendance(
        labId,
        entry.toJson(),
        cancelToken: _attendanceMutationRequest.token,
      );
      if (!result.isSuccess) {
        failedCount++;
      }
    }

    await loadAttendance(labId);
    if (!isRequestCurrent(_attendanceMutationRequest, requestId)) {
      return;
    }

    final refreshed = _loadedOrNull;
    if (refreshed == null) {
      return;
    }

    if (failedCount == 0) {
      emitIfOpen(
        refreshed.copyWith(
          isSubmittingAttendance: false,
          message: 'Attendance updated.',
          clearErrorMessage: true,
        ),
      );
      return;
    }

    emitIfOpen(
      refreshed.copyWith(
        isSubmittingAttendance: false,
        errorMessage:
            'Some attendance updates failed. Updated ${attendanceList.length - failedCount}/${attendanceList.length}.',
        clearMessage: true,
      ),
    );
  }

  void clearMessages() {
    final current = _loadedOrNull;
    if (current == null) {
      return;
    }

    emitIfOpen(current.copyWith(clearMessage: true, clearErrorMessage: true));
  }

  void _emitMessage(String message) {
    final current = _loadedOrNull;
    if (current == null) {
      return;
    }

    emitIfOpen(current.copyWith(message: message, clearErrorMessage: true));
  }

  LabDetailLoaded? get _loadedOrNull {
    final current = state;
    if (current is LabDetailLoaded) {
      return current;
    }
    return null;
  }

  dynamic get _cachedLabOrNull {
    final current = state;
    if (current is LabDetailLoading) {
      return current.cachedLab;
    }
    if (current is LabDetailLoaded) {
      return current.lab;
    }
    if (current is LabDetailError) {
      return current.cachedLab;
    }
    return null;
  }
}

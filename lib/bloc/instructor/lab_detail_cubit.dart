import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

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

class LabDetailCubit extends Cubit<LabDetailState> {
  LabDetailCubit({required LabService labService})
    : _labService = labService,
      super(const LabDetailInitial());

  final LabService _labService;

  Future<void> loadLabDetail(String labId) async {
    final cached = _cachedLabOrNull;
    emit(LabDetailLoading(cachedLab: cached));

    final result = await _labService.getById(labId);
    if (!result.isSuccess || result.data == null) {
      emit(
        LabDetailError(
          message: result.error?.message ?? 'Failed to load lab details',
          statusCode: result.error?.statusCode,
          cachedLab: cached,
        ),
      );
      return;
    }

    emit(LabDetailLoaded(lab: result.data!));
  }

  Future<void> loadInstructions(String labId) async {
    final current = _loadedOrNull;
    if (current == null) {
      return;
    }

    final result = await _labService.getInstructions(labId);
    final refreshed = _loadedOrNull;
    if (refreshed == null) {
      return;
    }

    if (!result.isSuccess || result.data == null) {
      emit(
        refreshed.copyWith(
          errorMessage: result.error?.message ?? 'Failed to load instructions',
          clearMessage: true,
        ),
      );
      return;
    }

    final sorted = List<LabInstructionModel>.from(result.data!)
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    emit(refreshed.copyWith(instructions: sorted, clearErrorMessage: true));
  }

  Future<void> loadSubmissions(String labId) async {
    final current = _loadedOrNull;
    if (current == null) {
      return;
    }

    final result = await _labService.getSubmissions(labId);
    final refreshed = _loadedOrNull;
    if (refreshed == null) {
      return;
    }

    if (!result.isSuccess || result.data == null) {
      emit(
        refreshed.copyWith(
          errorMessage: result.error?.message ?? 'Failed to load submissions',
          clearMessage: true,
        ),
      );
      return;
    }

    final sorted = List<LabSubmissionModel>.from(result.data!)
      ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));

    emit(refreshed.copyWith(submissions: sorted, clearErrorMessage: true));
  }

  Future<void> loadAttendance(String labId) async {
    final current = _loadedOrNull;
    if (current == null) {
      return;
    }

    final result = await _labService.getAttendance(labId);
    final refreshed = _loadedOrNull;
    if (refreshed == null) {
      return;
    }

    if (!result.isSuccess || result.data == null) {
      emit(
        refreshed.copyWith(
          errorMessage: result.error?.message ?? 'Failed to load attendance',
          clearMessage: true,
        ),
      );
      return;
    }

    emit(refreshed.copyWith(attendance: result.data, clearErrorMessage: true));
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

    emit(
      LabInstructionUpdating(
        lab: current.lab,
        instructions: current.instructions,
        submissions: current.submissions,
        attendance: current.attendance,
      ),
    );

    final result = await _labService.addInstruction(labId, <String, dynamic>{
      'instructionText': text,
      'orderIndex': orderIndex,
    });

    if (!result.isSuccess || result.data == null) {
      final refreshed = _loadedOrNull;
      if (refreshed != null) {
        emit(
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

    emit(
      LabInstructionUpdating(
        lab: current.lab,
        instructions: current.instructions,
        submissions: current.submissions,
        attendance: current.attendance,
      ),
    );

    final result = await _labService.uploadInstructionFile(
      labId,
      file,
      orderIndex: orderIndex,
      onSendProgress: (sent, total) {
        if (total <= 0 || onProgress == null) {
          return;
        }
        onProgress((sent / total).clamp(0, 1).toDouble());
      },
    );

    if (!result.isSuccess || result.data == null) {
      final refreshed = _loadedOrNull;
      if (refreshed != null) {
        emit(
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

    emit(
      LabInstructionUpdating(
        lab: current.lab,
        instructions: current.instructions,
        submissions: current.submissions,
        attendance: current.attendance,
        updatingInstructionId: parsedInstructionId,
      ),
    );

    final result = await _labService.updateInstruction(
      labId,
      instructionId,
      <String, dynamic>{'instructionText': text},
    );

    if (!result.isSuccess || result.data == null) {
      final fallbackSucceeded = await _fallbackUpdateInstruction(
        labId,
        instructionId,
        text,
      );
      if (!fallbackSucceeded) {
        final refreshed = _loadedOrNull;
        if (refreshed != null) {
          emit(
            refreshed.copyWith(
              errorMessage:
                  result.error?.message ?? 'Failed to update instruction',
              clearMessage: true,
            ),
          );
        }
        return;
      }
    }

    await loadInstructions(labId);
    _emitMessage('Instruction updated.');
  }

  Future<void> deleteInstruction(String labId, String instructionId) async {
    final current = _loadedOrNull;
    if (current == null) {
      return;
    }

    emit(
      LabInstructionUpdating(
        lab: current.lab,
        instructions: current.instructions,
        submissions: current.submissions,
        attendance: current.attendance,
        updatingInstructionId: int.tryParse(instructionId),
      ),
    );

    final result = await _labService.deleteInstruction(labId, instructionId);
    if (!result.isSuccess) {
      final fallbackSucceeded = await _fallbackDeleteInstruction(
        labId,
        instructionId,
      );
      if (!fallbackSucceeded) {
        final refreshed = _loadedOrNull;
        if (refreshed != null) {
          emit(
            refreshed.copyWith(
              errorMessage:
                  result.error?.message ?? 'Failed to delete instruction',
              clearMessage: true,
            ),
          );
        }
        return;
      }
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

    emit(
      LabInstructionUpdating(
        lab: current.lab,
        instructions: current.instructions,
        submissions: current.submissions,
        attendance: current.attendance,
      ),
    );

    var failedCount = 0;
    for (var index = 0; index < reordered.length; index++) {
      final instruction = reordered[index];
      final result = await _labService.updateInstruction(
        labId,
        instruction.id,
        <String, dynamic>{'orderIndex': index},
      );
      if (!result.isSuccess) {
        failedCount++;
      }
    }

    if (failedCount > 0) {
      final fallbackResult = await _labService.update(labId, <String, dynamic>{
        'instructions': reordered
            .asMap()
            .entries
            .map(
              (entry) => <String, dynamic>{
                'id': entry.value.id,
                'orderIndex': entry.key,
                'instructionText': entry.value.instructionText,
                'fileId': entry.value.fileId,
              },
            )
            .toList(growable: false),
      });

      if (!fallbackResult.isSuccess) {
        final refreshed = _loadedOrNull;
        if (refreshed != null) {
          emit(
            refreshed.copyWith(
              errorMessage:
                  'Failed to reorder some instructions. Please retry.',
              clearMessage: true,
            ),
          );
        }
        return;
      }
    }

    await loadInstructions(labId);

    if (failedCount == 0) {
      _emitMessage('Instruction order updated.');
    } else {
      _emitMessage('Instruction order applied with partial fallback recovery.');
    }
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
      emit(
        current.copyWith(
          errorMessage:
              'Score must be between 0 and ${current.lab.maxScore.toStringAsFixed(1)}.',
          clearMessage: true,
        ),
      );
      return;
    }

    emit(
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
    );

    final refreshed = _loadedOrNull;
    if (refreshed == null) {
      return;
    }

    if (!result.isSuccess) {
      emit(
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

    emit(
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

    emit(
      current.copyWith(
        isSubmittingAttendance: true,
        clearMessage: true,
        clearErrorMessage: true,
      ),
    );

    var failedCount = 0;
    for (final entry in attendanceList) {
      final result = await _labService.markAttendance(labId, entry.toJson());
      if (!result.isSuccess) {
        failedCount++;
      }
    }

    await loadAttendance(labId);

    final refreshed = _loadedOrNull;
    if (refreshed == null) {
      return;
    }

    if (failedCount == 0) {
      emit(
        refreshed.copyWith(
          isSubmittingAttendance: false,
          message: 'Attendance updated.',
          clearErrorMessage: true,
        ),
      );
      return;
    }

    emit(
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

    emit(current.copyWith(clearMessage: true, clearErrorMessage: true));
  }

  Future<bool> _fallbackUpdateInstruction(
    String labId,
    String instructionId,
    String text,
  ) async {
    final current = _loadedOrNull;
    final instructions = current?.instructions;
    if (current == null || instructions == null) {
      return false;
    }

    final updatedInstructions = instructions
        .map((item) {
          if (item.id.toString() != instructionId) {
            return item;
          }
          return LabInstructionModel(
            id: item.id,
            labId: item.labId,
            instructionText: text,
            fileId: item.fileId,
            file: item.file,
            orderIndex: item.orderIndex,
            createdAt: item.createdAt,
          );
        })
        .toList(growable: false);

    final result = await _labService.update(labId, <String, dynamic>{
      'instructions': updatedInstructions
          .map(
            (item) => <String, dynamic>{
              'id': item.id,
              'instructionText': item.instructionText,
              'fileId': item.fileId,
              'orderIndex': item.orderIndex,
            },
          )
          .toList(growable: false),
    });

    return result.isSuccess;
  }

  Future<bool> _fallbackDeleteInstruction(
    String labId,
    String instructionId,
  ) async {
    final current = _loadedOrNull;
    final instructions = current?.instructions;
    if (current == null || instructions == null) {
      return false;
    }

    final filtered = instructions
        .where((item) => item.id.toString() != instructionId)
        .toList(growable: false);

    final result = await _labService.update(labId, <String, dynamic>{
      'instructions': filtered
          .asMap()
          .entries
          .map(
            (entry) => <String, dynamic>{
              'id': entry.value.id,
              'instructionText': entry.value.instructionText,
              'fileId': entry.value.fileId,
              'orderIndex': entry.key,
            },
          )
          .toList(growable: false),
    });

    return result.isSuccess;
  }

  void _emitMessage(String message) {
    final current = _loadedOrNull;
    if (current == null) {
      return;
    }

    emit(current.copyWith(message: message, clearErrorMessage: true));
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

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/bloc/instructor/lab_detail_cubit.dart';
import 'package:edu_verse/bloc/instructor/lab_detail_state.dart';
import 'package:edu_verse/common/service_error.dart';
import 'package:edu_verse/models/core/drive_file_model.dart';
import 'package:edu_verse/models/core/enums/assignment_enums.dart'
    as assignment_api;
import 'package:edu_verse/models/core/enums/lab_enums.dart' as api;
import 'package:edu_verse/models/core/lab_attendance_model.dart';
import 'package:edu_verse/models/core/lab_instruction_model.dart';
import 'package:edu_verse/models/core/shared_models.dart';
import 'package:edu_verse/models/labs/lab_model.dart';
import 'package:edu_verse/models/labs/lab_submission_model.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/lab_service.dart';

class _FakeLabService extends LabService {
  _FakeLabService() : super(coreApiClient: CoreApiClient.test()) {
    labResult = ServiceResult<LabModel>.success(_lab());
    instructionsResult = ServiceResult<List<LabInstructionModel>>.success(
      const <LabInstructionModel>[],
    );
    submissionsResult = ServiceResult<List<LabSubmissionModel>>.success(
      const <LabSubmissionModel>[],
    );
    attendanceResult = ServiceResult<List<LabAttendanceModel>>.success(
      const <LabAttendanceModel>[],
    );
    addInstructionResult = ServiceResult<LabInstructionModel>.success(
      _instruction(id: 1, orderIndex: 0, text: 'Instruction 1'),
    );
    uploadInstructionResult = ServiceResult<DriveFileModel>.success(
      _driveFile(),
    );
    updateInstructionResult = ServiceResult<LabInstructionModel>.success(
      _instruction(id: 1, orderIndex: 0, text: 'Instruction 1'),
    );
    gradeResult = ServiceResult<Map<String, dynamic>>.success(<String, dynamic>{
      'ok': true,
    });
  }

  late ServiceResult<LabModel> labResult;
  late ServiceResult<List<LabInstructionModel>> instructionsResult;
  late ServiceResult<List<LabSubmissionModel>> submissionsResult;
  late ServiceResult<List<LabAttendanceModel>> attendanceResult;
  late ServiceResult<LabInstructionModel> addInstructionResult;
  late ServiceResult<DriveFileModel> uploadInstructionResult;
  late ServiceResult<LabInstructionModel> updateInstructionResult;
  late ServiceResult<Map<String, dynamic>> gradeResult;

  dynamic lastAddInstructionLabId;
  Map<String, dynamic>? lastAddInstructionPayload;

  bool uploadInstructionCalled = false;
  dynamic lastUploadInstructionLabId;
  int? lastUploadOrderIndex;

  int gradeCallCount = 0;
  dynamic lastGradedLabId;
  dynamic lastGradedSubmissionId;
  double? lastGradedScore;
  String? lastGradedStatus;
  String? lastGradedFeedback;

  final List<Map<String, dynamic>> updateInstructionCalls =
      <Map<String, dynamic>>[];

  @override
  Future<ServiceResult<LabModel>> getById(
    dynamic id, {
    CancelToken? cancelToken,
  }) async => labResult;

  @override
  Future<ServiceResult<List<LabInstructionModel>>> getInstructions(
    dynamic labId, {
    CancelToken? cancelToken,
  }) async {
    return instructionsResult;
  }

  @override
  Future<ServiceResult<LabInstructionModel>> addInstruction(
    dynamic labId,
    Map<String, dynamic> data, {
    CancelToken? cancelToken,
  }) async {
    lastAddInstructionLabId = labId;
    lastAddInstructionPayload = data;
    return addInstructionResult;
  }

  @override
  Future<ServiceResult<DriveFileModel>> uploadInstructionFile(
    dynamic labId,
    File file, {
    String? title,
    int? orderIndex,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    uploadInstructionCalled = true;
    lastUploadInstructionLabId = labId;
    lastUploadOrderIndex = orderIndex;
    onSendProgress?.call(25, 100);
    return uploadInstructionResult;
  }

  @override
  Future<ServiceResult<List<LabSubmissionModel>>> getSubmissions(
    dynamic labId, {
    CancelToken? cancelToken,
  }) async {
    return submissionsResult;
  }

  @override
  Future<ServiceResult<Map<String, dynamic>>> gradeSubmission(
    dynamic labId,
    dynamic submissionId,
    double score, {
    String status = 'graded',
    String? feedback,
    CancelToken? cancelToken,
  }) async {
    gradeCallCount++;
    lastGradedLabId = labId;
    lastGradedSubmissionId = submissionId;
    lastGradedScore = score;
    lastGradedStatus = status;
    lastGradedFeedback = feedback;
    return gradeResult;
  }

  @override
  Future<ServiceResult<LabInstructionModel>> updateInstruction(
    dynamic labId,
    dynamic instructionId,
    Map<String, dynamic> data, {
    CancelToken? cancelToken,
  }) async {
    updateInstructionCalls.add(<String, dynamic>{
      'labId': labId,
      'instructionId': instructionId,
      'data': data,
    });

    final parsedId = instructionId is int
        ? instructionId
        : int.tryParse(instructionId.toString()) ?? 0;

    final resolvedOrderIndex = (data['orderIndex'] is int)
        ? data['orderIndex'] as int
        : 0;

    final resolvedText = data['instructionText']?.toString();

    return ServiceResult<LabInstructionModel>.success(
      LabInstructionModel(
        id: parsedId,
        labId: 1,
        instructionText: resolvedText,
        orderIndex: resolvedOrderIndex,
      ),
    );
  }

  @override
  Future<ServiceResult<List<LabAttendanceModel>>> getAttendance(
    dynamic labId, {
    CancelToken? cancelToken,
  }) async {
    return attendanceResult;
  }
}

LabModel _lab({double maxScore = 100}) {
  return LabModel(
    id: '1',
    labId: 1,
    courseId: 10,
    title: 'Lab One',
    dueDate: DateTime(2026, 6, 1),
    maxScore: maxScore,
    status: api.LabStatus.published,
    course: const CourseInfo(id: 10, name: 'Course 10', code: 'CS10'),
  );
}

LabInstructionModel _instruction({
  required int id,
  required int orderIndex,
  String? text,
}) {
  return LabInstructionModel(
    id: id,
    labId: 1,
    instructionText: text,
    orderIndex: orderIndex,
  );
}

LabSubmissionModel _submission({required int id}) {
  return LabSubmissionModel(
    id: id,
    labId: 1,
    userId: 100 + id,
    submissionStatus: assignment_api.SubmissionStatus.submitted,
    isLate: false,
    submittedAt: DateTime(2026, 5, id),
    user: UserInfo(
      userId: 100 + id,
      firstName: 'Student$id',
      lastName: 'Test',
      email: 'student$id@example.com',
    ),
  );
}

DriveFileModel _driveFile() {
  return const DriveFileModel(
    driveFileId: 1,
    driveId: 'drive-1',
    fileName: 'instructions.pdf',
    webViewLink: 'https://drive.example/view',
    downloadUrl: 'https://drive.example/download',
    iframeUrl: 'https://drive.example/preview',
  );
}

void main() {
  group('LabDetailCubit (instructor)', () {
    test(
      'addTextInstruction calls service and refreshes instructions',
      () async {
        final fakeLabService = _FakeLabService()
          ..instructionsResult =
              ServiceResult<List<LabInstructionModel>>.success(
                <LabInstructionModel>[
                  _instruction(id: 5, orderIndex: 0, text: 'Step 1'),
                ],
              );

        final cubit = LabDetailCubit(labService: fakeLabService);

        await cubit.loadLabDetail('1');
        await cubit.addTextInstruction('1', 'Step 1', 0);

        expect(fakeLabService.lastAddInstructionLabId, '1');
        expect(
          fakeLabService.lastAddInstructionPayload?['instructionText'],
          'Step 1',
        );
        expect(fakeLabService.lastAddInstructionPayload?['orderIndex'], 0);

        final state = cubit.state as LabDetailLoaded;
        expect(state.instructions, isNotNull);
        expect(state.instructions!.length, 1);
        expect(state.instructions!.first.instructionText, 'Step 1');
        expect(state.message, 'Instruction added successfully.');

        await cubit.close();
      },
    );

    test(
      'uploadInstructionFile calls upload endpoint and reports progress',
      () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'instructor_lab_detail_test',
        );
        final file = File(
          '${tempDir.path}${Platform.pathSeparator}instruction.txt',
        );
        await file.writeAsString('instruction content');

        try {
          final fakeLabService = _FakeLabService()
            ..instructionsResult =
                ServiceResult<List<LabInstructionModel>>.success(
                  <LabInstructionModel>[
                    _instruction(id: 1, orderIndex: 0, text: 'Existing'),
                  ],
                );

          final cubit = LabDetailCubit(labService: fakeLabService);
          double progress = 0;

          await cubit.loadLabDetail('1');
          await cubit.uploadInstructionFile(
            '1',
            file,
            2,
            onProgress: (value) {
              progress = value;
            },
          );

          expect(fakeLabService.uploadInstructionCalled, isTrue);
          expect(fakeLabService.lastUploadInstructionLabId, '1');
          expect(fakeLabService.lastUploadOrderIndex, 2);
          expect(progress, greaterThan(0));

          final state = cubit.state as LabDetailLoaded;
          expect(state.message, 'Instruction file uploaded.');

          await cubit.close();
        } finally {
          if (await tempDir.exists()) {
            await tempDir.delete(recursive: true);
          }
        }
      },
    );

    test('gradeSubmission rejects score above maxScore', () async {
      final fakeLabService = _FakeLabService()
        ..labResult = ServiceResult<LabModel>.success(_lab(maxScore: 100))
        ..submissionsResult = ServiceResult<List<LabSubmissionModel>>.success(
          <LabSubmissionModel>[_submission(id: 7)],
        );

      final cubit = LabDetailCubit(labService: fakeLabService);

      await cubit.loadLabDetail('1');
      await cubit.loadSubmissions('1');
      await cubit.gradeSubmission('1', '7', 150);

      final state = cubit.state as LabDetailLoaded;
      expect(state.errorMessage, contains('Score must be between 0 and 100.0'));
      expect(fakeLabService.gradeCallCount, 0);

      await cubit.close();
    });

    test(
      'reorderInstructions updates order index for all instructions',
      () async {
        final fakeLabService = _FakeLabService()
          ..instructionsResult =
              ServiceResult<List<LabInstructionModel>>.success(
                <LabInstructionModel>[
                  _instruction(id: 1, orderIndex: 0, text: 'First'),
                  _instruction(id: 2, orderIndex: 1, text: 'Second'),
                  _instruction(id: 3, orderIndex: 2, text: 'Third'),
                ],
              );

        final cubit = LabDetailCubit(labService: fakeLabService);

        await cubit.loadLabDetail('1');
        await cubit.loadInstructions('1');

        await cubit.reorderInstructions('1', <String>['3', '1', '2']);

        expect(fakeLabService.updateInstructionCalls.length, 3);

        expect(
          fakeLabService.updateInstructionCalls[0]['instructionId'].toString(),
          '3',
        );
        expect(
          (fakeLabService.updateInstructionCalls[0]['data']
              as Map<String, dynamic>)['orderIndex'],
          0,
        );

        expect(
          fakeLabService.updateInstructionCalls[1]['instructionId'].toString(),
          '1',
        );
        expect(
          (fakeLabService.updateInstructionCalls[1]['data']
              as Map<String, dynamic>)['orderIndex'],
          1,
        );

        expect(
          fakeLabService.updateInstructionCalls[2]['instructionId'].toString(),
          '2',
        );
        expect(
          (fakeLabService.updateInstructionCalls[2]['data']
              as Map<String, dynamic>)['orderIndex'],
          2,
        );

        await cubit.close();
      },
    );
  });
}

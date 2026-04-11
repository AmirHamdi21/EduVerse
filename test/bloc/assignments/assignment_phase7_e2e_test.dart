import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/bloc/assignments/assignment_bloc.dart';
import 'package:edu_verse/bloc/assignments/assignment_event.dart';
import 'package:edu_verse/bloc/assignments/assignment_state.dart';
import 'package:edu_verse/common/service_error.dart';
import 'package:edu_verse/models/assignments/assignment_model.dart';
import 'package:edu_verse/models/assignments/assignment_submission_model.dart';
import 'package:edu_verse/models/core/enums/assignment_enums.dart' as api;
import 'package:edu_verse/models/core/paginated_response.dart';
import 'package:edu_verse/services/api/assignment_service.dart';
import 'package:edu_verse/services/api/core_api_client.dart';

class _FlowAssignmentService extends AssignmentService {
  _FlowAssignmentService({
    required this.assignments,
    Map<int, AssignmentSubmissionModel>? initialSubmissions,
  }) : submissions = Map<int, AssignmentSubmissionModel>.from(
         initialSubmissions ?? const <int, AssignmentSubmissionModel>{},
       ),
       super(coreApiClient: CoreApiClient.test());

  final List<AssignmentModel> assignments;
  final Map<int, AssignmentSubmissionModel> submissions;

  int textSubmitCalls = 0;
  int fileSubmitCalls = 0;

  api.SubmissionStatus submitResultStatus = api.SubmissionStatus.submitted;
  double? submitScore;
  String? submitFeedback;

  int _resolveId(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value.toString()) ?? 0;
  }

  @override
  Future<ServiceResult<PaginatedResponse<AssignmentModel>>> getAll({
    int? courseId,
    int? sectionId,
    api.AssignmentStatus? status,
    String? search,
    int? page,
    int? limit,
    String? sortBy,
    String? sortOrder,
  }) async {
    return ServiceResult<PaginatedResponse<AssignmentModel>>.success(
      PaginatedResponse<AssignmentModel>(
        data: assignments,
        total: assignments.length,
        page: 1,
        limit: assignments.isEmpty ? 1 : assignments.length,
        totalPages: 1,
      ),
    );
  }

  @override
  Future<ServiceResult<AssignmentModel>> getById(dynamic id) async {
    final resolved = _resolveId(id);
    final assignment = assignments.firstWhere(
      (item) => item.assignmentId == resolved,
      orElse: () => assignments.first,
    );

    return ServiceResult<AssignmentModel>.success(assignment);
  }

  @override
  Future<ServiceResult<AssignmentSubmissionModel>> getMySubmission(
    dynamic assignmentId,
  ) async {
    final id = _resolveId(assignmentId);
    final submission = submissions[id];

    if (submission == null) {
      return ServiceResult<AssignmentSubmissionModel>.failure(
        const ServiceError(
          type: ServiceErrorType.server,
          statusCode: 404,
          message: 'No submission found',
        ),
      );
    }

    return ServiceResult<AssignmentSubmissionModel>.success(submission);
  }

  @override
  Future<ServiceResult<AssignmentSubmissionModel>> submit(
    dynamic assignmentId, {
    String? submissionText,
    String? submissionLink,
  }) async {
    textSubmitCalls += 1;
    final id = _resolveId(assignmentId);
    final previous = submissions[id];

    final updated = _buildSubmission(
      assignmentId: id,
      status: submitResultStatus,
      attemptNumber: (previous?.attemptNumber ?? 0) + 1,
      score: submitScore,
      feedback: submitFeedback,
      submissionText: submissionText,
      submissionLink: submissionLink,
    );

    submissions[id] = updated;
    return ServiceResult<AssignmentSubmissionModel>.success(updated);
  }

  @override
  Future<ServiceResult<AssignmentSubmissionModel>> submitFile(
    dynamic assignmentId,
    File file, {
    String? submissionText,
    String? submissionLink,
    ProgressCallback? onSendProgress,
  }) async {
    fileSubmitCalls += 1;
    return submit(
      assignmentId,
      submissionText: submissionText,
      submissionLink: submissionLink,
    );
  }
}

AssignmentModel _assignment({
  required int id,
  required String title,
  required DateTime dueDate,
  bool lateSubmissionAllowed = true,
  api.SubmissionType submissionType = api.SubmissionType.text,
}) {
  return AssignmentModel(
    id: id.toString(),
    assignmentId: id,
    courseId: 1,
    title: title,
    description: 'description for $title',
    courseName: 'Algorithms',
    courseCode: 'CS301',
    instructorName: 'Dr. Ahmed',
    type: AssignmentType.document,
    status: AssignmentStatus.pending,
    priority: AssignmentPriority.medium,
    dueDate: dueDate,
    maxGrade: 100,
    createdAt: DateTime(2026, 1, 1),
    apiStatus: api.AssignmentStatus.published,
    submissionType: submissionType,
    lateSubmissionAllowed: lateSubmissionAllowed,
    maxFileSizeMb: 20,
  );
}

AssignmentSubmissionModel _buildSubmission({
  required int assignmentId,
  required api.SubmissionStatus status,
  required int attemptNumber,
  double? score,
  String? feedback,
  String? submissionText,
  String? submissionLink,
}) {
  return AssignmentSubmissionModel(
    id: assignmentId * 10 + attemptNumber,
    assignmentId: assignmentId,
    userId: 55,
    submissionText: submissionText,
    submissionLink: submissionLink,
    submissionStatus: status,
    isLate: false,
    attemptNumber: attemptNumber,
    submittedAt: DateTime.now(),
    score: score,
    feedback: feedback,
    gradedAt: score == null ? null : DateTime.now(),
  );
}

Future<void> _settle() async {
  await Future<void>.delayed(const Duration(milliseconds: 10));
}

void main() {
  group('Phase 7 end-to-end assignment flows', () {
    test(
      'T081: fetch -> filter submitted -> select -> submit text -> grade',
      () async {
        final service = _FlowAssignmentService(
          assignments: <AssignmentModel>[
            _assignment(
              id: 1,
              title: 'Flow Assignment',
              dueDate: DateTime.now().add(const Duration(days: 1)),
            ),
          ],
          initialSubmissions: <int, AssignmentSubmissionModel>{
            1: _buildSubmission(
              assignmentId: 1,
              status: api.SubmissionStatus.submitted,
              attemptNumber: 1,
              submissionText: 'initial submission',
            ),
          },
        );

        final bloc = AssignmentBloc(assignmentService: service);

        bloc.add(const FetchAssignments());
        await _settle();
        await _settle();

        bloc.add(
          const SetAssignmentFilterStatus(
            filterStatus: AssignmentFilterStatus.submitted,
          ),
        );
        await _settle();

        expect(bloc.state.filteredAssignments.length, 1);

        bloc.add(
          SelectAssignment(assignment: bloc.state.filteredAssignments.first),
        );
        await _settle();
        await _settle();

        service.submitResultStatus = api.SubmissionStatus.graded;
        service.submitScore = 94;
        service.submitFeedback = 'Great improvement';

        bloc.add(
          const SubmitTextAssignment(
            assignmentId: 1,
            submissionText: 'updated text submission',
          ),
        );
        await _settle();
        await _settle();
        await _settle();

        expect(service.textSubmitCalls, 1);
        expect(bloc.state.mySubmission, isNotNull);
        expect(
          bloc.state.mySubmission!.submissionStatus,
          api.SubmissionStatus.graded,
        );
        expect(bloc.state.mySubmission!.score, 94);

        await bloc.close();
      },
    );

    test(
      'T082: fetch -> filter overdue keeps overdue/no-late assignments',
      () async {
        final service = _FlowAssignmentService(
          assignments: <AssignmentModel>[
            _assignment(
              id: 2,
              title: 'Overdue Assignment',
              dueDate: DateTime.now().subtract(const Duration(days: 2)),
              lateSubmissionAllowed: false,
            ),
          ],
        );

        final bloc = AssignmentBloc(assignmentService: service);

        bloc.add(const FetchAssignments());
        await _settle();
        await _settle();

        bloc.add(
          const SetAssignmentFilterStatus(
            filterStatus: AssignmentFilterStatus.overdue,
          ),
        );
        await _settle();

        expect(bloc.state.filteredAssignments.length, 1);
        final assignment = bloc.state.filteredAssignments.first;
        expect(assignment.submissionFilterStatus, 'overdue');
        expect(assignment.lateSubmissionAllowed, isFalse);

        await bloc.close();
      },
    );

    test(
      'T083: file submission flow succeeds for file-type assignment',
      () async {
        final service = _FlowAssignmentService(
          assignments: <AssignmentModel>[
            _assignment(
              id: 3,
              title: 'File Assignment',
              dueDate: DateTime.now().add(const Duration(days: 1)),
              submissionType: api.SubmissionType.file,
            ),
          ],
        );

        final bloc = AssignmentBloc(assignmentService: service);
        bloc.add(const FetchAssignments());
        await _settle();
        await _settle();

        final dir = await Directory.systemTemp.createTemp('phase7_file_flow');
        final file = File('${dir.path}${Platform.pathSeparator}upload.pdf');
        await file.writeAsString('mock file content');

        try {
          bloc.add(SelectAssignment(assignment: bloc.state.assignments.first));
          await _settle();
          await _settle();

          bloc.add(
            SubmitFileAssignment(
              assignmentId: 3,
              file: file,
              submissionText: 'device upload',
            ),
          );

          await _settle();
          await _settle();
          await _settle();

          expect(service.fileSubmitCalls, 1);
          expect(bloc.state.submitError, isNull);
          expect(bloc.state.mySubmission, isNotNull);
          expect(bloc.state.mySubmission!.assignmentId, 3);
        } finally {
          try {
            if (await dir.exists()) {
              await dir.delete(recursive: true);
            }
          } on FileSystemException {
            // Best-effort cleanup on Windows.
          }
          await bloc.close();
        }
      },
    );

    test('T084: graded submission can be resubmitted as new attempt', () async {
      final service = _FlowAssignmentService(
        assignments: <AssignmentModel>[
          _assignment(
            id: 4,
            title: 'Resubmission Assignment',
            dueDate: DateTime.now().add(const Duration(days: 1)),
          ),
        ],
        initialSubmissions: <int, AssignmentSubmissionModel>{
          4: _buildSubmission(
            assignmentId: 4,
            status: api.SubmissionStatus.graded,
            attemptNumber: 1,
            score: 80,
            feedback: 'Needs better edge-case handling',
            submissionText: 'first attempt',
          ),
        },
      );

      final bloc = AssignmentBloc(assignmentService: service);

      bloc.add(const FetchAssignments());
      await _settle();
      await _settle();

      bloc.add(SelectAssignment(assignment: bloc.state.assignments.first));
      await _settle();
      await _settle();

      expect(bloc.state.mySubmission, isNotNull);
      expect(
        bloc.state.mySubmission!.submissionStatus,
        api.SubmissionStatus.graded,
      );
      expect(bloc.state.mySubmission!.attemptNumber, 1);

      service.submitResultStatus = api.SubmissionStatus.submitted;
      service.submitScore = null;
      service.submitFeedback = null;

      bloc.add(
        const SubmitTextAssignment(
          assignmentId: 4,
          submissionText: 'second attempt',
        ),
      );
      await _settle();
      await _settle();
      await _settle();

      expect(service.textSubmitCalls, 1);
      expect(bloc.state.mySubmission, isNotNull);
      expect(bloc.state.mySubmission!.attemptNumber, 2);
      expect(
        bloc.state.mySubmission!.submissionStatus,
        api.SubmissionStatus.submitted,
      );

      await bloc.close();
    });
  });
}

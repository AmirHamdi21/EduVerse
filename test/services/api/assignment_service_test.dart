import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/models/core/enums/assignment_enums.dart' as api;
import 'package:edu_verse/services/api/assignment_service.dart';
import 'package:edu_verse/services/api/core_api_client.dart';

class _QueueAdapter implements HttpClientAdapter {
  final List<Map<String, dynamic>> responses;
  final List<RequestOptions> requests = <RequestOptions>[];

  _QueueAdapter(this.responses);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);

    final next = responses.isNotEmpty
        ? responses.removeAt(0)
        : <String, dynamic>{'statusCode': 200, 'data': <String, dynamic>{}};

    final statusCode = next['statusCode'] as int? ?? 200;
    final data = next['data'];

    return ResponseBody.fromString(
      jsonEncode(data ?? <String, dynamic>{}),
      statusCode,
      headers: <String, List<String>>{
        'content-type': <String>['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Map<String, dynamic> _assignmentJson({int id = 1, String title = 'HW'}) {
  return <String, dynamic>{
    'id': id,
    'courseId': 7,
    'title': title,
    'description': 'Assignment description',
    'instructions': '# Steps',
    'maxScore': 100,
    'weight': 10,
    'dueDate': '2026-04-20T12:00:00.000Z',
    'availableFrom': '2026-04-01T08:00:00.000Z',
    'lateSubmissionAllowed': 1,
    'latePenaltyPercent': 5,
    'submissionType': 'file',
    'maxFileSizeMb': 20,
    'allowedFileTypes': '["pdf","zip"]',
    'status': 'published',
    'createdBy': 2,
    'createdAt': '2026-04-01T08:00:00.000Z',
    'updatedAt': '2026-04-05T10:00:00.000Z',
    'course': <String, dynamic>{'id': 7, 'name': 'Algorithms', 'code': 'CS301'},
    'instructionFiles': <Map<String, dynamic>>[
      <String, dynamic>{
        'driveFileId': 9,
        'driveId': 'abc123',
        'fileName': 'instructions.pdf',
        'webViewLink': 'https://drive.google.com/file/d/abc123/view',
        'webContentLink':
            'https://drive.google.com/uc?id=abc123&export=download',
      },
    ],
  };
}

Map<String, dynamic> _submissionJson({
  int assignmentId = 1,
  String status = 'submitted',
}) {
  return <String, dynamic>{
    'id': 33,
    'assignmentId': assignmentId,
    'userId': 12,
    'submissionText': 'My answer',
    'submissionLink': 'https://example.com/work',
    'submissionStatus': status,
    'isLate': 0,
    'attemptNumber': 1,
    'submittedAt': '2026-04-11T10:00:00.000Z',
    'score': status == 'graded' ? 88.5 : null,
    'feedback': status == 'graded' ? 'Good work' : null,
    'driveFile': <String, dynamic>{
      'driveFileId': 17,
      'driveId': 'file17',
      'fileName': 'submission.pdf',
      'webViewLink': 'https://drive.google.com/file/d/file17/view',
      'webContentLink': 'https://drive.google.com/uc?id=file17&export=download',
    },
  };
}

void main() {
  group('AssignmentService', () {
    test(
      'getAll sends query params and parses paginated assignments',
      () async {
        final client = CoreApiClient.test();
        final adapter = _QueueAdapter(<Map<String, dynamic>>[
          <String, dynamic>{
            'statusCode': 200,
            'data': <String, dynamic>{
              'data': <Map<String, dynamic>>[_assignmentJson(id: 11)],
              'meta': <String, dynamic>{
                'total': 1,
                'page': 2,
                'limit': 5,
                'totalPages': 1,
              },
            },
          },
        ]);
        client.dio.httpClientAdapter = adapter;

        final service = AssignmentService(coreApiClient: client);
        final result = await service.getAll(
          courseId: 7,
          sectionId: 4,
          status: api.AssignmentStatus.published,
          search: 'binary',
          page: 2,
          limit: 5,
          sortBy: 'dueDate',
          sortOrder: 'ASC',
        );

        expect(result.isSuccess, isTrue);
        expect(adapter.requests.length, 1);
        expect(adapter.requests.first.path, '/assignments');
        expect(adapter.requests.first.method, 'GET');
        expect(adapter.requests.first.queryParameters['courseId'], 7);
        expect(adapter.requests.first.queryParameters['sectionId'], 4);
        expect(adapter.requests.first.queryParameters['status'], 'published');
        expect(adapter.requests.first.queryParameters['search'], 'binary');
        expect(adapter.requests.first.queryParameters['page'], 2);
        expect(adapter.requests.first.queryParameters['limit'], 5);
        expect(adapter.requests.first.queryParameters['sortBy'], 'dueDate');
        expect(adapter.requests.first.queryParameters['sortOrder'], 'ASC');

        final page = result.data!;
        expect(page.data.length, 1);
        expect(page.data.first.assignmentId, 11);
        expect(page.page, 2);
        expect(page.limit, 5);
      },
    );

    test('getById fetches one assignment by id', () async {
      final client = CoreApiClient.test();
      final adapter = _QueueAdapter(<Map<String, dynamic>>[
        <String, dynamic>{
          'statusCode': 200,
          'data': <String, dynamic>{'data': _assignmentJson(id: 42)},
        },
      ]);
      client.dio.httpClientAdapter = adapter;

      final service = AssignmentService(coreApiClient: client);
      final result = await service.getById(42);

      expect(result.isSuccess, isTrue);
      expect(adapter.requests.length, 1);
      expect(adapter.requests.first.path, '/assignments/42');
      expect(adapter.requests.first.method, 'GET');
      expect(result.data!.assignmentId, 42);
    });

    test('submit posts text/link payload and parses submission', () async {
      final client = CoreApiClient.test();
      final adapter = _QueueAdapter(<Map<String, dynamic>>[
        <String, dynamic>{
          'statusCode': 201,
          'data': <String, dynamic>{'data': _submissionJson(assignmentId: 9)},
        },
      ]);
      client.dio.httpClientAdapter = adapter;

      final service = AssignmentService(coreApiClient: client);
      final result = await service.submit(
        9,
        submissionText: 'Text body',
        submissionLink: 'https://example.com/work',
      );

      expect(result.isSuccess, isTrue);
      expect(adapter.requests.first.path, '/assignments/9/submit');
      expect(adapter.requests.first.method, 'POST');
      expect(adapter.requests.first.data, <String, dynamic>{
        'submissionText': 'Text body',
        'submissionLink': 'https://example.com/work',
      });
      expect(result.data!.assignmentId, 9);
      expect(result.data!.submissionText, 'My answer');
    });

    test('submitFile posts multipart data to upload endpoint', () async {
      final client = CoreApiClient.test();
      final adapter = _QueueAdapter(<Map<String, dynamic>>[
        <String, dynamic>{
          'statusCode': 201,
          'data': <String, dynamic>{'data': _submissionJson(assignmentId: 15)},
        },
      ]);
      client.dio.httpClientAdapter = adapter;

      final tempDir = await Directory.systemTemp.createTemp(
        'assignment_service_test',
      );
      final file = File('${tempDir.path}${Platform.pathSeparator}work.txt');
      await file.writeAsString('hello');

      try {
        final service = AssignmentService(coreApiClient: client);
        final result = await service.submitFile(
          15,
          file,
          submissionText: 'note',
          submissionLink: 'https://example.com/file',
        );

        expect(result.isSuccess, isTrue);
        expect(
          adapter.requests.first.path,
          '/assignments/15/submissions/upload',
        );
        expect(adapter.requests.first.method, 'POST');

        final payload = adapter.requests.first.data;
        expect(payload, isA<FormData>());

        final formData = payload as FormData;
        final fieldNames = formData.fields.map((entry) => entry.key).toList();
        final fileNames = formData.files.map((entry) => entry.key).toList();
        expect(fieldNames, contains('submissionText'));
        expect(fieldNames, contains('submissionLink'));
        expect(fileNames, contains('file'));

        expect(result.data!.assignmentId, 15);
        expect(result.data!.driveFile, isNotNull);
      } finally {
        try {
          if (await tempDir.exists()) {
            await tempDir.delete(recursive: true);
          }
        } on FileSystemException {
          // Best-effort cleanup on Windows where multipart streams
          // may keep a temporary handle alive briefly.
        }
      }
    });

    test('getMySubmission fetches my submission by assignment id', () async {
      final client = CoreApiClient.test();
      final adapter = _QueueAdapter(<Map<String, dynamic>>[
        <String, dynamic>{
          'statusCode': 200,
          'data': <String, dynamic>{
            'data': _submissionJson(assignmentId: 21, status: 'graded'),
          },
        },
      ]);
      client.dio.httpClientAdapter = adapter;

      final service = AssignmentService(coreApiClient: client);
      final result = await service.getMySubmission(21);

      expect(result.isSuccess, isTrue);
      expect(adapter.requests.first.path, '/assignments/21/submissions/my');
      expect(adapter.requests.first.method, 'GET');
      expect(result.data!.assignmentId, 21);
      expect(result.data!.submissionStatus, api.SubmissionStatus.graded);
    });
  });
}

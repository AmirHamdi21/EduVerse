import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/services/api/assignment_service.dart';
import 'package:edu_verse/services/api/core_api_client.dart';

class _QueueAdapter implements HttpClientAdapter {
  _QueueAdapter(this.responses);

  final List<Map<String, dynamic>> responses;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final next = responses.isNotEmpty
        ? responses.removeAt(0)
        : <String, dynamic>{
            'statusCode': 201,
            'data': <String, dynamic>{'data': <String, dynamic>{}},
          };

    return ResponseBody.fromString(
      jsonEncode(next['data'] ?? <String, dynamic>{}),
      next['statusCode'] as int? ?? 201,
      headers: <String, List<String>>{
        'content-type': <String>['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Map<String, dynamic> _submissionJson() {
  return <String, dynamic>{
    'id': 301,
    'assignmentId': 30,
    'userId': 77,
    'submissionText': '10mb upload test',
    'submissionStatus': 'submitted',
    'isLate': 0,
    'attemptNumber': 1,
    'submittedAt': '2026-04-11T11:00:00.000Z',
    'driveFile': <String, dynamic>{
      'driveFileId': 99,
      'driveId': 'perf-test-file',
      'fileName': 'upload-10mb.bin',
      'webViewLink': 'https://drive.google.com/file/d/perf-test-file/view',
      'webContentLink':
          'https://drive.google.com/uc?id=perf-test-file&export=download',
    },
  };
}

void main() {
  test('T080: 10MB upload path completes under 30 seconds', () async {
    final client = CoreApiClient.test();
    client.dio.httpClientAdapter = _QueueAdapter(<Map<String, dynamic>>[
      <String, dynamic>{
        'statusCode': 201,
        'data': <String, dynamic>{'data': _submissionJson()},
      },
    ]);

    final tempDir = await Directory.systemTemp.createTemp(
      'assignment_10mb_perf',
    );
    final file = File(
      '${tempDir.path}${Platform.pathSeparator}upload-10mb.bin',
    );

    try {
      final bytes = List<int>.filled(10 * 1024 * 1024, 65);
      await file.writeAsBytes(bytes, flush: true);

      final service = AssignmentService(coreApiClient: client);
      final stopwatch = Stopwatch()..start();

      final result = await service.submitFile(
        30,
        file,
        submissionText: 'performance upload sample',
      );

      stopwatch.stop();

      expect(result.isSuccess, isTrue);
      expect(stopwatch.elapsed, lessThan(const Duration(seconds: 30)));

      // ignore: avoid_print
      print('T080 measured_upload_ms=${stopwatch.elapsedMilliseconds}');
    } finally {
      try {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      } on FileSystemException {
        // Best-effort cleanup on Windows.
      }
    }
  });
}

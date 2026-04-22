import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/lab_service.dart';

class _QueueAdapter implements HttpClientAdapter {
  _QueueAdapter(this.responses);

  final List<Map<String, dynamic>> responses;
  final List<RequestOptions> requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);

    // Consume the outgoing multipart stream so temporary file handles are
    // released before test teardown deletes the temp directory on Windows.
    if (requestStream != null) {
      await requestStream.fold<int>(0, (sum, chunk) => sum + chunk.length);
    }

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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'uploadInstructionFile sends multipart file field without manual JSON content type',
    () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'lab_upload_contract',
      );
      final file = File(
        '${tempDir.path}${Platform.pathSeparator}instruction.txt',
      );
      await file.writeAsString('hello instruction upload');

      try {
        final client = CoreApiClient.test();
        final adapter = _QueueAdapter(<Map<String, dynamic>>[
          <String, dynamic>{
            'statusCode': 201,
            'data': <String, dynamic>{
              'data': <String, dynamic>{
                'id': 11,
                'file': <String, dynamic>{
                  'driveFileId': 2,
                  'driveId': 'drive-id-2',
                  'fileName': 'instruction.txt',
                  'webViewLink': 'https://drive.example/view',
                  'downloadUrl': 'https://drive.example/download',
                },
              },
            },
          },
        ]);
        client.dio.httpClientAdapter = adapter;

        final service = LabService(coreApiClient: client);
        final result = await service.uploadInstructionFile(
          1,
          file,
          orderIndex: 3,
        );

        expect(result.isSuccess, isTrue);
        expect(adapter.requests.length, 1);

        final request = adapter.requests.first;
        expect(request.path, '/labs/1/instructions/upload');
        expect(request.method, 'POST');

        final data = request.data;
        expect(data, isA<FormData>());
        final formData = data as FormData;

        expect(formData.files.any((entry) => entry.key == 'file'), isTrue);
        expect(
          formData.fields.any(
            (entry) => entry.key == 'orderIndex' && entry.value == '3',
          ),
          isTrue,
        );

        final headers = request.headers;
        final contentType =
            (headers['content-type'] ?? headers['Content-Type'] ?? '')
                .toString()
                .toLowerCase();

        expect(contentType.contains('application/json'), isFalse);
        expect(contentType.contains('multipart/form-data'), isTrue);
      } finally {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      }
    },
  );
}

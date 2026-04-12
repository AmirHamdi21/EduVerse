import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/material_service.dart';

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

    final next = responses.isNotEmpty
        ? responses.removeAt(0)
        : <String, dynamic>{'statusCode': 200, 'data': <String, dynamic>{}};

    return ResponseBody.fromString(
      jsonEncode(next['data'] ?? <String, dynamic>{}),
      next['statusCode'] as int? ?? 200,
      headers: <String, List<String>>{
        'content-type': <String>['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Future<File> _createTempFile(String name) async {
  final dir = await Directory.systemTemp.createTemp('eduverse_test_');
  final file = File('${dir.path}/$name');
  await file.writeAsString('file-content');
  return file;
}

void main() {
  group('MaterialService phase5 uploads', () {
    test(
      'uploadDocument sends FormData with document and weekNumber',
      () async {
        final file = await _createTempFile('notes.pdf');
        addTearDown(() async {
          try {
            if (await file.exists()) {
              await file.delete();
            }
            if (await file.parent.exists()) {
              await file.parent.delete(recursive: true);
            }
          } catch (_) {}
        });

        final client = CoreApiClient.test();
        final adapter = _QueueAdapter(<Map<String, dynamic>>[
          <String, dynamic>{
            'statusCode': 200,
            'data': <String, dynamic>{
              'materialId': '1',
              'courseId': '5',
              'materialType': 'document',
              'title': 'Week 2 Notes',
              'isPublished': true,
              'createdAt': '2026-04-12T10:00:00.000Z',
            },
          },
        ]);
        client.dio.httpClientAdapter = adapter;
        final service = MaterialService(coreApiClient: client);

        final model = await service.uploadDocument(
          5,
          file: file,
          title: 'Week 2 Notes',
          weekNumber: 2,
        );

        expect(model.materialType, 'document');
        expect(adapter.requests.first.path, '/courses/5/materials/document');
        expect(adapter.requests.first.method, 'POST');

        final formData = adapter.requests.first.data as FormData;
        final fieldNames = formData.fields.map((entry) => entry.key).toList();
        final fileFieldNames = formData.files
            .map((entry) => entry.key)
            .toList();
        expect(fileFieldNames, contains('document'));
        expect(fieldNames, contains('title'));
        expect(fieldNames, contains('weekNumber'));
        expect(fieldNames, contains('isPublished'));
      },
    );

    test('uploadVideo sends FormData with video field', () async {
      final file = await _createTempFile('lecture.mp4');
      addTearDown(() async {
        try {
          if (await file.exists()) {
            await file.delete();
          }
          if (await file.parent.exists()) {
            await file.parent.delete(recursive: true);
          }
        } catch (_) {}
      });

      final client = CoreApiClient.test();
      final adapter = _QueueAdapter(<Map<String, dynamic>>[
        <String, dynamic>{
          'statusCode': 200,
          'data': <String, dynamic>{
            'materialId': '2',
            'courseId': '5',
            'materialType': 'video',
            'title': 'Week 2 Lecture',
            'isPublished': true,
            'createdAt': '2026-04-12T10:00:00.000Z',
          },
        },
      ]);
      client.dio.httpClientAdapter = adapter;
      final service = MaterialService(coreApiClient: client);

      await service.uploadVideo(
        5,
        file: file,
        title: 'Week 2 Lecture',
        weekNumber: 2,
        onSendProgress: (_, __) {},
      );

      expect(adapter.requests.first.path, '/courses/5/materials/video');
      final formData = adapter.requests.first.data as FormData;
      final fieldNames = formData.fields.map((entry) => entry.key).toList();
      final fileFieldNames = formData.files.map((entry) => entry.key).toList();
      expect(fileFieldNames, contains('video'));
      expect(fieldNames, contains('weekNumber'));
    });

    test('uploadTextLink posts JSON body including weekNumber', () async {
      final client = CoreApiClient.test();
      final adapter = _QueueAdapter(<Map<String, dynamic>>[
        <String, dynamic>{
          'statusCode': 200,
          'data': <String, dynamic>{
            'materialId': '3',
            'courseId': '5',
            'materialType': 'link',
            'title': 'Reference',
            'externalUrl': 'https://example.com',
            'isPublished': true,
            'createdAt': '2026-04-12T10:00:00.000Z',
          },
        },
      ]);
      client.dio.httpClientAdapter = adapter;
      final service = MaterialService(coreApiClient: client);

      final model = await service.uploadTextLink(
        5,
        title: 'Reference',
        url: 'https://example.com',
        type: 'link',
        weekNumber: 6,
      );

      expect(model.materialType, 'link');
      expect(adapter.requests.first.path, '/courses/5/materials');
      expect(adapter.requests.first.method, 'POST');

      final body = adapter.requests.first.data as Map<String, dynamic>;
      expect(body['title'], 'Reference');
      expect(body['url'], 'https://example.com');
      expect(body['type'], 'link');
      expect(body['weekNumber'], 6);
      expect(body['isPublished'], isTrue);
    });
  });
}

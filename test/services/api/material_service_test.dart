import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/material_service.dart';

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

void main() {
  group('MaterialService.recordView', () {
    test('posts to /materials/{id}/view with courseId body', () async {
      final client = CoreApiClient.test();
      final adapter = _QueueAdapter(<Map<String, dynamic>>[
        <String, dynamic>{
          'statusCode': 200,
          'data': <String, dynamic>{'success': true, 'viewCount': 46},
        },
      ]);
      client.dio.httpClientAdapter = adapter;

      final service = MaterialService(coreApiClient: client);
      await service.recordView(5, 101);

      expect(adapter.requests.length, 1);
      expect(adapter.requests.first.path, '/materials/101/view');
      expect(adapter.requests.first.method, 'POST');
      expect(adapter.requests.first.data, <String, dynamic>{'courseId': 5});
    });

    test(
      'falls back to legacy endpoint when direct endpoint returns 404',
      () async {
        final client = CoreApiClient.test();
        final adapter = _QueueAdapter(<Map<String, dynamic>>[
          <String, dynamic>{
            'statusCode': 404,
            'data': <String, dynamic>{'message': 'Not Found'},
          },
          <String, dynamic>{
            'statusCode': 200,
            'data': <String, dynamic>{'success': true},
          },
        ]);
        client.dio.httpClientAdapter = adapter;

        final service = MaterialService(coreApiClient: client);
        await service.recordView(5, 101);

        expect(adapter.requests.length, 2);
        expect(adapter.requests.first.path, '/materials/101/view');
        expect(adapter.requests.last.path, '/courses/5/materials/101/view');
      },
    );
  });
}

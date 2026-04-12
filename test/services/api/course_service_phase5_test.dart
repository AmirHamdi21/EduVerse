import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/course_service.dart';

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

void main() {
  group('CourseService phase5 structure endpoints', () {
    test('create, update, delete and reorder structure items', () async {
      final client = CoreApiClient.test();
      final adapter = _QueueAdapter(<Map<String, dynamic>>[
        <String, dynamic>{
          'statusCode': 200,
          'data': <String, dynamic>{
            'organizationId': '11',
            'courseId': '5',
            'title': 'Week 3',
            'weekNumber': 3,
            'organizationType': 'lecture',
            'orderIndex': 1,
          },
        },
        <String, dynamic>{
          'statusCode': 200,
          'data': <String, dynamic>{
            'organizationId': '11',
            'courseId': '5',
            'title': 'Week 3 Updated',
            'weekNumber': 3,
            'organizationType': 'lecture',
            'orderIndex': 1,
          },
        },
        <String, dynamic>{'statusCode': 200, 'data': <String, dynamic>{}},
        <String, dynamic>{'statusCode': 200, 'data': <String, dynamic>{}},
      ]);
      client.dio.httpClientAdapter = adapter;

      final service = CourseService(coreApiClient: client);

      final created = await service.createStructureItem(5, <String, dynamic>{
        'title': 'Week 3',
        'weekNumber': 3,
      });
      expect(created.title, 'Week 3');

      final updated = await service.updateStructureItem(
        5,
        '11',
        <String, dynamic>{'title': 'Week 3 Updated'},
      );
      expect(updated.title, 'Week 3 Updated');

      await service.deleteStructureItem(5, '11');
      await service.reorderStructureItems(5, <int>[2, 1, 3]);

      expect(adapter.requests[0].path, '/courses/5/structure');
      expect(adapter.requests[0].method, 'POST');
      expect(adapter.requests[1].path, '/courses/5/structure/11');
      expect(adapter.requests[1].method, 'PUT');
      expect(adapter.requests[2].path, '/courses/5/structure/11');
      expect(adapter.requests[2].method, 'DELETE');
      expect(adapter.requests[3].path, '/courses/5/structure/reorder');
      expect(adapter.requests[3].method, 'PATCH');
      expect(adapter.requests[3].data, <String, dynamic>{
        'itemIds': <int>[2, 1, 3],
      });
    });
  });
}

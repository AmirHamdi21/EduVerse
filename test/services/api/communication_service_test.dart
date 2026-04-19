import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/communication_service.dart';

class _MockAdapter implements HttpClientAdapter {
  final Map<String, dynamic> Function(RequestOptions options) handler;

  _MockAdapter(this.handler);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final Map<String, dynamic> result = handler(options);
    final int statusCode = result['statusCode'] as int? ?? 200;
    final dynamic data = result['data'];

    return ResponseBody.fromString(
      data is String ? data : jsonEncode(data),
      statusCode,
      headers: <String, List<String>>{
        'content-type': <String>['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

CommunicationService _buildService(
  Map<String, dynamic> Function(RequestOptions options) handler,
) {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://eduverse.test',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );
  dio.httpClientAdapter = _MockAdapter(handler);

  return CommunicationService(
    coreApiClient: CoreApiClient.test(dioOverride: dio),
  );
}

void main() {
  group('CommunicationService getAnnouncementsByCourseId', () {
    test('sends courseId query parameter and maps response', () async {
      dynamic observedCourseId;

      final service = _buildService((options) {
        observedCourseId = options.queryParameters['courseId'];
        return <String, dynamic>{
          'statusCode': 200,
          'data': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 1,
              'courseId': 22,
              'title': 'Quiz reminder',
              'content': 'Quiz this week',
              'createdBy': 4,
              'priority': 'medium',
              'publishedAt': '2026-04-01T10:00:00.000Z',
              'createdAt': '2026-04-01T10:00:00.000Z',
              'updatedAt': '2026-04-01T10:00:00.000Z',
            },
          ],
        };
      });

      final result = await service.getAnnouncementsByCourseId(22);

      expect(observedCourseId, 22);
      expect(result, isNotEmpty);
      expect(result.first.courseId, '22');
      expect(result.first.title, 'Quiz reminder');
    });
  });
}

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/student_stats_service.dart';

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

StudentStatsService _buildService(
  Map<String, dynamic> Function(RequestOptions options) handler,
) {
  final Dio dio = Dio(BaseOptions(baseUrl: 'https://eduverse.test'));
  dio.httpClientAdapter = _MockAdapter(handler);
  return StudentStatsService(
    coreApiClient: CoreApiClient.test(dioOverride: dio),
  );
}

void main() {
  test('getStudentGpa maps gpa endpoint payload', () async {
    String? observedPath;

    final service = _buildService((options) {
      observedPath = options.path;
      return <String, dynamic>{
        'statusCode': 200,
        'data': <String, dynamic>{
          'data': <String, dynamic>{'studentId': 42, 'gpa': 3.76},
        },
      };
    });

    final gpa = await service.getStudentGpa(42);

    expect(observedPath, '/grades/gpa/42');
    expect(gpa.studentId, 42);
    expect(gpa.gpa, closeTo(3.76, 0.0001));
  });

  test('getUnreadCount maps unread-count endpoint payload', () async {
    String? observedPath;

    final service = _buildService((options) {
      observedPath = options.path;
      return <String, dynamic>{
        'statusCode': 200,
        'data': <String, dynamic>{
          'data': <String, dynamic>{'unreadCount': 9},
        },
      };
    });

    final unread = await service.getUnreadCount();

    expect(observedPath, '/notifications/unread-count');
    expect(unread.unreadCount, 9);
  });
}

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/schedule_api_service.dart';

class _MockAdapter implements HttpClientAdapter {
  final Map<String, dynamic> Function(RequestOptions options) handler;

  _MockAdapter(this.handler);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final result = handler(options);
    final statusCode = result['statusCode'] as int? ?? 200;
    final data = result['data'];

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

ScheduleApiService _buildService(
  Map<String, dynamic> Function(RequestOptions options) handler,
) {
  final dio = Dio(BaseOptions(baseUrl: 'https://eduverse.test'));
  dio.httpClientAdapter = _MockAdapter(handler);

  return ScheduleApiService(
    coreApiClient: CoreApiClient.test(dioOverride: dio),
  );
}

void main() {
  group('ScheduleApiService', () {
    test('getDailySchedule calls correct endpoint with date query', () async {
      String? observedPath;
      Map<String, dynamic>? observedQuery;

      final service = _buildService((options) {
        observedPath = options.path;
        observedQuery = options.queryParameters;

        return <String, dynamic>{
          'statusCode': 200,
          'data': <String, dynamic>{
            'data': <String, dynamic>{
              'date': '2026-04-21',
              'dayOfWeek': 'TUESDAY',
              'schedules': <dynamic>[],
              'events': <dynamic>[],
              'exams': <dynamic>[],
              'campusEvents': <dynamic>[],
            },
          },
        };
      });

      final result = await service.getDailySchedule(date: '2026-04-21');

      expect(observedPath, '/schedule/my/daily');
      expect(observedQuery?['date'], '2026-04-21');
      expect(result.isSuccess, isTrue);
      expect(result.data, isNotNull);
      expect(result.data!.date, '2026-04-21');
    });

    test('getCampusEvents maps paginated list and metadata', () async {
      String? observedPath;
      Map<String, dynamic>? observedQuery;

      final service = _buildService((options) {
        observedPath = options.path;
        observedQuery = options.queryParameters;

        return <String, dynamic>{
          'statusCode': 200,
          'data': <String, dynamic>{
            'items': <Map<String, dynamic>>[
              <String, dynamic>{
                'eventId': 44,
                'title': 'Hackathon',
                'eventType': 'GENERAL',
                'startDatetime': '2026-04-21T16:00:00Z',
                'endDatetime': '2026-04-21T18:00:00Z',
                'location': 'Auditorium',
                'registrationRequired': true,
              },
            ],
            'meta': <String, dynamic>{
              'page': 2,
              'limit': 5,
              'total': 21,
              'totalPages': 5,
            },
          },
        };
      });

      final result = await service.getCampusEvents(page: 2, limit: 5);

      expect(observedPath, '/campus-events');
      expect(observedQuery?['page'], 2);
      expect(observedQuery?['limit'], 5);
      expect(result.isSuccess, isTrue);
      expect(result.data, isNotNull);
      expect(result.data!.items.length, 1);
      expect(result.data!.items.first.eventId, 44);
      expect(result.data!.meta.page, 2);
      expect(result.data!.meta.totalPages, 5);
    });

    test(
      'unregisterFromCampusEvent issues DELETE to register endpoint',
      () async {
        String? observedPath;
        String? observedMethod;

        final service = _buildService((options) {
          observedPath = options.path;
          observedMethod = options.method;

          return <String, dynamic>{
            'statusCode': 200,
            'data': <String, dynamic>{'ok': true},
          };
        });

        final result = await service.unregisterFromCampusEvent(99);

        expect(observedMethod, 'DELETE');
        expect(observedPath, '/campus-events/99/register');
        expect(result.isSuccess, isTrue);
      },
    );
  });
}

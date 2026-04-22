import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/office_hours_service.dart';

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

OfficeHoursService _buildService(
  Map<String, dynamic> Function(RequestOptions options) handler,
) {
  final Dio dio = Dio(BaseOptions(baseUrl: 'https://eduverse.test'));
  dio.httpClientAdapter = _MockAdapter(handler);
  return OfficeHoursService(
    coreApiClient: CoreApiClient.test(dioOverride: dio),
  );
}

void main() {
  test(
    'getSlots forwards instructorId filter and maps paginated response',
    () async {
      dynamic observedInstructor;

      final service = _buildService((options) {
        observedInstructor = options.queryParameters['instructorId'];
        return <String, dynamic>{
          'statusCode': 200,
          'data': <String, dynamic>{
            'data': <Map<String, dynamic>>[
              <String, dynamic>{
                'slotId': 3,
                'instructorId': 19,
                'dayOfWeek': 'monday',
                'startTime': '10:00:00',
                'endTime': '12:00:00',
                'location': 'C-305',
                'mode': 'in_person',
                'maxAppointments': 4,
                'currentAppointments': 1,
              },
            ],
            'meta': <String, dynamic>{
              'page': 1,
              'limit': 10,
              'total': 1,
              'totalPages': 1,
            },
          },
        };
      });

      final result = await service.getSlots(instructorId: 19);

      expect(observedInstructor, 19);
      expect(result.items, isNotEmpty);
      expect(result.items.first.slotId, 3);
    },
  );

  test('bookAppointment sends expected payload and maps response', () async {
    dynamic observedPayload;

    final service = _buildService((options) {
      observedPayload = options.data;
      return <String, dynamic>{
        'statusCode': 201,
        'data': <String, dynamic>{
          'data': <String, dynamic>{
            'appointmentId': 11,
            'studentName': 'Sara Omar',
            'topic': 'Project guidance',
            'appointmentDate': '2026-04-20',
            'status': 'booked',
          },
        },
      };
    });

    final booked = await service.bookAppointment(
      slotId: 3,
      appointmentDate: '2026-04-20',
      topic: 'Project guidance',
    );

    expect((observedPayload as Map<String, dynamic>)['slotId'], 3);
    expect(booked.appointmentId, 11);
    expect(booked.status.toLowerCase(), 'booked');
  });
}

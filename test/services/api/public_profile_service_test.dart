import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/public_profile_service.dart';

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

PublicProfileService _buildService(
  Map<String, dynamic> Function(RequestOptions options) handler,
) {
  final Dio dio = Dio(BaseOptions(baseUrl: 'https://eduverse.test'));
  dio.httpClientAdapter = _MockAdapter(handler);
  return PublicProfileService(
    coreApiClient: CoreApiClient.test(dioOverride: dio),
  );
}

void main() {
  test('getPublicProfile maps /users/{id}/public payload', () async {
    String? observedPath;

    final service = _buildService((options) {
      observedPath = options.path;
      return <String, dynamic>{
        'statusCode': 200,
        'data': <String, dynamic>{
          'data': <String, dynamic>{
            'userId': 7,
            'firstName': 'Lina',
            'lastName': 'Ali',
            'email': 'lina.ali@eduverse.test',
            'role': 'instructor',
          },
        },
      };
    });

    final profile = await service.getPublicProfile(7);

    expect(observedPath, '/users/7/public');
    expect(profile.userId, 7);
    expect(profile.fullName, 'Lina Ali');
    expect(profile.email, 'lina.ali@eduverse.test');
  });
}

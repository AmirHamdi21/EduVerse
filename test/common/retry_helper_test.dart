import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edu_verse/common/retry_helper.dart';
import 'package:edu_verse/common/service_error.dart';

void main() {
  group('RetryHelper', () {
    test('retries transient timeout errors and eventually succeeds', () async {
      var attempts = 0;

      final result = await RetryHelper.execute<String>(() async {
        attempts += 1;
        if (attempts < 3) {
          throw DioException(
            requestOptions: RequestOptions(path: '/test'),
            type: DioExceptionType.connectionTimeout,
            message: 'Connection timed out',
          );
        }
        return 'ok';
      });

      expect(attempts, 3);
      expect(result.isSuccess, isTrue);
      expect(result.data, 'ok');
      expect(result.error, isNull);
    });

    test('does not retry non-transient 401 errors', () async {
      var attempts = 0;

      final result = await RetryHelper.execute<void>(() async {
        attempts += 1;
        throw DioException(
          requestOptions: RequestOptions(path: '/protected'),
          response: Response<dynamic>(
            requestOptions: RequestOptions(path: '/protected'),
            statusCode: 401,
            data: <String, dynamic>{'message': 'Unauthorized'},
          ),
          type: DioExceptionType.badResponse,
          message: 'Unauthorized',
        );
      });

      expect(attempts, 1);
      expect(result.isFailure, isTrue);
      expect(result.error?.type, ServiceErrorType.auth);
      expect(result.error?.statusCode, 401);
    });

    test('retries 500 errors then returns server failure', () async {
      var attempts = 0;

      final result = await RetryHelper.execute<void>(() async {
        attempts += 1;
        throw DioException(
          requestOptions: RequestOptions(path: '/unstable'),
          response: Response<dynamic>(
            requestOptions: RequestOptions(path: '/unstable'),
            statusCode: 500,
            data: <String, dynamic>{'message': 'Server error'},
          ),
          type: DioExceptionType.badResponse,
          message: 'Server error',
        );
      });

      expect(attempts, 3);
      expect(result.isFailure, isTrue);
      expect(result.error?.type, ServiceErrorType.server);
      expect(result.error?.statusCode, 500);
      expect(result.error?.message, 'Server error');
    });

    test('maps parsing exceptions to parsing failures', () async {
      final result = await RetryHelper.execute<void>(() async {
        throw const FormatException('Invalid payload format');
      });

      expect(result.isFailure, isTrue);
      expect(result.error?.type, ServiceErrorType.parsing);
      expect(result.error?.message, contains('Invalid payload format'));
    });
  });
}

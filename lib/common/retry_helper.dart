import 'dart:io';

import 'package:dio/dio.dart';

import 'service_error.dart';

typedef RetryableAction<T> = Future<T> Function();
typedef RetryableVoidAction = Future<void> Function();

class RetryHelper {
  static const int maxAttempts = 3;
  static const List<Duration> _retryDelays = <Duration>[
    Duration(seconds: 1),
    Duration(seconds: 2),
    Duration(seconds: 4),
  ];

  static Future<ServiceResult<T>> execute<T>(
    RetryableAction<T> action, {
    String fallbackMessage = 'Request failed',
  }) async {
    Object? lastError;

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final result = await action();
        return ServiceResult<T>.success(result);
      } catch (error) {
        lastError = error;

        final canRetry = attempt < maxAttempts && isTransientError(error);
        if (canRetry) {
          await Future.delayed(_retryDelays[attempt - 1]);
          continue;
        }

        return ServiceResult<T>.failure(
          mapToServiceError(error, fallbackMessage: fallbackMessage),
        );
      }
    }

    return ServiceResult<T>.failure(
      mapToServiceError(
        lastError ?? Exception(fallbackMessage),
        fallbackMessage: fallbackMessage,
      ),
    );
  }

  static Future<ServiceResult<void>> executeVoid(
    RetryableVoidAction action, {
    String fallbackMessage = 'Request failed',
  }) async {
    Object? lastError;

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        await action();
        return ServiceResult<void>.success(null);
      } catch (error) {
        lastError = error;

        final canRetry = attempt < maxAttempts && isTransientError(error);
        if (canRetry) {
          await Future.delayed(_retryDelays[attempt - 1]);
          continue;
        }

        return ServiceResult<void>.failure(
          mapToServiceError(error, fallbackMessage: fallbackMessage),
        );
      }
    }

    return ServiceResult<void>.failure(
      mapToServiceError(
        lastError ?? Exception(fallbackMessage),
        fallbackMessage: fallbackMessage,
      ),
    );
  }

  static bool isTransientError(Object error) {
    if (error is SocketException) {
      return true;
    }

    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      if (statusCode != null && statusCode >= 500 && statusCode <= 599) {
        return true;
      }

      return error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.error is SocketException;
    }

    return false;
  }

  static ServiceError mapToServiceError(
    Object error, {
    String fallbackMessage = 'Request failed',
  }) {
    if (error is ServiceError) {
      return error;
    }

    if (error is FormatException || error is TypeError) {
      return ServiceError(
        type: ServiceErrorType.parsing,
        message: error.toString(),
        originalError: error,
      );
    }

    if (error is SocketException) {
      final message = error.message.isNotEmpty
          ? error.message
          : 'No internet connection';
      return ServiceError(
        type: ServiceErrorType.network,
        message: message,
        originalError: error,
      );
    }

    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      return ServiceError(
        type: _mapDioErrorType(error, statusCode),
        statusCode: statusCode,
        message: _resolveDioMessage(error, fallbackMessage),
        originalError: error,
      );
    }

    return ServiceError(
      type: ServiceErrorType.server,
      message: fallbackMessage,
      originalError: error,
    );
  }

  static ServiceErrorType _mapDioErrorType(
    DioException error,
    int? statusCode,
  ) {
    if (statusCode == 401 || statusCode == 403) {
      return ServiceErrorType.auth;
    }

    if (statusCode == 404 || statusCode == 409) {
      return ServiceErrorType.server;
    }

    if (statusCode != null && statusCode >= 500 && statusCode <= 599) {
      return ServiceErrorType.server;
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError ||
        error.error is SocketException) {
      return ServiceErrorType.network;
    }

    return ServiceErrorType.server;
  }

  static String _resolveDioMessage(DioException error, String fallbackMessage) {
    final responseData = error.response?.data;
    if (responseData is Map<String, dynamic>) {
      final message = responseData['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }

    if (error.message != null && error.message!.trim().isNotEmpty) {
      return error.message!;
    }

    return fallbackMessage;
  }
}

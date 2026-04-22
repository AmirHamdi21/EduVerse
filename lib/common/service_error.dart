class ServiceResult<T> {
  final bool isSuccess;
  final T? data;
  final ServiceError? error;

  const ServiceResult._({required this.isSuccess, this.data, this.error});

  factory ServiceResult.success(T data) {
    return ServiceResult<T>._(isSuccess: true, data: data);
  }

  factory ServiceResult.failure(ServiceError error) {
    return ServiceResult<T>._(isSuccess: false, error: error);
  }

  bool get isFailure => !isSuccess;
}

enum ServiceErrorType { network, auth, server, parsing }

class ServiceError {
  final ServiceErrorType type;
  final int? statusCode;
  final String message;
  final dynamic originalError;

  const ServiceError({
    required this.type,
    this.statusCode,
    required this.message,
    this.originalError,
  });
}

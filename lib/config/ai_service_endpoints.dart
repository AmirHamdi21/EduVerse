import 'ai_service_endpoints.local.dart';

class AiServiceEndpoints {
  const AiServiceEndpoints._();

  static String _trimTrailingSlash(String value) {
    return value.trim().replaceFirst(RegExp(r'/+$'), '');
  }

  static String get aiAttendancePhotoUrl {
    return _trimTrailingSlash(LocalAiServiceEndpoints.aiAttendancePhotoUrl);
  }

  static String get aiQuizBaseUrl {
    return _trimTrailingSlash(LocalAiServiceEndpoints.aiQuizBaseUrl);
  }
}

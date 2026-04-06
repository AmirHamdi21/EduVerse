import 'package:dio/dio.dart';
import 'storage_service.dart';

/// Dio interceptor that handles:
/// 1. Automatically injecting Bearer accessToken into request headers
/// 2. Refreshing expired access tokens using the refresh token
/// 3. Retrying failed requests after a successful token refresh
class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final StorageService _storage;
  final String _baseUrl;

  /// Whether a token refresh is currently in flight to prevent parallel refreshes
  bool _isRefreshing = false;

  AuthInterceptor({
    required Dio dio,
    required StorageService storage,
    required String baseUrl,
  })  : _dio = dio,
        _storage = storage,
        _baseUrl = baseUrl;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final accessToken = await _storage.getAccessToken();
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Only handle 401 Unauthorized
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Avoid infinite loops on auth endpoints
    final path = err.requestOptions.path;
    if (path.contains('/auth/login') ||
        path.contains('/auth/register') ||
        path.contains('/auth/refresh-token')) {
      return handler.next(err);
    }

    // Prevent parallel refresh attempts
    if (_isRefreshing) {
      return handler.next(err);
    }

    _isRefreshing = true;

    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null) {
        _isRefreshing = false;
        return handler.next(err);
      }

      // Use a separate Dio instance to avoid interceptor loops
      final refreshDio = Dio(BaseOptions(
        baseUrl: _baseUrl,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ));

      final response = await refreshDio.post(
        '/auth/refresh-token',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['accessToken'] as String;
        final newRefreshToken = response.data['refreshToken'] as String;

        // Persist new tokens
        await _storage.saveTokens(newAccessToken, newRefreshToken);

        _isRefreshing = false;

        // Retry the failed request with the new token
        final retryOptions = err.requestOptions;
        retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';

        final retryResponse = await _dio.fetch(retryOptions);
        return handler.resolve(retryResponse);
      }
    } on DioException {
      // Refresh itself failed — propagate original error
    } catch (_) {
      // Unexpected error during refresh
    }

    _isRefreshing = false;

    // Refresh failed — clear tokens (session is dead)
    await _storage.clearAll();
    handler.next(err);
  }
}
